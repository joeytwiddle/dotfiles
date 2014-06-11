" When searching, shows the total count of matching lines, and the position of the current line within that search.
" To use this, add %{GetSearchStatus()} to your 'statusline'
" (Note that the total count of matching lines is not the same as the number of occurrences, because one line could contain more than one match!)
" Inspired by http://stackoverflow.com/questions/23975604/
" See also: http://www.vim.org/scripts/script.php?script_id=1682#IndexedSearch
" See also: http://www.vim.org/scripts/script.php?script_id=2634#SearchPosition

" If the current file is larger than the max (in bytes), then do not display the summary.  This can prevent sluggishness when working on large files.
if !exists('g:ShowSearchOccurrences_MaxBufferSize')
	let g:ShowSearchOccurrences_MaxBufferSize = 2000000
endif

function! GetSearchStatus()
	if match(mode(),'[nv]') == -1
		return ""
	endif
	let this_line = getline('.')
	let current_column = col('.')
	if match(this_line, @/, current_column-1) == current_column-1
		let buffer_size = line2byte(line("$")+1)-1
		if buffer_size > g:ShowSearchOccurrences_MaxBufferSize
			return ""
		endif
		let this_lnum = line('.')
		let count_matches = 0
		let this_index = -1
		let line_count = line("$")
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
		return "(".this_index."/".count_matches.") "
	else
		return ""
	endif
endfunction

