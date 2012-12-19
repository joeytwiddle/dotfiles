" Repeats the last few actions you made

" The '.' key is fantastic at repeating the last 1 action you made.  But
" sometimes I do three actions, and then want to repeat them again.

" My goal would be to make "3\." do that.

" One approach might be to record a macro *all* the time, and then take the
" last few things we need from it, when "\." is called.

" The problem is, the macro might contain 12 keys which actually represent
" only 2 actions.  For example "cwNewWord" is only one action.

" Having to interactively select how much of the macro to choose will slow
" down the process, and lose the whole advantage of this feature.

" So... can we split up the keys the macro recorded into actions?
"   - By parsing the macro from the start, we might be able to
"   - We could watch for mode changes such as InsertEnter, CursorHold, and
"     perhaps use these to split up our macro keys while they are being
"     generated.  Still this leaves us not knowing how to split non-modechange
"     commands, e.g. "3r_" is one action.

" We will use register x to store our stuff.
" You must have this macro recording on ALL THE TIME!

normal qx

function! s:RepeatLast(num)
  call s:ShowLast(a:num)
endfunction!

function! s:ShowLast(num)
  normal q
  let @z = "Your action history macro is:\n"
  normal "zP
  let @z = @x . "\n"
  normal "zp
  normal qx
endfunction!

map <Leader>. :RepeatLast 5<Enter>
command! -nargs=* RepeatLast call <SID>RepeatLast(<q-args>)

