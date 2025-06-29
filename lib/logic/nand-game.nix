microkanren:
with microkanren;
# there are proper ways of doing full pure relational arithmetic:
# https://okmij.org/ftp/Prolog/Arithm/arithm.pdf
# https://github.com/TheReasonedSchemer2ndEd/CodeFromTheReasonedSchemer2ndEd/blob/master/trs2-arith.scm
# but i wanted to have fun playing a little bit of the nandgame:
# https://nandgame.com/
let
  nando = X: Y: R:
    conde [
      [ (eqq 0 X) (eqq 0 Y) (eqq 1 R) ]
      [ (eqq 0 X) (eqq 1 Y) (eqq 1 R) ]
      [ (eqq 1 X) (eqq 0 Y) (eqq 1 R) ]
      [ (eqq 1 X) (eqq 1 Y) (eqq 0 R) ]
    ];

  noto = X: R:
    nando X X R;

  ando = X: Y: R:
    fresh ({ C0 }: [
      (nando X Y C0)
      (noto C0 R)
    ]);

  oro = X: Y: R:
    fresh ({ C0, C1 }: [
      (nando X X C0)
      (nando Y Y C1)
      (nando C0 C1 R)
    ]);

  xoro = X: Y: R:
    fresh ({ C0, C1, C2 }: [
      (nando X Y C0)
      (nando X C0 C1)
      (nando C0 Y C2)
      (nando C1 C2 R)
    ]);

  half-addero = X: Y: H: L:
    conj [
      (ando X Y H)
      (xoro X Y L)
    ];

  full-addero = X: Y: C: H: L:
    fresh ({ C0, C1, C2 }: [
      (half-addero X Y C0 C1)
      (half-addero C1 C C2 L)
      (oro C0 C2 H)
    ]);

  # factorio! (shouldn't but why not)
  b5-addero = A: B: C0: C5: S:
    fresh ({ C1, C2, C3, C4, S0, S1, S2, S3, S4, A0, A1, A2, A3, A4, B0, B1, B2, B3, B4 }: [
      (eqq A [ A4 A3 A2 A1 A0 ])
      (eqq B [ B4 B3 B2 B1 B0 ])
      (full-addero A0 B0 C0 C1 S0)
      (full-addero A1 B1 C1 C2 S1)
      (full-addero A2 B2 C2 C3 S2)
      (full-addero A3 B3 C3 C4 S3)
      (full-addero A4 B4 C4 C5 S4)
      (eqq S [ S4 S3 S2 S1 S0 ])
    ]);

  incremento = In: Out:
    fresh ({ C }: [
      (b5-addero In [ 0 0 0 0 1 ] 0 C Out)
    ]);

  inverto = X: R:
    fresh ({ X0, X1, X2, X3, X4, R0, R1, R2, R3, R4 }: [
      (eqq X [ X4 X3 X2 X1 X0 ])
      (noto X0 R0)
      (noto X1 R1)
      (noto X2 R2)
      (noto X3 R3)
      (noto X4 R4)
      (eqq R [ R4 R3 R2 R1 R0 ])
    ]);

  subtractiono = A: B: R:
    fresh ({ C0, C1, C3 }: [
      (inverto B C0)
      (incremento C0 C1)
      (b5-addero A C1 0 C3 R)
    ]);

  eqZero = In: Out:
    fresh ({ I0, I1, I2, I3, I4, C0, C1, C2, C3 }: [
      (eqq In [ I4 I3 I2 I1 I0 ])
      (oro I0 I1 C0)
      (oro I2 I3 C1)
      (oro C0 C1 C2)
      (oro I4 C2 C3)
      (noto C3 Out)
    ]);

  negativo = A: R:
    fresh ({ A0, A1, A2, A3 }: [
      (eqq A [ R A3 A2 A1 A0 ])
    ]);

  gto = A: B:
    fresh ({ R, A', A3, A2, A1, A0, B', B3, B2, B1, B0 }: [
      # not having a good conso hurts but whatever.
      (eqq A [ A3 A2 A1 A0 ])
      (eqq B [ B3 B2 B1 B0 ])
      (eqq A' [ 0 A3 A2 A1 A0 ])
      (eqq B' [ 0 B3 B2 B1 B0 ])
      (subtractiono A' B' R)
      (negativo R 0)
      (eqZero R 0)
    ]);

  gteqo = A: B:
    conde [
      [ (eqq A B) ]
      [ (gto A B) ]
    ];
  lto = A: B:
    gto B A;
  lteqo = A: B:
    gteqo B A;


  # or you don't have to play the nand game
  # really need a better conso...
  gto' = A: B:
    fresh
      ({ HA, TA, HB, TB }: [
        (conso HA TA A)
        (conso HB TB B)
        (conde [
          [ (eqq HA 1) (eqq HB 0) ]
          [ (gto' TA TB) ]
        ])
      ]);

  # how many bits for numbers in semvar? (jk)
  versions = facto [
    [ 0 0 0 1 ]
    [ 0 0 1 0 ]
    [ 0 1 0 0 ]
    [ 1 0 0 0 ]
  ];
  testo = solve "all" ({ X }: [
    (versions X)
    (gteqo X [ 0 0 1 0 ])
    (lteqo X [ 1 0 0 0 ])
  ]);
  testo2 = solve "all" ({ X, Y }: [
    (lto X Y)
  ]);
  testo3 = solve 5 ({ X, Y }: [
    (gto' X Y)
  ]);
in
{
  inherit testo testo2 testo3;
}
