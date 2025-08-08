(defsrc
  esc  mute vold volu                          prnt slck pause ins del  home pgup
       f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11   f12      end  pgdn
  grv  1    2    3    4    5    6    7    8    9    0    -     =        bspc
  tab  q    w    e    r    t    y    u    i    o    p    [     ]        ret
  caps a    s    d    f    g    h    j    k    l    ;    '     \
  lsft 102d z    x    c    v    b    n    m    ,    .    /              rsft
  wkup lctl lmet lalt           spc            ralt cmps rctl      bck  up   fwd
                                                                   left down rght
)

(defalias
  hyp (multi lsft lmet lctl lalt)
  ;; Control that does 'spc' on tap
  csp (tap-hold-release 200 200 spc lctl)
  ;; "Hyper" that does 'esc' on tap
  ehp (tap-hold-release 200 200 esc @hyp))

(deflayer qwerty
  caps mute vold volu                          prnt slck pause ins del  home pgup
       f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11   f12      end  pgdn
  grv  1    2    3    4    5    6    7    8    9    0    -     =        bspc
  tab  q    w    e    r    t    y    u    i    o    p    [     ]        ret
  @ehp a    s    d    f    g    h    j    k    l    ;    '     \
  lsft _    z    x    c    v    b    n    m    ,    .    /              rsft
  _    lctl lmet lalt          @csp            ralt rmet rctl      bck  up   fwd
                                                                   left down rght
)