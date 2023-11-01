" simple_sessions - Auto-save sessions on exit, and simple session loader.
" by joeytwiddle
"
" The loader uses NetRW to selection the session.
"
" When loading a session, ONLY the buffer/argument list and the working
" directory are changed.  The session vim script is NOT sourced.  (This avoids
" problems with broken plugin windows when sourcing a vim session.)
"
" Existing buffers remain open, so you may combine multiple sessions.

" Will automatically save the current session whenever you quit vim.
if !exists("g:simple_sessions_autosave")
	let g:simple_sessions_autosave = 1
endif

" The folder which sessions are stored in.
if !exists("g:simple_sessions_folder")
	let g:simple_sessions_folder = $HOME . "/.vim/sessions"
endif

" Small sessions won't be saved, only sessions with at least this many buffers
" (This actually uses the total number of buffers opened during the session, not the number open at present.)
if !exists("g:simple_sessions_min_buffers")
	let g:simple_sessions_min_buffers = 3
endif

command! Sopen :call s:OpenSessionViewer()

au VimLeavePre * call s:OnQuitSaveSession()

function! s:OpenSessionViewer()
	let s:old_cmdheight = &ch

	" Set netrw to show recent files at top
	" TODO: We should set these back to the original values, after opening netrw
	let g:netrw_sort_by = "time"
	let g:netrw_sort_direction = "r"
	let g:netrw_liststyle = 1
	let g:netrw_maxfilenamelen = 48
	" Open netrw:
	edit ~/.vim/sessions/

	" TODO: Might be nice to disable moving to a different folder.

	" Make it disappear when we leave it.
	" BUG: Doesn't happen when LoadFocusedSession() runs but does happen if we visit it and leave it by hand.
	set bufhidden=wipe
	" We could also set nobuflisted to hide it from BufExplorers.

	" Now setup some handy stuff on the window

	nmap <buffer> <CR> :call <SID>LoadFocusedSession()<Enter>

	augroup SimpleSessionMan
		au!
		au CursorHold <buffer> call s:ShowSessionSummary(s:GetFocusedFile())
	augroup END

endfunction

function! s:OnQuitSaveSession()
	if g:simple_sessions_autosave
		if bufnr('$') < g:simple_sessions_min_buffers
			return
		endif
		"let sessionName = split($PWD,'/')[-1]
		" The session name is made from the last TWO parts of the cwd path.
		" We change '/' to '#' but then need to escape '#' delimeter or it gets expanded to "-MiniBufExplorer-"!
		" Changed '\#' into '+' because if we try to source a session file with -S, Vim tries to do something with the '#' and fails.  '|' failed the mksession below, but even when escaped, '\|' failed on sourcing!
		let sessionName = join(split($PWD,'/')[-2:],'+')
		" TODO: If there is only one (real) buffer open, use his filename instead of $PWD.
		" Add the number of buffers.  Essentially this is so I don't overwrite a nice long session with a small one when I open and close Vim to edit one file.
		let sessionName .= "-" . bufnr('$')
		let sessionFile = g:simple_sessions_folder."/".sessionName.".vim"
		if !isdirectory(g:simple_sessions_folder)
			call mkdir(g:simple_sessions_folder, 'p')
		endif
		exec 'mksession! '.escape(sessionFile,' ')
	endif
endfunction

function! s:GetFocusedFile()
	"let fname = expand("<CWORD>")
	let fname = getline('.')
	" Strip branch art in case netrw is in tree mode
	let fname = substitute(fname, '^\([|│] \)*', '', '')
	" Strip date from the right hand side, in case netrw is in listmode 1
	let fname = substitute(fname, '\.vim *[0-9]*.*', '.vim', '')
	let fullPath = b:netrw_curdir . "/" . fname
	if !filereadable(fullPath)
		echo "Could not find file: " . fullPath
	endif
	return fullPath
endfunction

function! s:LoadFocusedSession()
	let fullPath = s:GetFocusedFile()
	"echo "Will load ".fullPath
	if filereadable(fullPath)
		let s = s:GetSessionSummary(fullPath)
		if exists("l:s")
			let &ch = s:old_cmdheight
			exec "cd ".escape(s.path,' ')
			let escapedFiles = map(s.files,'escape(v:val," ")')
			exec "argadd ".join(escapedFiles," ")
			bnext
		endif
	endif
endfunction

function! s:ShowSessionSummary(name)
	let s = s:GetSessionSummary(a:name)
	if type(s) == 4   " Is a dictionary, not -1
		let message = "[".s.path."] " . join(s.files, ", ")
		" We alter cmdheight as needed, to display the whole message.
		" Without setting noruler and noshowcmd, the "Press Enter" message
		" will somtimes appears even when there is room!
		let linesNeeded = ( (len(message)+1) / &columns) + 1
		let &ch = linesNeeded
		let x=&ruler | let y=&showcmd
		set noruler noshowcmd
		echo message
		let &ruler=x | let &showcmd=y
	endif
endfunction

function! s:GetSessionSummary(name)
	if a:name != '' && a:name[0] != '"' && filereadable(a:name)
		let lines = readfile(a:name)
		let path = ''
		let files = []
		for line in lines
			let words = split(line)
			if len(words)<1
				continue
			endif
			let firstArg = remove(words,0)
			if firstArg == 'cd'
				let path = join(words)
			elseif firstArg == 'args' && 0
				" I have disabled this block because filenames are still listed in 'args' even after their buffers have been closed.  I hope we can get the list of open buffers from badd alone.
				" Any word ending with '\' should have a space and the next word appended to it.
				" We may need to repeat this if there were originally two spaces.
				while 1
					let i = match(words, '\\$')
					if i >= 0 && i < len(words)-1
						let addToWord = remove(words,i+1)
						let words[i] = words[i] . ' ' . addToWord
					else
						break
					endif
				endwhile
				call extend(files,words)
			elseif firstArg == 'badd'
				" The next field is usually +<line_number>
				call remove(words,0)
				call add(files,join(words))
			endif
		endfor

		let obj = {}
		let obj.path = path
		let obj.files = files
		return obj
	endif
	return -1
endfunction

