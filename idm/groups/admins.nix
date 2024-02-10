with builtins;
map (x: readFile (../users/${x}/pubkeys/ssh.pub) + " root")
  [ "man" ]
