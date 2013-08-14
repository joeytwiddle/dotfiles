
" My magical JS syntax rules just make a mess in jade
"syntax clear OperatorMinus
"syntax clear javascriptParens
"syntax clear javascriptNumber
"syntax clear javascriptAssignVar

if maparg("gF", 'n') == ''
  nnoremap <buffer> gF :call <SID>LoadJadeOrBladeFile()<CR>
endif

function! s:LoadJadeOrBladeFile()
  let cfile = expand("<cfile>")
  let fname = cfile
  if !filereadable(fname)
    for root in [expand("%:h"), '.', './views']
      let fname = root . "/" . cfile
      if filereadable(fname) | break | endif
      let fname = root . "/" . cfile . ".jade"
      if filereadable(fname) | break | endif
      let fname = root . "/" . cfile . ".blade"
      if filereadable(fname) | break | endif
    endfor
  endif
  if filereadable(fname)
    let fname = simplify(fname)
    "exec "edit ".fname
    call feedkeys(":edit ".fname."\n")
    " Using feedkeys prevents this function being blamed if any errors/warnings occur!
  else
    " Both of these show "error in function" :P
    normal! gF
    "echoerr "Can't find file ".cfile." in path"
  endif
endfunction

