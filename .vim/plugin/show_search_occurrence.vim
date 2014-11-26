" When performing a search, displays "(n/m)" in the statusbar to indicate the
" index of the current line within the list of matching lines in the buffer.
"
" To use this you need to add the function to your status line, for example:
"
"   :let &statusline = '%{GetSearchStatus()}' . &statusline
"
" (Note that the total count of matching lines is not the same as the number
" of occurrences, because one line could contain more than one match!)
"
" Inspired by http://stackoverflow.com/questions/23975604/
" See also: http://www.vim.org/scripts/script.php?script_id=1682#IndexedSearch
"           https://github.com/henrik/vim-indexed-search
" See also: http://www.vim.org/scripts/script.php?script_id=2634#SearchPosition

" If the current file is larger than the threshold (in bytes), then do not
" display the summary.  This can prevent sluggishness when working on large
" files.
let g:ShowSearchOccurrences_MaxBufferSize = get(g:, 'ShowSearchOccurrences_MaxBufferSize', 1000000)

function! GetSearchStatus()
	" Only display when in normal or visual mode
	if match(mode(),'[nv]') == -1
		return ""
	endif
	" Only display when the cursor is sitting on the first character of a match
	let this_line = getline('.')
	let current_column = col('.')
	" Check if we are on one of the search results
	" TODO BUG: This only works if we are on the first character.  So it is not much use for e.g. /search/e-3
	if match(this_line, @/, current_column-1) == current_column-1
		let buffer_size = line2byte(line("$")+1)-1
		if buffer_size > g:ShowSearchOccurrences_MaxBufferSize
			return ""
		endif
		" Loop all the lines in the file, to calculate the number of matches
		let this_lnum = line('.')
		let count_matches = 0
		let this_index = -1
		let line_count = line("$")
		let lnum = 1
		while lnum <= line_count
			let line = getline(lnum)
			if match(line, @/) >= 0
				let count_matches += 1
				" If this match is on the current line, then record the index
				if lnum == this_lnum
					let this_index = count_matches
				end
			endif
			let lnum += 1
		endwhile
		return "(".this_index."/".count_matches.") "
	else
		return ""
	endif
endfunction

