" Description: VimBuddy statusline character
" Author:      Flemming Madsen <fma@cci.dk>
" Modified:    June 2001
" Version:     0.9.1
"
" Usage:       Insert %{VimBuddy()} into your 'statusline'
"

:set statusline=%<%f\ %m%h%r%=\ %P\ (%l,%c)%V\ \#%B%<\ %{VimBuddy()}
:set rulerformat=%40(%=%m\ %<%f\ (%l,%c)\ \#%B\ %{VimBuddy()}%)
" :set rulerformat=%15(%c%V\ %p%%%)

function! VimBuddy()
    " Take a copy for others to see the messages
    if ! exists("g:vimbuddy:msg")
        let g:vimbuddy:msg = v:statusmsg
    endif
    if ! exists("g:vimbuddy:warn")
        let g:vimbuddy:warn = v:warningmsg
    endif
    if ! exists("g:vimbuddy:err")
        let g:vimbuddy:err = v:errmsg
    endif
    if ! exists("g:vimbuddy:onemore")
        let g:vimbuddy:onemore = ""
    endif

    if ( exists("g:actual_curbuf") && (g:actual_curbuf != bufnr("%")))
        " Not my buffer, sleeping
        return "|-o"
    elseif g:vimbuddy:err != v:errmsg
        let v:errmsg = v:errmsg . " "
        let g:vimbuddy:err = v:errmsg
        return ":-("
    elseif g:vimbuddy:warn != v:warningmsg
        let v:warningmsg = v:warningmsg . " "
        let g:vimbuddy:warn = v:warningmsg
        return "(-:"
    elseif g:vimbuddy:msg != v:statusmsg
        let v:statusmsg = v:statusmsg . " "
        let g:vimbuddy:msg = v:statusmsg
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
		  let g:vimbuddy:onemore = str
		  return str
	 elseif g:vimbuddy:onemore != ""
		let str = g:vimbuddy:onemore
		let g:vimbuddy:onemore = ""
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

