" Automatically adds a global mark whenever you leave Insert mode, so you can
" easily return to text you were last working on, even if you have moved to a
" different buffer!  I tend to need this after I have been navigating around
" files to do some research.  This saves us from hitting Ctrl-O repeatedly!

nmap <C-y> g'Z
" I tend to forget that there is a ' in g'Z so I just hit gZ.  Let's make that work!  I don't think I'm overwriting any default.
nmap gZ g'Z

augroup LastEditMarker
  autocmd!
  autocmd InsertLeave * normal mZ
augroup END

" ISSUES: not all edits require Insert mode.  e.g. undo or 4r0
" And leaving Insert mode is not always an edit (e.g. Insert mode on a
" conqueterm, or i<Esc> aborted edit).

" Really we want g; and g, but globally not local to the current buffer.  If
" we develop this further, a historical list of edits might be nice.  (I would
" also like to skip previous entries within 5 lines of the current.)

"" Alternative attempt to activate using keybind:
" imap <Esc> <Esc>mZ
" But triggering on <Esc> will not detect all edits, for example those using
" ~ or r or d!
" And also it manages to break lots of other things!

" Wild idea: In theory we could use Ctrl-O or the jumplist to go back to
" previous positions, and stop when we find one that matches the :changes
" changelist of the current buffer.  Although if we happen to pass through a
" buffer we changed earlier, on the line we changed, how will we know not to
" stop there (it isn't the most recent change we made)?

" How we might track changes:  We could hook onto CursorHold and keep checking
" the :changes list, updating our own global list when we detect new entries
" there.  Does CursorHold fire after a change if the cursor didn't move?  It
" does on 'dw'!

