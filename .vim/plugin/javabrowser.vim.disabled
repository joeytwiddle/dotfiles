" File: JavaBrowser.vim
" Author: Pradeep Unde (pradeep_unde AT yahoo DOT com)
" Version: l.12
" Last Modified: Apr 15, 2003
"
" ChangeLog:
" Version 1.12:
" 1. Small bug fix to remove unwanted echo for visibility.
" Version 1.11:
" 1. Now interface methods are highlighted as public, abstract. I missed
" the abstract part in the previous version.
" 2. The visibility modifier (public/protected/private) can now be anywhere
" in the method/field declaration and it will be highlighted correctly.
" Version 1.10:
" 1. Now interface methods are highlighted as public and fields as public,
" static
" Version 1.9:
" 1. Added syntax highlighting (italic, underline) for xterm users
" Version 1.8:
" 1. Bug fix for comment syntax matching.
" Version 1.7:
" 1. Now the syntax highlighting can be configured in the gvimrc for
" various types of members as per individual taste. Defaults provided with the
" script can be OK for the most. Variuos syntax highlight groups that can be
" configured can be found out from the file. They generally look like
" JavaBrowser_public_static etc. Think of all possible combinations for
" public/protected/private with static and abstarct.
" Version 1.6:
" 1. Added colors for color term. It seems to be working for me for color
" Xterm. I use Mandrake 9.0 and KDE (konsole as xterm).
" Version 1.5:
" 1. If JavaBrowser is requested (:JavaBrowser) for any file other than
" a 'java' file, an error message is shown.
" Version 1.4:
" 1. Fixed bug for overriden methods. Now JavaBrowser understands overriden
" methods and jumps to the proper ones.
" Version 1.3:
" 1. Fixed bugs for inner classes and other minor bug fixes.
" Version 1.2:
" 1. Added syntax matching for abstract and final with combination of
" visibility. abstract members are shown in italics, statics are underlined as
" per UML specs.
" 2. Various syntax groups are defined in the file that can be changed to user
" taste for colors.
"
" Version 1.1:
" 1. Added syntax matching for visibility i.e. public,protected and private
" Limitations: Last name of field/method wins the syntax highlight. So, if the
" file has 2 or more classes with same field/method name with different
" visibilites, both of them are highlighted with the syntax colour of the last
" one encountered.
"
" Version 1.01:
" 1. Added syntax matching for types
" 2. Added opening for one fold level so it looks like
"           package
"              java.util
"           class
"              TreeMap
"              TreeMap.SubMap
"              ....
" when you open JavaBrowser
"
" Overview
" --------
" The "Java Browser" plugin provides the following features:
"
" 1. Opens a vertically/horizontally split Vim window with a list of packages,
"    classes in the current Java file in a tree form. They can be expanded to
"    look at details. e.g:
"        package
"           java.util
"        class
"           HashSet
"              field
"                map
"                PRESENT
"                ...
"              method
"                iterator
"                size
"                ...
" 2. Groups the tags by their type and displays them in a foldable tree.
" 3. Automatically updates the browser window as you switch between
"    files/buffers.
" 4. When a tag name is selected from the taglist window, positions the cursor
"    at the definition of the tag in the source file
" 5. Automatically highlights the current tag name.
" 6. Can display the prototype of a tag from the taglist window.
" 7. The tag list can be sorted either by name or by line number.
" 8. Runs in all the platforms where the exuberant ctags utility and Vim are
"     supported (this includes MS-Windows and Unix based systems).
" 9. Runs in both console/terminal and GUI versions of Vim.
" 
" TODO:
" 1. To cache ctags output for a file to speed up displaying the taglist
"     window.
"
" This plugin relies on the exuberant ctags utility to generate the tag
" listing. You can download the exuberant ctags utility from
" http://ctags.sourceforge.net. The exuberant ctags utility must be installed
" in your system to use this plugin. You should use exuberant ctags version
" 5.3 and above.  There is no need for you to create a tags file to use this
" plugin.
"
" This script relies on the Vim "filetype" detection mechanism to determine
" the type of the current file. To turn on filetype detection use
"
"               :filetype on
"
" This plugin will not work in 'compatible' mode.  Make sure the 'compatible'
" option is not set. This plugin will not work if you run Vim in the
" restricted mode (using the -Z command-line argument). This plugin also
" assumes that the system() Vim function is supported.
"
" Installation
" ------------
" 1. Copy the javabrowser.vim script to the $HOME/.vim/plugin directory. Refer to
"    ':help add-plugin', ':help add-global-plugin' and ':help runtimepath' for
"    more details about Vim plugins.
" 2. Set the JavaBrowser_Ctags_Cmd variable to point to the exuberant ctags utility
"    path.
" 3. If you are running a terminal/console version of Vim and the terminal
"    doesn't support changing the window width then set the JavaBrowser_Inc_Winwidth
"    variable to 0.
" 4. Restart Vim.
" 5. You can use the ":JavaBrowser" command to open/close the taglist window. 
"
" Usage
" -----
" You can open the taglist window from a source window by using the ":JavaBrowser"
" command. Invoking this command will toggle (open or close) the taglist
" window. You can map a key to invoke this command:
"
"               nnoremap <silent> <F8> :JavaBrowser<CR>
"
" Add the above mapping to your ~/.vimrc file.
"
" You can close the browser window from the browser window by pressing 'q' or
" using the Vim ":q" command. As you switch between source files, the taglist
" window will be automatically updated with the tag listing for the current
" source file.
"
" The tag names will grouped by their type (variable, function, class, etc)
" and displayed as a foldable tree using the Vim folding support. You can
" collapse the tree using the '-' key or using the Vim zc fold command. You
" can open the tree using the '+' key or using hte Vim zo fold command. You
" can open all the fold using the '*' key or using the Vim zR fold command
" You can also use the mouse to open/close the folds.
"
" You can select a tag either by pressing the <Enter> key or by double
" clicking the tag name using the mouse.
"
" The script will automatically highlight the name of the current tag.  The
" tag name will be highlighted after 'updatetime' milliseconds. The default
" value for this Vim option is 4 seconds.
"
" If you place the cursor on a tag name in the browser window, then the tag
" prototype will be displayed at the Vim status line after 'updatetime'
" milliseconds. The default value for the 'updatetime' Vim option is 4
" seconds. You can also press the space bar to display the prototype of the
" tag under the cursor.
"
" By default, the tag list will be sorted by the order in which the tags
" appear in the file. You can sort the tags either by name or by order by
" pressing the "s" key in the taglist window.
"
" You can press the 'x' key in the taglist window to maximize the taglist
" window width/height. The window will be maximized to the maximum possible
" width/height without closing the other existing windows. You can again press
" 'x' to restore the taglist window to the default width/height.
"
" You can open the taglist window on startup using the following command line:
"
"               $ vim +JavaBrowser
"
" If the line number is not supplied, this command will display the prototype
" of the current function.
"
" Configuration
" -------------
" By changing the following variables you can configure the behavior of this
" script. Set the following variables in your .vimrc file using the 'let'
" command.
"
" The script uses the JavaBrowser_Ctags_Cmd variable to locate the ctags utility.
" By default, this is set to ctags. Set this variable to point to the location
" of the ctags utility in your system:
"
"               let JavaBrowser_Ctags_Cmd = 'd:\tools\ctags.exe'
"
" By default, the tag names will be listed in the order in which they are
" defined in the file. You can alphabetically sort the tag names by pressing
" the "s" key in the taglist window. You can also change the default order by
" setting the variable JavaBrowser_Sort_Type to "name" or "order":
"
"               let JavaBrowser_Sort_Type = "name"
"
" Be default, the tag names will be listed in a vertically split window.  If
" you prefer a horizontally split window, then set the
" 'JavaBrowser_Use_Horiz_Window' variable to 1. If you are running MS-Windows
" version of Vim in a MS-DOS command window, then you should use a
" horizontally split window instead of a vertically split window.  Also, if
" you are using an older version of xterm in a Unix system that doesn't
" support changing the xterm window width, you should use a horizontally split
" window.
"
"               let JavaBrowser_Use_Horiz_Window = 1
"
" By default, the vertically split taglist window will appear on the left hand
" side. If you prefer to open the window on the right hand side, you can set
" the JavaBrowser_Use_Right_Window variable to one:
"
"               let JavaBrowser_Use_Right_Window = 1
"
" To automatically open the taglist window, when you start Vim, you can set
" the JavaBrowser_Auto_Open variable to 1. By default, this variable is set to 0 and
" the taglist window will not be opened automatically on Vim startup.
"
"               let JavaBrowser_Auto_Open = 1
"
" By default, only the tag name will be displayed in the taglist window. If
" you like to see tag prototypes instead of names, set the
" JavaBrowser_Display_Prototype variable to 1. By default, this variable is set to 0
" and only tag names will be displayed.
"
"               let JavaBrowser_Display_Prototype = 1
"
" The default width of the vertically split taglist window will be 30.  This
" can be changed by modifying the JavaBrowser_WinWidth variable:
"
"               let JavaBrowser_WinWidth = 20
"
" Note that the value of the 'winwidth' option setting determines the minimum
" width of the current window. If you set the 'JavaBrowser_WinWidth' variable to a
" value less than that of the 'winwidth' option setting, then Vim will use the
" value of the 'winwidth' option.
"
" By default, when the width of the window is less than 100 and a new taglist
" window is opened vertically, then the window width will be increased by the
" value set in the JavaBrowser_WinWidth variable to accomodate the new window.  The
" value of this variable is used only if you are using a vertically split
" taglist window.  If your terminal doesn't support changing the window width
" from Vim (older version of xterm running in a Unix system) or if you see any
" weird problems in the screen due to the change in the window width or if you
" prefer not to adjust the window width then set the 'JavaBrowser_Inc_Winwidth'
" variable to 0.  CAUTION: If you are using the MS-Windows version of Vim in a
" MS-DOS command window then you must set this variable to 0, otherwise the
" system may hang due to a Vim limitation (explained in :help win32-problems)
"
"               let JavaBrowser_Inc_Winwidth = 0
"
" By default, when you double click on the tag name using the left mouse 
" button, the cursor will be positioned at the definition of the tag. You 
" can set the JavaBrowser_Use_SingleClick variable to one to jump to a tag when
" you single click on the tag name using the mouse. By default this variable
" is set to zero.
"
"               let JavaBrowser_Use_SingleClick = 1
"
" By default, the taglist window will contain text that display the name of
" the file, sort order information and the key to press to get help. Also,
" empty lines will be used to separate different groups of tags. If you
" don't need these information, you can set the JavaBrowser_Compact_Format variable
" to one to get a compact display.
"
"               let JavaBrowser_Compact_Format = 1
"
" Extending
" ---------
" You can add support for new languages or modify the support for an already
" supported language by setting the following variables in the .vimrc file.
"
" To modify the support for an already supported language, you have to set the
" jbrowser_xxx_ctags_args and jbrowser_xxx_tag_types variables (replace xxx with the
" name of the language).  For example, to list only the classes and functions
" defined in a C++ language file, add the following lines to your .vimrc file
"
"       let jbrowser_cpp_ctags_args = '--language-force=c++ --c++-types=fc'
"       let jbrowser_cpp_tag_types = 'class function'
"
" The jbrowser_xxx_ctags_args setting will be passed as command-line argument to
" the exuberant ctags tool. The names set in the jbrowser_xxx_tag_types variable
" must exactly match the tag type names used by the exuberant ctags tool.
" Otherwise, you will get error messages when using the taglist plugin. You
" can get the tag type names used by exuberant ctags using the command line
"
"       ctags -f - --fields=K <filename>
"
" To add support for a new language, you have to set the name of the language
" in the jbrowser_file_types variable. For example,
"
"       let jbrowser_file_types = 'xxx'
"
" In addition to the above setting, you have to set the jbrowser_xxx_ctags_args
" and the jbrowser_xxx_tag_types variable as described above.
"
if exists('loaded_javabroswer') || &cp
    finish
