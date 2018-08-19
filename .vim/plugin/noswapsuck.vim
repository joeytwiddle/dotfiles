" NO SWAP SUCK! by joeytwiddle.  (c) Paul Clark, released under MIT license.

" This plugin mitigates Vim's inconvenient swapfile behaviour by only creating
" a swapfile when we actually modify a buffer.

" Vim's default 'swapfile' behaviour can be annoying because:
"
" - Vim creates a swapfile for every open file, even if you haven't edited it.
"
" - If your machine crashes or reboots without closing Vim tidily, all these
"   swapfiles will be left on disk.
"
" - When you edit a file with a swapfile present, it is difficult to determine
"   which is the copy you desire.  Vim doesn't even check if they are
"   identical!  (See |alternatives|)

" Some people turn 'swapfile' off, but then they lose the ability to recover
" unsaved work if their machine loses power.

" To monitor the behaviour of this plugin, you can set g:NoSwapSuck_Debug, but
" that can interrupt your workflow with "Press ENTER" messages.
"
" A friendlier way to monitor whether a swapfile is currently being used, is
" to add an indicator to your statusline.
"
"   " Do this first if you don't have a custom 'statusline'
"   :set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
"
"   :let &statusline = substitute(&statusline, '%=', '%{ \&swapfile ? " swap" : "" }%=', '')

" Alternative solutions:                                        *alternatives*
"
" - Christian Brabandt's recover.vim plugin can automatically recover
"   swapfiles for you.
"
"   (I have an adapted version that will delete the swapfile if it is found to
"   be identical.)
"
" - My diff_against_file_on_disk.vim plugin has a :DiffSplitAgainstFileOnDisk
"   command which makes it easy to check if your current (recovered) buffer
"   matches the most recent file.

" There are minor complications when using this script alongside recover.vim
"
" - We don't want to set swapfile on BufReadPre because we are still on the
"   previous buffer (the one we are about to "hide"), so that would create an
"   unwanted swapfile.
"
" - But if swapfile isn't set then, recover.vim won't be able to do its magic
"   immediately when we open the file.  Setting 'swapfile' on BufReadPost is
"   too late for recover.vim!
"
" I tried to munge recover.vim to work even if 'swapfile' was not set, but
" that didn't work smoothly either.



" === Options ===

" g:NoSwapSuck_Enabled: Allows plugin to be enabled/disabled from config, or
" disabled at runtime.

let g:NoSwapSuck_Enabled = get(g:, 'NoSwapSuck_Enabled', 1)

" g:NoSwapSuck_CloseSwapfileOnWrite: Disable this (set to 0) if you are in an
" edit-save-edit-save workflow and want there to be fewer disk writes.
"
" Disabling will prevent removing/recreating the swapfile, but it might leave
" unwanted swapfiles on disk!
"
" Disabling is appropriate if:
"
" - you want to reduce power consumption
" - you are saving onto a slow filesystem (network based, USB, SD card or
"   floppy disk)
" - you are editing huge files.

let g:NoSwapSuck_CloseSwapfileOnWrite = get(g:, 'NoSwapSuck_CloseSwapfileOnWrite', 1)

" g:NoSwapSuck_CheckSwapfileOnLoad: When opening a file for the first time,
" will `:set swapfile` to force Vim to check if there is a swapfile present
" for that file.

let g:NoSwapSuck_CheckSwapfileOnLoad = get(g:, 'NoSwapSuck_CheckSwapfileOnLoad', 1)

" g:NoSwapSuck_CreateSwapfileOnInsert: Create a swapfile immediately when you
" enter Insert mode.
"
" Advantages:
"
" - If you do a long edit without leaving insert mode, your changes will be
"   safely stored in the swapfile.
"
" Disadvantages:
"
" - If a swapfile is present, you may be interrupted while entering insert
"   mode, when you were just about to type something!
"
"   This can be avoided by setting g:NoSwapSuck_CheckSwapfileOnLoad.

let g:NoSwapSuck_CreateSwapfileOnInsert = get(g:, 'NoSwapSuck_CreateSwapfileOnInsert', 1)

" g:NoSwapSuck_Debug: Prints messages in the command area when the 'swapfile'
" option is enabled or disabled.  Clear for development / testing, but can be
" a little disruptive.

let g:NoSwapSuck_Debug = get(g:, 'NoSwapSuck_Debug', 0)



if !g:NoSwapSuck_Enabled
  finish
endif

