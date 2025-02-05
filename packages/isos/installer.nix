{ pkgs, lib, ... }:
# TODO: this is broken.
# TODO: fix later.
let
  username = "installer";
in
{
  imports = [
    # TODO: clean this up
    ../../idm/users/man/config/zsh
    ../../modules/hardware/common/wifi
  ];

  os = {
    auth.enable = false;
    nix.enable = false;
    hostname = "zoo-zoo";
  };

  system.stateVersion = lib.mkForce "24.11";
  ryzst.mek.zoo-zoo.version = "";

  #nixpkgs.hostPlatform.system = "x86_64-linux";

  # ISO naming.
  isoImage = lib.mkForce {
    isoName = "installer.iso";
    volumeID = "ryzst-iso";
    makeEfiBootable = true;
    makeBiosBootable = true;
    makeUsbBootable = true;
    squashfsCompression = "gzip -Xcompression-level 1";
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  users.users = {
    ${username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" ];
      # no password
      initialHashedPassword = "";
    };
    root = {
      # no password
      initialHashedPassword = "";
    };
  };

  home-manager.users.${username} = { pkgs, ... }: {
    imports = [
      # TODO: clean this up
      ../../idm/users/man/config/alacritty
    ];
    programs.zsh.initExtra = ''
      [[ -v DISPLAY ]] && sudo ${pkgs.ryzst.apps}/bin/ryzst-installer
    '';
    # TODO: cleanup
    home.stateVersion = "24.11";
  };
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  hardware.graphics.enable = true;

  services.cage = {
    enable = true;
    program = "${pkgs.alacritty}/bin/alacritty";
    user = username;
    extraArguments = [ "-d" "-s" ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      dejavu_fonts
    ];
  };
}
