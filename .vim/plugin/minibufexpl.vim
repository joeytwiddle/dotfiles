"=============================================================================
"    Copyright: Copyright (C) 2002 & 2003 Bindu Wavell 
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               minibufexplorer.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damamges
"               resulting from the use of this software.
"
" Name Of File: minibufexpl.vim
"  Description: Mini Buffer Explorer Vim Plugin
"   Maintainer: Bindu Wavell <bindu@wavell.net>
"          URL: http://vim.sourceforge.net/scripts/script.php?script_id=159
"  Last Change: Friday, March 28, 2003
"      Version: 6.2.4
"               Derived from Jeff Lanzarotta's bufexplorer.vim version 6.0.7
"               Jeff can be reached at (jefflanzarotta@yahoo.com) and the
"               original plugin can be found at:
"               http://lanzarotta.tripod.com/vim/plugin/6/bufexplorer.vim.zip
"
"        Usage: Normally, this file should reside in the plugins
"               directory and be automatically sourced. If not, you must
"               manually source this file using ':source minibufexplorer.vim'.
"
"               You may use the default keymappings of
"
"                 <Leader>mbe - Opens MiniBufExplorer
"
"               or you may want to add something like the following
"               key mapping to your _vimrc/.vimrc file.
"
"                 map <Leader>b :MiniBufExplorer<cr>
"
"               However, in most cases you won't need any key-bindings at all.
"
"               <Leader> is usually backslash so type "\mbe" (quickly) to open 
"               the -MiniBufExplorer- window.
"
"               To control where the new split window goes relative to the 
"               current window, use the setting:
"
"                 let g:miniBufExplSplitBelow=0  " Put new window above
"                                                " current.
"                 let g:miniBufExplSplitBelow=1  " Put new window below
"                                                " current.
"
"               The default for this is read from the &splitbelow VIM option.
"
"               By default we are now (as of 6.0.2) forcing the -MiniBufExplorer-
"               window to open up at the edge of the screen. You can turn this 
"               off by setting the following variable in your .vimrc:
"
"                 let g:miniBufExplSplitToEdge = 0
"
"               It is now (as of 6.1.1) possible to set a maximum height for
"               the -MiniBufExplorer- window. You can set the max height by
"               letting the following variable in your .vimrc:
"
"                 let g:miniBufExplMaxHeight = <max lines: defualt 0>
"
"               setting this to 0 will mean the window gets as big as
"               needed to fit all your buffers.
"
"               As of 6.2.2 it is possible to set a minimum height for the 
"               -MiniBufExplorer- window. You can set the min height by
"               letting the following variable in your .vimrc:
"
"                 let g:miniBufExplMinHeight = <min height: default 1>
"
"               By default we are now (as of 6.0.1) turning on the MoreThanOne
"               option. This stops the -MiniBufExplorer- from opening 
"               automatically until more than one eligible buffer is available.
"               You can turn this feature off by setting the following variable
"               in your .vimrc:
"                 
"                 let g:miniBufExplorerMoreThanOne=1
"
"               (The following enhancement is as of 6.2.2)
"               Setting this to 0 will cause the MBE window to be loaded even
"               if no buffers are available. Setting it to 1 causes the MBE
"               window to be loaded as soon as an eligible buffer is read. You
"               can also set it to larger numbers. So if you set it to 4 for
"               example the MBE window wouldn't auto-open until 4 eligibles
"               buffers had been loaded. This is nice for folks that don't 
"               want an MBE window unless they are editing more than 2 or
"               three buffers.
"
"               To enable the optional mapping of Control + Vim Direction Keys 
"               [hjkl] to window movement commands, you can put the following into 
"               your .vimrc:
"
"                 let g:miniBufExplMapWindowNavVim = 1
"
"               To enable the optional mapping of Control + Arrow Keys to window 
"               movement commands, you can put the following into your .vimrc:
"
"                 let g:miniBufExplMapWindowNavArrows = 1
"
"               To enable the optional mapping of <C-TAB> and <C-S-TAB> to a 
"               function that will bring up the next or previous buffer in the
"               current window, you can put the following into your .vimrc:
"
"                 let g:miniBufExplMapCTabSwitchBufs = 1
"
"               To enable the optional mapping of <C-TAB> and <C-S-TAB> to mappings
"               that will move to the next and previous (respectively) window, you
"               can put the following into your .vimrc:
"
"                 let g:miniBufExplMapCTabSwitchWindows = 1
"
"
"               NOTE: If you set the ...TabSwitchBufs AND ...TabSwitchWindows, 
"                     ...TabSwitchBufs will be enabled and ...TabSwitchWindows 
"                     will not.
"
"               MBE has had a basic debugging capability for quite some time.
"               However, it has not been very friendly in the past. As of 6.0.8, 
"               you can put one of each of the following into your .vimrc:
"
"                 let g:miniBufExplorerDebugLevel = 0  " MBE serious errors output
"                 let g:miniBufExplorerDebugLevel = 4  " MBE all errors output
"                 let g:miniBufExplorerDebugLevel = 10 " MBE reports everything
"
"                 let g:miniBufExplorerDebugMode  = 0  " Errors will show up in 
"                                                      " a vim window
"                 let g:miniBufExplorerDebugMode  = 1  " Uses VIM's echo function
"                                                      " to display on the screen
"                 let g:miniBufExplorerDebugMode  = 2  " Writes to a file
"                                                      " MiniBufExplorer.DBG
"                 let g:miniBufExplorerDebugMode  = 3  " Store output in global:
"                                                 " g:miniBufExplorerDebugOutput
"
"               Or if you are able to start VIM, you might just perform these
"               at a command prompt right before you do the operation that is
"               failing.
"
" Known Issues: When debugging is turned on and set to output to a window, there
"               are some cases where the window is opened more than once, there
"               are other cases where an old debug window can be lost.
"
"      History: 6.2.4 o Because of the autocommand switch (see 6.2.0) it 
"                       was possible to remove the restriction on the
"                       :set hidden option. It is now possible to use
"                       this option with MBE.
"               6.2.3 o Added miniBufExplTabWrap option. It is turned 
"                       off by default. When turned on spaces are added
"                       between tabs and gq} is issued to perform line
"                       formatting. This won't work very well if filenames
"                       contain spaces. It would be pretty easy to write
"                       my own formatter, but I'm too lazy, so if someone
"                       really needs that feature I'll add it :)
"               6.2.2 o Changed the way the g:miniBufExplorerMoreThanOne
"                       global is handled. You can set this to the number
"                       of eligible buffers you want to be loaded before
"                       the MBE window is loaded. Setting it to 0 causes
"                       the MBE window to be opened even if there are no
"                       buffers. Setting it to 4 causes the window to stay
"                       closed until the 4th eligible buffer is loaded.
"                     o Added a MinHeight option. This is nice if you want
"                       the MBE window to always take the same amount of
"                       space. For example set MaxHeight and MinHeight to 2
"                       and set MoreThanOne to 0 and you will always have
"                       a 2 row (plus the ruler :) MBE window.
"                     o I now setlocal foldcomun=0 and nonumber in the MBE 
"                       window. This is for those of you that like to have
"                       these options turned on locally. I'm assuming noone
"                       outthere wants foldcolumns and line numbers in the
"                       MBE window? :)
"                     o Fixed a bug where an empty MBE window was taking half
"                       of the screen (partly why the MinHeight option was 
"                       added.)
"               6.2.1 o If MBE is the only window (because of :bd for example)
"                       and there are still eligible buffers then one of them
"                       will be displayed.
"                     o The <Leader>mbe mapping now highlights the buffer from
"                       the current window.
"                     o The delete ('d') binding in the MBE window now restors
"                       the cursor position, which can help if you want to 
"                       delete several buffers in a row that are not at the
"                       beginning of the buffer list.
"                     o Added a new key binding ('p') in the MBE window to 
"                       switch to the previous window (last edit window)
"               6.2.0 o Major overhaul of autocommand and list updating code,
"                       we now have much better handling of :bd (which is the 
"                       most requested feature.) As well as resolving other
"                       issues where the buffer list would not be updated
"                       automatically. The old version tried to trap specific
"                       events, this one just updates frequently, but it keeps
"                       track and only changes the screen if there has been
"                       a change.
"                     o Added g:miniBufExplMaxHeight variable so you can keep
"                       the -MiniBufExplorer- window small when you have lots
"                       of buffers (or buffers with long names :)
"                     o Improvement to internal syntax highlighting code
"                       I renamed the syntax group names. Anyone who has 
"                       figured out how to use them already shouldn't have
"                       any trouble with the new Nameing :)
"                     o Added debug mode 3 which writes to a global variable
"                       this is fast and doesn't mess with the buffer/window
"                       lists.
"               6.1.0 o <Leader>mbc was failing because I was calling one of
"                       my own functions with the wrong number of args. :(
"                       Thanks to Gerry Patterson for finding this!
"                       This code is very stable (although it has some
"                       idiocyncracies.)
"               6.0.9 o Double clicking tabs was overwriting the cliboard 
"                       register on MS Windows.  Thanks to Shoeb Bhinderwala 
"                       for reporting this issue.
"               6.0.8 o Apparently some VIM builds are having a hard time with
"                       line continuation in scripts so the few that were here
"                       have been removed.
"                     o Generalized FindExplorer and FindCreateExplorer so
"                       that they can be used for the debug window. Renaming
"                       to FindWindow and FindCreateWindow.
"                     o Updated debugging code so that debug output is put into
"                       a buffer which can then be written to disk or emailed
"                       to me when someone is having a major issue. Can also
"                       write directly to a file (VERY SLOWLY) on UNIX or Win32
"                       (not 95 or 98 at the moment) or use VIM's echo function 
"                       to display the output to the screen.
"                     o Several people have had issues when the hidden option 
"                       is turned on. So I have put in several checks to make
"                       sure folks know this if they try to use MBE with this
"                       option set.
"               6.0.7 o Handling BufDelete autocmd so that the UI updates 
"                       properly when using :bd (rather than going through 
"                       the MBE UI.)
"                     o The AutoUpdate code will now close the MBE window when 
"                       there is a single eligible buffer available.
"                       This has the usefull side effect of stopping the MBE
"                       window from blocking the VIM session open when you close 
"                       the last buffer.
"                     o Added functions, commands and maps to close & update
"                       the MBE window (<leader>mbc and <leader>mbu.)
"                     o Made MBE open/close state be sticky if set through
"                       StartExplorer(1) or StopExplorer(1), which are 
"                       called from the standard mappings. So if you close
"                       the mbe window with \mbc it won't be automatically 
"                       opened again unless you do a \mbe (or restart VIM).
"                     o Removed spaces between "tabs" (even more mini :)
"                     o Simplified MBE tab processing 
"               6.0.6 o Fixed register overwrite bug found by Sébastien Pierre
"               6.0.5 o Fixed an issue with window sizing when we run out of 
"                       buffers.  
"                     o Fixed some weird commenting bugs.  
"                     o Added more optional fancy window/buffer navigation:
"                     o You can turn on the capability to use control and the 
"                       arrow keys to move between windows.
"                     o You can turn on the ability to use <C-TAB> and 
"                       <C-S-TAB> to open the next and previous (respectively) 
"                       buffer in the current window.
"                     o You can turn on the ability to use <C-TAB> and 
"                       <C-S-TAB> to switch windows (forward and backwards 
"                       respectively.)
"               6.0.4 o Added optional fancy window navigation: 
"                     o Holding down control and pressing a vim direction 
"                       [hjkl] will switch windows in the indicated direction.
"               6.0.3 o Changed buffer name to -MiniBufExplorer- to resolve
"                       Issue in filename pattern matching on Windows.
"               6.0.2 o 2 Changes requested by Suresh Govindachar:
"                     o Added SplitToEdge option and set it on by default
"                     o Added tab and shift-tab mappings in [MBE] window
"               6.0.1 o Added MoreThanOne option and set it on by default
"                       MiniBufExplorer will not automatically open until
"                       more than one eligible buffers are opened. This
"                       reduces cluter when you are only working on a
"                       single file. 
"                       NOTE: See 6.2.2 for more details about this feature
"               6.0.0 o Initial Release on November 20, 2001
"
"         Todo: Provide better support for user defined syntax highlighting
"               This is improved as of 6.1.1 but it's still not perfect.
"         Todo: Add the ability to specify a regexp for eligible buffers
"               allowing the ability to filter out certain buffers that 
"               you don't want to control from MBE
"
"=============================================================================

