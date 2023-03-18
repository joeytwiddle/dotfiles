" From: http://stackoverflow.com/questions/2586984/how-can-i-swap-positions-of-two-open-files-in-splits-in-vim

" Allows you to swap two windows without changing the layout.
" Use \mw to mark a window, move to another, then \pw to swap them.

function! MarkWindowSwap()
    let g:markedWinNum = winnr()
endfunction

function! DoWindowSwap()

    " Mark destination
    let windowA = winnr()
    let bufferA = bufnr( "%" )
    if !exists("g:markedWinNum")
        echohl WarningMsg
        echo 'First select a window with \cw'
        echohl None
        return
    endif
    let windowB = g:markedWinNum

    " Switch to windowB
    exe windowB . "wincmd w"
    let bufferB = bufnr( "%" )
    let filetypeB = &filetype

    if filetypeB == "qf"
        " windowB is the quickfix window.
        " It will fail if we run this way round, so we swap.
        exe windowA . "wincmd w"
        let [windowA, windowB] = [windowB, windowA]
        let [bufferA, bufferB] = [bufferB, bufferA]
    endif

    " We are now in windowB

    " split
    " if !&splitbelow
      " wincmd j
    " endif
    " let tmpWin = winnr()
    " wincmd k

    " Open bufferA in this window
    " (Use hidden so that we aren't prompted and keep history)
    exe 'hide buf' bufferA

    " PROBLEM: If the bufferB was e.g. the cope list, this will cause it to
    " be closed!  So we can't load it up again 3 lines down!
    " One solution to this is to swap them the reverse way round!
    " Another dirty solution might be to split the window before swapping,
    " then close the split afterwards.  This would keep the fragile buffer
    " always visible.

    " Switch to dest and shuffle source->dest
    exe windowA . "wincmd w"
    " Open bufferB in this window
    " (Use hidden so that we aren't prompted and keep history)
    exe 'hide buf' bufferB

    "Pick up the current window, so we could move it again if we want
    call MarkWindowSwap()
endfunction

" Keybinds depend on how you want to remember the command!
" Originally: \mw Mark Window, \pw Put Window
noremap <silent> <leader>mw :call MarkWindowSwap()<CR>
noremap <silent> <leader>pw :call DoWindowSwap()<CR>
" Then I tried: Mark Window, Swap Windows
"noremap <silent> <leader>sw :call DoWindowSwap()<CR>
" Then I settled on: Copy Window, Paste Window
noremap <silent> <leader>cw :call MarkWindowSwap()<CR>
" New idea: Start on one on of the windows.  Click on the other with the mouse and do \swapwin or :SwapWindows
noremap <silent> <leader>swapwin :call MarkWindowSwap()<CR>:wincmd p<CR>:call DoWindowSwap()<CR>
command! SwapWindows call MarkWindowSwap() | :wincmd p | :call DoWindowSwap()

" \SW \WI "swap window with"
noremap <silent> <leader>SW :call MarkWindowSwap()<CR>
noremap <silent> <leader>WI :call DoWindowSwap()<CR>

" QUICKFIX
" It doesn't work if we mark the quickfix window, then do the swap from the file window.