endif
let loaded_javabroswer=1

" Location of the exuberant ctags tool
if !exists('JavaBrowser_Ctags_Cmd')
    let JavaBrowser_Ctags_Cmd = 'ctags'
endif

" Tag listing sort type - 'name' or 'order'
if !exists('JavaBrowser_Sort_Type')
    let JavaBrowser_Sort_Type = 'order'
endif

" Tag listing window split (horizontal/vertical) control
if !exists('JavaBrowser_Use_Horiz_Window')
    let JavaBrowser_Use_Horiz_Window = 0
endif

" Open the vertically split taglist window on the left or on the right side.
" This setting is relevant only if JavaBrowser_Use_Horiz_Window is set to zero (i.e.
" only for vertically split windows)
if !exists('JavaBrowser_Use_Right_Window')
    let JavaBrowser_Use_Right_Window = 0
endif

" Increase Vim window width to display vertically split taglist window.  For
" MS-Windows version of Vim running in a MS-DOS window, this must be set to 0
" otherwise the system may hang due to a Vim limitation.
if !exists('JavaBrowser_Inc_Winwidth')
    if (has('win16') || has('win95')) && !has('gui_running')
        let JavaBrowser_Inc_Winwidth = 0
    else
        let JavaBrowser_Inc_Winwidth = 1
    endif
endif

" Vertically split taglist window width setting
if !exists('JavaBrowser_WinWidth')
    let JavaBrowser_WinWidth = 30
endif

" Horizontally split taglist window height setting
if !exists('JavaBrowser_WinHeight')
    let JavaBrowser_WinHeight = 10
endif

" Automatically open the taglist window on Vim startup
if !exists('JavaBrowser_Auto_Open')
    let JavaBrowser_Auto_Open = 0
endif

" Display tag prototypes or tag names in the taglist window
if !exists('JavaBrowser_Display_Prototype')
    let JavaBrowser_Display_Prototype = 0
endif

" Use single left mouse click to jump to a tag. By default this is disabled.
" Only double click using the mouse will be processed.
if !exists('JavaBrowser_Use_SingleClick')
    let JavaBrowser_Use_SingleClick = 0
endif

" Control whether additional help is displayed as part of the taglist or not.
" Also, controls whether empty lines are used to separate the tag tree.
if !exists('JavaBrowser_Compact_Format')
    let JavaBrowser_Compact_Format = 0
endif

" File types supported by taglist
"let s:jbrowser_file_types = 'cpp java php python ruby'
let s:jbrowser_file_types = 'java'
if exists('g:jbrowser_file_types')
    " Add user specified file types
    let s:jbrowser_file_types = s:jbrowser_file_types . ' ' . g:jbrowser_file_types
endif