"
" Has this plugin already been loaded?
"
if exists('loaded_minibufexplorer')
  call <SID>DEBUG('MiniBufExplorer already loaded!', 5)
  finish
endif
let loaded_minibufexplorer = 1
let s:debugIndex = 0

" 
" If we don't already have a keyboard
" mapping for mbe then create one.
" 
if !hasmapto('<Plug>MiniBufExplorer')
  map <unique> <Leader>mbe <Plug>MiniBufExplorer
endif
if !hasmapto('<Plug>CMiniBufExplorer')
  map <unique> <Leader>mbc <Plug>CMiniBufExplorer
endif
if !hasmapto('<Plug>UMiniBufExplorer')
  map <unique> <Leader>mbu <Plug>UMiniBufExplorer
endif

" 
" Setup <Script> internal map.
" 
noremap <unique> <script> <Plug>MiniBufExplorer  :call <SID>StartExplorer(1, -1)<CR>:<BS>
noremap <unique> <script> <Plug>CMiniBufExplorer :call <SID>StopExplorer(1)<CR>:<BS>
noremap <unique> <script> <Plug>UMiniBufExplorer :call <SID>AutoUpdate(-1)<CR>:<BS>

" 
" Create command mbe command.
" 
if !exists(':MiniBufExplorer')
  command! MiniBufExplorer :call <SID>StartExplorer(1, -1)
