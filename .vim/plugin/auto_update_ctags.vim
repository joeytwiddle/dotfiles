" Update ctags tags file whenever we save a buffer.
" To get started,  :!touch tags  then  :w
" Needed for Ctrl-] to work after adding new code.

" The super-simple version would be just this:
"autocmd BufWritePost,FileWritePost *.* :!ctags -a %
"autocmd BufWritePost,FileWritePost *.* if filewritable("tags")==1 | if &ch>1 | echo "Updating tags..." | endif | silent exec '!ctags -a "%:p" 2> >(grep -v "^ctags: Warning: ignoring null tag")' | endif

function! AutoUpdateCTags()
	if filewritable("tags")==1
		if &cmdheight > 1
			echo "Updating tags..."
		endif
		" We want to normalize the filenames, to avoid getting duplicates in the tags file with differing non-canonical paths
		" But absolute path (%:p) is not the most user-friendly solution (e.g. very wide quickfix windows!)
		" If the file was opened with a leading './' we remove it.
		" We can also remove the current working directory from the path, if we want to.
		" When manually running ctags, you should be sure to create filenames with the same path, or we will see duplicates in the tag file.
		let filename = expand('%')
		let filename = substitute(filename, '^./',     '', '')
		"let filename = substitute(filename, getcwd().'/', '', '')
		silent exec '!ctags -a ' . shellescape(filename) . ' 2> >(grep -v "^ctags: Warning: ignoring null tag")'

		" Let other plugins know that this buffer is being tagged.
		let b:auto_updated_ctags = 1
	else
		let b:auto_updated_ctags = 0
	endif
endfunction

augroup AutoUpdateCTags
	autocmd!
	autocmd BufWritePost,FileWritePost * call AutoUpdateCTags()
augroup END

" TODO: Update ../tags or ../../tags or ../../../tags if it exists.  Could cache it in b:my_nearest_tagsfile.
" In that case, the path normalization above should be done relative to the folder containing that tags file, not cwd.
" But perhaps better we should `cd` to the same folder as `tags`, and always normalize paths relative to that folder.
