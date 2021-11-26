" Highlight searches but only temporarily.  Clear the highlight automatically after a moment.

" To disable this script:
"
"     let g:temphlsearch = 0
"
" (Setting that at runtime will disable the clearing of highlights, but not the showing of highlights.)
"
if !get(g:, 'temphlsearch', 1)
    finish
endif

set hlsearch

" We want these keys to temporarily flash the highlighting again
nnoremap <silent> n :set hlsearch<CR>n
nnoremap <silent> N :set hlsearch<CR>N
nnoremap <silent> gn :set hlsearch<CR>gn
nnoremap <silent> gN :set hlsearch<CR>gN

" Redundant mappings, since they re-enable highlighting automatically
"nnoremap / :set hlsearch<CR>/
"nnoremap ? :set hlsearch<CR>?
"nnoremap * :set hlsearch<CR>*
"nnoremap # :set hlsearch<CR>#

" Clear the highlighting after a short pause
" As documented in the help, nohlsearch does not work when run inside an autocmd, but we can work around that by calling feedkeys
augroup HLTemp
    autocmd!
    " This leaves a `:` on the statusline.  We can append `\<Backspace>` to remove it, but that results in an endless loop of CursorHolds!
    autocmd CursorHold * if get(g:, 'temphlsearch', 1) | call feedkeys(":nohlsearch\r:\r") | endif
augroup END