endif
if !exists(':CMiniBufExplorer')
  command! CMiniBufExplorer :call <SID>StopExplorer(1, -1)
endif
if !exists(':UMiniBufExplorer')
  command! UMiniBufExplorer :call <SID>AutoUpdate(-1)
endif

"
" Debug Level
"
" 0 = no logging
" 1=5 = errors ; 1 is the most important
" 5-9 = info ; 5 is the most important
" 10 = Entry/Exit
if !exists('g:miniBufExplorerDebugLevel')
  let g:miniBufExplorerDebugLevel = 0 
endif

"
" Debug Mode
"
" 0 = debug to a window
" 1 = use vim's echo facility
" 2 = write to a file named MiniBufExplorer.DBG
"     in the directory where vim was started
"     THIS IS VERY SLOW
if !exists('g:miniBufExplorerDebugMode')
  let g:miniBufExplorerDebugMode = 0 
endif

"
" Allow auto update?
"
" We start out with this off for startup, but once vim is running we 
" turn this on.
if !exists('g:miniBufExplorerAutoUpdate')
  let g:miniBufExplorerAutoUpdate = 0
endif

"
" Display Mini Buf Explorer when there are 'More Than One' eligible buffers
"
if !exists('g:miniBufExplorerMoreThanOne')
  let g:miniBufExplorerMoreThanOne = 2
endif

"
" When opening a new -MiniBufExplorer- window, split the new windows below or 
" above the current window?  1 = below, 0 = above.
"
if !exists('g:miniBufExplSplitBelow')
  let g:miniBufExplSplitBelow = &splitbelow
endif

"
" When opening a new -MiniBufExplorer- window, split the new windows to the
" full edge? 1 = yes, 0 = no.
"
if !exists('g:miniBufExplSplitToEdge')
  let g:miniBufExplSplitToEdge = 1
endif

"
" When sizing the -MiniBufExplorer- window, assign a maximum window height.
" 0 = size to fit all buffers, otherwise the value is number of lines for
" buffer.
"
if !exists('g:miniBufExplMaxHeight')
  let g:miniBufExplMaxHeight = 0
endif

"
" When sizing the -MiniBufExplorer- window, assign a minumum window height.
" the value is minimum number of lines for buffer. Setting this to zero can
" cause strange height behavior. The default value is 1
"
if !exists('g:miniBufExplMinHeight')
  let g:miniBufExplMinHeight = 1
endif

"
" By default line wrap is used (possibly breaking a tab name between two
" lines.) Turning this option on (setting it to 1) can take more screen
" space, but will make sure that each tab is on one and only one line.
"
if !exists('g:miniBufExplTabWrap')
  let g:miniBufExplTabWrap = 0
endif

"
" Global flag to turn extended window navigation commands on or off
" enabled = 1, dissabled = 0
"
if !exists('g:miniBufExplMapWindowNav')
  " This is for backwards compatibility and may be removed in a
  " later release, please use the ...NavVim and/or ...NavArrows 
  " settings.
  let g:miniBufExplMapWindowNav = 0
endif
if !exists('g:miniBufExplMapWindowNavVim')
  let g:miniBufExplMapWindowNavVim = 0
endif
if !exists('g:miniBufExplMapWindowNavArrows')
  let g:miniBufExplMapWindowNavArrows = 0
endif
if !exists('g:miniBufExplMapCTabSwitchBufs')
  let g:miniBufExplMapCTabSwitchBufs = 0
endif
" Notice: that if CTabSwitchBufs is turned on then
" we turn off CTabSwitchWindows.
if g:miniBufExplMapCTabSwitchBufs == 1 || !exists('g:miniBufExplMapCTabSwitchWindows')
  let g:miniBufExplMapCTabSwitchWindows = 0
endif

" Global used to store the buffer list so we don't update the
" UI unless the list has changed.
if !exists('g:miniBufExplBufList')
  let g:miniBufExplBufList = ''
endif

" Variable used as a mutex so that we don't do lots
" of AutoUpdates at the same time.
if !exists('g:miniBufExplInAutoUpdate')
  let g:miniBufExplInAutoUpdate = 0
endif

" In debug mode 3 this variable will hold the debug output
if !exists('g:miniBufExplorerDebugOutput')
  let g:miniBufExplorerDebugOutput = ''
endif

" In debug mode 3 this variable will hold the debug output
if !exists('g:miniBufExplForceDisplay')
  let g:miniBufExplForceDisplay = 0
endif

"
" If we have enabled control + vim direction key remapping
" then perform the remapping
"
" Notice: I left g:miniBufExplMapWindowNav in for backward
" compatibility. Eventually this mapping will be removed so
" please use the newer g:miniBufExplMapWindowNavVim setting.
if g:miniBufExplMapWindowNavVim || g:miniBufExplMapWindowNav
  noremap <C-J> <C-W>j
  noremap <C-K> <C-W>k
  noremap <C-H> <C-W>h
  noremap <C-L> <C-W>l
endif

"
" If we have enabled control + arrow key remapping
" then perform the remapping
"
if g:miniBufExplMapWindowNavArrows
  noremap <C-Down>  <C-W>j
  noremap <C-Up>    <C-W>k
  noremap <C-Left>  <C-W>h
  noremap <C-Right> <C-W>l
endif

