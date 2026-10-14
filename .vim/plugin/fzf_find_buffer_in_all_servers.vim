" fzf_find_buffer_in_all_servers.vim
"
" :FindBufferInAllServers
"   Fuzzy-find any buflisted buffer across every running Vim server
"   (as reported by `vim --serverlist`) and jump to it.
"
"   Each candidate is shown in two columns: SERVER (truncated/padded to
"   12 chars) and BUFNAME.  The raw values are smuggled in as hidden tab-separated
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
"   SERVER<TAB>BUFNAME<TAB>SERVER_padded(12)  BUFNAME
" Fields 1 and 2 carry the raw values for the sink/preview; field 3 is
" the formatted display.  We hide fields 1-2 from fzf via --with-nth=3..
" so the user only sees the pretty two-column layout, but on selection
" fzf hands us back the WHOLE line so we can extract the raw values.
"
" Each remote-expr asks its server for `<lastused>\t<name>` per listed
" buffer.  getbufinfo({"buflisted":1}) exposes both directly: `name`
" is already the full path (no fnamemodify needed -- bufname() alone
" was the unreliable one) and `lastused` is the localtime timestamp at
" which the buffer was last entered (requires +viminfo, which all
" modern Vims have).  [No Name] buffers come back with an empty name,
" which our sink and preview both already handle.
"
" Current approach: query each server with a single remote_expr() call,
" collect results in Vimscript, sort locally, and return lines to fzf
" as a list.  Uses only serverlist() + remote_expr() — no shell, so it
" sidesteps MacVim's `--remote-expr` replying on stderr with a trailing
" ": Send expression failed.".
"
" Trade-off: fzf doesn't open until all servers have responded because
" the Vimscript function runs to completion before returning the source
" list.  For a fast initial launch with incremental streaming, see the
" old shell-pipeline approach commented out below.
"
" Old shell-pipeline approach (commented out below):
"   The pipeline fans out queries via `xargs -P 20` for parallelism and
"   pipes directly into fzf's source, so fzf opens immediately and starts
"   streaming results as sort produces them.  However, it depends on
"   xargs, sort, awk, and sed with POSIX/GNU compatibility quirks.
"
"   Cross-platform notes for the old pipeline:
"     * `xargs -r` — GNU needs it to skip on empty input; BSD accepts -r
"       as a no-op.  With -r, both behave identically when no servers
"       are up.
"     * `xargs -I {}` is newline-delimited on both BSD and GNU, so
"       server names with spaces survive intact.
"     * `sort -t "$(printf '\t')"` rather than `sort -t $'\t'` because
"       $'...' is a bashism not guaranteed under POSIX /bin/sh (dash,
"       ash); the printf form works on any POSIX shell.
"     * To switch back, uncomment s:list_command and change s:Run()'s
"       'source' from s:ListBuffers() to s:list_command.

function! s:ListBuffers() abort
	let l:servers = split(serverlist(), "\n")
	if len(l:servers) == 0
		return []
	endif

	let l:entries = []
	let l:vim_expr = 'join(map(getbufinfo({"buflisted":1}), "v:val.lastused . \"\\t\" . v:val.name"), "\n")'

	for server in l:servers
		if empty(server) | continue | endif
		if server ==# v:servername
			for info in getbufinfo({'buflisted':1})
				call add(l:entries, [info.lastused, server, info.name])
			endfor
		else
			try
				let l:out = remote_expr(server, l:vim_expr, '', 2)
			catch
				continue
			endtry
			for line in split(l:out, "\n", 1)
				if empty(line) | continue | endif
				let l:parts = split(line, "\t", 1)
				if len(l:parts) < 2 | continue | endif
				let l:lastused = str2nr(l:parts[0])
				let l:bufname = l:parts[1]
				call add(l:entries, [l:lastused, server, l:bufname])
			endfor
		endif
	endfor

	call sort(l:entries, {a, b -> b[0] - a[0]})

	let l:result = []
	for [l:lastused, l:server, l:bufname; _] in l:entries
		let l:display_server = printf('%-12.12s', l:server)
		call add(l:result, l:server . "\t" . l:bufname . "\t" . l:display_server . '  ' . l:bufname)
	endfor

	return l:result
endfunction

" Old shell-pipeline source (streams to fzf immediately; see trade-off
" notes above).  Uncomment this and swap s:ListBuffers() for
" s:list_command in s:Run() to switch back.
"
" let s:list_command =
" 	\   'vim --serverlist | xargs -r -P 20 -I {} sh -c '''
" 	\ . 'server="$1";'
" 	\ . ' vim --servername "$server" --remote-expr "join(map(getbufinfo({\"buflisted\":1}), \"v:val.lastused . \\\"\\\\t\\\" . v:val.name\"), \"\\n\")"'
" 	\ . ' 2>&1 | sed "s/: Send expression failed.//"'
" 	\ . ' | awk -v s="$server" "BEGIN{OFS=\"\\t\"} {print s, \$0}"'
" 	\ . ''' _ {}'
" 	\ . ' | sort -t "$(printf ''\t'')" -k2,2 -nr'
" 	\ . ' | awk -F "\t" ''{ printf "%s\t%s\t%-12.12s  %s\n", $1, $3, $1, $3; fflush() }'''

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
		\ 'source':  s:ListBuffers(),
		"\ 'source':  s:list_command,  " old shell-pipeline source
		\ 'sink':    function('s:OpenInServer'),
		\ 'options': [
		\     '--prompt', 'Buffers(Global)> ',
		\     '--layout=reverse',
		\     '--no-multi',
		\     '--delimiter', "\t",
		\     '--with-nth', '3..',
		\     '--tiebreak', 'index',
		\     '--preview', '[ -f {2} ] && show_file_contents {2} 2>/dev/null || echo "(no preview)"',
		\     '--preview-window', 'right,40%,nowrap',
		\ ],
		\ }))
endfunction

command! FindBufferInAllServers call s:Run()
