nixpkgs:
with nixpkgs.lib;
# http://webyrd.net/scheme-2013/papers/HemannMuKanren2013.pdf
let
  # logic variables
  mkVar = int: { __Var = int; };
  isVar = term: term ? __Var;
  eqVar = a: b: a == b;

  # arrays (instead of pairs)
  isArray = term: (isList term) && (term != [ ]);

  # substitutions
  occurs-check = var: val: sub:
    let v = walk val sub;
    in if isVar v then
      eqVar v var
    else if isArray v then
      occurs-check var (head v) sub || occurs-check var (tail v) sub
    else
      false;
  extendSub = var: val: sub:
    if occurs-check var val sub then
      false
    else
      sub // { ${toString var.__Var} = val; };
  emptySub = { };

  # unification
  walk = term: sub:
    let
      lookup = var: sub: sub ? "${toString var.__Var}";
      binding = if isVar term then lookup term sub else false;
    in
    if binding then walk sub."${toString term.__Var}" sub else term;
  unify = A: B: sub:
    let
      a = walk A sub;
      b = walk B sub;
    in
    if (isVar a) && (isVar b) && (eqVar a b) then
      sub
    else if (isVar a) then
      extendSub a b sub
    else if (isVar b) then
      extendSub b a sub
    else if (isArray a) && (isArray b) then
      let
        headSub = unify (head a) (head b) sub;
        tailSub = unify (tail a) (tail b) headSub;
      in
      if !(isBool headSub) then tailSub else false
    else if (a == b) then
      sub
    else
      false;

  # logic stream
  emptyState = {
    sub = emptySub;
    counter = 0;
  };
  isEmptyStream = x: x == { };
  isImmatureStream = x: x ? force;
  delay = x: { force = x; };

  mzero = { };
  unit = state: {
    head = state;
    tail = mzero;
  };
  mplus = s1: s2:
    if (isEmptyStream s1) then
      s2
    else if (isImmatureStream s1) then
      delay (mplus s2 s1.force)
    else {
      inherit (s1) head;
      tail = mplus s1.tail s2;
    };
  bind = stream: goal:
    if (isEmptyStream stream) then
      mzero
    else if (isImmatureStream stream) then
      delay (bind stream.force goal)
    else
      mplus (goal stream.head) (bind stream.tail goal);

  # single constraint
  eqq = a: b: state:
    let sub = unify a b state.sub;
    in if !(isBool sub) then
      unit
        {
          inherit sub;
          inherit (state) counter;
        }
    else
      mzero;

  # goals
  disj-i = g1: g2: state: mplus (g1 state) (g2 state);
  conj-i = g1: g2: state: bind (g1 state) g2;
  conj = goals:
    if (length goals) == 1 then
      head goals
    else
      conj-i (head goals) (conj (tail goals));
  disj = goals:
    if (length goals) == 1 then
      head goals
    else
      disj-i (head goals) (disj (tail goals));
  conde = clauses: disj (map conj clauses);
  fresh = f: state:
    let
      vars = foldlAttrs
        (acc: n: v: {
          counter = acc.counter + 1;
          vars = acc.vars // { ${n} = mkVar acc.counter; };
        })
        {
          inherit (state) counter;
          vars = { };
        }
        (functionArgs f);
    in
    (conj (f vars.vars)) {
      inherit (state) sub;
      inherit (vars) counter;
    };

  # stream helpers
  pull = stream:
    if isImmatureStream stream then pull stream.force else stream;
  take-all = Stream:
    let stream = pull Stream;
    in if stream == { } then
      [ ]
    else
      [ stream.head ] ++ (take-all stream.tail);
  take = num: Stream:
    if num == 0 then
      [ ]
    else
      let stream = pull Stream;
      in if isEmptyStream stream then
        [ ]
      else
        [ stream.head ] ++ (take (num - 1) stream.tail);

  # reify
  mkReify = vars: states: map (reify-state-vars vars) states;
  reify-state-vars = vars: state:
    let mkVal = n: walk-h (mkVar n) state.sub;
    in (foldlAttrs
      (acc: n: v:
        let val = mkVal acc.counter;
        in {
          counter = acc.counter + 1;
          vars = acc.vars // {
            ${n} = walk-h val (reify-sub val emptySub);
          };
        })
      {
        counter = 0;
        vars = { };
      }
      vars).vars;
  reify-sub = v: sub:
    let
      val = walk v sub;
      name = reify-name (length (attrNames sub));
    in
    if isVar val then
      extendSub val name sub
    else if isArray val then
      reify-sub (tail val) (reify-sub (head val) sub)
    else
      sub;
  reify-name = n: "__${toString n}";
  walk-h = v: sub:
    let val = walk v sub;
    in if isVar val then
      val
    else if isArray val then
      [ (walk-h (head val) sub) ] ++ (walk-h (tail val) sub)
    else
      val;

  # run
  solve = all-or-num: goals:
    let stream = (fresh goals) emptyState;
    in mkReify (functionArgs goals) (if all-or-num == "all" then
      take-all stream
    else
      take all-or-num stream);

  # helper goals
  facto = vals: X: disj (map (x: eqq x X) vals);
  conso = H: T: P: (eqq ([ H ] ++ [ T ]) P);
  fail = state: mzero;
  succeed = unit;

in
{
  # goals
  inherit fresh conde conj disj eqq facto conso fail succeed;
  # interface
  inherit solve;
}
