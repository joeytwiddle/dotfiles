" Usually `[I` shows a list of all lines containing the word under the cursor.
"
" This scripts enhances `[I` to also prompt which line to jump to.

function! UnderOccurences()
	exe "normal! [I"
	let nr = input("Which one: ")
	if nr == ""
		return
	endif
	exe "normal! " . nr . "[\t"
endfunction!

function! FindOccurences()
	let pattern = input("Prompt Find: ")
	if pattern == ""
		return
	endif
	exe "ilist " . pattern
	let nr = input("Which one: ")
	if nr == ""
		return
	endif
	exe "ijump " . nr . pattern
endfunction

:nmap [I :call UnderOccurences()<Return>
