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
	""       We might risk forgetting to delete them there if we delete syntax here.
  "" DONE: All highlights which set colors were moved.  Now in here and in after/syntax files when I do highlight, I try to link to an existing group.

	:syntax on

	"" Doesn't work for C - overidden by bracket matches?
	" :syntax match functionCall /[[:alpha:][:digit:]]+(/
	" :highlight functionCall ctermfg=cyan

	" :syntax region javaClassLine start=/class / end=/{/ contains=javaClassDecl

	" for jfc diffs
	:syntax keyword jDiff @@>>

	" for Mason
	:syntax region jComment start="/\*"  end="\*/"
  " TODO: Isn't this a bit heavy?

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
	:syntax keyword jTodo TODO Todo ToDo todo BUG BUGS WARN CONSIDER Consider NOTE TEST TESTING TOTEST Testing containedin=Comment,jShComment,jComment,shComment,ucComment,vimComment
	" Well they don't appear to work in all languages.
	" See also the shTodo rule I overrode in ~/.vim/after/syntax/sh.vim
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

	if &filetype == "log" || substitute(bufname("%"), '.*\.', '', '') == "log"
		"" Log4j:
		" :syntax match log4jDebug " DEBUG "
		" :syntax match log4jInfo  " INFO "
		" :syntax match log4jWarn  " WARN "
		" :syntax match log4jError " ERROR "
		:syntax match log4jDebug "^.* DEBUG .*$"
		:syntax match log4jInfo  "^.* INFO .*$"
		:syntax match log4jWarn  "^.* WARN .*$"
		:syntax match log4jError "^.* ERROR .*$"
	endif

	" if exists(":Joeyhighlight")
		" :Joeyhighlight
	" endif

	"" I find myself making two types of comments: documentation text in
	"" English, for reading by developers, and code comments for old code I am
	"" not using.  Ideally I would like to highlight them differently!

	"" This separates single comments from double comments, for files where single comments are commented code and double comments indicate documentation.
	"" Does not seem to work on vim files.
	" :syntax match friendlyComment /^\s*\(##\|""\|\/\/\/\/\).*/ contains=confTodo contains=shTodo
	"" Also assume a single-symbol comment is a human comment if it starts with
	"" a capital (or more strictly, capital then lowercase).
	" :syntax match friendlyComment +^\s*\(##\|""\|////\|// [A-Z]\|# [A-Z][a-z]\|" [A-Z][a-z]\).*+  contains=confTodo contains=shTodo
	"" Disabled cos it was a bit sucky.
	"" Now going for something more like vimTitle:
	" :syntax match friendlyComment +^\s*\(#\|"\|//\|##\|""\|////\) \([A-Za-z0-9]*:\|[A-Z]*\>\)+ contains=confTodo contains=shTodo
	"" Well that's even worse.  We need to be containedin a Comment!
	"" This is what I want to express, but not valid vim:
	" :syntax match friendlyComment +\([A-Za-z0-9]*:\|[A-Z]*\>\)+ containedin=Comment
	"" Until then, we have to take the whole line, which looks sucky if it wraps
	"" onto a second and loses its color.

	"" Instead, a blacklist approach: naff-comments
	"" BUG: Can't get it working with sh syntax rules!
	"syn clear
	"" Broad (space allowed, catches some text comments)
	"syntax match naffComment +^\s*\(#\|"\|//\)\s*\([a-z0-9:]\+\).*+ contains=confTodo contains=shTodo
	"" Narrow (comment immediately followed by lower-case char)
	"syntax match    naffComment /^\s*\(#\|"\|\/\/\)\([a-z0-9:]\).*/  contains=confTodo contains=shTodo
	"" Slightly broader (any comment not followed by a space)
	syntax match    naffComment /^\s*\(#\|"\|\/\/\)[^ ].*/ contains=confTodo contains=shTodo
	syntax match notNaffComment /^\s*\(#\|"\|\/\/\) .*/    contains=confTodo contains=shTodo
	hi naffComment ctermfg=darkblue guifg=#666666 gui=none
	if &t_Co >= 256
		"hi naffComment ctermfg=18    " very dark blue
		hi naffComment ctermfg=239   " pretty dark grey
	endif
	hi link notNaffComment Comment
	"" For concealing, we can add to naffComment:
	" conceal cchar=#
	"" and then:
	" :setlocal conceallevel=2

	" OH DUDE YOU JUST WROTE THIS ABOVE!
	" My new rule is that '// stuff' means human comment, '//stuff' means commented code.
	":syntax match codeComment +^\s*\(#\|"\|//\|##\|""\|////\)[^ ]*+
	"contains=confTodo contains=shTodo


	syntax match Comma /,/

endfun

call Joeysyntax()
