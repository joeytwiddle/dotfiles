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

function! GetCurrentGitBranch(full_path)
    let result = system('cd '.shellescape(a:full_path).' && git symbolic-ref --short HEAD')
    if v:shell_error > 0
        return ''
    else
        " Strip trailing newline
        let result = substitute(result, '\n', '', 'g')
        return result
    endif
endfunction

function! ShowCurrentGitBranch()
    let full_path = expand('%:p:h')
    let branch_name = GetCurrentGitBranch(full_path)
    return branch_name == '' ? '' : '['.branch_name.'] '
endfunction

if exists('*ShowCurrentGitBranch')
    let &statusline = substitute(&statusline, '%f', '%{ShowCurrentGitBranch()}%f', '')
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

