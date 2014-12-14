" Description: VimBuddy statusline character
" Author:      Flemming Madsen <fma@cci.dk>
" Modified:    June 2001
" Version:     0.9.1
"
" Usage:       Insert %{VimBuddy()} into your 'statusline'
"

" This is Joey's statusline and should be moved to his .vimrc
set shm=atT
set statusline=%<%f\ %#Error#%m%##%h%r%=\ %P\ (%0l/%-0L,%c~%v)\ \#%02B\ \|%0n\|%<
" We highlight the modified flag to make it stand out.
" I don't really want %m to show [-] when nomodifiable, but since it does, I highlight %h%r ("[Help][RO]") also, so that is clear why there is something highlighted.
" OK fixed, now we show [+] and [-] in different places, so only [+] gets highlighted.
"function! ModifiedStatus()
"    return &modified ? "[+]" : ""
"endfunction
"let &statusline = substitute(&statusline, '%m', '%{ModifiedStatus()}', '')
" %y for filetype
let &statusline = substitute(&statusline, '%m', '%{ \&modified ? "[+]" : "" }', '')
let s:moreflags  = '%{ \&modifiable ? "" : "[-]" }'
let s:moreflags = s:moreflags . '%#StatusDiffing#%{ \&diff ? "[d]" : "" }%##'
"highlight StatusDiffing ctermbg=darkyellow ctermfg=black guibg=darkyellow guifg=black
highlight StatusDiffing ctermbg=blue ctermfg=white guibg=blue guifg=white
let &statusline = substitute(&statusline, '%h', s:moreflags.'%h', '')
if exists('*GetSearchStatus')
  let &statusline = substitute(&statusline, '= ', '= %{GetSearchStatus()}', '')
endif



let g:ShowCurrentGitBranch = get(g:, 'ShowCurrentGitBranch', 1)
let g:ShowGitStatusForBuffer = get(g:, 'ShowGitStatusForBuffer', 1)

function! ShowGitStatus()
  let str = ""
  if g:ShowCurrentGitBranch
    let str .= ShowCurrentGitBranch()
  endif
  if g:ShowGitStatusForBuffer
    let str .= ShowGitStatusForBuffer()
  endif
  return str
endfunction

function! ShowCurrentGitBranch(...)
  let  left_wrapper = a:0 >= 1 ? a:1 : '['
  let right_wrapper = a:0 >= 2 ? a:2 : '] '
  if exists('b:last_checked_branch_time') && s:get_ms_since(b:last_checked_branch_time) < 10000
    " Use cached value
  else
    " Get value and cache it
    let full_path = fnamemodify(resolve(expand('%:p')),':h')
    let b:last_checked_branch_value = s:CleanSystemCall('cd '.shellescape(full_path).' && git symbolic-ref --short HEAD')
    let b:last_checked_branch_time = reltime()
  endif
  let branch_name = b:last_checked_branch_value
  return branch_name == '' ? '' : left_wrapper . branch_name . right_wrapper
endfunction

function! ShowGitStatusForBuffer(...)
  let  left_wrapper = a:0 >= 1 ? a:1 : '['
  let right_wrapper = a:0 >= 2 ? a:2 : '] '
  if exists('b:last_checked_buffers_git_status_time') && s:get_ms_since(b:last_checked_buffers_git_status_time) < 10000
    " Use cached value
  else
    " Get value and cache it
    let full_file_path = resolve(expand('%:p'))
    let b:last_checked_buffers_git_status_value = s:CleanSystemCall('git status --porcelain '.shellescape(full_file_path))[0:1]
    let b:last_checked_buffers_git_status_time = reltime()
  endif
  let file_status = b:last_checked_buffers_git_status_value
  return file_status == '' ? '' : left_wrapper . file_status . right_wrapper
endfunction

function! s:CleanSystemCall(command)
  let result = system(a:command)
  if v:shell_error > 0
    return ''
  else
    " Strip trailing newline
    let result = substitute(result, '\n$', '', '')
    " Escape all other newlines
    let result = substitute(result, '\n', '\\n', 'g')
    return result
  endif
endfunction

function! s:get_ms_since(time)   " Terry Ma
  let cost = split(reltimestr(reltime(a:time)), '\.')
  return str2nr(cost[0])*1000 + str2nr(cost[1])/1000.0
endfunction

if exists('*ShowGitStatus')
  "let &statusline = substitute(&statusline, '%f', '%{ShowGitStatus()}%f', '')
  let &statusline = substitute(&statusline, '%f', '%{ShowCurrentGitBranch()}%f%{ShowGitStatusForBuffer(" [","]")}', '')
endif


" Shows time:
" :set rulerformat=%55(%{strftime('%a\ %b\ %e\ %I:%M\ %p')}\ %5l,%-6(%c%V%)\ %P%)
" Previous:
:set rulerformat=%60(%=%m\ \"%<%f\"\ (%l,%c)\ \#%B%)

" :set statusline=%<%f\ %m%h%r%=\ %P\ (%l,%c)%V\ \#%B%<\ %{VimBuddy()}
" :set rulerformat=%60(%=%m\ \"%<%f\"\ (%l,%c)\ \#%B\ %{VimBuddy()}%)
" " :set rulerformat=%15(%c%V\ %p%%%)

function! VimBuddy()
    " Take a copy for others to see the messages
    if ! exists("g:vimbuddy_msg")
        let g:vimbuddy_msg = v:statusmsg
    endif
    if ! exists("g:vimbuddy_warn")
        let g:vimbuddy_warn = v:warningmsg
    endif
    if ! exists("g:vimbuddy_err")
        let g:vimbuddy_err = v:errmsg
    endif
    if ! exists("g:vimbuddy_onemore")
        let g:vimbuddy_onemore = ""
    endif

    if ( exists("g:actual_curbuf") && (g:actual_curbuf != bufnr("%")))
        " Not my buffer, sleeping
        return "|-o"
    elseif g:vimbuddy_err != v:errmsg
        let v:errmsg = v:errmsg . " "
        let g:vimbuddy_err = v:errmsg
        return ":-("
    elseif g:vimbuddy_warn != v:warningmsg
        let v:warningmsg = v:warningmsg . " "
        let g:vimbuddy_warn = v:warningmsg
        return "(-:"
    elseif g:vimbuddy_msg != v:statusmsg
        let v:statusmsg = v:statusmsg . " "
        let g:vimbuddy_msg = v:statusmsg
        let test = matchstr(v:statusmsg, 'lines *$')
        let num = substitute(v:statusmsg, '^\([0-9]*\).*', '\1', '') + 0
        " How impressed should we be
        if test != "" && num > 20
            let str = ":-O"
        elseif test != "" && num
            let str = ":-o"
        else
            let str = ":-/"
        endif
		  let g:vimbuddy_onemore = str
		  return str
	 elseif g:vimbuddy_onemore != ""
		let str = g:vimbuddy_onemore
		let g:vimbuddy_onemore = ""
		return str
    endif

    if ! exists("b:lastcol")
        let b:lastcol = col(".")
    endif
    if ! exists("b:lastlineno")
        let b:lastlineno = line(".")
    endif
    let num = b:lastcol - col(".")
    let b:lastcol = col(".")
    if (num == 1 || num == -1) && b:lastlineno == line(".")
        " Let VimBuddy rotate
        let num = b:lastcol % 4
        if num == 0
            let ch = '|'
         elseif num == 1
            let ch = '/'
        elseif num == 2
            let ch = '-'
        else
            let ch = '\'
        endif
        return ":" . ch . ")"
    endif
    let b:lastlineno = line(".")

    " Happiness is my favourite mood
    return ":-)"
endfunction