" Highlight the comments
if has('syntax')
    syntax match JavaBrowserComment '^" .*'

    " Colors used to highlight the selected tag name
    highlight clear TagName
    if has('gui_running') || &t_Co > 2
        highlight link TagName Search
    else
        highlight TagName term=reverse cterm=reverse
    endif

    " Colors to highlight. These are the defaults. User can change them in
    " their gvimrc as per their wish
    highlight link JavaBrowserComment Comment
    highlight clear JavaBrowserTitle
    highlight link JavaBrowserTitle Title
    highlight link JavaBrowserType Type
    highlight link JavaBrowserId Identifier
    
    " Colors for public members
    highlight link JavaBrowser_public Special
    highlight JavaBrowser_public ctermfg=green guifg=green

    " Colors for protected members
    highlight link JavaBrowser_protected Statement
    highlight JavaBrowser_protected ctermfg=brown guifg=orange

    " Colors for private members
    highlight link JavaBrowser_private Keyword
    highlight JavaBrowser_private ctermfg=red guifg=red

    " Colors for public, abstract members
    highlight link JavaBrowser_public_abstract JavaBrowser_public
    highlight JavaBrowser_public_abstract ctermfg=green term=italic cterm=italic guifg=green gui=italic
    
    " Colors for protected, abstract members
    highlight link JavaBrowser_protected_abstract JavaBrowser_protected
    highlight JavaBrowser_protected_abstract ctermfg=brown term=italic cterm=italic guifg=orange gui=italic
    
    " Colors for private, abstarct members
    highlight link JavaBrowser_private_abstract JavaBrowser_private
    highlight JavaBrowser_private_abstract ctermfg=red term=italic cterm=italic guifg=red gui=italic

    " Colors for public, static members
    highlight link JavaBrowser_public_static JavaBrowser_public
    highlight JavaBrowser_public_static ctermfg=green term=underline cterm=underline guifg=green gui=underline
    
    " Colors for protected, static members
    highlight link JavaBrowser_protected_static JavaBrowser_protected
    highlight JavaBrowser_protected_static ctermfg=brown term=underline cterm=underline guifg=orange gui=underline
    
    " Colors for private, static members
    highlight link JavaBrowser_private_static JavaBrowser_private
    highlight JavaBrowser_private_static ctermfg=red term=underline cterm=underline guifg=red gui=underline

    " Colors for abstract, static members (with default visibility)
    highlight link JavaBrowser_abstract_static Normal
    highlight JavaBrowser_abstract_static term=italic,underline cterm=italic,underline gui=italic,underline
    
    " Colors for static members (with default visibility)
    highlight link JavaBrowser_static Normal
    highlight JavaBrowser_static term=underline cterm=underline gui=underline
    
    " Colors for abstract members (with default visibility)
    highlight link JavaBrowser_abstract Normal
    highlight JavaBrowser_abstract term=italic cterm=italic gui=italic
    
    " Colors for public, abstract, static members
    highlight link JavaBrowser_public_abstract_static JavaBrowser_public
    highlight JavaBrowser_public_abstract_static ctermfg=green term=italic,underline cterm=italic,underline guifg=green gui=italic,underline
    
    " Colors for protected, abstract, static members
    highlight link JavaBrowser_protected_abstract_static JavaBrowser_protected
    highlight JavaBrowser_protected_abstract_static ctermfg=brown term=italic,underline cterm=italic,underline guifg=orange gui=italic,underline
    
    " Colors for private, abstract, static members
    highlight link JavaBrowser_private_abstract_static JavaBrowser_private
    highlight JavaBrowser_private_abstract_static ctermfg=red term=italic,underline cterm=italic,underline guifg=red gui=italic,underline
endif

" c++ language
"let s:jbrowser_def_cpp_ctags_args = '--language-force=c++ --c++-types=vdtcgsuf'
"let s:jbrowser_def_cpp_tag_types = 'macro typedef class enum struct union ' .
"                            \ 'variable function'
" java language
let s:jbrowser_def_java_ctags_args = '--language-force=java --java-types=pcifm'
let s:jbrowser_def_java_tag_types = 'package class interface field method'
let s:jbrowser_def_java_super_tag_types = 'package class interface'
let s:jbrowser_def_java_visibilities = 'public protected private'

" JavaBrowser_Init()
" Initialize the taglist script local variables for the supported file types
" and tag types
function! s:JavaBrowser_Init()
    let s:jbrowser_winsize_chgd = 0
    let s:jbrowser_win_maximized = 0
endfunction

" Initialize the script
call s:JavaBrowser_Init()

function! s:JavaBrowser_Show_Help()
    echo 'Keyboard shortcuts for the browser window'
    echo '-----------------------------------------'
    echo '<Enter> : Jump to the definition'
    echo 'o       : Jump to the definition in a new window'
    echo '<Space> : Display the prototype'
    echo 'u       : Update the browser window'
    echo 's       : Sort the list by ' . 
                            \ (b:jbrowser_sort_type == 'name' ? 'order' : 'name')
    echo 'x       : Zoom-out/Zoom-in the window'
    echo '+       : Open a fold'
    echo '-       : Close a fold'
    echo '*       : Open all folds'
    echo 'q       : Close the browser window'
endfunction

" An autocommand is used to refresh the taglist window when entering any
" buffer. We don't want to refresh the taglist window if we are entering the
" file window from one of the taglist functions. The 'JavaBrowser_Skip_Refresh'
" variable is used to skip the refresh of the taglist window
let s:JavaBrowser_Skip_Refresh = 0

function! s:JavaBrowser_Warning_Msg(msg)
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfunction

" JavaBrowser_Skip_Buffer()
" Check whether tag listing is supported for the specified buffer.
function! s:JavaBrowser_Skip_Buffer(bufnum)
    " Skip buffers with 'buftype' set to nofile, nowrite, quickfix or help
    if getbufvar(a:bufnum, '&buftype') != ''
        return 1
    endif

    " Skip buffers with filetype not set
    if getbufvar(a:bufnum, '&filetype') == ''
        return 1
    endif

    let filename = fnamemodify(bufname(a:bufnum), '%:p')

    " Skip buffers with no names
    if filename == ''
        return 1
    endif

    " Skip files which are not readable or files which are not yet stored
    " to the disk
    if !filereadable(filename)
        return 1
    endif

    return 0
endfunction

" JavaBrowser_TagType_Init
function! s:JavaBrowser_TagType_Init(ftype)
    " If the user didn't specify any settings, then use the default
    " ctags args. Otherwise, use the settings specified by the user
    let var = 'g:jbrowser_' . a:ftype . '_ctags_args'
    if exists(var)
        " User specified ctags arguments
        let s:jbrowser_{a:ftype}_ctags_args = {var}
    else
        " Default ctags arguments
        let s:jbrowser_{a:ftype}_ctags_args = s:jbrowser_def_{a:ftype}_ctags_args
    endif

    " Same applies for tag types
    let var = 'g:jbrowser_' . a:ftype . '_tag_types'
    if exists(var)
        " User specified exuberant ctags tag names
        let s:jbrowser_{a:ftype}_tag_types = {var}
    else
        " Default exuberant ctags tag names
        let s:jbrowser_{a:ftype}_tag_types = s:jbrowser_def_{a:ftype}_tag_types
    endif

    let s:jbrowser_{a:ftype}_count = 0

    " Get the supported tag types for this file type
    let txt = 's:jbrowser_' . a:ftype . '_tag_types'
    if exists(txt)
        " Process each of the supported tag types
        let tts = s:jbrowser_{a:ftype}_tag_types . ' '
        let cnt = 0
        while tts != ''
            " Create the script variable with the tag type name
            let ttype = strpart(tts, 0, stridx(tts, ' '))
            if ttype != ''
                let cnt = cnt + 1
                let s:jbrowser_{a:ftype}_{cnt}_name = ttype
            endif
            let tts = strpart(tts, stridx(tts, ' ') + 1)
        endwhile
        " Create the tag type count script local variable
        let s:jbrowser_{a:ftype}_count = cnt
    endif
endfunction

" JavaBrowser_Cleanup()
" Cleanup all the taglist window variables.
function! s:JavaBrowser_Cleanup()
    match none

    if exists('b:jbrowser_ftype') && b:jbrowser_ftype != ''
        let count_var_name = 's:jbrowser_' . b:jbrowser_ftype . '_count'
        if exists(count_var_name)
            let old_ftype = b:jbrowser_ftype
            let i = 1
            while i <= s:jbrowser_{old_ftype}_count
                let ttype = s:jbrowser_{old_ftype}_{i}_name
                let j = 1
                let var_name = 'b:jbrowser_' . old_ftype . '_' . ttype . '_count'
                if exists(var_name)
                    let cnt = b:jbrowser_{old_ftype}_{ttype}_count
                else
                    let cnt = 0
                endif
                while j <= cnt
                    unlet! b:jbrowser_{old_ftype}_{ttype}_{j}
                    let j = j + 1
                endwhile
                unlet! b:jbrowser_{old_ftype}_{ttype}_count
                "unlet! b:jbrowser_{old_ftype}_{ttype}_start
                let i = i + 1
            endwhile
        endif
    endif

    " Clean up all the variables containing the tags output
    if exists('b:jbrowser_tag_count')
        while b:jbrowser_tag_count > 0
            unlet! b:jbrowser_tag_{b:jbrowser_tag_count}
            let b:jbrowser_tag_count = b:jbrowser_tag_count - 1
        endwhile
    endif

    unlet! b:jbrowser_bufnum
    unlet! b:jbrowser_bufname
    unlet! b:jbrowser_ftype
