{ ... }:
{
  services.octoprint = {
    enable = true;
    plugins = plugins: with plugins; [
      themeify
    ];
  };
}
