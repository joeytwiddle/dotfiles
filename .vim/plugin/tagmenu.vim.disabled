" File: tagmenu.vim
" Author: Yegappan Lakshmanan
" Version: 1.3
" Last Modified: Sep 25, 2002
"
" Overview
" --------
" The "Tags Menu" plugin provides the following features:
"
" 1. Creates a "Tags" menu containing all the tags (variables, functions,
"    classes, methods, macros, etc) defined in the current file.
" 2. Creates a popup menu with the contents of the "Tags" menu. This popup
"    menu can be accessed  by right clicking the mouse.
" 3. Groups the tags by their type and displays them in separate submenus.
" 4. The "Tags" menu can be sorted either by name or by line number.
" 5. When a tag name is selected from the "Tags" menu, positions the cursor
"    at the definition of the tag.
" 6. Automatically updates the "Tags" menu as you switch between
"    files/buffers.
" 7. If the number of tags in a particular type exceeds a configurable limit,
"    splits the menu for that tag type into one or more submenus.
" 8. Supports the following language files: Assembly, ASP, Awk, C, C++,
"    Cobol, Eiffel, Fortran, Java, Lisp, Make, Pascal, Perl, PHP, Python,
"    Rexx, Ruby, Scheme, Shell, Slang, TCL, Verilog, Vim and Yacc.
" 9. Runs in all the platforms where the exuberant ctags utility and Vim are
"    supported (this includes MS-Windows and Unix based systems).
" 10. Will run only in the GUI version of Vim.
" 11. The ctags output for a file is cached to speed up updating the "Tags"
"     menu.
"
" This script relies on the exuberant ctags utility to get the tags defined in
" a file. You can download the exuberant ctags utility from
" http://ctags.sourceforge.net. The exuberant ctags utility must be installed
" in your system to use this plugin. You should use exuberant ctags version
" 5.3 and above.  There is no need for you to create a tags file to use this
" plugin.
"
" Installation
" ------------
" 1. Copy the tagmenu.vim script to the $HOME/.vim/plugin directory.  Refer to
"    ':help add-plugin', ':help add-global-plugin' and ':help runtimepath' for
"    more details about Vim plugins.
" 2. Set the Tmenu_ctags_cmd variable to point to the exuberant ctags utility
"    path.
" 3. Restart Vim.
"
" Configuration
" -------------
" By changing the following variables you can configure the behavior of this
" script. Set the following variables in your .vimrc file using the 'let'
" command.
"
" The script uses the Tmenu_ctags_cmd variable to locate the ctags utility.
" By default, this is set to ctags. Set this variable to point to the
" location of the ctags utility in your system:
"
"           let Tmenu_ctags_cmd = 'd:\tools\ctags.exe'
"
" If a file contains too many tags of a particular type (function, variable,
" etc), greater than a configurable limit, then the tags menu for that tag
" type will be split into sub-menus.  The default limit is 25.  This can be
" changed by setting the Tmenu_max_submenu_items variable:
"
"           let Tmenu_max_submenu_items = 20
"
" If the number of tags of a particular tag type is more than that specified
" by Tmenu_max_submenu_items setting, then the tags menu for that tag type
" will be split into sub-menus. The name of the submenu is formed using the
" names of the first and the last tag entries in that submenu. Only the first
" Tmenu_max_tag_length characters from these names will be used to form the
" submenu name. Change the Tmenu_max_tag_length setting if you want to include
" more or less characters:
"
"           let Tmenu_max_tag_length = 10
"
" By default, the tag names will be added to the menu in the order in which
" they are defined in the file. You can alphabetically sort the tag names
" in the menu by selecting the "Sort menu by->Name" menu item. You can also
" change the default order by setting the variable Tmenu_sort_type to
" "name" or "order":
"
"           let Tmenu_sort_type = "name"
"
" This script will not work in 'compatible' mode.  Make sure the 'compatible'
" option is not set. This script depends on the file type detected by Vim.
" Make sure the Vim file type detection (:filetype on) is turned on.
"
"
" ****************** Do not modify after this line ************************
if exists("loaded_tagmenu") || &cp
    finish
endif
let loaded_tagmenu=1

" This script is useful only in GUI Vim
if !has("gui_running")
    finish
endif

" The default location of the exuberant ctags
if !exists("Tmenu_ctags_cmd")
    let Tmenu_ctags_cmd = 'ctags'
endif

