#!/usr/bin/env -S nix shell nixpkgs#rlwrap nixpkgs#swi-prolog --command rlwrap swipl

:- use_module(library(crypto)).
:- use_module(library(http/json)).
:- initialization(main, main).

% https://arxiv.org/pdf/1007.4446
% butchered from Figure 8

% https://www.tweag.io/blog/2022-07-14-taming-unix-with-nix/
% thunks be derivations

% COOL: raw kademlia (for spreading across trusted nodes...)
% https://www.scs.stanford.edu/~dm/home/papers/kpos.pdf

% REPL
main :- write("content-addressable call-by-need lamba-calculus:\n"),
	repeat, repl.
repl :- write("λ> "), read_line_to_codes(user_input, Input),
	parser(Input,[Exp]), eval(Exp, Out),
	writef("\e[32mANSWER=>\e[0m %w\n\n", [Out]), !, fail.

% Parser
parser(String, Exps) :- phrase(exp(Exps), String).
exp([E]) --> wso, sexp(E), wso.
exp([]) --> [].

sexp(E) --> slist(E).
sexp(E) --> satom(E).

slist(E) --> "(", wso, elm(E), wso, ")".
elm([E|Es]) --> sexp(E), wsr, !, elm(Es).
elm([E]) --> sexp(E).
elm([]) --> [].

satom(A) --> symbol(Cs), { atom_codes(A,Cs)}.

symbol([C|Cs]) --> symbol_first(C), symbol_rest(Cs).
symbol_first(C) --> [C], { code_type(C, alpha) }.
symbol_rest([C|Cs]) --> [C], { code_type(C, alnum) }, symbol_rest(Cs).
symbol_rest([]) --> [].

wsr --> ws, wsr; ws.
wso --> ws, wso; [].
ws --> [W], { code_type(W, white); code_type(W, space) }.

% Control String (code)
term(Exp) :-
	variable(Exp);
	abstraction(Exp,_,_);
	application(Exp,_,_).
values(Exp) :-
	abstraction(Exp, _, _).
variable(Exp) :-
	atom(Exp).
abstraction(Exp, Var, Body) :-
	Exp = [lambda, [Var], Body],
	variable(Var), term(Body).
application(Exp, E1, E2) :-
	Exp = [E1, E2],
	term(E1), term(E2).
closure(Exp, Val, Env) :-
	Exp = [closure, Val, Env],
	values(Val), env(Env).
thunk(Thunk, Exp, Env) :-
	Thunk = [thunk, Exp, Env],
	term(Exp), env(Env).

% Environment (Variable to Extensional-Reference (floabw))
env(Env) :-
	is_dict(Env, env).
lookup(Var, Env, Ref) :-
	Ref = Env.get(Var).
extendEnv(Var, Ref, Env, Out) :-
	Out = Env.put(Var, Ref).

% Store (Address to Storable)
address(A) :-
	hex_bytes(A,_),
	string_length(A,64).
storable(S) :-
	thunk(S,_,_);
	closure(S,_,_).
hash(Object, Address) :-
	term_string(Object, Str),
	crypto_data_hash(Str, Hash, [algorithm(sha256)]),
	atom_string(Address, Hash).
alloc(Storable, Address) :-
	storable(Storable),
	hash(Storable, Address).
dereference(Address, Store, Storable) :-
	Storable = Store.get(Address).
extendStore(Address, Storable, Store, Out) :-
	address(Address), storable(Storable),
	Out = Store.put(Address, Storable).
% not smart enough to prove, but can check.
cacheck(Store) :-
	dict_keys(Store, Keys),
	cacheck(Store, Keys, Test),
	writef("CA Check: %w\n", [Test]).
cacheck(Store, [Key|Keys], Test) :-
	Value = Store.Key,
	alloc(Value, Address),
	(   dif(Key, Address), Test = false
	;   Key = Address, cacheck(Store, Keys, Test)
	).
cacheck(_, [], Test) :-
	Test = true.

% Kontinuation (just think stack)
% keeping out of store so easier to read.
k_mt(Frame) :-
	Frame = [k_mt].
k_bd(Frame, Ref, Kont) :-
	Frame = [k_bd, Ref, Kont].
k_el(Frame, Ref, Kont) :-
	Frame = [k_el, Ref, Kont].
kont(Frame) :-
	k_mt(Frame);
	k_bd(Frame, _, _);
	k_el(Frame, _, _).

% Derivations (floabw) (Extensional-Reference to thunk Address)
% maybe sign something to know: who made the thunk?
find(Ref, Drv, Address) :-
	Address = Drv.get(Ref).
extendDrv(Ref, Address, Drv, Out) :-
	Out = Drv.put(Ref, Address).