endfunction

" JavaBrowser_Open_Window
" Create a new taglist window. If it is already open, clear it
function! s:JavaBrowser_Open_Window()
    " Tag list window name
    let bname = '__JBrowser_List__'

    " Cleanup the taglist window listing, if the window is open
    let winnum = bufwinnr(bname)
    if winnum != -1
        " Jump to the existing window
        if winnr() != winnum
            exe winnum . 'wincmd w'
        endif
    else
        " Create a new window. If user prefers a horizontal window, then open
        " a horizontally split window. Otherwise open a vertically split
        " window
        if g:JavaBrowser_Use_Horiz_Window == 1
            " If a single window is used for all files, then open the tag
            " listing window at the very bottom
            let win_dir = 'botright'
            " Horizontal window height
            let win_size = g:JavaBrowser_WinHeight
        else
            " Increase the window size, if needed, to accomodate the new
            " window
            if g:JavaBrowser_Inc_Winwidth == 1 &&
                        \ &columns < (80 + g:JavaBrowser_WinWidth)
                " one extra column is needed to include the vertical split
                let &columns= &columns + (g:JavaBrowser_WinWidth + 1)
                let s:jbrowser_winsize_chgd = 1
            else
                let s:jbrowser_winsize_chgd = 0
            endif

            " Open the window at the leftmost place
            if g:JavaBrowser_Use_Right_Window == 1
                let win_dir = 'botright vertical'
            else
                let win_dir = 'topleft vertical'
            endif
            let win_size = g:JavaBrowser_WinWidth
        endif

        " If the tag listing temporary buffer already exists, then reuse it.
        " Otherwise create a new buffer
        let bufnum = bufnr(bname)
        if bufnum == -1
            " Create a new buffer
            let wcmd = bname
        else
            " Edit the existing buffer
            let wcmd = '+buffer' . bufnum
        endif

        " Create the taglist window
        exe 'silent! ' . win_dir . ' ' . win_size . 'split ' . wcmd
    endif
endfunction

" JavaBrowser_Zoom_Window
" Zoom (maximize/minimize) the taglist window
function! s:JavaBrowser_Zoom_Window()
    if s:jbrowser_win_maximized == 1
        if g:JavaBrowser_Use_Horiz_Window == 1
            exe 'resize ' . g:JavaBrowser_WinHeight
        else
            exe 'vert resize ' . g:JavaBrowser_WinWidth
        endif
        let s:jbrowser_win_maximized = 0
    else
        " Set the window size to the maximum possible without closing other
        " windows
        if g:JavaBrowser_Use_Horiz_Window == 1
            resize
        else
            vert resize
        endif
        let s:jbrowser_win_maximized = 1
    endif
endfunction

" JavaBrowser_Init_Window
" Set the default options for the taglist window
function! s:JavaBrowser_Init_Window(bufnum)
    " Set report option to a huge value to prevent informations messages
    " while deleting the lines
    let old_report = &report
    set report=99999

    " Mark the buffer as modifiable
    setlocal modifiable

    " Delete the contents of the buffer to the black-hole register
    silent! %delete _

    " Mark the buffer as not modifiable
    setlocal nomodifiable

    " Restore the report option
    let &report = old_report

    " Clean up all the old variables used for the last filetype
    call <SID>JavaBrowser_Cleanup()

    let filename = fnamemodify(bufname(a:bufnum), ':p')

    " Set the sort type. First time, use the global setting. After that use
    " the previous setting
    let b:jbrowser_sort_type = getbufvar(a:bufnum, 'jbrowser_sort_type')
    if b:jbrowser_sort_type == ''
        let b:jbrowser_sort_type = g:JavaBrowser_Sort_Type
    endif

    let b:jbrowser_tag_count = 0
    let b:jbrowser_bufnum = a:bufnum
    let b:jbrowser_bufname = fnamemodify(bufname(a:bufnum), ':p')
    let b:jbrowser_ftype = getbufvar(a:bufnum, '&filetype')

    " Mark the buffer as modifiable
    setlocal modifiable

    if g:JavaBrowser_Compact_Format == 0
        call append(0, '" Press ? for help')
        call append(1, '" Sorted by ' . b:jbrowser_sort_type)
        call append(2, '" =' . fnamemodify(filename, ':t') . ' (' . 
                                   \ fnamemodify(filename, ':p:h') . ')')
    endif
    if has('syntax')
        syntax match JavaBrowserComment '^" .*'
    endif

    " Mark the buffer as not modifiable
    setlocal nomodifiable
    
    " Folding related settings
    if has('folding')
        setlocal foldenable
        setlocal foldmethod=manual
        setlocal foldcolumn=2
        setlocal foldtext=v:folddashes.getline(v:foldstart)
    endif

    " Mark buffer as scratch
    silent! setlocal buftype=nofile
    silent! setlocal bufhidden=delete
    silent! setlocal noswapfile
    silent! setlocal nowrap
    silent! setlocal nobuflisted

    " If the 'number' option is set in the source window, it will affect the
    " taglist window. So forcefully disable 'number' option for the taglist
    " window
    silent! setlocal nonumber

    " Create buffer local mappings for jumping to the tags and sorting the list
    nnoremap <buffer> <silent> <CR> :call <SID>JavaBrowser_Jump_To_Tag(0)<CR>
    nnoremap <buffer> <silent> o :call <SID>JavaBrowser_Jump_To_Tag(1)<CR>
    nnoremap <buffer> <silent> <2-LeftMouse> :call <SID>JavaBrowser_Jump_To_Tag(0)<CR>
    nnoremap <buffer> <silent> s :call <SID>JavaBrowser_Change_Sort()<CR>
    nnoremap <buffer> <silent> + :silent! foldopen<CR>
    nnoremap <buffer> <silent> - :silent! foldclose<CR>
    nnoremap <buffer> <silent> * :silent! %foldopen!<CR>
    nnoremap <buffer> <silent> <kPlus> :silent! foldopen<CR>
    nnoremap <buffer> <silent> <kMinus> :silent! foldclose<CR>
    nnoremap <buffer> <silent> <kMultiply> :silent! %foldopen!<CR>
    nnoremap <buffer> <silent> <Space> :call <SID>JavaBrowser_Show_Tag_Prototype()<CR>
    nnoremap <buffer> <silent> u :call <SID>JavaBrowser_Update_Window()<CR>
    nnoremap <buffer> <silent> x :call <SID>JavaBrowser_Zoom_Window()<CR>
    nnoremap <buffer> <silent> ? :call <SID>JavaBrowser_Show_Help()<CR>
    nnoremap <buffer> <silent> q :close<CR>

    " Map single left mouse click if the user wants this functionality
    if g:JavaBrowser_Use_SingleClick == 1
    nnoremap <silent> <LeftMouse> <LeftMouse>:if bufname("%") =~ "__JBrowser_List__"
                        \ <bar> call <SID>JavaBrowser_Jump_To_Tag(0) <bar> endif <CR>
    else
        if hasmapto('<LeftMouse>')
            nunmap <LeftMouse>
        endif
    endif

    " Define the autocommand to highlight the current tag
    augroup JavaBrowserAutoCmds
        autocmd!
        " Display the tag prototype for the tag under the cursor.
        autocmd CursorHold __JBrowser_List__ call s:JavaBrowser_Show_Tag_Prototype()
        " Highlight the current tag 
        "autocmd CursorHold * silent call <SID>JavaBrowser_Highlight_Tag(bufnr('%'), 
        "                                \ line('.'))
        " Adjust the Vim window width when taglist window is closed
        autocmd BufUnload __JBrowser_List__ call <SID>JavaBrowser_Close_Window()
        " Auto refresh the taglisting window
        autocmd BufEnter * call <SID>JavaBrowser_Refresh_Window()
    augroup end
endfunction

