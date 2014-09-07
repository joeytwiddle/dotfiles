setlocal iskeyword-=.

vnoremap <buffer> <Leader>log yoecho "[log] <C-R>": $<C-R>""<Esc>
nmap <buffer> <Leader>log viw<Leader>log
nmap <buffer> <Leader>Log viW<Leader>log