" If we have enabled <C-TAB> and <C-S-TAB> to switch buffers
" in the current window then perform the remapping
"
if g:miniBufExplMapCTabSwitchBufs
  noremap <C-TAB>   :call <SID>CycleBuffer(1)<CR>:<BS>
  noremap <C-S-TAB> :call <SID>CycleBuffer(0)<CR>:<BS>
endif

"
" If we have enabled <C-TAB> and <C-S-TAB> to switch windows
" then perform the remapping
"
if g:miniBufExplMapCTabSwitchWindows
  noremap <C-TAB>   <C-W>w
  noremap <C-S-TAB> <C-W>W
endif



"
" Setup an autocommand group and some autocommands that keep our explorer
" updated automatically.
"
augroup MiniBufExplorer
autocmd MiniBufExplorer BufDelete   * call <SID>DEBUG('-=> BufDelete AutoCmd', 10) |call <SID>AutoUpdate(expand('<abuf>'))
autocmd MiniBufExplorer BufEnter    * call <SID>DEBUG('-=> BufEnter  AutoCmd', 10) |call <SID>AutoUpdate(-1)
autocmd MiniBufExplorer VimEnter    * call <SID>DEBUG('-=> VimEnter  AutoCmd', 10) |let g:miniBufExplorerAutoUpdate = 1 |call <SID>AutoUpdate(-1)

" 
" StartExplorer
" 
" Sets up our explorer and causes it to be displayed
"
function! <SID>StartExplorer(sticky, delBufNum)
  call <SID>DEBUG('===========================',10)
  call <SID>DEBUG('Entering StartExplorer()'   ,10)
  call <SID>DEBUG('===========================',10)

  if a:sticky == 1
    let g:miniBufExplorerAutoUpdate = 1
  endif

  " Store the current buffer
  let l:curBuf = bufnr('%')

  call <SID>FindCreateWindow('-MiniBufExplorer-', -1, 1, 1)

  " Make sure we are in our window
  if bufname('%') != '-MiniBufExplorer-'
    call <SID>DEBUG('StartExplorer called in invalid window',1)
    return
  endif

  " Prevent a report of our actions from showing up.
  let l:save_rep = &report
  let l:save_sc  = &showcmd
  let &report    = 10000
  set noshowcmd 

  " !!! We may want to make the following optional -- Bindu
  " New windows don't cause all windows to be resized to equal sizes
  set noequalalways
  " !!! We may want to make the following optional -- Bindu
  " We don't want the mouse to change focus without a click
  set nomousefocus

  " If folks turn numbering and columns on by default we will turn 
  " them off for the MBE window
  setlocal foldcolumn=0
  setlocal nonumber
 
  if has("syntax")
    syn match MBEBorder             '[\[\]]'
    syn match MBEChanged            '\[[^\]]*\]+'
    syn match MBEVisibleNormal      '\[[^\]]*\]\*+\='
    syn match MBEVisibleChanged     '\[[^\]]*\]\*+'
    
    " if !exists("g:did_minibufexplorer_syntax_inits")
      let g:did_minibufexplorer_syntax_inits = 1
      " hi def link MBEBorder         Comment
      " hi def link MBEChanged        String
      " hi def link MBEVisibleNormal  Special
      " hi def link MBEVisibleChanged Special
      "" Changes by Joey:
      hi MBEBorder         ctermbg=black ctermfg=green  guibg=black guifg=green  cterm=none gui=none
      hi MBEVisibleNormal  ctermbg=black ctermfg=cyan   guibg=black guifg=cyan   cterm=bold gui=bold
      hi MBEChanged        ctermbg=black ctermfg=red    guibg=black guifg=red    cterm=bold gui=bold
      hi MBEVisibleChanged ctermbg=black ctermfg=yellow guibg=black guifg=yellow cterm=bold gui=bold
    endif
  " endif

  " If you press return in the -MiniBufExplorer- then try
  " to open the selected buffer in the previous window.
  nnoremap <buffer> <CR> :call <SID>MBESelectBuffer()<CR>:<BS>
  " If you DoubleClick in the -MiniBufExplorer- then try
  " to open the selected buffer in the previous window.
  nnoremap <buffer> <LEFTMOUSE> :call <SID>MBEDoubleClick()<CR>:<BS>
  " If you press d in the -MiniBufExplorer- then try to
  " delete the selected buffer.
  nnoremap <buffer> d :call <SID>MBEDeleteBuffer()<CR>:<BS>
  " If you press w in the -MiniBufExplorer- then switch back
  " to the previous window.
  nnoremap <buffer> p :wincmd p<CR>:<BS>
  " The following allow us to use regular movement keys to 
  " scroll in a wrapped single line buffer
  nnoremap <buffer> j gj
  nnoremap <buffer> k gk
  nnoremap <buffer> <down> gj
  nnoremap <buffer> <up> gk
  " The following allows for quicker moving between buffer
  " names in the [MBE] window it also saves the last-pattern
  " and restores it.
  nnoremap <buffer> <TAB>   :call search('\[[0-9]*:[^\]]*\]')<CR>:<BS>
  nnoremap <buffer> <S-TAB> :call search('\[[0-9]*:[^\]]*\]','b')<CR>:<BS>
 
  call <SID>DisplayBuffers(a:delBufNum)

  if (l:curBuf != -1)
    call search('\['.l:curBuf.':'.expand('#'.l:curBuf.':t').'\]')
  else
    call <SID>DEBUG('No current buffer to search for',9)
  endif

  let &report  = l:save_rep
  let &showcmd = l:save_sc

  call <SID>DEBUG('===========================',10)
  call <SID>DEBUG('Completed StartExplorer()'  ,10)
  call <SID>DEBUG('===========================',10)

endfunction

"
" StopExplorer
"
" Looks for our explorer and closes the window if it is open
"
function! <SID>StopExplorer(sticky)
  call <SID>DEBUG('===========================',10)
  call <SID>DEBUG('Entering StopExplorer()'    ,10)
  call <SID>DEBUG('===========================',10)

  if a:sticky == 1
    let g:miniBufExplorerAutoUpdate = 0
  endif

  let l:winNum = <SID>FindWindow('-MiniBufExplorer-', 1)

  if l:winNum != -1 
    exec l:winNum.' wincmd w'
    silent! close
    wincmd p
  endif

  call <SID>DEBUG('===========================',10)
  call <SID>DEBUG('Completed StopExplorer()'   ,10)
  call <SID>DEBUG('===========================',10)

endfunction

