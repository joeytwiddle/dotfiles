" Maps shift-Tab as well =)

" Joey this is the one you are currently using!  It works very well; basically the important thing is that it lets Tab work normally at the beginning of a line.

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

inoremap <tab> <c-r>=InsertTabWrapper ("forward")<cr>
inoremap <s-tab> <c-r>=InsertTabWrapper ("backward")<cr>

if exists("g:give_me_tab_completion_in_search") && g:give_me_tab_completion_in_search
    " Discussion: https://groups.google.com/forum/#!topic/vim_use/-IPWgth2h_k

    " One alternative is this, although it won't work if you are recording a macro.
    nnoremap / q/20-i

    " <Up> and <Down> can look at related history, but that's not what I want.

    " Let's just use an external plugin then :)
    " https://github.com/vim-scripts/SearchComplete
endif

