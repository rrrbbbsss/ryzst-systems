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