{ self }:
let
  inherit (self.inputs.nixpkgs) lib;

  # Preallocate 2^16 computer names:
  # <hostname> ::= <byte-word>-<byte-word>
  # (there are proper byte wordlists out there, but this will do for me)
  wordlist = with builtins; fromJSON (readFile ./wordlist.json);

  toInt = hostname:
    let
      lookup = byteword: lib.lists.findFirstIndex
        (x: x == byteword)
        (abort "byteword not found: ${byteword}")
        wordlist;
      words = lib.strings.splitString "-" hostname;
      first = builtins.elemAt words 0;
      second = builtins.elemAt words 1;
    in
    if builtins.length words != 2 then
      (abort "incorrect hostname: ${hostname}")
    else
      256 * (lookup first) + (lookup second);

  fromInt = int:
    if int > 65535 || int < 0 then
      (abort "int outside of 2^16: ${int}")
    else
      builtins.elemAt wordlist (int / 256) + "-" +
      builtins.elemAt wordlist (lib.trivial.mod int 256);

  toHex = hostname:
    let
      val = lib.trivial.toHexString (toInt hostname);
      padded = lib.strings.fixedWidthString 4 "0" val;
    in
    padded;

  fromHex = hex:
    let
      hexDigits = {
        "A" = 10;
        "B" = 11;
        "C" = 12;
        "D" = 13;
        "E" = 14;
        "F" = 15;
      };
      hexToInt = x:
        hexDigits.${x} or (lib.strings.toInt x);
      power = base: expt:
        if expt == 0 then 1
        else base * (power base (expt - 1));
      list = lib.strings.stringToCharacters hex;
      result = lib.lists.foldr
        (x: acc: {
          val = (hexToInt x) * (power 16 acc.index) + acc.val;
          index = acc.index + 1;
        })
        { val = 0; index = 0; }
        list;
    in
    fromInt result.val;
in
{
  inherit toInt;
  inherit fromInt;
  inherit toHex;
  inherit fromHex;
}
