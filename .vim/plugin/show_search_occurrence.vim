" When searching, shows the total count of matching lines, and the position of the current line within that search.
" (Note that the total count of matching lines is not the same as the number of occurrences, because one line could contain more than one match!)
" Inspired by http://stackoverflow.com/questions/23975604/

" If the current file contains more lines than this, do not display the summary (it may be too slow!).
" TODO: Buffer's total size may be more relevant than line count.
if !exists('g:ShowSearchOccurrences_MaxLines')
	let g:ShowSearchOccurrences_MaxLines = 20000
endif

let s:recently_echoed_search_status = 0

augroup ShowSearchOccurrences
	autocmd!
	autocmd CursorHold * call s:CheckSearchStatus()
augroup END

function! s:CheckSearchStatus()
	let this_line = getline('.')
	" TODO: To trigger only when at the start of a match (rather than anywhere on a matching line), discard the part of the line before the cursor, and require match()==0
	" We were previously checking &hlsearch but this doesn't seem relevant.  It is *not* set to 0 when :nohlsearch is called, and we still might want this plugin to act even if 'nohlsearch' is set.
	if match(this_line, @/) >= 0
		let this_lnum = line('.')
		let count_matches = 0
		let this_index = -1
		let line_count = line("$")
		if line_count > g:ShowSearchOccurrences_MaxLines
			return
		endif
		let lnum = 1
		while lnum <= line_count
			let line = getline(lnum)
			if match(line, @/) >= 0
				let count_matches += 1
				if lnum == this_lnum
					let this_index = count_matches
				end
			endif
			let lnum += 1
		endwhile
		" TODO: Echoing should be optional.  We could instead set some global variables for other scripts to use, and/or change the display on the statusline.
		echo "Search result (".this_index."/".count_matches.") for ".@/
		let s:recently_echoed_search_status = 1
	else
		" Clear the echo line when it is no longer relevant.
		if s:recently_echoed_search_status
			echo
			let s:recently_echoed_search_status = 0
		endif
	endif
endfunction

