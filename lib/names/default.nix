{ self }:
let
  inherit (self.inputs.nixpkgs) lib;

  power = base: expt:
    if expt == 0 then 1
    else base * (power base (expt - 1));

  # Preallocate names:
  # <username> ::= <byte-word>
  # <hostname> ::= <byte-word>-<byte-word>
  # (there are proper byte wordlists out there, but this will do for me)
  wordlist = with builtins; fromJSON (readFile ./wordlist.json);

  bytewords = num: rec {
    toInt = bytewords:
      let
        lookup = byteword: lib.lists.findFirstIndex
          (x: x == byteword)
          (abort "byteword not found: ${byteword}")
          wordlist;
        words = lib.strings.splitString "-" bytewords;
        result = lib.lists.foldr
          (x: acc: {
            val = (lookup x) * (power 256 acc.index) + acc.val;
            index = acc.index + 1;
          })
          { val = 0; index = 0; }
          words;
      in
      if builtins.length words != num then
        (abort "incorrect number of bytewords: ${bytewords}")
      else
        result.val;

    fromInt = int:
      let
        baseDigits = lib.trivial.toBaseDigits 256 int;
        length = builtins.length baseDigits;
        padding = builtins.genList (x: 0) (num - length);
      in
      if (length > num) then
        (abort "int larger than ${toString num} byetwords: ${toString int}")
      else
        lib.lists.foldr
          (x: acc: (builtins.elemAt wordlist x) +
            (if acc != "" then "-${acc}" else acc))
          ""
          (padding ++ baseDigits);

    toHex = bytewords:
      let
        val = lib.trivial.toHexString (toInt bytewords);
        padded = lib.strings.fixedWidthString (2 * num) "0" val;
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
  };

  user =
    let
      username = bytewords 1;
      base = 5000;
    in
    {
      toUID = name:
        base + (username.toInt name);

      fromUID = uid:
        (username.fromInt uid - base);
    };

  host =
    let
      # TODO: transition to ipv6 lazy bum...
      hostname = bytewords 2;
      networkOctets = "10.255";
    in
    {
      inherit (hostname) toInt;
      inherit (hostname) fromInt;
      inherit (hostname) toHex;
      inherit (hostname) fromHex;

      toIP = name:
        let
          int = host.toInt name;
          baseDigits = lib.trivial.toBaseDigits 256 int;
          digits = map toString baseDigits;
          length = builtins.length baseDigits;
          padding = builtins.genList (x: "0") (2 - length);
          hostOctets = padding ++ digits;
        in
        networkOctets + builtins.concatStringsSep "." hostOctets;
      fromIP = ip:
        let
          octets = lib.strings.splitString "." ip;
          byteword = bytewords 1;
          first = byteword.fromInt (lib.toInt (builtins.elemAt octets 2));
          second = byteword.fromInt (lib.toInt (builtins.elemAt octets 3));
        in
        "${first}-${second}";
    };
in
{
  inherit user;
  inherit host;
}
