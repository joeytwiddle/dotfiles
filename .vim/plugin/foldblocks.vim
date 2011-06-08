" Fold up all blocks of text between "\n\n" separators
" DONE: should not wrap-to-top on the last search, should fold to last line
" :map! :foldblocks<Enter> :set foldmethod=manual<Enter>:0<Enter>zEqf/^.<Enter>v/\n\n\n<Enter>zfq99@f
" :command! FoldBlocks set foldmethod=manual | normal :0<Enter>zEqf/^.<Enter>v/\n\n\n<Enter>zfq99@f
" :command! FoldBlocks set foldmethod=manual | normal :0<C-v>\nzEqf/^.<C-v>\nv/\n\n\n<C-v>\nzfq99@f
function! FoldBlocks()
	set foldmethod=manual
	normal :0
	normal zE
	"" Recording: Find non-empty line.  Start visual.  Find double-line-break.  Create fold.
	" normal qf/^.v/\n\n\nzfq
	let @f="/^.v/\\n\\n\\n\\nzf"
	"" Execute as many times as possible, without wrapping to top of file
	set nowrapscan
	normal 999@f
	"" Will stop when no further match can be found - so complete the fold up to the last line
	normal 9999
	normal zf
	" Restore to "default":
	set wrapscan
endfunction
:command! FoldBlocks call FoldBlocks()

