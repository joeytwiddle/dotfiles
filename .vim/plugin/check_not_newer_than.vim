
function! CheckNotNewerThan(fname)
  let otherFile = a:fname
  " echo "otherFile=".otherFile
  if filereadable(otherFile)
    let thisFile = expand("%")
    let thisModified = getftime(bufname("%"))
    let otherModified = getftime(otherFile)
    " echo "This: ".thisModified." Other: ".otherModified
    if otherModified > thisModified
      "" Displays but does not wait for keypress, may disappear quickly without being seen!
      " echoerr "..."
      let res = confirm("Warning! File ".otherFile." is newer than this one!\nPerhaps you should be editing that instead!","&Press Enter")
    endif
  endif
endfunction

command! -nargs=1 CheckNotNewerThan call CheckNotNewerThan(<q-args>)

