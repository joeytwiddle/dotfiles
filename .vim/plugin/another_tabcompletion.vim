" Map <Tab> and <Shift-Tab> to perform word completion.

" This is the one I am currently using!

" It uses Vim's built-in <C-n> completion, but it lets <Tab> work normally at the beginning of a line.

" It comes from an old revision of http://vim.wikia.com/wiki/Smart_mapping_for_tab_completion

function! InsertTabWrapper(direction)
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    elseif "backward" == a:direction
        return "\<c-p>"
    else
        return "\<c-n>"
    endif
endfunction

" This causes a lot of flicker (3 or 4 screen redraws) in xterm.
inoremap <silent> <tab> <c-r>=InsertTabWrapper ("forward")<cr>
inoremap <silent> <s-tab> <c-r>=InsertTabWrapper ("backward")<cr>

" This causes no flicker!
"inoremap <expr> <silent> <tab> InsertTabWrapper("forward")
"inoremap <expr> <silent> <s-tab> InsertTabWrapper("backward")
" But unfortunately it doesn't work when UltiSnips is using it as a fallback, because UltiSnips does not expect to replay an <expr> mapping.

" Control test.  Causes no flicker.  But also doesn't check for start of line!
"imap <silent> <tab> <c-n>
"imap <silent> <s-tab> <c-p>



if exists("g:give_me_tab_completion_in_search") && g:give_me_tab_completion_in_search
    " Discussion: https://groups.google.com/forum/#!topic/vim_use/-IPWgth2h_k

    " One alternative is this, although it won't work if you are recording a macro.
    nnoremap / q/20-i

    " <Up> and <Down> can look at related history, but that's not what I want.

    " Let's just use an external plugin then :)
    " https://github.com/vim-scripts/SearchComplete
endif

" Some people recommend using omnifunc when it is available.
" However I found 'rubycomplete#Complete' did not complete on basic words, e.g. gem names in the Gemfile, so I prefer the basic word completion.
"if exists('&omnifunc') && &omnifunc != ''
    "return "\<c-x>\<c-o>"
"else
    "return "\<c-n>"
"endif

