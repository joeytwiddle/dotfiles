" Displays the syntax/highlight group under the cursor.
" Useful if you want to change the highlight rules of the current file.

" From the VimTips wiki

" I found I had to press it twice to get sensible readings.
" That wasn't a bug dufus.  That was the highlight-current-word script!

" map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
" \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
" \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" My adapted version, additionally shows where the highlight rule was defined

map <F10> :call <SID>ShowSyntaxUnderCursor()<CR>

function! s:ShowSyntaxUnderCursor()
	call s:ShowSyntaxRule(synIDattr(synID(line("."),col("."),1),"name"))
	call s:ShowSyntaxRule(synIDattr(synID(line("."),col("."),0),"name"))
	call s:ShowSyntaxRule(synIDattr(synIDtrans(synID(line("."),col("."),1)),"name"))
endfunction

function! s:ShowSyntaxRule(rule)
	"" Does not give source file/line
	" exec ":verbose syntax list ".a:rule
	exec ":verbose highlight ".a:rule
endfunction

