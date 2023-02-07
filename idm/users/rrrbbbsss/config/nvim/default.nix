{ pkgs, ... }:
{
  #eventually build out neovim...

  home.packages = with pkgs; [
    neovide
  ];

  programs.neovim = {
    enable = true;
    #defaultEditor = true; todo: wait for this in stable
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = direnv-vim;
        type = "lua";
      }
      {
        plugin = telescope-nvim;
        type = "lua";
      }
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
      }
      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = builtins.readFile ./catppuccin-nvim.lua;
      }
      {
        plugin = nvim-web-devicons;
        type = "lua";
        config = builtins.readFile ./web-devicons.lua;
      }
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = builtins.readFile ./nvim-tree.lua;
      }
      {
        plugin = orgmode;
        type = "lua";
      }
    ];
    extraConfig = builtins.readFile ./rc.vim;
  };
}
