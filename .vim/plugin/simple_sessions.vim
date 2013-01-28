" simple_sessions - Auto-save sessions on exit, and simple session loader.
"
" The loader uses NetRW for selection manager.
"
" When loading a session, ONLY the buffer/argument list and the working
" directory are changed.  The session vim script is NOT sourced.  (This avoids
" problems with broken plugin windows when sourcing a vim session.)
"
" Existing buffers remain open, so you may union multiple sessions.

" Will automatically save the current session whenever you quit vim.
if !exists("g:simple_sessions_autosave")
	let g:simple_sessions_autosave = 1
endif

" The folder which sessions are stored in.
if !exists("g:simple_sessions_folder")
	let g:simple_sessions_folder = $HOME . "/.vim/sessions"
endif

:command! Sopen :call s:OpenSessionViewer()

au VimLeavePre * call s:OnQuitSaveSession()

function! s:OpenSessionViewer()
	let s:old_cmdheight = &ch

	" Set netrw to show recent files at top
	let g:netrw_sort_by = "time"
	let g:netrw_sort_direction = "r"
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
		"let sessionName = split($PWD,'/')[-1]
		" The session name is made from the last TWO parts of the cwd path.
		let sessionName = join(split($PWD,'/')[-2:],'#')
		" TODO: If there is only one (real) buffer open, use his filename instead of $PWD.
		" Tried '#' as a delimeter but it got expanded to "-MiniBufExplorer-" :f
		let sessionFile = g:simple_sessions_folder."/".sessionName.".vim"
		exec 'mksession! '.escape(sessionFile,' ')
	endif
endfunction

function! s:GetFocusedFile()
	"let fname = getline('.')
	let fname = expand("<cword>")
	let fullPath = b:netrw_curdir . "/" . fname
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
	if exists("l:s")
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
	if a:name != '' && a:name[0] != '"'
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
			elseif firstArg == 'args'
				call add(files,join(words))
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
	return 0
endfunction

