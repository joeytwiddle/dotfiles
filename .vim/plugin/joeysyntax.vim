:command! Joeysyntax call Joeysyntax()
if has("menu")
	amenu &Joey's\ Tools.&Joey's\ syntax\ rules :call Joeysyntax()<CR>
endif

function! Joeysyntax()

	" Detect whether our terminal can support 256 colors, and if so set it.
	" This worked for Ubuntu 12.04.  (Some HOWTOs suggest setting TERM=xterm-256 but that is not needed here.)
	" But anyway see my .vimrc which may do better by using a blacklist, and runs before all plugins!
	"if $TERM == "xterm" && $XTERM_VERSION == "XTerm(278)"
		"set t_Co=256
	"endif

	" For slow computers:
	" :syn sync maxlines=50
	" :syn sync minlines=10

	"" Why is this here and not in joeyhighlight.vim ?
	" :set background=dark
	"" TODO: Should we move all highlight lines into joeyhighlight.vim ?
	""       We might risk forgetting to delete them there if we delete syntax here.
	"" DONE: All highlights which set colors were moved.  Now in here and in after/syntax files when I do highlight, I try to link to an existing group.

	:syntax on

	" for sh, but bad for #defines!
	" :syntax region jShComment start="[#]*## " end='$'
	" :highlight link jShComment jComment

	"" When TODO highlighting works in config files, it is because of the confComment and confTodo rules.
	"" When TODO highlighting works in vim files, it is because of the vimTodo rule.
	"" These both use "contained TODO" so perhaps we should too!

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
	"       But not always.  Sometimes only if the text is outside a Comment (e.g. in Python).
	:syntax keyword jTodo TODO Todo ToDo todo BUG BUGS WARN CONSIDER Consider NOTE TEST TESTING TOTEST Testing containedin=Comment,jShComment,jComment,shComment,ucComment,vimComment contained=TODO
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

	":syntax match jXmlBits /\(<\|>\)[[:alpha:]]*/
	":highlight jXmlBits ctermfg=red term=bold

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
	"" TODO: We really need to define this separately for each filetype.
	""       Lines leading with # in CSS/LESS/SCSS files are not comments!
	syntax match    naffComment /^\s*\(#\|"\|\/\/\)[^ ].*/ contains=confTodo contains=shTodo
	syntax match notNaffComment /^\s*\(#\|"\|\/\/\) .*/    contains=confTodo contains=shTodo
	hi naffComment ctermfg=darkblue guifg=#666666 gui=none
	if &t_Co >= 256
		"hi naffComment ctermfg=18    " very dark blue
		hi naffComment ctermfg=239   guifg=#333333 " pretty dark grey
	endif
	hi link notNaffComment Comment
	"" For concealing, we can add to naffComment:
	" conceal cchar=#
	"" and then:
	" :setlocal conceallevel=2

	" My new rule is that '// stuff' means human comment, '//stuff' means commented code.
	":syntax match codeComment +^\s*\(#\|"\|//\|##\|""\|////\)[^ ]*+
	"contains=confTodo contains=shTodo


	syntax match Comma /,/

endfun

call Joeysyntax()
