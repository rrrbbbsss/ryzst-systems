require("catppuccin").setup({
    compile_path = vim.fn.stdpath "cache" .. "/catppuccin"
})
vim.cmd.colorscheme "catppuccin"