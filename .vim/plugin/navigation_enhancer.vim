noremap <C-W><Up> :call NavigateUp()<Enter>
inoremap <C-W><Up> <Esc>:call NavigateUp()<Enter>a
noremap <C-Up> :call NavigateUp()<Enter>
inoremap <C-Up> <Esc>:call NavigateUp()<Enter>a
noremap <C-W><Down> :call NavigateDown()<Enter>
inoremap <C-W><Down> <Esc>:call NavigateDown()<Enter>a
noremap <C-Down> :call NavigateDown()<Enter>
inoremap <C-Down> <Esc>:call NavigateDown()<Enter>a

" Current weak algorithm: If Vim moves us up to a column which has a column to
" its right with many windows in it, choose the column to the right instead!
" CONSIDER: Better behaviour might be to stick with the most-recently used
" column.  This would feel natural to the user.
" Algorithm would be: check all columns, find potential windows which are one
" step above startWin.  Choose the most recent of those!
" So... how will we store lastUsedTime of windows, without it being updated
" undesirably when traversing windows for consideration?!
" I suppose we could store lastVisited on BufExit, only IFF global/script var
" doNotUpdate is not set.  :)
function! NavigateUp()
  let l:startWin = winnr()
  wincmd k
  let l:proposedWin = winnr()
  " Now: if we go right, and down, 
  if s:TryNavigate("l")
    if s:TryNavigate("j")
      let l:currentWin = winnr()
      if l:currentWin != l:startWin
        " We have detected a column with more windows in it!
        let l:lastWin = winnr()
        while s:TryNavigate("j")
          if winnr() == l:startWin
            " We really wanted to move to lastWin!
            exec l:lastWin."wincmd w"
            return
          endif
        endwhile
        " Oh - we never found the startWin
        " So this column is not a suitable route
      endif
    endif
  endif
  " We had better fall back to whatever Vim proposed originally.
  exec l:proposedWin."wincmd w"
endfunction

function! NavigateDown()
  wincmd j
endfunction

function! s:TryNavigate(direction)
  let wasAt = winnr()
  exec "wincmd ".a:direction
  let nowAt = winnr()
  " if nowAt == wasAt
    " " We haven't moved - navigation failed!
    " return 0
  " else
    " return 1
  " endif
  return (nowAt != wasAt)
endfunction
