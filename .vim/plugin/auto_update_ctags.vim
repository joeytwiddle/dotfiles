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
		let filename = substitute(filename, '^\./',     '', '')
		"let filename = substitute(filename, getcwd().'/', '', '')
		"silent exec '!ctags -a ' . shellescape(filename) . ' 2> >(grep -v "^ctags: Warning: ignoring null tag")'

		" My OS has switched from exuberant-ctags to universal-ctags, but that doesn't work well for me, so I'm sticking with locally compiled exuberant-ctags v5.8
		" But for some reason it needs a whole bunch of options to work properly.
		" We can find the right arguments from what taglist executes.
		" For example for ucc files it generates this:
		" ctags -f - --format=2 --excmd=pattern --fields=nks --sort=no --language-force=c --c-types=csvfm "filename.txt"

		" So that inspires us to use their approach:
		if s:Tlist_FileType_Init(&filetype)
			let ctags_args = ' --format=2 --excmd=pattern --fields=nks '
			let ctags_args = ctags_args . ' ' . s:tlist_{&filetype}_ctags_args
			let ctags_cmd = '!ctags -a ' . ctags_args . ' ' . shellescape(filename)
			"echo "ctags_cmd: ".ctags_cmd
			"silent exec ctags_cmd . ' 2> >(grep -v "^ctags: Warning: ignoring null tag")'
			silent exec ctags_cmd
		endif

		" Let other plugins know that this buffer is being tagged.
		let b:auto_updated_ctags = 1
	else
		let b:auto_updated_ctags = 0
	endif
endfunction

" Tlist_FileType_Init
" Initialize the ctags arguments and tag variable for the specified
" file type
function! s:Tlist_FileType_Init(ftype)
    "call s:Tlist_Log_Msg('Tlist_FileType_Init (' . a:ftype . ')')
    " If the user didn't specify any settings, then use the default
    " ctags args. Otherwise, use the settings specified by the user
    let var = 'g:tlist_' . a:ftype . '_settings'
    if exists(var)
        " User specified ctags arguments
        let settings = {var} . ';'
    else
        " Default ctags arguments
        let var = 's:tlist_def_' . a:ftype . '_settings'
        if !exists(var)
            " No default settings for this file type. This filetype is
            " not supported
            return 0
        endif
        let settings = s:tlist_def_{a:ftype}_settings . ';'
    endif

    let msg = 'Taglist: Invalid ctags option setting - ' . settings

    " Format of the option that specifies the filetype and ctags arugments:
    "
    "       <language_name>;flag1:name1;flag2:name2;flag3:name3
    "

    " Extract the file type to pass to ctags. This may be different from the
    " file type detected by Vim
    let pos = stridx(settings, ';')
    if pos == -1
        call s:Tlist_Warning_Msg(msg)
        return 0
    endif
    let ctags_ftype = strpart(settings, 0, pos)
    if ctags_ftype == ''
        call s:Tlist_Warning_Msg(msg)
        return 0
    endif
    " Make sure a valid filetype is supplied. If the user didn't specify a
    " valid filetype, then the ctags option settings may be treated as the
    " filetype
    if ctags_ftype =~ ':'
        call s:Tlist_Warning_Msg(msg)
        return 0
    endif

    " Remove the file type from settings
    let settings = strpart(settings, pos + 1)
    if settings == ''
        call s:Tlist_Warning_Msg(msg)
        return 0
    endif

    " Process all the specified ctags flags. The format is
    " flag1:name1;flag2:name2;flag3:name3
    let ctags_flags = ''
    let cnt = 0
    while settings != ''
        " Extract the flag
        let pos = stridx(settings, ':')
        if pos == -1
            call s:Tlist_Warning_Msg(msg)
            return 0
        endif
        let flag = strpart(settings, 0, pos)
        if flag == ''
            call s:Tlist_Warning_Msg(msg)
            return 0
        endif
        " Remove the flag from settings
        let settings = strpart(settings, pos + 1)

        " Extract the tag type name
        let pos = stridx(settings, ';')
        if pos == -1
            call s:Tlist_Warning_Msg(msg)
            return 0
        endif
        let name = strpart(settings, 0, pos)
        if name == ''
            call s:Tlist_Warning_Msg(msg)
            return 0
        endif
        let settings = strpart(settings, pos + 1)

        let cnt = cnt + 1

        let s:tlist_{a:ftype}_{cnt}_name = flag
        let s:tlist_{a:ftype}_{cnt}_fullname = name
        let ctags_flags = ctags_flags . flag
    endwhile

    let s:tlist_{a:ftype}_ctags_args = '--language-force=' . ctags_ftype .
                            \ ' --' . ctags_ftype . '-types=' . ctags_flags
    let s:tlist_{a:ftype}_count = cnt
    let s:tlist_{a:ftype}_ctags_flags = ctags_flags

    " Save the filetype name
    "let s:tlist_ftype_{s:tlist_ftype_count}_name = a:ftype
    "let s:tlist_ftype_count = s:tlist_ftype_count + 1

    return 1
endfunction

augroup AutoUpdateCTags
	autocmd!
	autocmd BufWritePost,FileWritePost * call AutoUpdateCTags()
augroup END

" TODO: Update ../tags or ../../tags or ../../../tags if it exists.  Could cache it in b:my_nearest_tagsfile.
" In that case, the path normalization above should be done relative to the folder containing that tags file, not cwd.
" But perhaps better we should `cd` to the same folder as `tags`, and always normalize paths relative to that folder.
