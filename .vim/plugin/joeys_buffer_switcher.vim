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

" I had an issue on Ubuntu 12.04 that Tab-complete was does nothing during the prompt.
" At that time I disabled the plugin and used this fallback:
"nnoremap <C-e> :set nomore <Bar> :ls <Bar> :set more <CR>:b<Space>
"finish

" You are recommended to bind this plugin to a key, for example one of these:
"   nnoremap <C-E> :<C-U>JoeysBufferSwitch<CR>
"   nnoremap <Leader>b :<C-U>JoeysBufferSwitch<CR>

" Some alternatives to this plugin are:
"   nnoremap <C-E> :ls<CR>:b<space>
"   nnoremap <C-B> :BufExplorer<Enter>
"   nnoremap <Leader>b :MRU<Enter>
"   nnoremap <Leader>o :e .<Enter>
"   nnoremap <Leader>f :Explore .<Enter>

let g:JBS_Show_Buffer_List_First = get(g:, "JBS_Show_Buffer_List_First", 1)

command! JoeysBufferSwitch call JoeysBufferSwitch()

function! JoeysBufferSwitch()
  " If a count was provided before the keypress, then jump directly to the buffer with that number
  if v:count > 0
    exec v:count . "b"
    return
  endif
  " TODO: Consider improving that by jumping to the window containing that buffer, if it is visible.

  let more_was = &more
  if g:JBS_Show_Buffer_List_First
    " This successfully prevents the "-- More --" pager, but it still demands "Press ENTER to continue" message!
    " However doing `:set more` and `:set nomore` on the cmdline had a stronger effect, so perhaps that is different from setting `&more`.
    " DONE: Or perhaps we should re-enable &more only *after* we have asked for searchStr input - that may be what was triggering the "Press ENTER" message.
    let &more = 0
    execute "ls"
  endif

  try
    " We previously used "buffer" as the completion target, but now we have our own
    let searchStr = input("Type part of buffer then <Tab> or <Enter>: ", '', "customlist,CompleteBuffersAndFiles")
  catch
    echo "Error!"
    return
  endtry

  let &more = more_was

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

  " DONE: If we can find a visible window displaying that buffer, switch to
  " the window instead of loading the buffer in the current window.

  " TODO: Is there an exact matching buffer by string?  Done later...  But
  " shouldn't we try it first?  Exact buffer should really override partial
  " window match.  (e.g. foo.c.old is visible but we want to switch to foo.c)

  " DONE: We get some weird buffers/windows when looping these lists, e.g.
  " previously closed buffers, duplicates, etc.  We probably want to filter
  " out some of them according to their properties.

  " DONE: Exact matching should be a special var in each case.  We cannot rely
  " on len==1 to be sure that is what wss found.

  " Search windows for partial match. Hopefully there is only 1 (unambiguous).
  let foundWindows = []
  let foundExactWindow = -1
  let winCount = winnr('$')
  let i = 1
  while i <= winCount
    let winName = bufname(winbufnr(i))
    " Exact match causes single response
    " We use resolve and expand so that e.g. /home/joey/.vimrc will match ~/.vimrc
    if resolve(expand(winName)) == resolve(expand(searchStr))
      let foundExactWindow = i
      break
    " Otherwise we collect partial matches
    elseif match(winName, searchExpr) >= 0
      call add(foundWindows, i)
    endif
    let i += 1
  endwhile

  " Search buffers for partial or exact match.
  let foundBuffers = []
  let foundExactBuffer = -1
  let bufCount = bufnr('$')
  let i = 1   " bufname says: Number zero is the alternate buffer for the current window.
  while i <= bufCount
    let bufName = bufname(i)
    " TODO: Some buffers need to be ignored e.g. if they are closed (no longer visible)
    if bufexists(i) && buflisted(i) && bufName != ""
      " Special case: exact match means we return it as the only match!
      if bufName == searchStr
        "echo "Found exact match: ".i.": ".bufName
        " Does not work: sometimes it's a closed buffer, so :<i>b fails!
        let foundExactBuffer = i
        break
        " Opening by name seems safer:
        "exec ":b ".bufName
        " But that occasionally fails with: E93: More than one match for ...
        "exec ":".i."b"
        "return
      elseif match(bufName, searchExpr) >= 0
        call add(foundBuffers, i)
      endif
    endif
    let i += 1
  endwhile

  if foundExactWindow >= 0
    "echo "Switching to window ".foundExactWindow
    exec foundExactWindow."wincmd w"
    return
  endif
  if foundExactBuffer >= 0
    "echo "Loading buffer ".foundExactBuffer
    exec foundExactBuffer."b"
    return
  endif

  if len(foundWindows) == 1 && len(foundBuffers) <= 1
    "echo "Switching to window ".foundWindows[0]
    exec foundWindows[0]."wincmd w"
    return
  endif
  if len(foundBuffers) == 1 && len(foundWindows) == 0
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

  " The echoed text was appearing immediately after the text the user input; it refused to appear on the line below, even if we called an empty echo first.  But redraw solved that.
  redraw
  let more_was = &more
  let &more = 0
  echo len(foundWindows).' windows match "'.searchStr.'"'
  for wn in foundWindows
    echo "  <".wn."> ".bufname(winbufnr(wn))
  endfor
  echo len(foundBuffers).' buffers match "'.searchStr.'"'
  for bn in foundBuffers
    echo "  (".bn.") ".bufname(bn)
  endfor
  let &more = more_was

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

  let bufSearchExpr = '\V' . a:ArgLead
  let buffers = []
  let bufCount = bufnr('$')
  let i=0
  while i <= bufCount
    let bufName = bufname(i)
    if bufexists(i) && buflisted(i) && match(bufName, bufSearchExpr) >= 0
      call add(buffers, bufName)
    endif
    let i = i + 1
  endwhile

  call extend(files, buffers)

  let files = s:ListWithoutDuplicates(files)
  return files
endfunction

function! s:ListWithoutDuplicates(list)
  let seen = {}
  let newlist = []
  for i in range(len(a:list))
    if !get(seen,a:list[i])
      call add(newlist, a:list[i])
      let seen[a:list[i]] = 1
    endif
  endfor
  return newlist
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

