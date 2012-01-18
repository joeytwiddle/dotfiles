function! JoeysBufferSwitch()

  let searchStr = input("Type part of buffer then <Tab> or <Enter>: ", '', "buffer")
  "echo "Got: ".searchStr

  " Quick and dirty:
  "if searchStr != ""
    "silent exec ":b ".searchStr
    "return
  "endif

  if searchStr == '' && exists(":BufExplorer")
    exec ":BufExplorer"
    return
  endif " else we will probably print the whole list later

  let searchExpr = '\V' . searchStr

  "" TODO: If we can find a visible window displaying that buffer, switch to
  "" the window instead of loading the buffer in the current window.

  " TODO: Is there an exact matching buffer by string?  Done later...  But
  " shouldn't we try it first?  Exact buffer should really override partial
  " window match.  (e.g. foo.c.old is visible but we want to switch to foo.c)

  " TODO: We get some weird buffers/windows when looping these lists, e.g.
  " previously closed buffers, duplicates, etc.  We probably want to filter
  " out some of them according to their properties.

  " Search windows for partial match. Hopefully there is only 1 (unambiguous).
  let foundWindows = []
  let winCount = winnr('$')
  let i = 1
  while i <= winCount
    let winName = bufname(winbufnr(i))
    if match(winName, searchExpr) >= 0
      call add(foundWindows, i)
    endif
    let i += 1
  endwhile
  if len(foundWindows) == 1
    echo "Switching to window ".foundWindows[0]
    exec foundWindows[0]."wincmd w"
    return
  endif

  " Search buffers for partial or exact match.
  let foundBuffers = []
  let bufCount = bufnr('$')
  let i=0
  while i <= bufCount
    let bufName = bufname(i)
    " TODO: Some buffers need to be ignored e.g. if they are closed (no longer visible)
    if bufName != ""
      if match(bufName, searchExpr) >= 0
        call add(foundBuffers, i)
      endif
      " Special case: exact match means we return it as the only match!
      if bufName == searchStr
        "echo "Found exact match: ".i.": ".bufName
        " Does not work: sometimes it's a closed buffer, so :<i>b fails!
        "let foundBuffers = [i]
        "break
        " Opening by name seems safer:
        exec ":b ".bufName
        return
      endif
    endif
    let i += 1
  endwhile
  if len(foundBuffers) == 1
    "echo "Loading buffer ".foundBuffers[0]
    exec foundBuffers[0]."b"
    return
  endif

  " Failing a matching buffer or window, the user may have tab-completed a
  " filename offered by input().  If so
  " if len(foundWindows) == 0 && len(foundWindows) == 0 && filereadable(searchStr)
  if filereadable(searchStr)
    exec ":e ".searchStr
    return
  endif
  " BUG: Does not work on paths beginning with ~ or $HOME !

  echo "".len(foundWindows)." matching windows"
  for wn in foundWindows
    echo "  <".wn."> ".bufname(winbufnr(wn))
  endfor
  echo " "
  echo "".len(foundBuffers)." matching buffers"
  for bn in foundBuffers
    echo "  (".bn.") ".bufname(bn)
  endfor

endfunction

command! JoeysBufferSwitch call JoeysBufferSwitch()

nnoremap <C-B> :JoeysBufferSwitch<Enter>

