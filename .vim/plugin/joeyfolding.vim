:command! Joeyfolding call s:Joeyfolding()

:function! s:Joeyfolding()

	" All gentle:
	":map = zo
	":map + zo
	":map - zc
	" Or:
	:map - zc
	:map = zo
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
	" :set fdc=2
	:set fdc=0

	:set foldlevel=2
	:normal zR

	" For all languages with {}s
	" I have noticed problems (with sh functions) which disappear if language
	" syntax is not loaded.
	:syn region myFold matchgroup=myDummy start="{" end="}" transparent fold

	" C/Java comments
	" bad :syn region myFold2 start="/*" end="*/" transparent fold
	" bad :syn region myFold5 start="^$" end="^$" transparent fold
	:syn region myFold2 matchgroup=myDummy start="\/\*" end="\*\/" fold
	:highlight link myFold2 cComment

	" C/Java #ifdefs
	:syn region myFold4 start="#ifdef" end="#endif" transparent fold

	" PS
	:syn region myFold5 matchgroup=myDummy start="% Begin" end="% End" fold transparent

	" Tex
	:syn region myFold6 matchgroup=myDummy start="\\begin" end="\\end" fold transparent

	" sh
	":syn region myFold7 matchgroup=myDummy start="\<do\>" end="\<done\>" fold transparent

	:syn sync fromstart

	" :set foldmethod=manual

	" Fold colours
	:highlight Folded ctermbg=DarkBlue ctermfg=White guibg=#000060 guifg=White
	" :highlight foldColumn ctermbg=Grey ctermfg=Blue cterm=none gui=bold guifg=Green guibg=#000060
	:highlight FoldColumn ctermbg=DarkBlue ctermfg=White cterm=bold gui=bold guifg=White guibg=#000060

	:set foldtext=getline(v:foldstart).'\ \ \ ['.(v:foldend-v:foldstart).'\ lines]'

	" For treelist.hs:
	" :syntax match TreeListFoldLine ".*\(-{\|-}\|{-\|}-\).*" contains=TreeListHsTag,myFold
	" :highlight TreeListFoldLine ctermbg=Red ctermfg=White cterm=bold
	:syntax match TreeListHsTag "^\(\.\|+\|-\|\*\) "
	:highlight TreeListHsTag ctermbg=blue ctermfg=white cterm=bold
	" :syn region TreeListFold matchgroup=myDummy start="-{" end="}-" transparent fold
	"" Conflicts with TreeListFold
	" :syntax match TreeListHsCurl "\(-{\|{-\|-}\|}\)$"
	" :highlight TreeListHsCurl ctermbg=blue ctermfg=white cterm=bold
	"" These two fix the strange looking holes in treelists but make tabs look weird in normal folding situations.  :-(
	"" This listchars should do tabs cos tabs get turned into ^I :-(
	" :set listchars=trail:\ 
	" :highlight SpecialKey ctermbg=blue ctermfg=white

:endfun
