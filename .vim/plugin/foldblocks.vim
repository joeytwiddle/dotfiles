" Fold up all blocks of text separated by 3 (or 2) empty lines.
" This can be a useful fallback if no other folding methods are available,
" e.g. in plain text files, or for a different folding perspective on source
" code.

function! FoldBlocks(numBlankLines)

  let oldWrapScan = &wrapscan
  let oldLine = line(".")
  set nowrapscan
  " Clear existing folds and go to top
  set foldmethod=manual
  normal zE
  normal gg

  "" New method, using search()
  let seek = repeat('\n',a:numBlankLines+1)
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
    call cursor(line,1)
    normal zf
    normal 
    let blankLine = search(nonBlank)
    if blankLine <= 0 || blankLine<line
      break
    endif
    call cursor(blankLine,1)
    normal v
  endwhile

  "" Old method, always emitted one final error:
  " let @f="/^.v/\\n\\n\\nzf"
  " normal 999@f
  " normal 9999
  " normal zf

  let &wrapscan = oldWrapScan
  exec oldLine.":"

endfunction

command! FoldBlocks call FoldBlocks(3)
command! FoldBlocksLite call FoldBlocks(2)

"" Earliest failed attempts:
" :map! :foldblocks<Enter> :set foldmethod=manual<Enter>:0<Enter>zEqf/^.<Enter>v/\n\n\n<Enter>zfq99@f
" :command! FoldBlocks set foldmethod=manual | normal :0<Enter>zEqf/^.<Enter>v/\n\n\n<Enter>zfq99@f
" :command! FoldBlocks set foldmethod=manual | normal :0<C-v>\nzEqf/^.<C-v>\nv/\n\n\n<C-v>\nzfq99@f

