" From: http://stackoverflow.com/questions/2586984/how-can-i-swap-positions-of-two-open-files-in-splits-in-vim

" Allows you to swap two windows without changing the layout.
" Use \mw to mark a window, move to another, then \pw to swap them.

function! MarkWindowSwap()
    let g:markedWinNum = winnr()
endfunction

function! DoWindowSwap()
    "Mark destination
    let curNum = winnr()
    let curBuf = bufnr( "%" )
    "Switch to source and shuffle dest->source
    exe g:markedWinNum . "wincmd w"
    let markedBuf = bufnr( "%" )

    " split
    " if !&splitbelow
      " wincmd j
    " endif
    " let tmpWin = winnr()
    " wincmd k

    "Hide and open so that we aren't prompted and keep history
    exe 'hide buf' curBuf

    " PROBLEM: If the markedBuf was e.g. the cope list, this will cause it to
    " be closed!  So we can't load it up again 3 lines down!
    " One solution to this is to swap them the reverse way round!
    " Another dirty solution might be to split the window before swapping,
    " then close the split afterwards.  This would keep the fragile buffer
    " always visible.

    "Switch to dest and shuffle source->dest
    exe curNum . "wincmd w"
    "Hide and open so that we aren't prompted and keep history
    exe 'hide buf' markedBuf
    "Pick up the current window, so we could move it again
    call MarkWindowSwap()
endfunction

" Keybinds depend on how you want to remember the command!
" Originally: \mw Mark Window, \pw Put Window
noremap <silent> <leader>mw :call MarkWindowSwap()<CR>
noremap <silent> <leader>pw :call DoWindowSwap()<CR>
" Then I tried: Mark Window, Swap Windows
noremap <silent> <leader>sw :call DoWindowSwap()<CR>
" Then I settled on: Copy Window, Paste Window
noremap <silent> <leader>cw :call MarkWindowSwap()<CR>
" New idea: Start on one on of the windows.  Click on the other with the mouse and do \sw
noremap <silent> <leader>sw :call MarkWindowSwap()<CR>

