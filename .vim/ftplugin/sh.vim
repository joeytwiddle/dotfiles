setlocal iskeyword-=.

" Add a log command for the currently selected expression:
"vnoremap <buffer> <Leader>log yoecho "[log] <C-R>": $<C-R>""<Esc>

" Same, but display the filename instead of "log", with the extension stripped.
vnoremap <buffer> <Leader>log yoecho "[<C-R>=expand('%:t:r')<Enter>] <C-R>": $<C-R>""<Esc>

" When nothing is selected, select the word (or WORD) under the cursor, then invoke the vmap.
nmap <buffer> <Leader>log viw<Leader>log
nmap <buffer> <Leader>Log viW<Leader>log
