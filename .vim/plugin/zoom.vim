if &cp || exists("g:loaded_zoom")
    finish
endif
let g:loaded_zoom = 1

let s:save_cpo = &cpo
set cpo&vim

" keep default value
let s:current_font = &guifont

" command
command! -narg=0 ZoomIn    :call s:ZoomIn()
command! -narg=0 ZoomOut   :call s:ZoomOut()
command! -narg=0 ZoomReset :call s:ZoomReset()

" Map Ctrl-MouseWheel to zoom in/out
nmap <C-MouseDown> :ZoomIn<CR>
nmap <C-MouseUp> :ZoomOut<CR>

" Map Ctrl-KeypadPlus/Minus to zoom in/out
"nmap <C-kPlus> :ZoomIn<CR>
"nmap <C-kMinus> :ZoomOut<CR>
" I disabled these because I am using them in windows_remember_size.

" guifont size + 1
function! s:ZoomIn()
  " Original: let l:fsize = substitute(&guifont, '^.*:h\([^:]*\).*$', '\1', '')
  " But we made some changes for Vim6 on WindowsXP.
  let l:fsize = substitute(&guifont, '^.*[ -]\([0-9]*\)$', '\1', '')
  let l:fsize += 1
  let l:guifont = substitute(&guifont, '^\(.*[ -]\)[0-9]*$', '\1' . l:fsize, '')
  let &guifont = l:guifont
  " echo "Setting size=" . l:fsize . " and font=" . l:guifont
endfunction

" guifont size - 1
function! s:ZoomOut()
  let l:fsize = substitute(&guifont, '^.*[ -]\([0-9]*\)$', '\1', '')
  let l:fsize -= 1
  let l:guifont = substitute(&guifont, '^\(.*[ -]\)[0-9]*$', '\1' . l:fsize, '')
  let &guifont = l:guifont
  " echo "Setting size=" . l:fsize . " and font=" . l:guifont
endfunction

" reset guifont size
function! s:ZoomReset()
  let &guifont = s:current_font
endfunction

let &cpo = s:save_cpo
finish

==============================================================================
zoom.vim : control gui font size with "+" or "-" keys.
------------------------------------------------------------------------------
$VIMRUNTIMEPATH/plugin/zoom.vim
==============================================================================
author  : OMI TAKU
url     : http://nanasi.jp/
email   : mail@nanasi.jp
version : 2008/07/18 10:00:00
==============================================================================

This plugin is for GUI only.

Normal Mode:

    CTRL-kPlus         ... make font size bigger
    CTRL-MouseUp

    CTRL-kMinus        ... make font size smaller
    CTRL-MouseDown

Command-line Mode:

    :ZoomIn            ... make font size bigger
    :ZoomOut           ... make font size smaller
    :ZoomReset         ... reset font size changes.

==============================================================================

1. Copy the zoom.vim script to
   $HOME/vimfiles/plugin or $HOME/.vim/plugin directory.
   Refer to ':help add-plugin', ':help add-global-plugin' and
   ':help runtimepath' for more details about Vim plugins.

2. Restart Vim.

==============================================================================
" vim: set ff=unix et ft=vim nowrap :
