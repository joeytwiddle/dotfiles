" Automatically adds a global mark whenever you leave Insert mode, so you can
" easily return to text you were last working on, even if you have moved to a
" different buffer!  I tend to need this after I have been navigating around
" files to do some research.  This saves us from hitting Ctrl-O repeatedly!

nmap <C-y> g'Z

augroup LastEditMarker
  autocmd!
  autocmd InsertLeave * call s:SetLastEditMarker()
augroup END

function! s:SetLastEditMarker()
  normal mZ
endfunction

"" Alternative attempt to activate using keybind:
" imap <Esc> <Esc>mZ
" But triggering on <Esc> will not detect all edits, for example those using
" ~ or r or d!
" And also it manages to break lots of other things!