" JavaBrowser_Close_Window()
" Close the taglist window and adjust the Vim window width
function! s:JavaBrowser_Close_Window()
    " Remove the autocommands for the taglist window
    silent! autocmd! JavaBrowserAutoCmds

    if g:JavaBrowser_Use_Horiz_Window || g:JavaBrowser_Inc_Winwidth == 0 ||
                \ s:jbrowser_winsize_chgd == 0 ||
                \ &columns < (80 + g:JavaBrowser_WinWidth)
        " No need to adjust window width if horizontally split tag listing
        " window or if columns is less than 101 or if the user chose not to
        " adjust the window width
    else
        " Adjust the Vim window width
        let &columns= &columns - (g:JavaBrowser_WinWidth + 1)
    endif
endfunction

" JavaBrowser_IsInterface
" Checks if the passed variable exists as an interface in the open java file
" return 1 if an interface, 0 otherwise
function! s:JavaBrowser_IsInterface(bufnum, varname)
    let ftype = getbufvar(a:bufnum, '&filetype')
    "call s:JavaBrowser_Warning_Msg('interfaces: '.b:jbrowser_{ftype}_interface)
    if b:jbrowser_{ftype}_interface == ''
        return 0
    endif
    let l:allinterfaces = b:jbrowser_{ftype}_interface
    while l:allinterfaces != ''
        let l:iname = strpart(l:allinterfaces, 0, stridx(l:allinterfaces, "\n"))
        " Remove the line
        let l:allinterfaces = strpart(l:allinterfaces, stridx(l:allinterfaces, "\n") + 1)
        if iname == a:varname
            return 1
        endif
    endwhile
    return 0
endfunction

" JavaBrowser_Get_Visib_From_Proto
" Get the visibility of a class member from its prototype
function! s:JavaBrowser_Get_Visib_From_Proto(bufnum, proto)
    let l:visib = 'default'
    let ftype = getbufvar(a:bufnum, '&filetype')
    let l:visibstartidx = match(a:proto, '\a')
    let l:visibendidx = match(a:proto, '(', visibstartidx)
    if l:visibendidx == -1
        let l:visibendidx = match(a:proto, '$', visibstartidx)
    endif
    let l:tmp_proto = strpart(a:proto, l:visibstartidx, l:visibendidx-l:visibstartidx)
    while l:visibstartidx != -1
        let l:cur_proto_part = strpart(l:tmp_proto, 0, stridx(l:tmp_proto, " "))
        "call s:JavaBrowser_Warning_Msg('current proto part: '.l:cur_proto_part)
        if stridx(s:jbrowser_def_{ftype}_visibilities, l:cur_proto_part) != -1
            let l:visib = l:cur_proto_part
            break
        endif
        " Remove the word
        let l:tmp_proto = strpart(l:tmp_proto, stridx(l:tmp_proto, " ") + 1)
        let l:visibstartidx = match(l:tmp_proto, " ")
    endwhile
    return l:visib
endfunction