"
" FindWindow
"
" Return the window number of a named buffer, if none is found then 
" returns -1.
"
function! <SID>FindWindow(bufName, doDebug)
  if a:doDebug
    call <SID>DEBUG('Entering FindWindow()',10)
  endif

  " Try to find an existing window that contains 
  " our buffer.
  let l:bufNum = bufnr(a:bufName)
  if l:bufNum != -1
    if a:doDebug
      call <SID>DEBUG('Found buffer ('.a:bufName.'): '.l:bufNum,9)
    endif
    let l:winNum = bufwinnr(l:bufNum)
  else
    let l:winNum = -1
  endif

  return l:winNum

endfunction

" 
" FindCreateWindow
" 
" Attempts to find a window for a named buffer. If it is found then 
" moves there. Otherwise creates a new window and configures it and
" moves there.
"
" forceEdge, -1 use defaults, 0 below, 1 above
" isExplorer, 0 no, 1 yes 
" doDebug, 0 no, 1 yes
"
function! <SID>FindCreateWindow(bufName, forceEdge, isExplorer, doDebug)
  if a:doDebug
    call <SID>DEBUG('Entering FindCreateWindow('.a:bufName.')',10)
  endif

  " Save the user's split setting.
  let l:saveSplitBelow = &splitbelow

  " Set to our new values.
  let &splitbelow = g:miniBufExplSplitBelow

  " Try to find an existing explorer window
  let l:winNum = <SID>FindWindow(a:bufName, a:doDebug)

  " If found goto the existing window, otherwise 
  " split open a new window.
  if l:winNum != -1
    if a:doDebug
      call <SID>DEBUG('Found window ('.a:bufName.'): '.l:winNum,9)
    endif
    exec l:winNum.' wincmd w'
    let l:winFound = 1
  else

    if g:miniBufExplSplitToEdge == 1 || a:forceEdge >= 0

        let l:edge = &splitbelow
        if a:forceEdge >= 0
            let l:edge = a:forceEdge
        endif

        if l:edge
            exec 'bo sp '.a:bufName
        else
            exec 'to sp '.a:bufName
        endif
    else
        exec 'sp '.a:bufName
    endif

    let g:miniBufExplForceDisplay = 1

    " Try to find an existing explorer window
    let l:winNum = <SID>FindWindow(a:bufName, a:doDebug)
    if l:winNum != -1
      if a:doDebug
        call <SID>DEBUG('Created and then found window ('.a:bufName.'): '.l:winNum,9)
      endif
      exec l:winNum.' wincmd w'
    else
      if a:doDebug
        call <SID>DEBUG('FindCreateWindow failed to create window ('.a:bufName.').',1)
      endif
      return
    endif

    if a:isExplorer
      " Turn off the swapfile, set the buffer type so that it won't get written,
      " and so that it will get deleted when it gets hidden and turn on word wrap.
      setlocal noswapfile
      setlocal buftype=nofile
      setlocal bufhidden=delete
      setlocal wrap
    endif

    if a:doDebug
      call <SID>DEBUG('Window ('.a:bufName.') created: '.winnr(),9)
    endif

  endif

  " Restore the user's split setting.
  let &splitbelow = l:saveSplitBelow

endfunction

" 
" DisplayBuffers.
" 
" Makes sure we are in our explorer, then erases the current buffer and turns 
" it into a mini buffer explorer window.
"
function! <SID>DisplayBuffers(delBufNum)
  call <SID>DEBUG('Entering DisplayBuffers()',10)
  
  " Make sure we are in our window
  if bufname('%') != '-MiniBufExplorer-'
    call <SID>DEBUG('DisplayBuffers called in invalid window',1)
    return
  endif

  " We need to be able to modify the buffer
  setlocal modifiable

  call <SID>ShowBuffers(a:delBufNum)
  call <SID>ResizeWindow()
  
  normal! zz
  
  " Prevent the buffer from being modified.
  setlocal nomodifiable

endfunction

" 
" Resize Window
" 
" Makes sure we are in our explorer, then sets the height for our explorer 
" window so that we can fit all of our information without taking extra lines.
"
function! <SID>ResizeWindow()
  call <SID>DEBUG('Entering ResizeWindow()',10)

  " Make sure we are in our window
  if bufname('%') != '-MiniBufExplorer-'
    call <SID>DEBUG('ResizeWindow called in invalid window',1)
    return
  endif

  let l:width  = winwidth('.')
  if g:miniBufExplTabWrap == 0
    let l:length = strlen(getline('.'))
    let l:height = 0
    if (l:width == 0)
      let l:height = winheight('.')
    else
      let l:height = (l:length / l:width) 
      " handle truncation from div
      if (l:length % l:width) != 0
        let l:height = l:height + 1
      endif
    endif
  else
    exec("setlocal textwidth=".l:width)
    normal gg
    normal gq}
    normal G
    let l:height = line('.')
    normal gg
  endif

  " enforce max window height
  if g:miniBufExplMaxHeight != 0
    if g:miniBufExplMaxHeight < l:height
      let l:height = g:miniBufExplMaxHeight
    endif
  endif

  " enfore min window height
  if l:height < g:miniBufExplMinHeight || l:height == 0
    let l:height = g:miniBufExplMinHeight
  endif

  call <SID>DEBUG('ResizeWindow to '.l:height.' lines',9)

  exec('resize '.l:height)

endfunction

" 
" ShowBuffers.
" 
" Makes sure we are in our explorer, then adds a list of all modifiable 
" buffers to the current buffer. Special marks are added for buffers that 
" are in one or more windows (*) and buffers that have been modified (+)
"
function! <SID>ShowBuffers(delBufNum)
  call <SID>DEBUG('Entering ShowBuffers()',10)

  let l:ListChanged = <SID>BuildBufferList(a:delBufNum, 1)

  if (l:ListChanged == 1 || g:miniBufExplForceDisplay)
    let l:save_rep = &report
    let l:save_sc = &showcmd
    let &report = 10000
    set noshowcmd 

    " Delete all lines in buffer.
    1,$d _
  
    " Goto the end of the buffer put the buffer list 
    " and then delete the extra trailing blank line
    $
    put! =g:miniBufExplBufList
    $ d _

    let g:miniBufExplForceDisplay = 0

    let &report  = l:save_rep
    let &showcmd = l:save_sc
  else
    call <SID>DEBUG('Buffer list not update since there was no change',9)
  endif
  
endfunction

