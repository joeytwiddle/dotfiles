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



" Let's test the CursorHold idea...

if &ch < 3
  " We need this or we won't see echo and record when they are both printed.
  set ch=3
endif

let s:earlierActions = []
let s:maxToRecord = 30

function! s:EndActionDetected(trigger)
  " Stop the macro recording (register will not be set until then)
  normal q
  let lastAction = @x
  if lastAction == ""
    " This was a CursorMoved event because of some editing we did, but not an
    " actual movement.  We don't record (or display) an empty action!
    " echo "Null action triggered by ".a:trigger
  else
    echo "Your last action was: " . s:MyEscape(lastAction) . " (triggered by ".a:trigger.")"
    call add(s:earlierActions,lastAction)
    if len(s:earlierActions) > s:maxToRecord
      call remove(s:earlierActions,0)
    endif
  endif
  " Start recording the next action
  normal qx
endfunction

function! s:MyEscape(str)
  let out = ""
  let i = 0
  while i < len(a:str)
    let char = a:str[i]
    if char2nr(char) < 32 || char2nr(char) > 126
      let out = out . '#' . char2nr(char)
    else
      let out = out . char
    endif
    let i = i+1
  endwhile
  return out
endfunction

augroup RepeatLast
  autocmd!
  autocmd CursorHold * call s:EndActionDetected("CursorHold")
  " I get the feeling the CursorHold event is not being called whilst we are in
  " macro recording mode, but is called fine when we leave it.  Sob!
  autocmd InsertLeave * call s:EndActionDetected("InsertLeave")
  " InsertLeave does appear to fire!  Great!  Except without CursorHold it
  " means we detect all movements before the edit also.  :(
  autocmd CursorMoved * call s:EndActionDetected("CursorMoved")
augroup END


function! s:RepeatLast(num)
  " TODO: Do we need to stop the macro recording?
  normal q
  call s:ShowRecent(a:num)
  " Start recording again
  normal qx
endfunction

" ShowRecent is for debugging.  It pastes into the file rather than using echo
" because echo display gets messed up because special chars (e.g. \n) are not
" escaped.  If we can escape them
function! s:ShowRecent(num)
  let @z = "Your most recent actions were:\n"
  normal "zp
  let i = len(s:earlierActions) - 5
  if i < 0
    let i =0
  endif
  while i < len(s:earlierActions)
    let @z = i . ") " . s:earlierActions[i] . "\n"
    normal "zp
    let i = i+1
  endwhile
endfunction

map <Leader>? :ShowRecent 5<Enter>
command! -nargs=* ShowRecent call <SID>ShowRecent(<q-args>)

map <Leader>. :RepeatLast<Enter>
command! -count=1 RepeatLast call <SID>RepeatLast()