" JavaBrowser_Explore_File()
" List the tags defined in the specified file in a Vim window
function! s:JavaBrowser_Explore_File(bufnum)
    " Get the filename and file type
    let filename = fnamemodify(bufname(a:bufnum), ':p')
    let ftype = getbufvar(a:bufnum, '&filetype')

    " Check for valid filename and valid filetype
    if filename == '' || !filereadable(filename) || ftype == ''
        return
    endif

    " Make sure the current filetype is supported by exuberant ctags
    if stridx(s:jbrowser_file_types, ftype) == -1
        "call s:JavaBrowser_Warning_Msg('File type ' . ftype . ' not supported')
        return
    endif

    " If the tag types for this filetype are not yet created, then create
    " them now
    let var = 's:jbrowser_' . ftype . '_count'
    if !exists(var)
        call s:JavaBrowser_TagType_Init(ftype)
    endif

    " If the cached ctags output exists for the specified buffer, then use it.
    " Otherwise run ctags to get the output
    let valid_cache = getbufvar(a:bufnum, 'jbrowser_valid_cache')
    if valid_cache != ''
        " Load the cached processed tags output from the buffer local
        " variables
        let b:jbrowser_tag_count = getbufvar(a:bufnum, 'jbrowser_tag_count') + 0
        let i = 1
        while i <= b:jbrowser_tag_count
            let var_name = 'jbrowser_tag_' . i
            let b:jbrowser_tag_{i} =  getbufvar(a:bufnum, var_name)
            let i = i + 1
        endwhile

        let i = 1
        while i <= s:jbrowser_{ftype}_count
            let ttype = s:jbrowser_{ftype}_{i}_name
            "let var_name = 'jbrowser_' . ttype . '_start'
            "let b:jbrowser_{ftype}_{ttype}_start = 
            "            \ getbufvar(a:bufnum, var_name) + 0
            let var_name = 'jbrowser_' . ttype . '_count'
            let cnt = getbufvar(a:bufnum, var_name) + 0
            let b:jbrowser_{ftype}_{ttype}_count = cnt
            let var_name = 'jbrowser_' . ttype
            let l:jbrowser_{ftype}_{ttype} = getbufvar(a:bufnum, var_name)
            let j = 1
            while j <= cnt
                let var_name = 'jbrowser_' . ttype . '_' . j
                let b:jbrowser_{ftype}_{ttype}_{j} = getbufvar(a:bufnum, var_name)
                let j = j + 1
            endwhile
            let i = i + 1
        endwhile
    else
        " Exuberant ctags arguments to generate a tag list
        let ctags_args = ' -f - --format=2 --excmd=pattern --fields=nKs '

        " Form the ctags argument depending on the sort type 
        if b:jbrowser_sort_type == 'name'
            let ctags_args = ctags_args . ' --sort=yes '
        else
            let ctags_args = ctags_args . ' --sort=no '
        endif

        " Override count
        let l:override_cnt = 1

        " Add the filetype specific arguments
        let ctags_args = ctags_args . ' ' . s:jbrowser_{ftype}_ctags_args

        " Ctags command to produce output with regexp for locating the tags
        let ctags_cmd = g:JavaBrowser_Ctags_Cmd . ctags_args
        let ctags_cmd = ctags_cmd . ' "' . filename . '"'

        " Run ctags and get the tag list
        let cmd_output = system(ctags_cmd)

        " Cache the ctags output with a buffer local variable
        "call setbufvar(a:bufnum, 'jbrowser_valid_cache', 'Yes')
        call setbufvar(a:bufnum, 'jbrowser_sort_type', b:jbrowser_sort_type)

        " Handle errors
        if v:shell_error && cmd_output != ''
            "call s:JavaBrowser_Warning_Msg(cmd_output)
            return
        endif

        " No tags for current file
        if cmd_output == ''
            call s:JavaBrowser_Warning_Msg('No tags found for ' . filename)
            return
        endif

        " Initialize variables for the new filetype
        let i = 1
        while i <= s:jbrowser_{ftype}_count
            let ttype = s:jbrowser_{ftype}_{i}_name
            let b:jbrowser_{ftype}_{ttype} = ''
            let b:jbrowser_{ftype}_{ttype}_count = 0
            let i = i + 1
        endwhile

        " Process the ctags output one line at a time. Separate the tag output
        " based on the tag type and store it in the tag type variable
        let l:alltypes = ""
        let l:prefix = 'jbrowser_' . ftype
        while cmd_output != ''
            " Extract one line at a time
            let one_line = strpart(cmd_output, 0, stridx(cmd_output, "\n"))
            " Remove the line from the tags output
            let cmd_output = strpart(cmd_output, stridx(cmd_output, "\n") + 1)

            if one_line == ''
                " Line is not in proper tags format
                continue
            endif

            " Extract the tag type
            let ttype = s:JavaBrowser_Extract_Tagtype(one_line)

            let protostart = stridx(one_line, '^')
            let protoend = stridx(one_line, '$')
            let proto = strpart(one_line, protostart+1, protoend-protostart-1)
            let visib = s:JavaBrowser_Get_Visib_From_Proto(a:bufnum, proto)

            if ttype == ''
                " Line is not in proper tags format
                continue
            endif

            " Extract the tag name
            let ttxt = strpart(one_line, 0, stridx(one_line, "\t"))
            
            "call s:JavaBrowser_Warning_Msg('visibility for '.ttxt.' is "'.visib.'"')

            " Add the tag scope, if it is available. Tag scope is the last
            " field after the 'line:<num>\t' field
            let start = strridx(one_line, 'line:')
            let end = strridx(one_line, "\t")
            let lnnostart = strridx(one_line, 'line:')
            let lnnoend = strridx(one_line, "\t")
            let tscope = ''
            if end > start
                let lnno = strpart(one_line, lnnostart+5, lnnoend-lnnostart-5)
                let tscope = strpart(one_line, end + 1)
                let tscope = strpart(tscope, stridx(tscope, ':') + 1)
                "call s:JavaBrowser_Warning_Msg('scope for '.ttxt.' is '.tscope)
            else
                let lnno = strpart(one_line, lnnostart+5)
            endif
            
            " Check if the super type
            if stridx(s:jbrowser_def_{ftype}_super_tag_types, ttype) != -1
                " Check if the inner super type
                let l:temptxt = ttxt
                if tscope != ''
                    let l:temptxt = tscope . '.' . ttxt
                endif
                let b:jbrowser_{ftype}_{ttype} = b:jbrowser_{ftype}_{ttype} . l:temptxt . "\n"
                "call s:JavaBrowser_Warning_Msg('b:jbrowser_'.ftype.'_'.ttype.'='.b:jbrowser_{ftype}_{ttype})
                let l:{ttype}_{l:temptxt}_lineno = lnno
                let l:{ttype}_{l:temptxt}_lineno_proto = proto
                "call s:JavaBrowser_Warning_Msg('visibility for '.ttxt.' is '.visib)
                let l:{ttype}_{l:temptxt}_lineno_visib = ''
                if stridx(s:jbrowser_def_{ftype}_visibilities, visib) != -1
                    let l:{ttype}_{l:temptxt}_lineno_visib = visib
                endif
                if stridx(proto, ' abstract ') != -1
                    let l:{ttype}_{l:temptxt}_lineno_visib = l:{ttype}_{l:temptxt}_lineno_visib . '_abstract'
                    "call s:JavaBrowser_Warning_Msg('got abstarct='.proto)
                endif
                if stridx(proto, ' static ') != -1
                    let l:{ttype}_{l:temptxt}_lineno_visib = l:{ttype}_{l:temptxt}_lineno_visib . '_static'
                    "call s:JavaBrowser_Warning_Msg('got abstarct='.proto)
                endif
                " Cache result
                "let var_name = 'jbrowser_' . ftype . '_' . ttype
                "call setbufvar(a:bufnum, var_name, types)
                "call s:JavaBrowser_Warning_Msg('var name='.ttype.'_'.l:temptxt.'_lineno')
            else
                if tscope == ''
                    continue
                endif
                "call s:JavaBrowser_Warning_Msg('tscope before replacement of . with _'.tscope)
                let tscope = substitute(tscope, '\.', '_', 'g')
                "call s:JavaBrowser_Warning_Msg('tscope after replacement of . with _'.tscope)
                let l:thistype = tscope . '_' . ttype
                "call s:JavaBrowser_Warning_Msg('l:thistype='.l:thistype.' l:alltypes='.l:alltypes)
                if stridx(l:alltypes, l:thistype) == -1
                    let l:{tscope}_{ttype} = ''
                    let l:alltypes = l:alltypes . l:thistype . "\n"
                endif
                " Check for overriden methods
                let l:tmp_types = l:{tscope}_{ttype}
                while l:tmp_types != ''
                    let l:tmp_type = strpart(l:tmp_types, 0, stridx(l:tmp_types, "\n"))
                    " Remove the line
                    let l:tmp_types = strpart(l:tmp_types, stridx(l:tmp_types, "\n") + 1)
                    " Check if we encountered method with same name previously
                    if l:tmp_type == ttxt
                        let ttxt = ttxt . '__OVERRIDE__' . l:override_cnt
                        let l:override_cnt = l:override_cnt + 1
                        break
                    endif
                endwhile
                let l:{tscope}_{ttype} = l:{tscope}_{ttype} . ttxt . "\n"
                "call s:JavaBrowser_Warning_Msg('l:'.tscope.'_'.ttype.'='.l:{tscope}_{ttype})
                let l:{tscope}_{ttype}_{ttxt}_lineno = lnno
                let l:{tscope}_{ttype}_{ttxt}_lineno_proto = proto
                "call s:JavaBrowser_Warning_Msg('visibility for '.ttxt.' is '.visib)
                let l:{tscope}_{ttype}_{ttxt}_lineno_visib = ''
                if stridx(s:jbrowser_def_{ftype}_visibilities, visib) != -1
                    let l:{tscope}_{ttype}_{ttxt}_lineno_visib = visib
                endif
                if s:JavaBrowser_IsInterface(a:bufnum, tscope) == 1
                    if stridx(l:{tscope}_{ttype}_{ttxt}_lineno_visib, 'public') == -1
                        let l:{tscope}_{ttype}_{ttxt}_lineno_visib = l:{tscope}_{ttype}_{ttxt}_lineno_visib . 'public'
                    endif
                    if ttype == 'field'
                        let l:{tscope}_{ttype}_{ttxt}_lineno_visib = l:{tscope}_{ttype}_{ttxt}_lineno_visib . '_static'
                    endif
                    if ttype == 'method' && stridx(proto, 'abstract ') == -1
                        let l:{tscope}_{ttype}_{ttxt}_lineno_visib = l:{tscope}_{ttype}_{ttxt}_lineno_visib . '_abstract'
                    endif
                    "call s:JavaBrowser_Warning_Msg('got abstarct='.proto)
                endif
                if stridx(proto, 'abstract ') != -1
                    if stridx(l:{tscope}_{ttype}_{ttxt}_lineno_visib, 'abstract') == -1
                        let l:{tscope}_{ttype}_{ttxt}_lineno_visib = l:{tscope}_{ttype}_{ttxt}_lineno_visib . '_abstract'
                        "call s:JavaBrowser_Warning_Msg('got abstarct='.proto)
                    endif
                endif
                if stridx(proto, 'static ') != -1
                    if stridx(l:{tscope}_{ttype}_{ttxt}_lineno_visib, 'static') == -1
                        let l:{tscope}_{ttype}_{ttxt}_lineno_visib = l:{tscope}_{ttype}_{ttxt}_lineno_visib . '_static'
                        "call s:JavaBrowser_Warning_Msg('got abstarct='.proto)
                    endif
                endif
                "call s:JavaBrowser_Warning_Msg('l:'.tscope.'_'.ttype.'='.l:{tscope}_{ttype})
                "call s:JavaBrowser_Warning_Msg('l:{'.tscope.'}_{'.ttype.'}_{'.ttxt.'}_lineno='.lnno)
                "call s:JavaBrowser_Warning_Msg('var name='.tscope.'_'.ttype.'_'.ttxt.'_lineno')
            endif

            " Update the count of this tag type
            let cnt = b:jbrowser_{ftype}_{ttype}_count + 1
            let b:jbrowser_{ftype}_count = cnt

        endwhile

        " Cache the processed tags output using buffer local variables
        call setbufvar(a:bufnum, 'jbrowser_tag_count', b:jbrowser_tag_count)
        let i = 1
        while i <= b:jbrowser_tag_count
            let var_name = 'jbrowser_tag_' . i
            call setbufvar(a:bufnum, var_name, b:jbrowser_tag_{i})
            let i = i + 1
        endwhile

        let i = 1
        while i <= s:jbrowser_{ftype}_count
            let ttype = s:jbrowser_{ftype}_{i}_name
            let types = b:jbrowser_{ftype}_{ttype}
            if types != ''
                let var_name = 'jbrowser_' . ftype . '_' . ttype
                call setbufvar(a:bufnum, var_name, types)
            endif
            let i = i + 1
        endwhile
    endif

    " Set report option to a huge value to prevent informational messages
    " while adding lines to the taglist window
    let old_report = &report
    set report=99999

    " Mark the buffer as modifiable
    setlocal modifiable

    let i = 1
    let l:ttype_put = ''
    while i <= s:jbrowser_{ftype}_count
        let ttype = s:jbrowser_{ftype}_{i}_name
        " Add the tag type only if there are tags for that type
        if b:jbrowser_{ftype}_{ttype} != ''
            let l:ttype_start = line('.')
            " Put package, class interface etc
            if stridx(l:ttype_put, ttype) == -1
                silent! put =ttype
                " Syntax highlight the tag type names
                if has('syntax')
                    exe 'syntax match JavaBrowserType /^' . ttype . '$/'
                endif
                let l:ttype_put = l:ttype_put . ttype
            endif
            let l:types = b:jbrowser_{ftype}_{ttype}
            while l:types != ''
                let l:type = strpart(l:types, 0, stridx(l:types, "\n"))
                " Remove the line
                let l:types = strpart(l:types, stridx(l:types, "\n") + 1)
                let l:type_start = line('.')
                let b:line_no_{l:type_start} = l:{l:ttype}_{l:type}_lineno
                let b:line_no_{l:type_start}_proto = l:{l:ttype}_{l:type}_lineno_proto
                "call s:JavaBrowser_Warning_Msg('b:line_no_{'.l:type_start.'}:'.l:{l:ttype}_{l:type}_lineno)
                " Put actual class/package name etc
                silent! put ='  '.l:type
                " Syntax highlight the tag type names
                if has('syntax')
                    exe 'syntax match JavaBrowserId /^' . '  '.l:type . '$/'
                endif
                "while stridx(l:type, ".") > 0
                "    let l:type = strpart(l:type, stridx(l:type, ".") + 1)
                "endwhile
                let l:type = substitute(l:type, '\.', '_', 'g')
                let j = 1
                while j <= s:jbrowser_{ftype}_count
                    let l:curr_sub_type = s:jbrowser_{ftype}_{j}_name
                let l:type_sub_type = l:type . '_' . l:curr_sub_type
                    " Extract one line at a time
                    "call s:JavaBrowser_Warning_Msg('l:type_sub_type='.l:type_sub_type.' l:alltypes='.l:alltypes)
                    if stridx(l:alltypes, l:type_sub_type) != -1
                        "let l:curr_sub_type = strpart(l:type_sub_type, stridx(l:type_sub_type, "_") + 1)
                        let l:type_sub_type_start = line('.')
                        silent! put ='    ' . l:curr_sub_type
                        " Syntax highlight the tag type names
                        if has('syntax')
                            exe 'syntax match JavaBrowserTitle /^' . '    ' . l:curr_sub_type . '$/'
                        endif
                        while l:{type_sub_type} != ''
                            let one_val = strpart(l:{type_sub_type}, 0, stridx(l:{type_sub_type}, "\n"))
                            " Remove the line
                            let l:{type_sub_type} = strpart(l:{type_sub_type}, stridx(l:{type_sub_type}, "\n") + 1)
                            let l:curr_line = line('.')
                            let b:line_no_{l:curr_line} = l:{l:type_sub_type}_{one_val}_lineno
                            let b:line_no_{l:curr_line}_proto = l:{l:type_sub_type}_{one_val}_lineno_proto
                            let l:tmpvarname = 'l:'.l:type_sub_type.'_'.one_val.'_lineno_visib'
                            let l:subtype_val = one_val
                            let l:override_idx = stridx(one_val, '__OVERRIDE__')
                            if l:override_idx != -1
                                let l:subtype_val = strpart(one_val, 0, l:override_idx)
                            endif
                            silent! put ='      ' . l:subtype_val
                            if exists(l:tmpvarname)
                                let b:line_no_{l:curr_line}_visib = l:{l:type_sub_type}_{one_val}_lineno_visib
                                let l:syntaxGrp = 'JavaBrowser'
                                if stridx(b:line_no_{l:curr_line}_visib, '_') == 0
                                    let l:syntaxGrp = l:syntaxGrp . b:line_no_{l:curr_line}_visib
                                else
                                    let l:syntaxGrp = l:syntaxGrp . '_' . b:line_no_{l:curr_line}_visib
                                endif
                                if has('syntax')
                                    exe 'syntax match ' . l:syntaxGrp . ' /' . one_val . '$/'
                                endif
                            endif
                        endwhile
                        " create a fold for this tag type
                        if has('folding')
                            let fold_start = l:type_sub_type_start+1
                            let fold_end = line('.')
                            exe fold_start . ',' . fold_end  . 'fold'
                        endif
                    endif
                    let j = j + 1
                endwhile
                " create a fold for this tag type
                if has('folding')
                    let fold_start = l:type_start+1
                    let fold_end = line('.')
                    exe fold_start . ',' . fold_end  . 'fold'
                endif
            endwhile
            " create a fold for this tag type
            if has('folding')
                let fold_start = l:ttype_start+1
                let fold_end = line('.')
                exe fold_start . ',' . fold_end  . 'fold'
                exe 'normal ' . fold_start . 'G'
                exe 'normal zo'
                exe 'normal ' . fold_end . 'G'
            endif
            " Separate the tag types with a empty line
            normal! G
            if g:JavaBrowser_Compact_Format == 0
                silent! put =''
            endif
        endif
        let i = i + 1
    endwhile

    " Mark the buffer as not modifiable
    setlocal nomodifiable

    " Restore the report option
    let &report = old_report

    " Goto the first line in the buffer
    go

    return