" 
" BuildBufferList.
" 
" Creates the buffer list string and returns 1 if it is different than
" last time this was called and 0 otherwise.
"
function! <SID>BuildBufferList(delBufNum, updateBufList)
  call <SID>DEBUG('Entering BuildBufferList()',10)

  let l:NBuffers = bufnr('$')     " Get the number of the last buffer.
  let l:i = 0                     " Set the buffer index to zero.

  let l:fileNames = ''

  " Loop through every buffer less than the total number of buffers.
  while(l:i <= l:NBuffers)
    let l:i = l:i + 1
   
    " If we have a delBufNum and it is the current
    " buffer then ignore the current buffer. 
    " Otherwise, continue.
    if (a:delBufNum == -1 || l:i != a:delBufNum)
      " Make sure the buffer in question is listed.
      if(getbufvar(l:i, '&buflisted') == 1)
        " Get the name of the buffer.
        let l:BufName = bufname(l:i)
        " Check to see if the buffer is a blank or not. If the buffer does have
        " a name, process it.
        if(strlen(l:BufName))
          " Only show modifiable buffers (The idea is that we don't 
          " want to show Explorers)
          if (getbufvar(l:i, '&modifiable') == 1 && BufName != '-MiniBufExplorer-')
            
            " Get filename & Remove []'s & ()'s
            let l:shortBufName = fnamemodify(l:BufName, ":t")                  
            let l:shortBufName = substitute(l:shortBufName, '[][()]', '', 'g') 
            " joey changed: let l:fileNames = l:fileNames.'['.l:i.':'.l:shortBufName.']'
            " let l:fileNames = l:fileNames.'['.l:shortBufName.']'
            let l:fileNames = l:fileNames.'['.l:i.':'.l:shortBufName.']'

            " If the buffer is open in a window mark it
            if bufwinnr(l:i) != -1
              let l:fileNames = l:fileNames . '*'
            endif

            " If the buffer is modified then mark it
            if(getbufvar(l:i, '&modified') == 1)
              let l:fileNames = l:fileNames . '+'
            endif

            " If tab wrap is turned on we need to add spaces
            if g:miniBufExplTabWrap != 0
              let l:fileNames = l:fileNames.' '
            endif

          endif
        endif
      endif
    endif
  endwhile

  if (g:miniBufExplBufList != l:fileNames)
    if (a:updateBufList)
      let g:miniBufExplBufList = l:fileNames
    endif
    return 1
  else
    return 0
  endif

endfunction

" 
" HasEligibleBuffers
" 
" Returns 1 if there are any buffers that can be displayed in a 
" mini buffer explorer. Otherwise returns 0. If delBufNum is
" any non -1 value then don't include that buffer in the list
" of eligible buffers.
"
function! <SID>HasEligibleBuffers(delBufNum)
  call <SID>DEBUG('Entering HasEligibleBuffers()',10)

  let l:save_rep = &report
  let l:save_sc = &showcmd
  let &report = 10000
  set noshowcmd 
  
  let l:NBuffers = bufnr('$')     " Get the number of the last buffer.
  let l:i        = 0              " Set the buffer index to zero.
  let l:found    = 0              " No buffer found

  if (g:miniBufExplorerMoreThanOne > 1)
    call <SID>DEBUG('More Than One mode turned on',6)
  endif
  let l:needed = g:miniBufExplorerMoreThanOne

  " Loop through every buffer less than the total number of buffers.
  while(l:i <= l:NBuffers && l:found < l:needed)
    let l:i = l:i + 1
   
    " If we have a delBufNum and it is the current
    " buffer then ignore the current buffer. 
    " Otherwise, continue.
    if (a:delBufNum == -1 || l:i != a:delBufNum)
      " Make sure the buffer in question is listed.
      if (getbufvar(l:i, '&buflisted') == 1)
        " Get the name of the buffer.
        let l:BufName = bufname(l:i)
        " Check to see if the buffer is a blank or not. If the buffer does have
        " a name, process it.
        if (strlen(l:BufName))
          " Only show modifiable buffers (The idea is that we don't 
          " want to show Explorers)
          if ((getbufvar(l:i, '&modifiable') == 1) && (BufName != '-MiniBufExplorer-'))
            
              let l:found = l:found + 1
  
          endif
        endif
      endif
    endif
  endwhile

  let &report  = l:save_rep
  let &showcmd = l:save_sc

  call <SID>DEBUG('HasEligibleBuffers found '.l:found.' eligible buffers of '.l:needed.' needed',6)

  return (l:found >= l:needed)
  
endfunction

"
" Auto Update
"
" IF auto update is turned on     AND
"    we are in a real buffer      AND
"    we have an eligible buffer   THEN
" Update our explorer and get back to the current window
"
" If we get a buffer number for a buffer that 
" is being deleted, we need to make sure and 
" remove the buffer from the list of eligible 
" buffers in case we are down to one eligible
" buffer, in which case we will want to close
" the MBE window.
"
function! <SID>AutoUpdate(delBufNum)
  call <SID>DEBUG('===========================',10)
  call <SID>DEBUG('Entering AutoUpdate('.a:delBufNum.') : '.bufnr('%').' : '.bufname('%'),10)
  call <SID>DEBUG('===========================',10)

  if (g:miniBufExplInAutoUpdate == 1)
    call <SID>DEBUG('AutoUpdate recursion stopped',9)
    call <SID>DEBUG('===========================',10)
    call <SID>DEBUG('Terminated AutoUpdate()'    ,10)
    call <SID>DEBUG('===========================',10)
    return
  else
    let g:miniBufExplInAutoUpdate = 1
  endif

  " Don't bother autoupdating the MBE window
  if (bufname('%') == '-MiniBufExplorer-')
    " If this is the only buffer left then toggle the buffer
    if (winbufnr(2) == -1)
        call <SID>CycleBuffer(1)
        call <SID>DEBUG('AutoUpdate does not run for cycled windows', 9)
    else
      call <SID>DEBUG('AutoUpdate does not run for the MBE window', 9)
    endif

    call <SID>DEBUG('===========================',10)
    call <SID>DEBUG('Terminated AutoUpdate()'    ,10)
    call <SID>DEBUG('===========================',10)

    let g:miniBufExplInAutoUpdate = 0
    return

  endif

  if (a:delBufNum != -1)
    call <SID>DEBUG('AutoUpdate will make sure that buffer '.a:delBufNum.' is not included in the buffer list.', 5)
  endif
  
  " Only allow updates when the AutoUpdate flag is set
  " this allows us to stop updates on startup.
  if g:miniBufExplorerAutoUpdate == 1
    " Only show MiniBufExplorer if we have a real buffer
    if ((g:miniBufExplorerMoreThanOne == 0) || (bufnr('%') != -1 && bufname('%') != ""))
      if <SID>HasEligibleBuffers(a:delBufNum) == 1
        " if we don't have a window then create one
        let l:bufnr = <SID>FindWindow('-MiniBufExplorer-', 0)
        if (l:bufnr == -1)
          call <SID>DEBUG('About to call StartExplorer (Create MBE)', 9)
          call <SID>StartExplorer(0, a:delBufNum)
        else
        " otherwise only update the window if the contents have
        " changed
          let l:ListChanged = <SID>BuildBufferList(a:delBufNum, 0)
          if (l:ListChanged)
            call <SID>DEBUG('About to call StartExplorer (Update MBE)', 9) 
            call <SID>StartExplorer(0, a:delBufNum)
          endif
        endif

        " go back to the working buffer
        if (bufname('%') == '-MiniBufExplorer-')
          wincmd p
        endif
      else
        call <SID>DEBUG('Failed in eligible check', 9)
        call <SID>StopExplorer(0)
      endif
    else
      call <SID>DEBUG('No buffers loaded...',9)
    endif
  else
    call <SID>DEBUG('AutoUpdates are turned off, terminating',9)
  endif

  call <SID>DEBUG('===========================',10)
  call <SID>DEBUG('Completed AutoUpdate()'     ,10)
  call <SID>DEBUG('===========================',10)

  let g:miniBufExplInAutoUpdate = 0

