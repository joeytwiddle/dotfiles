"" Conque somtimes prints unwanted trailing spaces, and my listchars settings
"" make them visible!  Here we override my settings to hide them again.

"" Invalid:
" set listchars=&listchars,trail:\ 

"" Does not work due to all the \s
" exec "setlocal listchars=".&listchars.",trail:\ "

"" For some reason setlocal still affects everyone!
" setlocal listchars=trail:\ 
" setlocal listchars=trail:\ ,tab:>-

" listchars is a global var, so setlocal is the same as set
" TODO: set and unset this on BufEnter/BufLeave/WinEnter/WinLeave?
set listchars+=trail:\ 

" Override Joey's defaults, and do not return to insert mode when leaving
" Conque from insert mode.
" The behaviour I really want, is to retain the mode I was in when I last
" entered Conque, and I have an Autocmd to save and restore this, which fires
" when the mouse is used, but not when these keybinds are used!
"inoremap <buffer> <C-Up> <Esc><C-w>k
"inoremap <buffer> <C-Down> <Esc><C-w>j
"inoremap <buffer> <C-Left> <Esc><C-w>h
"inoremap <buffer> <C-Right> <Esc><C-w>l
" Aha, I have a solution.  The Auto whatnot can set these key mappings up
" appropriately!  :)