endfunction

" JavaBrowser_Toggle_Window()
" Open or close a taglist window
function! s:JavaBrowser_Toggle_Window(bufnum)
    let curline = line('.')

    " Tag list window name
    let bname = '__JBrowser_List__'

    " If taglist window is open then close it.
    let winnum = bufwinnr(bname)
    if winnum != -1
        if winnr() == winnum
            " Already in the taglist window. Close it and return
            close
        else
            " Goto the taglist window, close it and then come back to the
            " original window
            let curbufnr = bufnr('%')
            exe winnum . 'wincmd w'
            close
            " Need to jump back to the original window only if we are not
            " already in that window
            let winnum = bufwinnr(curbufnr)
            if winnr() != winnum
                exe winnum . 'wincmd w'
            endif
        endif
        return
    endif

    " Check if JavaBrowser is requested for a java file or not
    if &filetype !=# 'java'
        call s:JavaBrowser_Warning_Msg('File type "' . &filetype . '" not supported. Only supported file types are: "java"')
        return
    endif

    " Open the taglist window
    call s:JavaBrowser_Open_Window()

    " Initialize the taglist window
    call s:JavaBrowser_Init_Window(a:bufnum)

    " List the tags defined in a file
    call s:JavaBrowser_Explore_File(a:bufnum)

    " Highlight the current tag
    "call s:JavaBrowser_Highlight_Tag(a:bufnum, curline)

    " Go back to the original window
    let s:JavaBrowser_Skip_Refresh = 1
    wincmd p
    let s:JavaBrowser_Skip_Refresh = 0
endfunction

" JavaBrowser_Extract_Tagtype
" Extract the tag type from the tag text
function! s:JavaBrowser_Extract_Tagtype(tag_txt)
    " The tag type is after the tag prototype field. The prototype field
    " ends with the /;"\t string. We add 4 at the end to skip the characters
    " in this special string..
    let start = strridx(a:tag_txt, '/;"' . "\t") + 4
    let end = strridx(a:tag_txt, 'line:') - 1
    let ttype = strpart(a:tag_txt, start, end - start)

    " Replace all space characters in the tag type with underscore (_)
    let ttype = substitute(ttype, ' ', '_', 'g')

    return ttype
endfunction