endfunction

" 
" GetSelectedBuffer
" 
" If we are in our explorer window then return the buffer number
" for the buffer under the cursor.
"
function! <SID>GetSelectedBuffer()
  call <SID>DEBUG('Entering GetSelectedBuffer()',10)

  " Make sure we are in our window
  if bufname('%') != '-MiniBufExplorer-'
    call <SID>DEBUG('GetSelectedBuffer called in invalid window',1)
    return -1
  endif

  let l:save_reg = @"
  let @" = ""
  normal ""yi[
  if @" != ""
    let l:retv = substitute(@",'\([0-9]*\):.*', '\1', '') + 0
    let @" = l:save_reg
    return l:retv
  else
    let @" = l:save_reg
    return -1
  endif

endfunction

" 
" MBESelectBuffer.
" 
" If we are in our explorer, then we attempt to open the buffer under the
" cursor in the previous window.
"
function! <SID>MBESelectBuffer()
  call <SID>DEBUG('===========================',10)
  call <SID>DEBUG('Entering MBESelectBuffer()' ,10)
  call <SID>DEBUG('===========================',10)

  " Make sure we are in our window
  if bufname('%') != '-MiniBufExplorer-'
    call <SID>DEBUG('MBESelectBuffer called in invalid window',1)
    return 
  endif

  let l:save_rep = &report
  let l:save_sc  = &showcmd
  let &report    = 10000
  set noshowcmd 
  
  let l:bufnr  = <SID>GetSelectedBuffer()
  let l:resize = 0

  if(l:bufnr != -1)             " If the buffer exists.

    let l:saveAutoUpdate = g:miniBufExplorerAutoUpdate
    let g:miniBufExplorerAutoUpdate = 0
    " Switch to the previous window
    wincmd p

    " If we are in the buffer explorer then try another window
    if bufname('%') == '-MiniBufExplorer-'
      wincmd w
      " The following handles the case where -MiniBufExplorer-
      " is the only window left. We need to resize so we don't
      " end up with a 1 or two line buffer.
      if bufname('%') == '-MiniBufExplorer-'
        let l:resize = 1
      endif
    endif

    exec('b! '.l:bufnr)
    if (l:resize)
      resize
    endif
    let g:miniBufExplorerAutoUpdate = l:saveAutoUpdate
    call <SID>AutoUpdate(-1)

  endif

  let &report  = l:save_rep
  let &showcmd = l:save_sc

  call <SID>DEBUG('===========================',10)
  call <SID>DEBUG('Completed MBESelectBuffer()',10)
  call <SID>DEBUG('===========================',10)

endfunction

" 
" Delete selected buffer from list.
" 
" After making sure that we are in our explorer, This will delete the buffer 
" under the cursor. If the buffer under the cursor is being displayed in a
" window, this routine will attempt to get different buffers into the 
" windows that will be affected so that windows don't get removed.
"
function! <SID>MBEDeleteBuffer()
  call <SID>DEBUG('===========================',10)
  call <SID>DEBUG('Entering MBEDeleteBuffer()' ,10)
  call <SID>DEBUG('===========================',10)

  " Make sure we are in our window
  if bufname('%') != '-MiniBufExplorer-'
    call <SID>DEBUG('MBEDeleteBuffer called in invalid window',1)
    return 
  endif

  let l:curLine    = line('.')
  let l:curCol     = virtcol('.')
  let l:selBuf     = <SID>GetSelectedBuffer()
  let l:selBufName = bufname(l:selBuf)

  if l:selBufName == 'MiniBufExplorer.DBG' && g:miniBufExplorerDebugLevel > 0
    call <SID>DEBUG('MBEDeleteBuffer will not delete the debug window, when debugging is turned on.',1)
    return
  endif

  let l:save_rep = &report
  let l:save_sc  = &showcmd
  let &report    = 10000
  set noshowcmd 
  
  
  if l:selBuf != -1 

    " Don't want auto updates while we are processing a delete
    " request.
    let l:saveAutoUpdate = g:miniBufExplorerAutoUpdate
    let g:miniBufExplorerAutoUpdate = 0

    " Save previous window so that if we show a buffer after
    " deleting. The show will come up in the correct window.
    wincmd p
    let l:prevWin    = winnr()
    let l:prevWinBuf = winbufnr(winnr())

    call <SID>DEBUG('Previous window: '.l:prevWin.' buffer in window: '.l:prevWinBuf,5)
    call <SID>DEBUG('Selected buffer is <'.l:selBufName.'>['.l:selBuf.']',5)

    " If buffer is being displayed in a window then 
    " move window to a different buffer before 
    " deleting this one. 
    let l:winNum = (bufwinnr(l:selBufName) + 0)
    " while we have windows that contain our buffer
    while l:winNum != -1 
        call <SID>DEBUG('Buffer '.l:selBuf.' is being displayed in window: '.l:winNum,5)

        " move to window that contains our selected buffer
        exec l:winNum.' wincmd w'

        call <SID>DEBUG('We are now in window: '.winnr().' which contains buffer: '.bufnr('%').' and should contain buffer: '.l:selBuf,5)

        let l:origBuf = bufnr('%')
        call <SID>CycleBuffer(1)
        let l:curBuf  = bufnr('%')

        call <SID>DEBUG('Window now contains buffer: '.bufnr('%').' which should not be: '.l:selBuf,5)

        if l:origBuf == l:curBuf
            " we wrapped so we are going to have to delete a buffer 
            " that is in an open window.
            let l:winNum = -1
        else
            " see if we have anymore windows with our selected buffer
            let l:winNum = (bufwinnr(l:selBufName) + 0)
        endif
    endwhile

    " Attempt to restore previous window
    call <SID>DEBUG('Restoring previous window to: '.l:prevWin,5)
    exec l:prevWin.' wincmd w'

    " Try to get back to the -MiniBufExplorer- window 
    let l:winNum = bufwinnr(bufnr('-MiniBufExplorer-'))
    if l:winNum != -1
        exec l:winNum.' wincmd w'
        call <SID>DEBUG('Got to -MiniBufExplorer- window: '.winnr(),5)
    else
        call <SID>DEBUG('Unable to get to -MiniBufExplorer- window',1)
    endif
  
    " Delete the buffer selected.
    call <SID>DEBUG('About to delete buffer: '.l:selBuf,5)
    exec('silent! bd '.l:selBuf)

    let g:miniBufExplorerAutoUpdate = l:saveAutoUpdate 
    call <SID>DisplayBuffers(-1)
    call cursor(l:curLine, l:curCol)

  endif

  let &report  = l:save_rep
  let &showcmd = l:save_sc

  call <SID>DEBUG('===========================',10)
  call <SID>DEBUG('Completed MBEDeleteBuffer()',10)
  call <SID>DEBUG('===========================',10)

endfunction

"
" Cycle Through Buffers 
"
" Move to next or previous buffer in the current window. If there 
" are no more modifiable buffers then stay on the current buffer.
"
function! <SID>CycleBuffer(forward)

  " The following hack handles the case where we only have one
  " window open and it is too small
  let l:saveAutoUpdate = g:miniBufExplorerAutoUpdate
  if (winbufnr(2) == -1)
    resize
    let g:miniBufExplorerAutoUpdate = 0
  endif
  
  " Change buffer (keeping track of before and after buffers)
  let l:origBuf = bufnr('%')
  if (a:forward == 1)
    bn!
  else
    bp!
  endif
  let l:curBuf  = bufnr('%')

  " Skip any non-modifiable buffers, but don't cycle forever
  " This should stop us from stopping in any of the [Explorers]
  while getbufvar(l:curBuf, '&modifiable') == 0 && l:origBuf != l:curBuf
    if (a:forward == 1)
        bn!
    else
        bp!
    endif
    let l:curBuf = bufnr('%')
  endwhile

  let g:miniBufExplorerAutoUpdate = l:saveAutoUpdate
  if (l:saveAutoUpdate == 1)
    call <SID>AutoUpdate(-1)
  endif

endfunction

"
" MBEDoubleClick - Double click with the mouse.
"
function! s:MBEDoubleClick()
  call <SID>DEBUG('Entering MBEDoubleClick()',10)
  call <SID>MBESelectBuffer()
endfunction

"
" DEBUG
"
" Display debug output when debugging is turned on
"
"function! <SID>DEBUG(msg, level)
  "if g:miniBufExplorerDebugLevel >= a:level
    "call confirm(a:msg, 'OK')
  "endif
"endfunction


"
" DEBUG
"
" Display debug output when debugging is turned on
" Thanks to Charles E. Campbell, Jr. PhD <cec@NgrOyphSon.gPsfAc.nMasa.gov> 
" for Decho.vim which was the inspiration for this enhanced debugging 
" capability.
"
function! <SID>DEBUG(msg, level)

  if g:miniBufExplorerDebugLevel >= a:level

    " Prevent a report of our actions from showing up.
    let l:save_rep    = &report
    let l:save_sc     = &showcmd
    let &report       = 10000
    set noshowcmd 

    " Debug output to a buffer
    if g:miniBufExplorerDebugMode == 0
        " Save the current window number so we can come back here
        let l:prevWin     = winnr()
        wincmd p
        let l:prevPrevWin = winnr()
        wincmd p

        " Get into the debug window or create it if needed
        call <SID>FindCreateWindow('MiniBufExplorer.DBG', 1, 0, 0)
    
        " Make sure we really got to our window, if not we 
        " will display a confirm dialog and turn debugging
        " off so that we won't break things even more.
        if bufname('%') != 'MiniBufExplorer.DBG'
            call confirm('Error in window debugging code. Dissabling MiniBufExplorer debugging.', 'OK')
            let g:miniBufExplorerDebugLevel = 0
        endif

        " Write Message to DBG buffer
        let res=append("$",s:debugIndex.':'.a:level.':'.a:msg)
        norm G
        "set nomodified

        " Return to original window
        exec l:prevPrevWin.' wincmd w'
        exec l:prevWin.' wincmd w'
    " Debug output using VIM's echo facility
    elseif g:miniBufExplorerDebugMode == 1
      echo s:debugIndex.':'.a:level.':'.a:msg
    " Debug output to a file -- VERY SLOW!!!
    " should be OK on UNIX and Win32 (not the 95/98 variants)
    elseif g:miniBufExplorerDebugMode == 2
        if has('system') || has('fork')
            if has('win32') && !has('win95')
                let l:result = system("cmd /c 'echo ".s:debugIndex.':'.a:level.':'.a:msg." >> MiniBufExplorer.DBG'")
            endif
            if has('unix')
                let l:result = system("echo '".s:debugIndex.':'.a:level.':'.a:msg." >> MiniBufExplorer.DBG'")
            endif
        else
            call confirm('Error in file writing version of the debugging code, vim not compiled with system or fork. Dissabling MiniBufExplorer debugging.', 'OK')
            let g:miniBufExplorerDebugLevel = 0
        endif
    elseif g:miniBufExplorerDebugMode == 3
        let g:miniBufExplorerDebugOutput = g:miniBufExplorerDebugOutput."\n".s:debugIndex.':'.a:level.':'.a:msg
    endif
    let s:debugIndex = s:debugIndex + 1

    let &report  = l:save_rep
    let &showcmd = l:save_sc

  endif

endfunc
