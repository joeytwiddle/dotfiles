" Map <Tab> and <Shift-Tab> to perform word completion.

" This is the one I am currently using!

" It uses Vim's built-in <C-n> completion, but it lets <Tab> work normally at the beginning of a line.

" It comes from an old revision of http://vim.wikia.com/wiki/Smart_mapping_for_tab_completion

function! InsertTabWrapper(direction)
    " Often I don't want 'longest'; I want to perform a quick search.
    " So I remove 'longest' here.  And my mappings for other plugins, such as Tern, may enable it before they act.
    " (I might feel differently if the number of results is low, or the number of chars in the word-so-far is low.)
    set completeopt-=longest
    let col = col('.') - 1
    " \k matches chars in 'iskeyword'
    "if !col || getline('.')[col - 1] !~ '\k'
    " Only inserts a normal <Tab> if at the beginning of a line (everything before the cursor is whitespace)
    if !col || getline('.')[0:col - 1] =~ '^\s*$'
        return "\<tab>"
    elseif "backward" == a:direction
        return "\<c-p>"
    else
        return "\<c-n>"
    endif
endfunction

" This causes a lot of flicker (3 or 4 screen redraws) in xterm.  I believe that is because the returned values are re-interpreted.
inoremap <silent> <tab> <c-r>=InsertTabWrapper ("forward")<cr>
inoremap <silent> <s-tab> <c-r>=InsertTabWrapper ("backward")<cr>

" This causes no flicker!
"inoremap <expr> <silent> <tab> InsertTabWrapper("forward")
"inoremap <expr> <silent> <s-tab> InsertTabWrapper("backward")
" But unfortunately it doesn't work when UltiSnips is using it as a fallback, because UltiSnips does not expect to replay an <expr> mapping.

" Control test.  Causes no flicker.  But also doesn't check for start of line!
"imap <silent> <tab> <c-n>
"imap <silent> <s-tab> <c-p>


" I modified UltiSnips so I can use it on <Tab> and <Shift-Tab> but it will fallback to the exist definitions if no snippet is appropriate.
" Unfortunately it is still quite slow, because it seems to cause 3 screen redraws every time we hit Tab!
" We can mitigate this on some of the later <Tab> strokes, by skipping UltiSnips whenever the popup menu is open.
" We need to override UltiSnips mappings after they have loaded, so we wait for VimEnter.
" This looks nice, but when InsertTabWrapper return <c-n> this was being gobbled by Sparkup!
"au VimEnter * imap <expr> <Tab> pumvisible() ? InsertTabWrapper("forward") : "\<C-R>=UltiSnips_ExpandSnippetOrJump()\<CR>"
" This worked better:
"au VimEnter * imap <expr> <Tab> pumvisible() ? "\<C-R>=InsertTabWrapper('forward')\<CR>" : "\<C-R>=UltiSnips_ExpandSnippetOrJump()\<CR>"
"au VimEnter * imap <expr> <S-Tab> pumvisible() ? "\<C-R>=InsertTabWrapper('backward')\<CR>" : "\<C-R>=UltiSnips_JumpBackwards()\<CR>"
" TESTING:
"au VimEnter * if exists("*UltiSnips_ExpandSnippetOrJump") | imap <expr> <Tab> pumvisible() ? InsertTabWrapper('forward') : UltiSnips_ExpandSnippetOrJump() | endif
"au VimEnter * if exists("*UltiSnips_ExpandSnippetOrJump") | imap <expr> <S-Tab> pumvisible() ? InsertTabWrapper('backward') : UltiSnips_JumpBackwards() | endif
" If the menu is already open (e.g. from <Ctrl-Space> on a different plugin like tern) then cycle, don't check getline again!
au VimEnter * if exists("*UltiSnips_ExpandSnippetOrJump") | imap <expr> <Tab> pumvisible() ? "\<c-n>" : UltiSnips_ExpandSnippetOrJump() | endif
au VimEnter * if exists("*UltiSnips_ExpandSnippetOrJump") | imap <expr> <S-Tab> pumvisible() ? "\<c-p>" : UltiSnips_JumpBackwards() | endif
"au VimEnter * imap <expr> <Tab> InsertTabWrapper('forward')
"au VimEnter * imap <expr> <S-Tab> InsertTabWrapper('backward')
"au VimEnter * imap <expr> <Tab> "\<C-R>=InsertTabWrapper('forward')\<CR>"
"au VimEnter * imap <expr> <S-Tab> "\<C-R>=InsertTabWrapper('backward')\<CR>"



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

