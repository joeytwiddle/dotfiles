" Automatically adds a global mark whenever you leave Insert mode, so you can
" easily return to text you were last working on, even if you have moved to a
" different buffer!  I tend to need this after I have been navigating around
" files to do some research.  This saves us from hitting Ctrl-O repeatedly!

nmap <C-y> g'Z

augroup LastEditMarker
  autocmd!
  autocmd InsertLeave * normal mZ
augroup END

" ISSUES: not all edits require Insert mode.  e.g. undo or 4r0
" And leaving Insert mode is not always an edit (e.g. Insert mode on a
" conqueterm, or i<Esc> aborted edit).

"" Alternative attempt to activate using keybind:
" imap <Esc> <Esc>mZ
" But triggering on <Esc> will not detect all edits, for example those using
" ~ or r or d!
" And also it manages to break lots of other things!

