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

:function! Joeyfolding()

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

		" C/Java comments
		" bad :syn region myFold2 start="/*" end="*/" transparent fold
		" bad :syn region myFold5 start="^$" end="^$" transparent fold
		:syn region myFold2 matchgroup=myDummy start="\/\*" end="\*\/" fold
		:highlight link myFold2 cComment
		:hi link cComment Comment

		" C/Java #ifdefs
		" The first of the repeated syntax lines is simply there to ensure that the clear does not produce an error.
		" The clear prevents BUG where multiple sourcing repeats folds.
		:syn region myFold3 start="#ifdef" end="#endif" transparent fold
		:syn clear myFold3
		:syn region myFold3 start="#ifdef" end="#endif" transparent fold
		:syn region myFold4 start="#ifndef" end="#endif" transparent fold
		:syn clear myFold4
		:syn region myFold4 start="#ifdnef" end="#endif" transparent fold
		"" TODO: clear all like myFold4

		" PS
		:syn region myFold5 matchgroup=myDummy start="% Begin" end="% End" fold transparent

		" Tex
		:syn region myFold6 matchgroup=myDummy start="\\begin" end="\\end" fold transparent

		" sh
		":syn region myFold7 matchgroup=myDummy start="\<do\>" end="\<done\>" fold transparent

		"" TODO: I really want this to use shiftwidth to indent the line properly.
		""       It would read much better, and IMO is vital in some cases.
		"" TODO: After #lines in decimal, list #lines/50 with each 50 represented by a '.' character.  Much easier visually.
		" :set foldtext=getline(v:foldstart).'\ \ \ ['.(v:foldend-v:foldstart).'\ lines]'


		" For treelist.hs:
		" :syntax match TreeListFoldLine ".*\(-{\|-}\|{-\|}-\).*" contains=TreeListHsTag,myFold
		" :highlight TreeListFoldLine ctermbg=Red ctermfg=White cterm=bold
		"" tags are blue, blends in:
		" :syntax match TreeListHsTag "^\(\.\|+\|-\|\*\) "
		" :highlight TreeListHsTag ctermbg=blue ctermfg=white cterm=bold
		:syntax match TreeListHsTag "^\(+\|-\) [^{}]*"
		" :highlight TreeListHsTag ctermbg=darkmagenta ctermfg=white cterm=bold
		:highlight TreeListHsTag ctermbg=darkblue ctermfg=grey cterm=none gui=bold guibg=#000060
		:syntax match TreeListHsTagNorm "^\(\.\|\*\) "
		:highlight TreeListHsTagNorm ctermbg=darkblue ctermfg=grey cterm=none gui=bold guibg=#000060
		" :syn region TreeListFold matchgroup=myDummy start="-{" end="}-" transparent fold
		"" Conflicts with TreeListFold
		" :syntax match TreeListHsCurl "\(-{\|{-\|-}\|}\)$"
		" :highlight TreeListHsCurl ctermbg=blue ctermfg=white cterm=bold
		"" These two fix the strange looking holes in treelists but make tabs look weird in normal folding situations.  :-(
		"" This listchars should do tabs cos tabs get turned into ^I :-(
		" :set listchars=trail:\ 
		" :highlight SpecialKey ctermbg=blue ctermfg=white

	endif

	" :set foldmethod=manual

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
	" :map - zc
	" :map = zo   " No we don't want to redefine = because it's useful for indenting
	:map _ zC
	:map + zO
	" :map _ zm
	" :map + zr
	:map <kMinus> zc
	:map <kPlus> zo
	:map <kDivide> zm
	:map <kMultiply> zr

	" This is _intended_ to clear any current folding.
	:set foldmethod=manual
	:normal zE

	:set foldmethod=syntax
	" This may be my favourite, but not on every window we open!
	" :set fdc=5
	" :set fdc=0

	:set foldlevel=2
	" :normal zR
	" :normal zM

:endfun
