" joeys_buffer_switcher: Ctrl-E then type/autocomplete the buffer you want to
" switch to.  If the buffer you wanted is not open, allows autocompletion to a
" filename to open.  If the buffer is open in a window, jumps to that window.

" CONSIDER: If the user enters a number, open that numbered buffer?
" CONSIDER: Allow <file> completion if no matching <buffer> is open.  (Ideally
" we only want file completion IFF buffer completion offers no results).

" BUGS TODO:
" If you press Esc or Ctrl+C it should not proceed to the BufExplorer fallback!
"   The try catch below didn't fix that.
"   Yeah - could not find a way to differentiate between user hitting Enter
"   and user hitting Escape.  FIXEDFORNOW: no BufExplorer fallback
" Also, BufExplorer sometimes requires two presses of Ctrl-O to get out of it.

command! JoeysBufferSwitch call JoeysBufferSwitch()
" Disabled because I am using this for something else now:
"nnoremap <Leader>e :JoeysBufferSwitch<Enter>

"" Some alternatives:
" nnoremap <C-E> :ls<CR>:b<space>
" nnoremap <C-B> :BufExplorer<Enter>
" nnoremap <Leader>b :MRU<Enter>
" nnoremap <Leader>o :e .<Enter>
" nnoremap <Leader>f :Explore .<Enter>

function! JoeysBufferSwitch()

  try
    " We previously used "buffer" as the completion target, but now we have our own
    let searchStr = input("Type part of buffer then <Tab> or <Enter>: ", '', "customlist,CompleteBuffersAndFiles")
  catch
    echo "Error!"
    return
  endtry

  " Quick and dirty:
  "if searchStr != ""
    "silent exec ":b ".searchStr
    "return
  "endif

  if searchStr == ''
    " User couldn't find the file with JBS?  Open a file explorer (with netrw)...
    " exec ":e ."
    return
    " Or open a buffer explorer...
    " if exists(":BufExplorer")
      " exec ":BufExplorer"
      " return
    " endif
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
    " Exact match causes single response
    " We use resolve and expand so that /home/joey/.vimrc will match ~/.vimrc
    if resolve(expand(winName)) == resolve(expand(searchStr))
      let foundWindows = [i]
      break
    " Otherwise we collect partial matches
    elseif match(winName, searchExpr) >= 0
      call add(foundWindows, i)
    endif
    let i += 1
  endwhile
  " BUG: If the user entered an exact buffer match, but this *happened* to hit
  " exactly one partial match in the open window list, we jump to the win when
  " we should really bring up the specific buffer.
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
  " filename offered by input().
  " filereadable() does not work on paths beginning with ~ or $HOME, so first:
  let searchFile = expand(searchStr)
  " if len(foundWindows) == 0 && len(foundWindows) == 0 && filereadable(searchStr)
  if filereadable(searchFile)
    exec ":e ".searchStr
    " exec ":e ".searchFile
    return
  endif

  echo "".len(foundWindows)." matching windows"
  for wn in foundWindows
    echo "  <".wn."> ".bufname(winbufnr(wn))
  endfor
  echo "".len(foundBuffers)." matching buffers"
  for bn in foundBuffers
    echo "  (".bn.") ".bufname(bn)
  endfor

endfunction


function! CompleteBuffersAndFiles(ArgLead, CmdLine, CursorPos)
  let fileglob = a:ArgLead . "*"
  " This seems to list a bunch of help files (which I don't want) and recently used files (which could be useful).
  " We could split the glob ourself into dir and file and then use globpath().
  let files = glob(fileglob, 1, 1)
  " When selecting a folder, append the dir separator, so the user doesn't have to type it to start completing its children.
  for i in range(len(files))
    if isdirectory(files[i])
      let files[i] = files[i] . '/'
    endif
  endfor

  let bufglob = a:ArgLead
  let buffers = []
  let bufCount = bufnr('$')
  let i=0
  while i <= bufCount
    let bufName = bufname(i)
    if match(bufName, bufglob) >= 0
      call add(buffers, bufName)
    endif
    let i = i + 1
  endwhile

  call extend(files, buffers)
  return files
endfunction


" An alternative from VimTips Wiki.

function! BufSel(pattern)
  let bufcount = bufnr("$")
  let currbufnr = 1
  let nummatches = 0
  let firstmatchingbufnr = 0
  while currbufnr <= bufcount
    if(bufexists(currbufnr))
      let currbufname = bufname(currbufnr)
      if(match(currbufname, a:pattern) > -1)
        echo currbufnr . ": ". bufname(currbufnr)
        let nummatches += 1
        let firstmatchingbufnr = currbufnr
      endif
    endif
    let currbufnr = currbufnr + 1
  endwhile
  if(nummatches == 1)
    execute ":buffer ". firstmatchingbufnr
  elseif(nummatches > 1)
    let desiredbufnr = input("Enter buffer number: ")
    if(strlen(desiredbufnr) != 0)
      execute ":buffer ". desiredbufnr
    endif
  else
    echo "No matching buffers"
  endif
endfunction

" I could not find a way to add -complete=file as well as buffer.
command! -complete=buffer -nargs=1 Bs :call BufSel("<args>")
" nnoremap <C-B> :Bs 

