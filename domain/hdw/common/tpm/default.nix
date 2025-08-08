{ pkgs, ... }:
{
  security.tpm2 = {
    enable = true;
    tctiEnvironment = {
      enable = true;
      interface = "device";
    };
  };

  environment.systemPackages = with pkgs; [
    tpm2-tools
  ];
}
