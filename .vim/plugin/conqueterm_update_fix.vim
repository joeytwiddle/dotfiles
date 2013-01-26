function! UpdateConque()
  let s:startWin = winnr()
  let s:updatetimePrev = &updatetime
  wincmd b
  startinsert
  augroup UpdateConque
    autocmd!
    autocmd CursorHold * call UpdateConqueDone()
    autocmd CursorHoldI * call UpdateConqueDone()
  augroup END
  set updatetime=0
endfunction

function! UpdateConqueDone()
  exec ":set updatetime=".s:updatetimePrev
  augroup UpdateConque
    autocmd!
    autocmd CursorHold * call UpdateConque()
    autocmd CursorHoldI * call UpdateConque()
  augroup END
  stopinsert
  " Maybe wincmd p would do this anyway
  exec s:startWin."wincmd w"
endfunction