" JavaBrowser_Refresh_Window()
" Refresh the taglist window
function! s:JavaBrowser_Refresh_Window()
    " We are entering the buffer from one of the taglist functions. So no need
    " to refresh the taglist window again
    if s:JavaBrowser_Skip_Refresh == 1
        return
    endif

    " If the buffer doesn't support tag listing, skip it
    if s:JavaBrowser_Skip_Buffer(bufnr('%'))
        return
    endif

    let filename = expand('%:p')

    let curline = line('.')

    " Tag list window name
    let bname = '__JBrowser_List__'

    " Make sure the taglist window is open. Otherwise, no need to refresh
    let winnum = bufwinnr(bname)
    if winnum == -1
        return
    endif

    let bno = bufnr(bname)

    let cur_bufnr = bufnr('%')

    " If the tag listing for the current window is already present, no need to
    " refresh it
    if getbufvar(bno, 'jbrowser_bufnum') == cur_bufnr && 
                \ getbufvar(bno, 'jbrowser_bufname') == filename
        return
    endif

    " Save the current window number
    let cur_winnr = winnr()

    call s:JavaBrowser_Open_Window()

    call s:JavaBrowser_Init_Window(cur_bufnr)

    " Update the taglist window
    call s:JavaBrowser_Explore_File(cur_bufnr)

    " Highlight the current tag
    "call s:JavaBrowser_Highlight_Tag(cur_bufnr, curline)

    " Refresh the taglist window
    redraw

    " Jump back to the original window
    exe cur_winnr . 'wincmd w'
endfunction

" JavaBrowser_Change_Sort()
" Change the sort order of the tag listing
function! s:JavaBrowser_Change_Sort()
    if !exists('b:jbrowser_bufnum') || !exists('b:jbrowser_ftype')
        return
    endif

    let sort_type = getbufvar(b:jbrowser_bufnum, 'jbrowser_sort_type')

    " Toggle the sort order from 'name' to 'order' and vice versa
    if sort_type == 'name'
        call setbufvar(b:jbrowser_bufnum, 'jbrowser_sort_type', 'order')
    else
        call setbufvar(b:jbrowser_bufnum, 'jbrowser_sort_type', 'name')
    endif

    " Save the current line for later restoration
    let curline = '\V\^' . getline('.') . '\$'

    " Clear out the cached taglist information
    call setbufvar(b:jbrowser_bufnum, 'jbrowser_valid_cache', '')

    call s:JavaBrowser_Open_Window()

    call s:JavaBrowser_Init_Window(b:jbrowser_bufnum)

    call s:JavaBrowser_Explore_File(b:jbrowser_bufnum)

    " Go back to the tag line before the list is sorted
    call search(curline, 'w')
endfunction

" JavaBrowser_Update_Window()
" Update the window by regenerating the tag list
function! s:JavaBrowser_Update_Window()
    if !exists('b:jbrowser_bufnum') || !exists('b:jbrowser_ftype')
        return
    endif

    " Save the current line for later restoration
    let curline = '\V\^' . getline('.') . '\$'

    " Clear out the cached taglist information
    call setbufvar(b:jbrowser_bufnum, 'jbrowser_valid_cache', '')

    call s:JavaBrowser_Open_Window()

    call s:JavaBrowser_Init_Window(b:jbrowser_bufnum)

    " Update the taglist window
    call s:JavaBrowser_Explore_File(b:jbrowser_bufnum)

    " Go back to the tag line before the list is sorted
    call search(curline, 'w')
endfunction

function! s:JavaBrowser_Highlight_Tagline()
    " Clear previously selected name
    match none

    " Highlight the current selected name
    if g:JavaBrowser_Display_Prototype == 0
        exe 'match TagName /\%' . line('.') . 'l\s\+\zs.*/'
    else
        exe 'match TagName /\%' . line('.') . 'l.*/'
    endif
endfunction

" JavaBrowser_Jump_To_Tag()
" Jump to the location of the current tag
function! s:JavaBrowser_Jump_To_Tag(new_window)
    " Do not process comment lines and empty lines
    let curline = getline('.')
    if curline == '' || curline[0] == '"'
        return
    endif
    let l:lineno = line('.')
    let l:lineno = l:lineno - 1

    let s:JavaBrowser_Skip_Refresh = 1

    " Highlight the tagline
    call s:JavaBrowser_Highlight_Tagline()

    " If inside a fold, then don't try to jump to the tag
    if foldclosed('.') != -1
        return
    endif
    let l:varname = 'b:line_no_' . l:lineno
    if exists(l:varname)
        let l:bufflineno = b:line_no_{l:lineno}
        
        let winnum = bufwinnr(b:jbrowser_bufnum)
        exe winnum . 'wincmd w'
        exe 'normal ' . l:bufflineno . 'G'
        " Bring the line to the middle of the window
        normal! z.

        " If the line is inside a fold, open the fold
        if has('folding')
            if foldlevel('.') != 0
                normal zo
            endif
        endif
    endif

    " Highlight the tagline
    call s:JavaBrowser_Highlight_Tagline()

    let s:JavaBrowser_Skip_Refresh = 0
endfunction

" JavaBrowser_Show_Tag_Prototype()
" Display the prototype of the tag under the cursor
function! s:JavaBrowser_Show_Tag_Prototype()
    " If we have already display prototype in the tag window, no need to
    " display it in the status line
    if g:JavaBrowser_Display_Prototype == 1
        return
    endif

    " Clear the previously displayed line
    echo

    " Do not process comment lines and empty lines
    let curline = getline('.')
    if curline == '' || curline[0] == '"'
        return
    endif

    " If inside a fold, then don't display the prototype
    if foldclosed('.') != -1
        return
    endif

    let l:lineno = line('.')
    let l:lineno = l:lineno - 1
    let l:varname = 'b:line_no_' . l:lineno . '_proto'
    if exists(l:varname)
        echo b:line_no_{l:lineno}_proto
    endif
endfunction

" JavaBrowser_Locate_Tag_Text
" Locate the tag text given the line number in the source window
function! s:JavaBrowser_Locate_Tag_Text(sort_type, linenum)
    let left = 1
    let right = b:jbrowser_tag_count

    if a:sort_type == 'order'
        " Tag list sorted by order, do a binary search comparing the line
        " numbers

        " If the current line is the less than the first tag, then no need to
        " search
        let txt = b:jbrowser_tag_1
        let start = strridx(txt, 'line:') + strlen('line:')
        let end = strridx(txt, "\t")
        if end < start
            let first_lnum = strpart(txt, start) + 0
        else
            let first_lnum = strpart(txt, start, end - start) + 0
        endif

        if a:linenum < first_lnum
            return ""
        endif

        while left < right
            let middle = (right + left + 1) / 2
            let txt = b:jbrowser_tag_{middle}

            let start = strridx(txt, 'line:') + strlen('line:')
            let end = strridx(txt, "\t")
            if end < start
                let middle_lnum = strpart(txt, start) + 0
            else
                let middle_lnum = strpart(txt, start, end - start) + 0
            endif

            if middle_lnum == a:linenum
                let left = middle
                break
            endif

            if middle_lnum > a:linenum
                let right = middle - 1
            else
                let left = middle
            endif
        endwhile
    else
        " sorted by name, brute force method (Dave Eggum)
        let closest_lnum = 0
        let final_left = 0
        while left < right
            let txt = b:jbrowser_tag_{left}

            let start = strridx(txt, 'line:') + strlen('line:')
            let end = strridx(txt, "\t")
            if end < start
                let lnum = strpart(txt, start) + 0
            else
                let lnum = strpart(txt, start, end - start) + 0
            endif

            if lnum < a:linenum && lnum > closest_lnum
                let closest_lnum = lnum
                let final_left = left
            elseif lnum == a:linenum
                let closest_lnum = lnum
                break
            else
                let left = left + 1
            endif
        endwhile
        if closest_lnum == 0
            return ""
        endif
        if left == right
            let left = final_left
        endif
    endif

    return b:jbrowser_tag_{left}
endfunction

" Define tag listing autocommand to automatically open the taglist window on
" Vim startup
if g:JavaBrowser_Auto_Open
    autocmd VimEnter * nested JavaBrowser
endif


" Define the 'JavaBrowser' and user commands to open/close taglist
" window
command! -nargs=0 JavaBrowser call s:JavaBrowser_Toggle_Window(bufnr('%'))
