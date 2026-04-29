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
" We then sort across all servers, numerically descending by `lastused`,
" so most-recently-used buffers float to the top.  This costs us
" true streaming-into-fzf -- sort can't emit until it has consumed all
" input -- but the per-server `vim --remote-expr` round-trips already
" dominate latency, so the user-visible cost is small.  fflush() in
" the final awk keeps lines popping line-by-line into fzf once sort
" starts emitting.
"
" `sort -t $'\t'` forces tab-only field splitting; without -t, BSD
" sort would split on whitespace runs, which would mis-key any server
" name that contains spaces.

let s:list_command =
	\   'for server in $(vim --serverlist); do'
	\ . ' vim --servername "$server" --remote-expr'
	\ . ' ''join(map(getbufinfo({"buflisted":1}), "v:val.lastused . \"\\t\" . v:val.name"), "\n")'''
	\ . ' 2>&1 | sed ''s/: Send expression failed.//'''
	\ . ' | awk -v server="$server" ''BEGIN{OFS="\t"} {print server, $0}'';'
	\ . ' done'
	\ . ' | sort -t $''\t'' -k2,2 -nr'
	\ . ' | awk -F "\t" ''{ printf "%s\t%s\t%-12.12s  %s\n", $1, $3, $1, $3; fflush() }'''

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
