" File: foldlist.vim
" Author: Paul C. Wei
" Version: l.0.4
" Last Modified: 11/28/2002
"
" Overview
" --------
" This is inspired by the taglist plugin.  The "Fold List" plugin 
" provides the following features:
"
" 1. Opens a vertically split Vim window with a list of folds in 
"    the current file. Uses the fold name as a search pattern to
"    goto the fold.
" 2. Moving through the fold list with the j, k, l, h, moves to the
"    associated fold in the file.
" 3. <CR> jumps to associated fold in file.
"
" Installation
" ------------
" 1. Copy the foldlist.vim script to the $HOME/.vim/plugin directory.  Refer to
"    ':help add-plugin', ':help add-global-plugin' and ':help runtimepath' for
"    more details about Vim plugins.
" 2. Restart Vim.
" 3. You can use the ":Flist" command to open the foldlist window. 
" 4. Handle up to 9 levels of folds. (search for '__T9' to change)
"
" Usage
" -----
" You can open the foldinst window from a source window by using the ":Flist"
" command.
"               nnoremap <silent> <F9> :Flist<CR>
"
" Add the above mapping to your ~/.vimrc file.
"
" You can close the taglist window from the taglist window by pressing 'q' or
" using the Vim ":q" command. 
"
" Send comments/suggestions/fixes to pwei@san.rr.com.
"
" Caveats:
" ---------
" 1. Fold is searched using fold title only. This may find other places in file
"    with the same string. I currently just hit 'l' or 'h' till find the
"    correct fold. Will fix by adding a tag if it becomes sufficiently annoying.
"
" Wish List
" ---------
" 1. Make fold list hierarchical & folding.
" 2. Make compatible w/ hi-note on palm (prob through ext conversion prog).
" 3. Allow for changes in fold hierarchy in fold list reflect in file
"
" Example:
" --------
" /* vim: set fdm=marker : */
" Phones {{{
" }}}
" ToDo {{{
" Work {{{
" }}}
" Shop {{{
" }}}
" }}}
"
" Generates:
" Phones
" ToDo
"  Work
"  Shop
"
" ****************** Do not modify after this line ************************

if exists('loaded_foldlist') || &cp
    finish
endif
let loaded_foldlist=1

"======================================================================
" Flist - generate fold list
" Global Variables:
" g:Flist_buf - buffer of file
function! s:Flist(win)
    let win_width =10
    let win_dir   ='topleft vertical'
	let level     = 0
    let bname = '__Fold__'

	let curbufnr = a:win
    let g:Flist_buf = curbufnr
    let winnumt = bufwinnr(bname)
    if winnumt != -1
        " Jump to the existing window
        if winnr() != winnumt
            exe winnumt . 'wincmd w'
        endif
    else
		let win_width = 20
		let win_dir = 'topleft vertical'
        let bufnum = bufnr(bname)
        if bufnum == -1
            " Create a new buffer
            let wcmd = bname
        else
            " Edit the existing buffer
            let wcmd = '+buffer' . bufnum
        endif

        exe 'silent! ' . win_dir . ' ' . win_width . 'split ' . wcmd
		" make scratch buffer
		set buftype=nofile
		set noswapfile

        " Delete the contents of the buffer to the black-hole register
        let winnumt = bufwinnr(bname)
    endif

	" Mark the buffer as modifiable
	setlocal modifiable

	" del contents
	silent! %delete _

	" goto file window
    let winnum = bufwinnr(curbufnr)
	if winnr() != winnum
	  exe winnum . 'wincmd w'
    endif

	" look for all the folds in file
	let out=cursor(1,0)
	let lastline  = line('$')
	let scanline  = 0
	let prevline = -1
	while scanline != prevline
		if (foldlevel(scanline)>0 && scanline != prevline)
            let ln = getline(scanline)
            let ln = substitute(ln,"^[ \t]*","","")
            let ln = substitute(ln,"{{{","","")
            let ln = substitute(ln,"[ \t]*$","","")
            let ln = "__T".foldlevel(scanline).ln
            let ln = substitute(ln,"^__T1","","")
            let ln = substitute(ln,"^__T2"," ","")
            let ln = substitute(ln,"^__T3","  ","")
            let ln = substitute(ln,"^__T4","   ","")
            let ln = substitute(ln,"^__T5","    ","")
            let ln = substitute(ln,"^__T6","     ","")
            let ln = substitute(ln,"^__T6","      ","")
            let ln = substitute(ln,"^__T7","       ","")
            let ln = substitute(ln,"^__T8","        ","")
            let ln = substitute(ln,"^__T9","         ","")
			exe winnumt . 'wincmd w'
			exe append(line('$'),ln)
			exe winnum . 'wincmd w'
		endif
		" open all levels of current fold, goto next fold
		silent! exe "norm zOzj"
		let prevline = scanline
		let scanline = line('.')
	endwhile

	exe winnum . 'wincmd w'
	" close all folds
	silent! exe "norm zm 1G"

	" set interface for fold window
    nnoremap <buffer> <silent> <CR> :call <SID>Flist_Jump_To_List()<CR>

	" set interface for list window
	exe winnumt . 'wincmd w'

	" setup keyboard mapping
    nnoremap <buffer> <silent> q :bdelete<CR>
    nnoremap <buffer> <silent> <CR> :call <SID>Flist_Jump_To_Fold()<CR>
    nnoremap <buffer> <silent> j :call <SID>Flist_move('j')<CR>
    nnoremap <buffer> <silent> k :call <SID>Flist_move('k')<CR>
    nnoremap <buffer> <silent> l :call <SID>Flist_move('l')<CR>
    nnoremap <buffer> <silent> h :call <SID>Flist_move('h')<CR>
    autocmd BufDelete __Fold__ call <SID>Flist_Close_Window()

    " Define the autocommand to highlight the current tag
    augroup FoldListAutoCmds
        autocmd!
        " Auto refresh the taglisting window
        "autocmd BufEnter * :Flist<CR>
    augroup end

	" setup syntax highlighting
    if has('syntax')
        syntax match FoldListComment '^" .*'

        " Colors used to highlight the selected tag name
        highlight clear FoldName
        if has('gui_running') || &t_Co > 2
            highlight link FoldName Search
        else
            highlight FoldName term=reverse cterm=reverse
        endif

        " Colors to highlight comments and titles
        highlight clear FoldListComment
        highlight link FoldListComment Comment
        highlight clear FoldListTitle
        highlight link FoldListTitle Title
    endif

