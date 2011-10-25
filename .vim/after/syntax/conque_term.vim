"" Conque somtimes prints unwanted trailing spaces, and my listchars settings
"" make them visible!  Here we override my settings to hide them again.

"" Invalid:
" set listchars=&listchars,trail:\ 
"" Does not work due to all the \s
" exec "set listchars=".&listchars.",trail:\ "

set listchars=trail:\ 
" set listchars=trail:\ ,tab:>-

