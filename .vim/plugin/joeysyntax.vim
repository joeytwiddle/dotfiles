:command! Joeysyntax call Joeysyntax()
if has("menu")
	amenu &Joey's\ Tools.&Joey's\ syntax\ rulez :call Joeysyntax()<CR>
endif

:function! Joeysyntax()

	" For slow computers:
	" :syn sync maxlines=50
	" :syn sync minlines=10

	" :colors pablo
	" :set guifont=-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv
	" :set guifont=-schumacher-clean-medium-r-normal-*-*-150-*-*-c-*-iso646.1991-irv
	" :set guifont=-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1
	" :set guifont=-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1
	" :set guifont=-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1
	" :set guifont=-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv
	" :set guifont=-b&h-lucidatypewriter-medium-r-normal-*-14-*-*-*-m-*-iso10646-1
	" Good for Windows, bad on Linux:
	" :set guifont=-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso10646-1
	" :set guifont=LucidaTypewriter\ 8
	" :set guifont=LucidaTypewriter\ 7
	:set guifont=clean

	:set background=dark

	:syntax on

	"" Doesn't work for C - overidden by bracket matches?
	:syntax match functionCall /[[:alpha:][:digit:]]+(/
	:highlight functionCall ctermfg=cyan

	" :syntax region javaClassLine start=/class / end=/{/ contains=javaClassDecl

	" for jfc diffs
	:syntax keyword jDiff @@>>

	" for Mason
	:syntax region jComment start="/\*"  end="\*/"

	" for sh, but bad for #defines!
	" :syntax region jShComment start="[#]*## " end='$'
	" :highlight link jShComment jComment

	" :syntax match jEq /=/
	"" for webscraping log:
	:syntax match jEq /[[:alpha:]]*=/
	:highlight link jEq Statement

	" :syntax keyword jTodo TODO
	" :highlight link jTodo Todo
	" :syntax keyword jNote NOTE
	" :highlight link jNote Todo
	"" Marche pas:
	" :syntax keyword jTodo TODO Todo BUG BUGS Consider:
	"" Hmm the standard TODO's are contained inside Comment types
	" :syntax contain jTodo BUG linksto Todo
	"" BUG: Doesn't always work.  Works better now.  Wish I could say containedin=*  Err, they don't seem to be working at all, only "TODO" gets highlighted, and i suspect that's a script somewhere else doing it ^^
	" :highlight! link jTodo Todo
	" NOTE: these DO work, if you call :Joeysyntax after vim has started.
	:syntax keyword jTodo TODO Todo ToDo todo BUG BUGS WARN CONSIDER Consider TEST TESTING Testing containedin=Comment,jShComment,jComment,shComment,ucComment,vimComment
	" :syntax keyword jTodo TODO Todo ToDo todo BUG BUGS WARN containedin=Comment,jShComment,jComment,shComment linksto Todo
	"" Maybe worth noting, when I type :highlight, I see something like this:
	" :syntax keyword jTodo contained COMBAK RELEASED NOT TODO WIP WARN links to Todo
	"" Also interesting, after doing :Joeysyntax, lines containing WARN get turned yellow, although again I don't think that's done by this script!
	" :syntax keyword jNote NOTE Note \<NB: CONSIDER Consider: TEST TESTING containedin=Comment,jShComment,jComment,shComment
	" The "Consider:" was never getting highlighted
	:syntax keyword jNote NOTE Note \<NB: DONE Done: FIXED: containedin=Comment,jShComment,jComment,shComment,ucComment,vimComment
	" oh it appears to be case-insensitive after all

	" :syntax keyword vimTodo contained TODO BUG WARN COMBAK RELEASED NOT " linksto Todo?
	" :syntax keyword vimLook contained CONSIDER TEST NOTE

	" Hmm the highlighting is working ok for me in shellscripts, if i run :Joeysyntax, but this vimscript looks weird

	:syntax match jXmlBits /\(<\|>\)[[:alpha:]]*/
	:highlight jXmlBits ctermfg=red term=bold

	"" Log4j:
	" :syntax match log4jDebug " DEBUG "
	" :syntax match log4jInfo  " INFO "
	" :syntax match log4jWarn  " WARN "
	" :syntax match log4jError " ERROR "
	:syntax match log4jDebug "^.* DEBUG .*$"
	:syntax match log4jInfo  "^.* INFO .*$"
	:syntax match log4jWarn  "^.* WARN .*$"
	:syntax match log4jError "^.* ERROR .*$"

:endfun

call Joeysyntax()
