" Allows scripts to set a custom title for each quickfix list.
" Scripts should call g:SetQuickfixTitle(...)
" The title will be restored when :colder and :cnewer are used
"
" Use case: When walking through my previous :grep searches with :colder and
" :cnewer, the titles look ugly.  I would like to display what the list really
" represents, in human language.
"
" Solution: I actually use an ancient plugin called grep.vim.  I added a line
" to this which calls g:SetQuickfixTitle() when it creates a new search.

let s:mappedTitles = {}

function! g:SetQuickfixTitle(newTitle)
	let currentTitle = w:quickfix_title
	let s:mappedTitles[currentTitle] = a:newTitle
	let &l:statusline = a:newTitle
endfunction

function! g:RestoreQuickfixTitle()
	let storedTitle = w:quickfix_title
	if has_key(s:mappedTitles, storedTitle)
		let restoredTitle = s:mappedTitles[storedTitle]
		let &l:statusline = restoredTitle
	endif
endfunction

" Unfortunately I could NOT get WinEnter or CursorMoved actions to trigger on the quickfix list!
"
"   :autocmd QuickfixCmdPost quickfix make call s:RestoreQuickfixTitle()
"
" I could get BufRead, BufReadPost and BufReadPre to trigger.
"
"   :autocmd BufReadPost quickfix :call g:RestoreQuickfixTitle()
"
" But these trigger too soon!  All of them saw the storedTitle from the previous list, not the one being moved to!

" A WORKING solution is to use key mappings to execute :colder and :cnewer *and* trigger the restore:
"
"   :autocmd BufReadPost quickfix nnoremap <buffer> <C-PageDown> :cnewer<CR>:call g:RestoreQuickfixTitle()<CR>
"   :autocmd BufReadPost quickfix nnoremap <buffer> <C-PageUp> :colder<CR>:call g:RestoreQuickfixTitle()<CR>
"
" But if you don't use shortcuts, you could remap :cold<CR> and :colder<CR> and :cnewer<CR> themselves:
"
"   :autocmd BufReadPost quickfix nnoremap <buffer> <C-PageDown> :cnewer<CR>:call g:RestoreQuickfixTitle()<CR>
"
" Of course this will destroy the feature of :colder taking a [count] argument.  If you still want to use a count, you could try mapping through a :command with -range but that is too fiddly for this author!