endfunction

"======================================================================
" Flist_Jump_To_List()
function! s:Flist_Jump_To_List()
    let bname = '__Fold__'
    let winnumt = bufwinnr(bname)
	" return to fold list
	exe winnumt.'wincmd w'
endfunction

"======================================================================
" Flist_Jump_To_Fold()
" Jump to the location of the current tag
function! s:Flist_Jump_To_Fold()
	let ln = line('.')

	" Jump to the existing window
    let winnum = bufwinnr(g:Flist_buf)
	exe winnum . 'wincmd w'

	if line('.')==1
		let out=cursor(1,0)
    endif
endfunction

"======================================================================
" Flist_move()
" move and open fold
function! s:Flist_move(dir)
    let bname = '__Fold__'
	let flistwin = winnr()

	let rw = line(".")
	let cl = col(".")
	if a:dir=='j'
		let rw=rw+1
		let out=cursor(rw,0)
	elseif a:dir=='k'
		let rw=rw-1
		let out=cursor(rw,0)
	elseif a:dir=='l'
		let out=cursor(0,cl+1)
	elseif a:dir=='h'
		let out=cursor(0,cl-1)
	endif

	let curline = getline('.')

	" Jump to the existing window
    let winnum = bufwinnr(g:Flist_buf)
	exe winnum . 'wincmd w'

	" close all folds
	silent! exe "norm zm"
	if rw==1
		silent! exe "norm zm 1G"
    else
		if curline == '' || curline[0] == '"'
		else 
		  " find fold pattern
		  let tagpat = substitute(curline,"^[ \t]*","","")
		  echo ':'.tagpat.':'
		  call search(tagpat, 'w')

		  " highlight
		  let tagpat = substitute(tagpat,'\/','\\\/',"g")
		  exe 'match FoldName /^[ \t]*' . tagpat . '/'

		  "open fold, mov to window top
		  exe "norm zvzt"
		endif
	endif

	" return to fold list
	exe flistwin . 'wincmd w'
endfunction

"======================================================================
" Flist_Close_Window()
" Close the taglist window and adjust the Vim window width
function! s:Flist_Close_Window()
    " Remove the autocommands for the taglist window
    silent! autocmd! FoldListAutoCmds
endfunction

"======================================================================
" Define the 'Flist' user commands to open/close taglist
" window
command! -nargs=0 Flist call s:Flist(bufnr('%'))

"For my own editing of utility
"map [g :e c:\0setup\vim61\plugin\foldlist.vim<cr>
