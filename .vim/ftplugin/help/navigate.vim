" Jump between "links" in help files using Tab (as you would in a web browser)
" Credits to DrAl at http://stackoverflow.com/questions/1832085/how-to-jump-to-the-next-tag-in-vim-help-file#1832723

" Unfortunately by mapping Tab we also intercept <Ctrl-I> (which would usually
" step "forwards" in the history).  This might not be an issue in GVim or Neovim.

" Initial version, look for |.....|
" We use <zs> to land our cursor on the start of the word, not the '|'
"nnoremap <silent> <buffer>   <Tab> /<Bar>\zs\k\+<Bar><CR>:set nohlsearch<CR>
"nnoremap <silent> <buffer> <S-Tab> ?<Bar>\zs\k\+<Bar><CR>:set nohlsearch<CR>

" Jump to options too, look for '.....'
"nnoremap <silent> <buffer>   <Tab> /[<Bar>']\zs\k\+[<Bar>']<CR>:set nohlsearch<CR>
"nnoremap <silent> <buffer> <S-Tab> ?[<Bar>']\zs\k\+[<Bar>']<CR>:set nohlsearch<CR>

" TESTING: Slightly more accurate regexp, that won't land on a |.....' like the previous.
nnoremap <silent> <buffer>   <Tab> /\('\zs\k\+'\|<Bar>\zs\k\+<Bar>\)<CR>:set nohlsearch<CR>
nnoremap <silent> <buffer> <S-Tab> ?\('\zs\k\+'\|<Bar>\zs\k\+<Bar>\)<CR>:set nohlsearch<CR>