" Maximum number of tags, after which the menu will be split into submenus.
if !exists("Tmenu_max_submenu_items")
    let Tmenu_max_submenu_items = 25
endif

" Tag name sort type
if !exists("Tmenu_sort_type")
    let Tmenu_sort_type = "order"
endif

if !exists("Tmenu_max_tag_length")
    let Tmenu_max_tag_length = 10
endif

" File types supported by tagmenu
let s:tmenu_file_types = 'asm asp awk c cpp cobol eiffel fortran java lisp ' .
            \ 'make pascal perl php python rexx ruby scheme sh slang tcl ' .
            \ 'verilog vim yacc'

" assembly language
let s:tmenu_asm_ctags_args = '--language-force=asm --asm-types=dlmt'
let s:tmenu_asm_tag_types = 'define label macro type'

" asp language
let s:tmenu_asp_ctags_args = '--language-force=asp --asp-types=fs'
let s:tmenu_asp_tag_types = 'function sub'

" awk language
let s:tmenu_awk_ctags_args = '--language-force=awk --awk-types=f'
let s:tmenu_awk_tag_types = 'function'

" c language
let s:tmenu_c_ctags_args = '--language-force=c --c-types=dgsutvf'
let s:tmenu_c_tag_types = 'macro enum struct union typedef variable function'

" c++ language
let s:tmenu_cpp_ctags_args = '--language-force=c++ --c++-types=vdtcgsuf'
let s:tmenu_cpp_tag_types = 'variable macro typedef class enum struct ' .
                            \ 'union function'

" cobol language
let s:tmenu_cobol_ctags_args = '--language-force=cobol --cobol-types=p'
let s:tmenu_cobol_tag_types = 'paragraph'

" eiffel language
let s:tmenu_eiffel_ctags_args = '--language-force=eiffel --eiffel-types=cf'
let s:tmenu_eiffel_tag_types = 'class feature'

" fortran language
let s:tmenu_fortran_ctags_args = '--language-force=fortran ' .
                                 \ '--fortran-types=bcefiklmnpstv'
let s:tmenu_fortran_tag_types = 'block common entry function interface ' .
            \ 'type label module namelist program subroutine derived variable'

" java language
let s:tmenu_java_ctags_args = '--language-force=java --java-types=pcifm'
let s:tmenu_java_tag_types = 'method class field package interface'

" lisp language
let s:tmenu_lisp_ctags_args = '--language-force=lisp --lisp-types=f'
let s:tmenu_lisp_tag_types = 'function'

" makefiles
let s:tmenu_make_ctags_args = '--language-force=make --make-types=m'
let s:tmenu_make_tag_types = 'macro'

" pascal language
let s:tmenu_pascal_ctags_args = '--language-force=pascal --pascal-types=fp'
let s:tmenu_pascal_tag_types = 'function procedure'

" perl language
let s:tmenu_perl_ctags_args = '--language-force=perl --perl-types=ps'
let s:tmenu_perl_tag_types = 'package subroutine'

" php language
let s:tmenu_php_ctags_args = '--language-force=php --php-types=cf'
let s:tmenu_php_tag_types = 'class function'

" python language
let s:tmenu_python_ctags_args = '--language-force=python --python-types=cf'
let s:tmenu_python_tag_types = 'class function'

" rexx language
let s:tmenu_rexx_ctags_args = '--language-force=rexx --rexx-types=c'
let s:tmenu_rexx_tag_types = 'subroutine'

" ruby language
let s:tmenu_ruby_ctags_args = '--language-force=ruby --ruby-types=cf'
let s:tmenu_ruby_tag_types = 'class function'

" scheme language
let s:tmenu_scheme_ctags_args = '--language-force=scheme --scheme-types=sf'
let s:tmenu_scheme_tag_types = 'set function'

" shell language
let s:tmenu_sh_ctags_args = '--language-force=sh --sh-types=f'
let s:tmenu_sh_tag_types = 'function'

" slang language
let s:tmenu_slang_ctags_args = '--language-force=slang --slang-types=nf'
let s:tmenu_slang_tag_types = 'namespace function'

" tcl language
let s:tmenu_tcl_ctags_args = '--language-force=tcl --tcl-types=p'
let s:tmenu_tcl_tag_types = 'procedure'

"verilog language
let s:tmenu_verilog_ctags_args = '--language-force=verilog --verilog-types=mPrtwpvf'
let s:tmenu_verilog_tag_types = 'module parameter reg task wire port variable function'

