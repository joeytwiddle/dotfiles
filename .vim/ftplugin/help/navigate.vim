" Jump between "links" in help files using Tab (as you would in a web browser)
"nnoremap <silent> <buffer>   <Tab> /<Bar>\zs\k\+<Bar><CR>:set nohlsearch<CR>
"nnoremap <silent> <buffer> <S-Tab> ?<Bar>\zs\k\+<Bar><CR>:set nohlsearch<CR>
" But it is also nice to select options, which are often surrounded by ''s
nnoremap <silent> <buffer>   <Tab> /[<Bar>']\zs\k\+[<Bar>']<CR>:set nohlsearch<CR>
nnoremap <silent> <buffer> <S-Tab> ?[<Bar>']\zs\k\+[<Bar>']<CR>:set nohlsearch<CR>
" By DrAl at http://stackoverflow.com/questions/1832085/how-to-jump-to-the-next-tag-in-vim-help-file#1832723