" Unsetting swapfile at startup is useful to prevent the initial message
" "Setting NO swapfile" from triggering a "Press ENTER to continue" message
" every time you start Vim.
"
" Alternative solutions are to increase 'cmdheight', or to disable one of the options.

if g:NoSwapSuck_Debug && g:NoSwapSuck_CheckSwapfileOnLoad
  set noswapfile
endif

augroup NoSwapSuck
  autocmd!

  " Turn swapfile on when opening a file.  This is needed if we want Vim to
  " check if a swapfile exists in this moment.
  "
  autocmd BufReadPre *  if g:NoSwapSuck_CheckSwapfileOnLoad | call s:SetSwapfileToCheck() | endif

  " Turn swapfile off by default, for any newly opened buffer.
  "
  autocmd BufReadPost * call s:ConsiderClosingSwapfile()

  " It can be rather disruptive to enable the swapfile when we enter Insert
  " mode, because if an existing swapfile is found, editing will be
  " interrupted while Vim asks what to do next.
  "
  " (There is also a danger that the user will be typing characters to insert,
  " and these will get passed to the swapfile recovery prompt.)
  " (Although it seems the recover prompt does not show when we are in insert
  " mode, although it does interrupt the user a little!)
  "
  " But this is less of an issue since we started using CheckSwapfileOnLoad,
  " so we now enable it by default.
  "
  " Previously we only checked on InsertLeave, and never on InsertEnter.  The
  " disadvantage with that was that you might make a significant edit before
  " discovering the swapfile contains a more recent version of the file.
  "
  autocmd InsertEnter * if g:NoSwapSuck_CreateSwapfileOnInsert | call s:ConsiderCreatingSwapfile(1) | endif

  " Or, turn swapfile on *shortly after* we have started editing.
  "
  " Unlike InsertEnter, this won't disturb your typing if Vim discovers than
  " an old swapfile is present.  But that is actually even more annoying,
  " because you then have to deal with the swapfile *after* having entered
  " some new text!
  "
  "autocmd CursorHoldI * if g:NoSwapSuck_CreateSwapfileOnInsert | call s:ConsiderCreatingSwapfile() | endif

  " We always check when leaving Insert mode.
  "
  " If the buffer was modified, a swapfile will be created.
  "
  autocmd InsertLeave * call s:ConsiderCreatingSwapfile()

  " We also need to check on CursorHold, because editing can be made without
  " ever entering Insert mode!
  "
  autocmd CursorHold * call s:ConsiderCreatingSwapfile()

  autocmd BufWritePost * if g:NoSwapSuck_CloseSwapfileOnWrite | call s:ConsiderClosingSwapfile() | endif

  " If for some reason we didn't want to close the swapfile immediately after
  " writing (with BufWritePost) then we could do it shortly after instead.
  "
  " But we don't want to always do this, or it would destroy and recreate the
  " swapfile during a normal edit-save-edit-save workflow.
  "
  "autocmd CursorHold *   if g:NoSwapSuck_CloseSwapfileOnWrite | call s:ConsiderClosingSwapfile() | endif

  " Since 'swapfile' is a global, we have to keep switching it on/off when we
  " switch between buffers/windows.
  "
  autocmd WinLeave * call s:ConsiderClosingSwapfile()
  autocmd WinEnter * call s:ConsiderCreatingSwapfile()
  autocmd BufLeave * call s:ConsiderClosingSwapfile()
  autocmd BufEnter * call s:ConsiderCreatingSwapfile()

augroup END

function! s:ConsiderClosingSwapfile()
  if !g:NoSwapSuck_Enabled
    return
  endif

  if &swapfile && !&modified
    if g:NoSwapSuck_Debug | echo "Setting NO swapfile" | endif
    setlocal noswapfile
  endif
endfunction

function! s:ConsiderCreatingSwapfile(...)
  if !g:NoSwapSuck_Enabled
    return
  endif

  let about_to_be_modified = a:0 ? a:1 : 0
  if !&swapfile && ( &modified || about_to_be_modified ) && !s:SwapfileDisableForCurrentBuffer()
    if g:NoSwapSuck_Debug | echo "Setting swapfile" | endif
    setlocal swapfile
  endif
endfunction

function! s:SetSwapfileToCheck()
  if !g:NoSwapSuck_Enabled
    return
  endif

  set swapfile
endfunction

function! s:SwapfileDisableForCurrentBuffer()
  return get(b:, 'NoSwapSuck_NoSwapfile', 0)
endfunction

