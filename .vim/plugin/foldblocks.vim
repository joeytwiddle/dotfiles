" Fold up all blocks of text separated by 3 (or 2) empty lines.
" This can be a useful fallback if no other folding methods are available,
" e.g. in plain text files, or for a different folding perspective on source
" code.

" BUG: Never folds the first line.
" BUG: Always reports error on the final failed search. (ALWAYS_REPORTS_ERROR)

" DONE: should not wrap-to-top on the last search, should fold to last line

" :map! :foldblocks<Enter> :set foldmethod=manual<Enter>:0<Enter>zEqf/^.<Enter>v/\n\n\n<Enter>zfq99@f
" :command! FoldBlocks set foldmethod=manual | normal :0<Enter>zEqf/^.<Enter>v/\n\n\n<Enter>zfq99@f
" :command! FoldBlocks set foldmethod=manual | normal :0<C-v>\nzEqf/^.<C-v>\nv/\n\n\n<C-v>\nzfq99@f

function! FoldBlocks(num)

	" Clear existing folds and go to top
	set foldmethod=manual
	normal zE
	normal :0

	"" Create a recording:  Find non-empty line.  Start visual.  Find double-line-break.  Create fold.
	if a:num == 2
		"" I think we can't record a macro while doing normal command.
		" normal qf/^.v/\n\n\nzfq
		"" But we can just set it direct in the engine:
		let @f="/^.v/\\n\\n\\nzf"
	else
		let @f="/^.v/\\n\\n\\n\\nzf"
	endif

	"" Execute as many times as possible, without wrapping to top of file
	let oldWrapScan = &wrapscan
	set nowrapscan

	" ALWAYS_REPORTS_ERROR
	" For the moment, we must accept the error:
	normal 999@f
	" That stops when no further gap can be found, often at the top of the
	" last block.  We must complete the fold up to the last line.
	normal 9999
	normal zf

	" Some attempts to avoid it follow
	" If we run this with silent!, it doesn't perform the last fold below.
	"   silent! exec "normal 999@f"
	" If we wrap it in try endtry, it loops forever!
	"   try | normal 999@f | catch | finally | endtry

	" Another attempt to avoid errors; also failed.
	" Now that we have reached this complexity, we should forget about using a
	" macro, and write a walker in vimscript using search().
	"   let previousLine = getpos(".")[1]
	"   let secondPreviousLine = 0
	"   while 1
	"   	try
	"   		normal @f
	"   	catch
	"   	endtry
	"   	let currentLine = getpos(".")[1]
	"   	if currentLine <= previousLine
	"   		break
	"   	endif
	"   	let secondPreviousLine = previousLine
	"   	let previousLine = currentLine
	"   endwhile
	"   call setpos(".",[0,secondPreviousLine,1,0])
	"   normal v9999
	"   normal zf

	" Restore wrapscan to how it was before
	let &wrapscan = oldWrapScan

endfunction

command! FoldBlocks call FoldBlocks(3)
command! FoldBlocksLite call FoldBlocks(2)

