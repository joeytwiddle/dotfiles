" Type :Joeyfolding or find it on the gvim menu.
" It will start up vim folding for you with nice colours and 2 columns for mouse interaction.
" - It can detect some foldable blocks which Vim doesn't auto-detect:
" - It has rules for folding diff/patch files :D
" - It will always fold { ... } blocks
" - It can also fold: C++ #ifdefs, Latex
" If folding is still poor after :Joeyfolding, try :set foldmethod=index

" Much of this is now in treefolding.vim, which is auto-generated from treevim.sh.
" Can we hope to factor out the common code?  (jsh script <-dep-> joey rc script)

:command! Joeyfolding call Joeyfolding()
if has("menu")
	amenu &Joey's\ Tools.&Joey's\ folding :call Joeyfolding()<CR>
endif

function! Joeyfolding()

	" ------------- Syntax and highlighting ------------- 

	if &filetype == "diff"

		"" Diffs/patches:  (Probably more to do for other forms of diff.  This is the form makebak uses.)
		" :syn region joeyRecursiveDiffFoldFile matchgroup=myDummy start="^diff "rs=s+1 end="^diff "me=s-1,re=s-1 fold transparent
		:syn region joeyRecursiveDiffFoldFile matchgroup=myDummy start="^\(diff\|Index:\) "rs=s+1 end="^\(diff\|Index:\) "me=s-1,re=s-1 fold transparent
		" :syn region joeyRecursiveDiffFoldFile matchgroup=myDummy start="^Index: "rs=s+1 end="^Index: "me=s-1,re=s-1 fold transparent
		:syn region joeyRecursiveDiffFoldBit matchgroup=myDummy start="^@@ "rs=s+1 end="^\(diff\|@@\|Index:\) "me=s-1,re=s-1 fold transparent

	else

		" For all languages with {}s
		" I have noticed problems (with sh functions) which disappear if language
		" syntax is not loaded.  Probably due to "contains" conditions.
		:syn region myFold matchgroup=myDummy start="{" end="}" transparent fold

		" C/Java style comments
		if &filetype == "c" || &filetype == "java" || &filetype == "javascript" || &filetype == "haxe"
			" bad :syn region myFold2 start="/*" end="*/" transparent fold
			" bad :syn region myFold5 start="^$" end="^$" transparent fold
			:syn region myFold2 matchgroup=myDummy start="\/\*" end="\*\/" fold
			:highlight link myFold2 cComment
			:hi link cComment Comment
		endif

		" C/C++ #ifdefs
		if &ft != 'asm'
			:silent! :syn clear myFold3
			:syn region myFold3 start="#ifdef\>" end="#endif\>" transparent fold
			:silent! :syn clear myFold4
			:syn region myFold4 start="#ifndef\>" end="#endif\>" transparent fold
			:silent! :syn clear myFold4b
			:syn region myFold4b start="#if\>" end="#endif\>" transparent fold
		endif
		" BUG: In asm, we must clear asmComment, asmHashThingy, asmIdentifier
		" and asmPreCondit in order for our folds to work (close) properly.
		" But we might be able to fix this if we define our syntax rules before
		" the general ones are loaded.

		" PS
		if &filetype == "ps"
			:syn region myFold5 matchgroup=myDummy start="% Begin" end="% End" fold transparent
		endif

		" Tex
		if &filetype == "tex" || &filetype == "latex"
			:syn region myFold6 matchgroup=myDummy start="\\begin" end="\\end" fold transparent
		endif

		" sh
		"if &filetype == "sh"
			":syn region myFold7 matchgroup=myDummy start="\<do\>" end="\<done\>" fold transparent
		"endif

		"" TODO: I really want this to use shiftwidth to indent the line properly.
		""       It would read much better, and IMO is vital in some cases.
		"" TODO: After #lines in decimal, list #lines/50 with each 50 represented by a '.' character.  Much easier visually.
		" :set foldtext=getline(v:foldstart).'\ \ \ ['.(v:foldend-v:foldstart).'\ lines]'


		""" All of this has moved into 'treevim.sh'.
		""" For treelist.hs:
		"" :syntax match TreeListFoldLine ".*\(-{\|-}\|{-\|}-\).*" contains=TreeListHsTag,myFold
		"" :highlight TreeListFoldLine ctermbg=Red ctermfg=White cterm=bold
		""" tags are blue, blends in:
		"" :syntax match TreeListHsTag "^\(\.\|+\|-\|\*\) "
		"" :highlight TreeListHsTag ctermbg=blue ctermfg=white cterm=bold
		":syntax match TreeListHsTag "^\(+\|-\) [^{}]*"
		"" :highlight TreeListHsTag ctermbg=darkmagenta ctermfg=white cterm=bold
		":syntax match TreeListHsTagNorm "^\(\.\|\*\) "
		":highlight TreeListHsTag ctermbg=darkblue ctermfg=grey cterm=none gui=bold guibg=#000060
		":highlight TreeListHsTagNorm ctermbg=darkblue ctermfg=grey cterm=none gui=bold guibg=#000060
		"" :syn region TreeListFold matchgroup=myDummy start="-{" end="}-" transparent fold
		""" Conflicts with TreeListFold
		"" :syntax match TreeListHsCurl "\(-{\|{-\|-}\|}\)$"
		"" :highlight TreeListHsCurl ctermbg=blue ctermfg=white cterm=bold
		""" These two fix the strange looking holes in treelists but make tabs look weird in normal folding situations.  :-(
		""" This listchars should do tabs cos tabs get turned into ^I :-(
		"" :set listchars=trail:\ 
		"" :highlight SpecialKey ctermbg=blue ctermfg=white

	endif

	" " Fold colours
	" :highlight Folded ctermbg=DarkBlue ctermfg=White guibg=#000080 guifg=White
	" " :highlight foldColumn ctermbg=Grey ctermfg=Blue cterm=none gui=bold guifg=Green guibg=#000060
	" :highlight FoldColumn ctermbg=DarkBlue ctermfg=White cterm=bold gui=bold guifg=White guibg=#000080

	:syn sync fromstart

	" All gentle:
	":map = zo
	":map + zo
	":map - zc
	" Or:
	":map - zc
	":map = zo   " No we don't want to redefine = because it's useful for indenting
	":map _ zm
	":map + zr
	" This was the set I ended with but now I use the default keys.
	":map _ zC
	":map + zO
	":map <kMinus> zc
	":map <kPlus> zo
	":map <kDivide> zm
	":map <kMultiply> zr

	if &foldmethod != "diff"

		"" This is _intended_ to clear any current folding.
		" :set foldmethod=manual
		" :normal zE

		:set foldmethod=syntax

	endif
	" This may be my favourite, but not on every window we open!
	" :set fdc=5
	" :set fdc=0

	if !&diff

		"" Remind user we have folding, but don't fold everything up.
		"" TOOD: A nice (although odd) start might be: set level=1 but open first fold?
		:set foldlevel=1
		" :normal zR
		" :normal zM

	endif

endfun
