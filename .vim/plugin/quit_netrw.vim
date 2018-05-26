" Netrw buffers sometimes hang around even after they should have closed, reappearing when we use :bn or :bp
" This script tries to get them to close themselves automatically, whenever the window becomes hidden.
" But if that doesn't work, the user can manually `call QuitNetrwBuffers()` to wipe out any netrw windows which are hanging around in the background.

" Inspiration from: https://vi.stackexchange.com/questions/14622/how-can-i-close-the-netrw-buffer

function! QuitNetrwBuffers()
  for i in range(1, bufnr('$'))
    let buflisted = buflisted(i)
    if !buflisted
      continue
    endif
    let bufname = bufname(i)
    " Get the full path.  This will add '/' after a link to a folder, which should result in fstype='dir' instead of 'link'
    let fullname = len(bufname) ? fnamemodify(bufname, ':p') : ''
    let fstype = getftype(fullname)
    let filetype = getbufvar(i, '&filetype')
    let bufhidden = getbufvar(i, '&bufhidden')
    let winid = bufwinid(i)
    " BUG: Sometimes fstype == "link", in which case we need to follow it to find out if it's a directory or a file!
    " Surely we can find out more positively if this window is a netrw window
    "let destroy = filetype == "netrw"
    let destroy = len(bufname) && fstype == "dir" && winid == -1
    if destroy
      "echo ">>> WILL DESTROY BUFFER ".i." ".bufname
      "echo "buffer=".i." buflisted=".buflisted." fstype=".fstype." filetype=".filetype." bufhidden=".bufhidden." winid=".winid." bufname=".bufname." fullname=".fullname
      silent exe 'bwipeout ' . i
    endif
  endfor
endfunction

"autocmd MyAutoCmd VimLeavePre *  call QuitNetrwBuffers()

augroup netrw_buf_wipeout
  autocmd!
  "autocmd FileType * echo "THIS BUFFER WILL WIPE" | set bufhidden=wipe
  "autocmd BufLeave * echo "Leaving: " . &filetype
  "autocmd BufLeave * if &filetype == 'netrw' | bwipeout! | endif
  "autocmd BufLeave * if &filetype == 'netrw' | bwipeout! | endif
  " This sometimes triggers, and works, but sometimes it doesn't trigger
  "autocmd BufWinEnter * if &filetype == 'netrw' | echo "THIS NETRW BUFFER WILL WIPE" | set bufhidden=wipe | endif
  autocmd BufWinEnter * if &filetype == 'netrw' | set bufhidden=wipe | endif
augroup end
