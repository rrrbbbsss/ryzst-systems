{ pkgs, ... }:
{
  #eventually build out neovim...

  home.packages = with pkgs; [
      # gui
      neovide
  ];

  programs.neovim = {
    enable = true;
    #defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      {
        # for direnv integration
        plugin = direnv-vim;
        type = "lua";
        config = "";
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          '';
      }
      {
        # for parsing/syntax highlighting
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
        config = ''
          require("nvim-web-devicons").setup()
        '';
      }
      {
        # git
        plugin = neogit;
        type = "lua";
        config = ''
          local neogit = require('neogit')
          neogit.setup {}
        '';
      }
      {
        plugin = plenary-nvim;
        type = "lua";
        config = "";
      }
      {
        # for side tree
        plugin = nvim-tree-lua;
        type = "lua";
        config = ''
          vim.g.loaded_netrw = 1
          vim.g.loaded_netrwPlugin = 1

          require("nvim-tree").setup()
        '';
      }
      {
        plugin = nvim-web-devicons;
        type = "lua";
        config = ''
          require("nvim-web-devicons").setup()
        '';
      }
      {
        # for orgmode
        plugin = orgmode;
        type = "lua";
        config = "";
      }
    ];
    extraConfig = ''
      set termguicolors
      set showtabline=2
      if exists("g:neovide")
        set guifont=Hack\ Nerd\ Font:h10
        let g:neovide_cursor_animation_length=0
        let g:neovide_scale_factor=1.0
        function! ChangeScaleFactor(delta)
          if a:delta == 0
            let g:neovide_scale_factor = 1.0
          else
            let g:neovide_scale_factor = g:neovide_scale_factor * a:delta
          endif
        endfunction
        nnoremap <expr><C-=> ChangeScaleFactor(1.25)
        nnoremap <expr><C--> ChangeScaleFactor(1/1.25)
        nnoremap <expr><C-BS> ChangeScaleFactor(0)
      endif
    '';
  };
}
