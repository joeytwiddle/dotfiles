" fzf_find_buffer_in_all_servers.vim
"
" :FindBufferInAllServers
"   Fuzzy-find any buflisted buffer across every running Vim server
"   (as reported by `vim --serverlist`) and jump to it.
"
"   Each candidate is shown in two columns: SERVER (padded to 20 chars)
"   and BUFNAME.  The raw values are smuggled in as hidden tab-separated
"   columns ahead of the display text -- fzf returns the *complete*
"   original line on selection regardless of --with-nth, so this is the
"   tidiest way to keep the visible text purely cosmetic while still
"   recovering an exact servername (which may contain spaces) and the
"   exact bufname for `--remote`.
"
"   Picking one runs `vim --servername SERVER --remote BUFNAME`, which
"   switches the target server to that buffer (or loads it if it isn't
"   open yet).

" if exists('g:loaded_fzf_find_buffer_in_all_servers')
" 	finish
" endif
" let g:loaded_fzf_find_buffer_in_all_servers = 1

" Shell pipeline that emits one tab-separated line per buffer:
"   SERVER<TAB>BUFNAME<TAB>SERVER_padded  BUFNAME
" Fields 1 and 2 carry the raw values for the sink/preview; field 3 is
" the formatted display.  We hide fields 1-2 from fzf via --with-nth=3..
" so the user only sees the pretty two-column layout, but on selection
" fzf hands us back the WHOLE line so we can extract the raw values.
"
" `awk` runs streaming, so candidates appear in fzf as they arrive.
let s:list_command =
	\   'for server in $(vim --serverlist); do'
	\ . ' vim --servername "$server" --remote-expr'
	\ . ' ''join(map(filter(range(1,bufnr("$")), "buflisted(v:val)"), "bufname(v:val)"), "\n")'''
	\ . ' 2>&1 | sed ''s/: Send expression failed.//'' | sed "s/^/${server}\$/";'
	\ . ' done'
	\ . ' | awk ''{ i = index($0, "$"); s = substr($0, 1, i-1); b = substr($0, i+1); printf "%s\t%s\t%-20s  %s\n", s, b, s, b }'''

function! s:OpenInServer(line) abort
	" The line is `SERVER<TAB>BUFNAME<TAB>display...`; the third field
	" (the display text) is purely cosmetic.  Field 1 is the raw server
	" (may contain spaces); field 2 is the raw buffer name.
	let l:parts = split(a:line, "\t", 1)
	if len(l:parts) < 2
		echohl ErrorMsg | echomsg 'FindBufferInAllServers: cannot parse selection: ' . a:line | echohl None
		return
	endif
	let l:server  = l:parts[0]
	let l:bufname = l:parts[1]
	if empty(l:bufname)
		echohl ErrorMsg | echomsg 'FindBufferInAllServers: empty buffer name (server ' . l:server . ')' | echohl None
		return
	endif

	" If the user picked a buffer in *this* server, just switch to it locally
	" (avoids spawning a child vim process and, on macOS, focus juggling).
	if l:server ==# v:servername
		execute 'buffer ' . fnameescape(l:bufname)
		return
	endif

	let l:cmd = 'vim --servername ' . shellescape(l:server)
		\ . ' --remote ' . shellescape(l:bufname)
	let l:out = system(l:cmd)
	if v:shell_error
		echohl ErrorMsg
		echomsg 'FindBufferInAllServers: ' . substitute(l:out, '\n\+$', '', '')
		echohl None
	endif
endfunction

function! s:Run() abort
	if !exists('*fzf#run') || !exists('*fzf#wrap')
		echohl ErrorMsg | echomsg 'FindBufferInAllServers: fzf.vim is not loaded' | echohl None
		return
	endif
	call fzf#run(fzf#wrap('find-buffer-in-all-servers', {
		\ 'source':  s:list_command,
		\ 'sink':    function('s:OpenInServer'),
		\ 'options': [
		\     '--prompt', 'Server  Buffer> ',
		\     '--layout=reverse',
		\     '--no-multi',
		\     '--delimiter', "\t",
		\     '--with-nth', '3..',
		\     '--preview', '[ -f {2} ] && head -n 500 -- {2} 2>/dev/null || echo "(no preview)"',
		\     '--preview-window', 'right,60%,wrap',
		\ ],
		\ }))
endfunction

command! FindBufferInAllServers call s:Run()
