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
    "Hide and open so that we aren't prompted and keep history
    exe 'hide buf' curBuf
    "Switch to dest and shuffle source->dest
    exe curNum . "wincmd w"
    "Hide and open so that we aren't prompted and keep history
    exe 'hide buf' markedBuf
    "Pick up the current window, so we could move it again
    call MarkWindowSwap()
endfunction

" Keybinds depend on how you want to remember the command!
" Originally: Mark Window, Put Window
noremap <silent> <leader>mw :call MarkWindowSwap()<CR>
noremap <silent> <leader>pw :call DoWindowSwap()<CR>
" Then I tried: Mark Window, Swap Windows
noremap <silent> <leader>sw :call DoWindowSwap()<CR>
" Then I settled on: Copy Window, Paste Window
noremap <silent> <leader>cw :call MarkWindowSwap()<CR>