" vim language
let s:tmenu_vim_ctags_args = '--language-force=vim --vim-types=vf'
let s:tmenu_vim_tag_types = 'variable function'

" yacc language
let s:tmenu_yacc_ctags_args = '--language-force=yacc --yacc-types=l'
let s:tmenu_yacc_tag_types = 'label'

" Tmenu_Init()
" Initialize the tagmenu script local variables for the supported file types
" and tag types
function! s:Tmenu_Init()
    " Process each of the supported file types
    let fts = s:tmenu_file_types . ' '
    while fts != ''
        let ftype = strpart(fts, 0, stridx(fts, ' '))
        if ftype != ''
            " Get the supported tag types for this file type
            let txt = 's:tmenu_' . ftype . '_tag_types'
            if exists(txt)
                " Process each of the supported tag types
                let tts = s:tmenu_{ftype}_tag_types . ' '
                let cnt = 0
                while tts != ''
                    " Create the script variable with the tag type name
                    let ttype = strpart(tts, 0, stridx(tts, ' '))
                    if ttype != ''
                        let cnt = cnt + 1
                        let s:tmenu_{ftype}_{cnt}_name = ttype
                    endif
                    let tts = strpart(tts, stridx(tts, ' ') + 1)
                endwhile
                " Create the tag type count script local variable
                let s:tmenu_{ftype}_count = cnt
            endif
        endif
        let fts = strpart(fts, stridx(fts, ' ') + 1)
    endwhile
endfunction

" Initialize the script
call s:Tmenu_Init()

" Tag menu empty or not?
let s:tmenu_empty = 1

function! s:Remove_Tags_Menu()
    if !has("gui_running") || s:tmenu_empty
        return
    endif

    " Cleanup the Tags menu
    silent! unmenu T&ags
    silent! unmenu! T&ags

    amenu <silent> T&ags.Refresh\ menu :call <SID>Refresh_Tags_Menu()<CR>
    amenu <silent> T&ags.Sort\ menu\ by.Name 
                                    \ :call <SID>Sort_Tags_Menu("name")<CR>
    amenu <silent> T&ags.Sort\ menu\ by.Order 
                                    \ :call <SID>Sort_Tags_Menu("order")<CR>
    amenu T&ags.-SEP1-           :

    " Cleanup the popup menu
    silent! unmenu PopUp.T&ags
    silent! unmenu! PopUp.T&ags

    amenu <silent> PopUp.T&ags.Refresh\ menu 
                                \ :call <SID>Refresh_Tags_Menu()<CR>
    amenu <silent> PopUp.T&ags.Sort\ menu\ by.Name 
                                \ :call <SID>Sort_Tags_Menu("name")<CR>
    amenu <silent> PopUp.T&ags.Sort\ menu\ by.Order 
                                \ :call <SID>Sort_Tags_Menu("order")<CR>
    amenu PopUp.T&ags.-SEP1-           :

    let s:tmenu_empty = 1
endfunction

