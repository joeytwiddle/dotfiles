:command! Joeysyntax call Joeysyntax()
if has("menu")
	amenu &Joey's\ Tools.&Joey's\ syntax\ rules :call Joeysyntax()<CR>
endif

function! Joeysyntax()

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
	" This one for Windows:
	" :set guifont=-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso10646-1
	" :set guifont=LucidaTypewriter\ 8
	" :set guifont=LucidaTypewriter\ 7
	" :set guifont=clean
	" See ~/.vimrc for current settings.

	"" Why is this here and not in joeyhighlight.vim ?
	" :set background=dark
	"" TODO: Should we move all highlight lines into joeyhighlight.vim ?
	""       We might risk forgetting to delete

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

	" TODO: Failed attempt to highlight operators in Unrealscript.
	:syntax match jOperator1 /\(==\|!=\|&&\|||\)/
	:highlight link jOperator1 Statement

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
	" :syntax contain jTodo BUG linksto Todo
	" :syntax keyword jTodo TODO Todo ToDo todo BUG BUGS WARN containedin=Comment,jShComment,jComment,shComment linksto Todo
	"" Maybe worth noting, when I type :highlight, I see something like this:
	" :syntax keyword jTodo contained COMBAK RELEASED NOT TODO WIP WARN BUG WARNING links to Todo
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

	" if exists(":Joeyhighlight")
		" :Joeyhighlight
	" endif

	" :syntax match friendlyComment /^\s*\(##\|""\|\/\/\/\/\).*/ contains=confTodo contains=shTodo
	"" Assume a single-symbol comment is a friendlyComment if it starts with a
	"" capital (or more strictly, capital then lowercase).
	:syntax match friendlyComment +^\s*\(##\|""\|////\|// [A-Z]\|# [A-Z][a-z]\|" [A-Z][a-z]\).*+  contains=confTodo contains=shTodo


	:syntax match Comma /,/

endfun

call Joeysyntax()
