function! JoeysBufferSwitch()

  let searchStr = input("Type part of buffer then <Tab> or <Enter>: ", '', "buffer")
  "echo "Got: ".searchStr

  " Quick and dirty:
  "if searchStr != ""
    "silent exec ":b ".searchStr
    "return
  "endif

  "" TODO: If we can find a visible window displaying that buffer, switch to
  "" the window instead of loading the buffer in the current window.

  " TODO: Is there an exact matching buffer by string?

  let foundWindows = []
  let winCount = winnr('$')
  let i = 1
  while i <= winCount
    let winName = bufname(winbufnr(i))
    if match(winName, searchStr) >= 0
      call add(foundWindows, i)
    endif
    let i += 1
  endwhile
  if len(foundWindows) == 1
    exec foundWindows[0]."wincmd w"
    return
  endif

  let foundBuffers = []
  let bufCount = bufnr('$')
  let i=0
  while i < bufCount
    let bufName = bufname(i)
    " TODO: Some buffers need to be ignored e.g. if they are closed (no longer visible)
    if bufName != ""
      if match(bufName, searchStr) >= 0
        call add(foundBuffers, i)
      endif
      " Special case: exact match means we return it as the only match!
      if bufName == searchStr
        let foundBuffers = [i]
        break
      endif
    endif
    let i += 1
  endwhile
  if len(foundBuffers) == 1
    exec foundBuffers[0]."b"
    return
  endif

  echo "[JBS] ".len(foundWindows)." matching windows"
  for wn in foundWindows
    echo "  <".wn."> ".bufname(winbufnr(wn))
  endfor
  echo " "
  echo "[JBS] ".len(foundBuffers)." matching buffers"
  for bn in foundBuffers
    echo "  (".bn.") ".bufname(bn)
  endfor

  " Failing that, allow file?

endfunction

command! JoeysBufferSwitch call JoeysBufferSwitch()

nnoremap <C-B> :JoeysBufferSwitch<Enter>

