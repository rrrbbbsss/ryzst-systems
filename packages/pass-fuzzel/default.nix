{ pass, fuzzel }:
pass.overrideAttrs (old: {
  postPatch = ''
    substituteInPlace contrib/dmenu/passmenu \
      --replace '"$dmenu" "$@"' \
      '${fuzzel}/bin/fuzzel --dmenu'
  '' + old.postPatch;
})
