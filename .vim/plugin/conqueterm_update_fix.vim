" TODO: We should disable these autocommands when the (last?) conqueterm is closed.  Otherwise they continue to use CPU.
" In the meantime, you can run this command in Vim after you have closed conqueterm:
"     :StopUpdatingConque
" or:
"     :augroup UpdateConque <Bar> au! <Bar> augroup END

command! StopUpdatingConque :call StopUpdatingConque()
function! StopUpdatingConque()
  augroup UpdateConque
    au!
  augroup END
endfunction

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

