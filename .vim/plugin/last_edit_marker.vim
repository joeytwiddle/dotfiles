" Automatically adds a global mark whenever you leave Insert mode, so you can
" easily return to the previous change, even if you are on a different buffer!

" augroup LastEditMarker
  " autocmd!
  " autocmd InsertEnter * call s:SetLastEditMarker()
" augroup END

" function! s:SetLastEditMarker()
  " normal "mL"
" endfunction

imap <Esc> <Esc>mL

nmap <C-y> g'L

" NOTE: Triggering on <Esc> will not detect all edits, for example those using
" ~ or r or d!

