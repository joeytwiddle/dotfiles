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

" TODO: Offer a third datum: git branch status (which would display ahead/behind markers/count)?
" TODO: The caching pattern is repeated, and could be refactored out
" TODO: The caching pattern is not optimal.  statusline is regularly (continually) recalculated for *all* visible windows, not just the current one.  With many windows open, they might all have different update phase (although they will sync up after a pause), increasing the likelihood of unwanted interruption/delay.  (In fact, if one of the lookups takes a significant amount of time, later lookups in the same statusline will get a different refresh time, so the user might end up seeing them update at different times!)  The solution might be to link all updates to a global debounce (rate-limiting) timer, and to avoid interruption, also link to a CursorHold event.  Although if the CursorHold event fires *after* the statusline update, then we would just be setting up an annoying delay for the *next* keypress.  Therefore the solution is: we should split up the behaviour: performs (possibly debounced) updates on CursorHold, and place that value into a variable that statusline can read; statusline would never actually perform calculations itself inline.  However a concern with this approach is that the CursorHold handler might inefficiently calculate updates for data which is not actually being references in statusline!  A solution to this would be for statusline to leave a message indicating to CursorHold that a result should be calculated, and pick up the actual value on later updates.  Then what if the user changes their statusline, removing some of the calls?  Since statusline cannot inform the CursorHold about this, instead the CursorHold should occasionally or regularly *clear* the set of requested updates, then statusline will re-add still needed requests on the next update (and can at least display older cached values, rather than nothing, to avoid flicker.)  I dare say this two-threaded messaging approach is a little convoluted for such a simple feature, but it appears we can address all the major concerns, and optimize performance for users with slower machines / file access (consider the latency involved with sshfs mounted files - in fact use that as a test case!).

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
    " Of the two chars returned, I believe the first is staged status, while the second is file vs HEAD.
    " I think the user might not be interested in staged status, therefore in future I might modify this to display only the second char.
    let parent_folder = fnamemodify(full_file_path, ":h")
    let git_status_cmd = "cd " . shellescape(parent_folder) . " && git status --porcelain ".shellescape(full_file_path)
    let b:last_checked_buffers_git_status_value = s:CleanSystemCall(git_status_cmd)[0:1]
    " When the file is up-to-date with HEAD, git status returns nothing.
    " But if nothing is displayed, it looks like the tool is not working, and the status is ambiguous.
    " So we prefer to display two empty spaces instead of nothing.  (I also considered [ =] but this is non-standard so may be confusing.)
    if b:last_checked_buffers_git_status_value == ''
        let b:last_checked_buffers_git_status_value = '  '
    endif
    let b:last_checked_buffers_git_status_time = reltime()
    " [ M] means file is modified relative to stage/index
    " [M ] means changes have been are staged
    " [MM] means staged but also locally modified since then!
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
  "let &statusline = substitute(&statusline, '%f', '%{ShowCurrentGitBranch()}%f%{ShowGitStatusForBuffer(" [","]")}', '')
  " If we want to color only the things inside the brackets, then we must always show the brackets.
  " It seems least bad to use the "not-current" background on the current window than to use the "current" background on many not-current windows!
  highlight StatusGitStatus cterm=bold,reverse ctermfg=white ctermbg=magenta guifg=magenta guibg=#bbbbbb gui=bold
  let &statusline = substitute(&statusline, '%f', '%{ShowCurrentGitBranch()}%f [%#StatusGitStatus#%{ShowGitStatusForBuffer("","")}%##]', '')
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

