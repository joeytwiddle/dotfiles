" Adapted from: https://vi.stackexchange.com/a/36613/630

nnoremap <silent> <C-`> :call <SID>ToggleTerm()<CR>
vnoremap <silent> <C-`> <ESC>:call <SID>ToggleTerm()<CR>
inoremap <silent> <C-`> <ESC>:call <SID>ToggleTerm()<CR>
tnoremap <silent> <C-`> <C-W>N:call <SID>ToggleTerm()<CR>

" If this grows on me, I'll tnoremap <c-d> to <cmd>wincmd c<cr>

function! s:ToggleTerm() abort
	const terms = term_list()
	if empty(terms)
		" No terminals, make one
		"botright terminal ++rows=50
		" See also: termwinsize
		let height = &lines / 2
		execute "botright terminal ++rows=" . height
	else
		const term = terms[0]
		if bufwinnr(term) < 0
			" Terminal hidden, open it
			execute 'botright sbuffer' term
			" Get back into insert mode
			normal! A
		else
			" Terminal open, close all windows showing it in the tab
			for win_id in win_findbuf(term)
				let win_nr = win_id2win(win_id)
				if win_nr > 0
					execute win_nr 'close'
				endif
			endfor
		endif
	endif
endfunction

" Additional: Make it easy to quit Vim, even if it has terminals still running
" From: https://www.reddit.com/r/vim/comments/fwedfx/comment/fmnwar1/
autocmd QuitPre * call <sid>TermForceCloseAll()
function! s:TermForceCloseAll() abort
	let term_bufs = filter(range(1, bufnr('$')), 'getbufvar(v:val, "&buftype") == "terminal"')
	for t in term_bufs
		execute "bdelete! " t
	endfor
endfunction
" NOTE: If terminals are not closing down properly on exit, consider starting them with ++kill=term or ++kill=hup
