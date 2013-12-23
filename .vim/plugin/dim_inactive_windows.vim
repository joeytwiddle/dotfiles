" Dim inactive windows using 'colorcolumn' setting
" This tends to slow down redrawing, but is very useful.
" Based on https://groups.google.com/d/msg/vim_use/IJU-Vk-QLJE/xz4hjPjCRBUJ
" Now shared here: http://stackoverflow.com/questions/8415828/vim-dim-inactive-split-panes
" XXX: this will only work with lines containing text (i.e. not '~')

highlight InactiveWindows ctermbg=black guibg=#203838

function! s:DimInactiveWindows()

  if has('gui_running') != 1
    return
  endif

  hi clear ColorColumn
  hi link ColorColumn InactiveWindows

  for i in range(1, tabpagewinnr(tabpagenr(), '$'))
    if bufname(winbufnr(i)) == '-MiniBufExplorer-'
      continue
    end
    let l:range = ""
    if i != winnr()
      if &wrap
        " HACK: when wrapping lines is enabled, we use the maximum number
        " of columns getting highlighted. This might get calculated by
        " looking for the longest visible line and using a multiple of
        " winwidth().
        let l:width=256 " max
      else
        let l:width=winwidth(i)
      endif
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