% Narinfos (floabw) (Extensional-Reference to closure Address)
% maybe sign something to know: who made the closure?
% also, why can't this be a folder of symlinks/bindmounts or something?
follow(Ref, Narinfo, Address) :-
	Address = Narinfo.get(Ref).
extendNarinfo(Ref, Address, Narinfo, Out) :-
	Out = Narinfo.put(Ref, Address).

% Extional-Reference helpers
% think of the extentional-reference as the outpath in the extensional model
allocRef(Exp, Env, Ref) :-
	term(Exp), env(Env),
	hash([ref, Exp, Env], Address),
	% just make it easy to see
	atom_concat('ext-', Address, Ref).
resolve(Ref, Store, Drv, Narinfo, Storable) :-
	follow(Ref, Narinfo, Address),
	dereference(Address, Store, Storable);
	\+ follow(Ref, Narinfo, _),
	find(Ref, Drv, Address),
	dereference(Address, Store, Storable).

% Transitions
step([Exp, Env, Store, Kont, Drv, Narinfo], Next) :-
	variable(Exp),
	lookup(Exp, Env, Ref),
	resolve(Ref, Store, Drv, Narinfo, Storable),
	closure(Storable, Val, EnvC),
	Next = [Val, EnvC, Store, Kont, Drv, Narinfo],
	printState("Resolved a Closure", Next).
step([Exp, Env, Store, Kont, Drv, Narinfo], Next) :-
	variable(Exp),
	lookup(Exp, Env, Ref),
	resolve(Ref, Store, Drv, Narinfo, Storable),
	thunk(Storable, ExpT, EnvT),
	k_bd(Frame, Ref, Kont),
	Next = [ExpT, EnvT, Store, Frame, Drv, Narinfo],
	printState("Resolved a Thunk", Next).
step([Exp, Env, Store, Kont, Drv, Narinfo], Next) :-
	application(Exp, E1, E2),
	thunk(Thunk, E2, Env),
	alloc(Thunk, Address),
	extendStore(Address, Thunk, Store, StoreE),
	allocRef(E2, Env, Ref),
	extendDrv(Ref, Address, Drv, DrvE),
	k_el(Frame, Ref, Kont),
	Next = [E1, Env, StoreE, Frame, DrvE, Narinfo ],
	printState("Application", Next).
step([Exp, Env, Store, Kont, Drv, Narinfo], Next) :-
	values(Exp),
	k_bd(Kont, Ref, KontA),
	closure(Clos, Exp, Env),
	alloc(Clos, Address),
	extendStore(Address, Clos, Store, StoreE),
	extendNarinfo(Ref, Address, Narinfo, NarinfoE),
	Next = [Exp, Env, StoreE, KontA, Drv, NarinfoE],
	printState("Built Closure", Next).
step([Exp, Env, Store, Kont, Drv, Narinfo], Next) :-
	abstraction(Exp, Var, Body),
	k_el(Kont, Ref, KontA),
	extendEnv(Var, Ref, Env, EnvE),
	Next = [ Body, EnvE, Store, KontA, Drv, Narinfo ],
	printState("Beta", Next).

% json for cheap dict pretty printing
printState(Name, [Exp, Env, Store, Kont, Drv, Narinfo]) :-
	writef("\e[31m%w====>\e[0m\n", [Name]),
	writef("\e[33mControl String:\e[0m\n%w\n", [Exp]),
	writef("\e[33mEnvironment:\e[0m\n", []),
	json_write(current_output,Env), write("\n"),
	writef("\e[33mStore:\e[0m\n", []),
	json_write(current_output,Store), write("\n"),
	writef("\e[33mKontinuation:\e[0m\n%w\n", [Kont]),
	writef("\e[33mDerivations:\e[0m\n", []),
	json_write(current_output,Drv), write("\n"),
	writef("\e[33mNarinfos:\e[0m\n", []),
	json_write(current_output,Narinfo), write("\n\n").

% machine stops when there is a value in C and K is empty (k_mt)
answer(State) :-
	State = [Exp, _, _, Kont, _, _],
	values(Exp),
	k_mt(Kont).
run(State, Out) :-
	answer(State),
	State = [Exp, Env, Store, _, _, _],
	closure(Out, Exp, Env),
	cacheck(Store);
	\+ answer(State),
	step(State, Next),
	run(Next, Out).
inject(Exp, State) :-
	k_mt(Frame),
	State = [Exp, env{}, store{}, Frame, drv{}, narinfo{}].
eval(Exp, Out) :-
	inject(Exp, State),
	printState("Initial", State),
	run(State, Out).

% lazy test:
% ((lambda (z) ((lambda (x) (x x)) (lambda (y) y))) ((lambda (i) (i i)) (lambda (i) (i i))))