" Add_Tags_Menu
"   Add the tags defined in the current file to the menu
function! s:Add_Tags_Menu(menu_clear)
    if !has("gui_running")
        return
    endif

    if (a:menu_clear)
        " Cleanup the Tags menu
        silent! unmenu T&ags
        silent! unmenu! T&ags

        amenu <silent> T&ags.Refresh\ menu :call <SID>Refresh_Tags_Menu()<CR>
        amenu <silent> T&ags.Sort\ menu\ by.Name 
                                       \ :call <SID>Sort_Tags_Menu("name")<CR>
        amenu <silent> T&ags.Sort\ menu\ by.Order 
                                       \ :call <SID>Sort_Tags_Menu("order")<CR>
        amenu T&ags.-SEP1-           :

        " Cleanup the popup menu
        silent! unmenu PopUp.T&ags
        silent! unmenu! PopUp.T&ags

        amenu <silent> PopUp.T&ags.Refresh\ menu 
                                    \ :call <SID>Refresh_Tags_Menu()<CR>
        amenu <silent> PopUp.T&ags.Sort\ menu\ by.Name 
                                    \ :call <SID>Sort_Tags_Menu("name")<CR>
        amenu <silent> PopUp.T&ags.Sort\ menu\ by.Order 
                                    \ :call <SID>Sort_Tags_Menu("order")<CR>
        amenu PopUp.T&ags.-SEP1-           :

        let s:tmenu_empty = 1
    endif

    " If the tags menu for this buffer was already computed, then use it
    if exists("b:Tmenu_cmd")
        exe b:Tmenu_cmd
        let s:tmenu_empty = 0
        " Update the popup menu
        let cmd = substitute(b:Tmenu_cmd, '<silent> T\\&ags', 
                                        \ '<silent> PopUp.T\\\&ags', "g")
        exe cmd
        return
    endif

    let filename = expand("%")

    " empty filename
    if filename == ""
        return
    endif

    " Make sure the file is readable
    if !filereadable(filename)
        return
    endif

    let ftype = &filetype

    " Empty filetype
    if ftype == ''
        return
    endif

    " Translate Vim filetypes to that supported by exuberant ctags
    if ftype == 'aspperl' || ftype == 'aspvbs'
        let ftype = 'asp'
    elseif ftype =~ '\<[cz]\=sh\>'
        let ftype = 'sh'
    endif

    " Make sure the current filetype is supported
    if stridx(s:tmenu_file_types, ftype) == -1
        return
    endif

    " Exuberant ctags arguments to generate a tag list
    let ctags_args = ' -f - --format=2 --excmd=pattern --fields=K '

    if g:Tmenu_sort_type == "name"
        let ctags_args = ctags_args . " --sort=yes "
    else
        let ctags_args = ctags_args . " --sort=no "
    endif

    " Add the filetype specific arguments
    let ctags_args = ctags_args . ' ' . s:tmenu_{ftype}_ctags_args

    " Ctags command to produce output with regexp for locating the tags
    let ctags_cmd = g:Tmenu_ctags_cmd . ctags_args
    let ctags_cmd = ctags_cmd . ' "' . filename . '"'

    " Run ctags and get the tag list
    let cmd_output = system(ctags_cmd)

    if v:shell_error && cmd_output != ""
        echohl WarningMsg | echon cmd_output | echohl None
        return
    endif

    " No tags for current file
    if cmd_output == ''
        return
    endif

    " We are going to add entries to the tags menu, so the menu won't be
    " empty
    let s:tmenu_empty = 0

    " Add the 'B' flag to the 'cpoptions' option
    let old_cpo = &cpo
    set cpo+=B

    " Initialize variables for the new filetype
    let i = 1
    while i <= s:tmenu_{ftype}_count
        let ttype = s:tmenu_{ftype}_{i}_name
        let tag_{ttype}_count = 0
        let i = i + 1
    endwhile

    let len = strlen(cmd_output)

    " Process the ctags output one line at a time and group the tags by their
    " type
    while cmd_output != ''
        let one_line = strpart(cmd_output, 0, stridx(cmd_output, "\n"))

        " Extract the tag type
        let start = strridx(one_line, "\t") + 1
        let ttype = strpart(one_line, start)

        " Update the count of this tag type
        let cnt = tag_{ttype}_count + 1
        let tag_{ttype}_count = cnt

        " Extract the tag name
        let tname = strpart(one_line, 0, stridx(one_line, "\t"))
        " If there is more than one tag with the same name, then add a count
        " to the end of the menu name. Otherwise only one menu entry will be
        " added for multiple tags with the same name (overloaded functions).
        let var_name = ttype . '_' . substitute(tname, '\W', '__tagname__', 'g')
        if exists(var_name)
            let {var_name} = {var_name} + 1
            let tag_{ttype}_{cnt}_name = tname . '\ (' . {var_name} . ')'
        else
            let tag_{ttype}_{cnt}_name = tname
            let {var_name} = 1
        endif

        " Extract the tag pattern
        let start = stridx(one_line, '/^') + 2
        let end = stridx(one_line, '/;"' . "\t")
        if one_line[end - 1] == '$'
            let end = end - 1
        endif
        let tpat = '\\V\\^' . strpart(one_line, start, end 
                              \ - start) . (one_line[end] == '$' ? '\\$' : '')
        " Escape double quote characters so that the pattern can be used in
        " the search() function
        let tag_{ttype}_{cnt}_pat = escape(tpat, '"')

        " Remove the processed line
        let cmd_output = strpart(cmd_output, 
                                \ stridx(cmd_output, "\n") + 1, len)
    endwhile

    " Process the tags grouped by their type.
    let i = 1
    let cmd = ''
    while i <= s:tmenu_{ftype}_count
        " Get the tag type
        let ttype = s:tmenu_{ftype}_{i}_name
        let tcnt = tag_{ttype}_count " Number of tag entries for this tag type
        if tcnt == 0 " No entries for this tag type
            let i = i + 1
            continue
        endif
        " Process the tag entries for this tag type one at a time
        if tcnt > g:Tmenu_max_submenu_items
            let j = 1
            " Process the g:Tmenu_max_submenu_items entries to create the
            " submenu
            while j <= tcnt
                let final_index = j + g:Tmenu_max_submenu_items - 1
                if final_index > tcnt
                    let final_index = tcnt
                endif

                " Get the first and last tag name for this set of tags
                let first_tag = tag_{ttype}_{j}_name
                let last_tag = tag_{ttype}_{final_index}_name

                " Use only the configured number of characters from the first
                " and last tag names
                let first_tag = strpart(first_tag, 0, g:Tmenu_max_tag_length)
                let last_tag = strpart(last_tag, 0, g:Tmenu_max_tag_length)

                " Form the submenu name using the first and last tag names
                let submenu = first_tag . '\.\.\.' . last_tag . '.'

                " Form the menu commands to create the menu
                " Use the search() function to jump to the tag using the
                " tag search pattern. Use z. to center the tag line.
                let m_prefix = 'anoremenu <silent> T\&ags.' . ttype . 
                                                        \ '.' . submenu
                while j <= final_index
                    let cmd = cmd . m_prefix . tag_{ttype}_{j}_name
                    let cmd = cmd . ' :call search(' . '"'
                    let cmd = cmd . tag_{ttype}_{j}_pat . '"' . ', "w")<CR>\|'
                    let cmd = cmd . ':normal z.<CR>|'
                    let j = j + 1
                endwhile
            endwhile
        else
            " The number of tag entries for this tag type is less than the
            " g:Tmenu_max_submenu_items so create a single submenu for this
            " tag type
            let m_prefix = 'anoremenu <silent> T\&ags.' . ttype . '.'
            let j = 1
            while j <= tcnt
                let cmd = cmd . m_prefix . tag_{ttype}_{j}_name 
                let cmd = cmd . ' :call search(' . '"' . tag_{ttype}_{j}_pat
                let cmd = cmd . '"' . ', "w")<CR>\|:normal z.<CR>|'
                let j = j + 1
            endwhile
        endif

        let i = i + 1  " Next tag type
    endwhile

    " Store (cache) the tags menu command for this buffer
    let b:Tmenu_cmd = cmd

    " Add the tags menu. All the menu entries are added by this single
    " invocation
    exe cmd

    " Update the popup menu
    let cmd = substitute(cmd, '<silent> T\\&ags',
                                \ '<silent> PopUp.T\\\&ags', "g")
    exe cmd

    " Restore the 'cpoptions' settings
    let &cpo = old_cpo
