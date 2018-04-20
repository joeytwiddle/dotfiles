" This was a quick prototype based on FoldBlocks.  It could use some improvement.
" Specifically, it doesn't fold in any hierarchy, it just collapses each section flat, regardless of its level.

function! FoldMarkdown()

  let oldWrapScan = &wrapscan
  let oldLine = line(".")
  set nowrapscan
  " Clear existing folds and go to top
  set foldmethod=manual
  normal zE
  normal gg

  "" New method, using search()
  let seek = '^#'
  let nonBlank = '^.'
  normal v
  while 1
    let line = search(seek)
    if line <= 0
      " Build the last fold (which will drop us out of visual)
      normal G
      normal zf
      break
    endif
    call cursor(line, 1)
    " Go back to the previous non-black line
    let blankLine = search(nonBlank, 'b')
    if blankLine > 0
      call cursor(blankLine, 1)
    endif
    normal zf
    normal 
    " Go forward to the start of the next section, and enter visual mode again
    call cursor(line, 1)
    normal v
  endwhile

  let &wrapscan = oldWrapScan
  exec oldLine.":"

endfunction

command! FoldMarkdown call FoldMarkdown()

