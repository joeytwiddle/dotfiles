" Dim inactive windows using 'colorcolumn' setting
" This tends to slow down redrawing, but is very useful.
" Based on https://groups.google.com/d/msg/vim_use/IJU-Vk-QLJE/xz4hjPjCRBUJ
" Now shared here: http://stackoverflow.com/questions/8415828/vim-dim-inactive-split-panes
" XXX: this will only work with lines containing text (i.e. not '~')

" NOTE: One disadvantage of this plugin is that the background highlight set
" on inactive windows may override useful backgrounds.  For example, I use a
" background colour in taglist to indicate the current tag, and a background
" highlight in the QuickFix window to indicate the current 'error' line.
" Those highlights disappear when dim_inactive_windows dims those windows (at
" least on MacVim they do).

"highlight InactiveWindowsDefault ctermbg=black guibg=#203838
"highlight InactiveWindowsDefault ctermbg=black guibg=#445555 guifg=#999999
highlight InactiveWindowsDefault ctermbg=black guibg=#334444
if &t_Co >= 256
  highlight InactiveWindowsDefault ctermbg=238
endif
highlight link InactiveWindows InactiveWindowsDefault

function! s:DimInactiveWindows()

  " For 8-color terminals there is no color I like to use as a dimmed
  " background, so I disable DimInactiveWindows and rely on
  " blinking_statusline.vim to show me where focus has moved to.
  " This might be better as an option.
  if has('gui_running') != 1 && &t_Co < 60
    return
  endif

  hi clear ColorColumn
  hi link ColorColumn InactiveWindows

  let current_win_number = winnr()

  for i in range(1, tabpagewinnr(tabpagenr(), '$'))
    let dim = 1
    if i == current_win_number
      let dim = 0
    endif
    if bufname(winbufnr(i)) == '-MiniBufExplorer-'
      let dim = 0
    endif
    if getwinvar(i, '&diff')
      let dim = 0
    endif

    let l:range = ""
    if dim
      " We used to use winwidth(i) by default, only the max (256) if &wrap was set.
      " But in fact even without &wrap, the buffer may be scrolled to the right.
      " In that case, we could start the range higher and end it higher.
      " But simpler just to fill all the columns we can, starting from 1, and ignore those larger.
      let l:width = 256
      let l:range = join(range(1, l:width), ',')
    endif
    call setwinvar(i, '&colorcolumn', l:range)
  endfor

endfunction

augroup DimInactiveWindows
  au!
  au WinEnter * call s:DimInactiveWindows()
  au WinEnter * set cursorline
  au WinLeave * set nocursorline
augroup END