endfunction

function! s:Refresh_Tags_Menu()
    unlet! b:Tmenu_cmd " Invalidate the cached ctags output
    call s:Add_Tags_Menu(1)
endfunction

function! s:Sort_Tags_Menu(sort_type)
    unlet! b:Tmenu_cmd
    let g:Tmenu_sort_type = a:sort_type
    call s:Add_Tags_Menu(1)
endfunction

" Menu commands
amenu <silent> T&ags.Refresh\ menu :call <SID>Refresh_Tags_Menu()<CR>
amenu <silent> T&ags.Sort\ menu\ by.Name :call <SID>Sort_Tags_Menu("name")<CR>
amenu <silent> T&ags.Sort\ menu\ by.Order :call <SID>Sort_Tags_Menu("order")<CR>
amenu T&ags.-SEP1-           :

amenu <silent> PopUp.T&ags.Refresh\ menu :call <SID>Refresh_Tags_Menu()<CR>
amenu <silent> PopUp.T&ags.Sort\ menu\ by.Name 
          \ :call <SID>Sort_Tags_Menu("name")<CR>
amenu <silent> PopUp.T&ags.Sort\ menu\ by.Order 
          \ :call <SID>Sort_Tags_Menu("order")<CR>
amenu PopUp.T&ags.-SEP1-           :

" Automatically add the tags in the current file to the menu
augroup FunctionMenuAutoCmds
    autocmd!

    autocmd BufEnter * call s:Add_Tags_Menu(0)
    autocmd BufLeave * call s:Remove_Tags_Menu()
augroup end
