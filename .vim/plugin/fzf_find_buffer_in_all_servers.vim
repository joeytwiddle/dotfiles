" fzf_find_buffer_in_all_servers.vim
"
" :FindBufferInAllServers
"   Fuzzy-find any buflisted buffer across every running Vim server
"   (as reported by `vim --serverlist`) and jump to it.
"
"   Each candidate is shown as `SERVER$BUFNAME`.  Picking one runs
"   `vim --servername SERVER --remote BUFNAME`, which switches the
"   target server to that buffer (or loads it if it isn't open yet).

" If you want to add a keymap for this, add this to your ~/.vimrc:
"
"     nnoremap <silent> <Leader><Leader><C-E> :FindBufferInAllServers<CR>

if exists('g:loaded_fzf_find_buffer_in_all_servers')
	finish
endif
let g:loaded_fzf_find_buffer_in_all_servers = 1

" Shell pipeline that emits one line per buffer in the form: SERVER$BUFNAME
" (kept verbatim from the spec; just split across vim string concats)
let s:list_command =
	\   'for server in $(vim --serverlist); do'
	\ . ' vim --servername "$server" --remote-expr'
	\ . ' ''join(map(filter(range(1,bufnr("$")), "buflisted(v:val)"), "bufname(v:val)"), "\n")'''
	\ . ' 2>&1 | sed ''s/: Send expression failed.//'' | sed "s/^/${server}\$/";'
	\ . ' done'

function! s:OpenInServer(line) abort
	let l:idx = stridx(a:line, '$')
	if l:idx <= 0
		echohl ErrorMsg | echomsg 'FindBufferInAllServers: cannot parse selection: ' . a:line | echohl None
		return
	endif
	let l:server  = strpart(a:line, 0, l:idx)
	let l:bufname = strpart(a:line, l:idx + 1)
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
		\ 'options': ['--prompt', 'Server$Buffer> ', '--layout=reverse', '--no-multi', '--delimiter=\$', '--nth=1,2'],
		\ }))
endfunction

command! FindBufferInAllServers call s:Run()