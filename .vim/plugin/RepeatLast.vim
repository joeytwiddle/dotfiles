" Repeats the last few actions you made

" The '.' key is fantastic at repeating the last 1 action you made.  But
" sometimes I do three actions, and then want to repeat them again.

" Usage: Assuming your mapleader is "\"
"
"   \?   Show a list of recent actions
"
"   4\?  Show the last four actions
"
"   \.   Repeat the last action (the same as .)
"
"   4\.  Repeat the last four actions


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


" Options

if !exists("g:RepeatLast_Confirmation")
  let g:RepeatLast_Confirmation = 1
endif

if !exists("g:RepeatLast_Show_Recording")
  let g:RepeatLast_Show_Recording = 0
endif


" We will use register x to store our stuff.  Search and replace @x and qx if
" you want.
" We must have this macro recording on ALL THE TIME!  This is achieved by
" EndActionDetected().

" BUG: If we are already recording a macro, this will stop it and then 'x'
" will delete 1 char!  We need to detect whether macro recording is active.
normal qx



" This is

if g:RepeatLast_Show_Recording != 0 &ch < 3
  " We need this or we won't see echo because "record" will overwrite it.
  set ch=3
endif

let s:earlierActions = []
let s:maxToRecord = 30

function! s:EndActionDetected(trigger)

  " Stop the macro recording (its register will not be set until then)
  normal q

  let lastAction = @x
  let leadRE = GetEscapedMapLeader()

  if lastAction == ""
    " This often triggers from a CursorMoved event because of some editing we did.
    " But other triggers already recorded the action.  So CursorMoved has
    " nothing to see.  We don't record or display this empty action.
    if g:RepeatLast_Show_Recording != 0
      echo "Null action triggered by ".a:trigger
    endif

  " Now follow a bunch of checks for actions we DO NOT want to record.
  " Note that unlike '.' we DO want to record movement as an action.
  elseif substitute(lastAction,"[0-9]*u$","","") != lastAction            " Detects undo actions
      || substitute(lastAction,"[0-9]*". leadRE . "\.$") != lastAction    " Detects a call to RepeatLast
      || substitute(lastAction,"[0-9]*". leadRE . "\?$") != lastAction    " Detects a call to ShowRecent

    if g:RepeatLast_Show_Recording != 0
      echo "Ignoring non-action: " . s:MyEscape(lastAction) . " (triggered by ".a:trigger.")"
    endif

  else

    " OK this is an action we do want to record
    if g:RepeatLast_Show_Recording != 0
      echo "Your last action was: " . s:MyEscape(lastAction) . " (triggered by ".a:trigger.")"
    endif
    call add(s:earlierActions,lastAction)
    if len(s:earlierActions) > s:maxToRecord
      call remove(s:earlierActions,0)
    endif

  endif

  " Start recording the next action
  normal qx

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



function! s:ShowRecent(num)

  let numWanted = a:num
  if numWanted == 0
    let numWanted = 10   " default
  else
    " Fix because <count> is a range, not just the number we gave it
    let numWanted = numWanted - line(".") + 1
  endif

  echo "Your last ".numWanted." actions were:"

  let start = len(s:earlierActions) - numWanted
  if start < 0
    let start = 0
  endif

  for i in range(start,len(s:earlierActions)-1)
    let howFarBack = len(s:earlierActions) - i
    echo howFarBack . ") " . s:earlierActions[i] . "\n"
  endfor

endfunction

function! s:RepeatLast(num)

  let numWanted = a:num
  if numWanted == 0
    let numWanted = 1   " default
  else
    " Fix because <count> is a range, not just the number we gave it
    let numWanted = numWanted - line(".") + 1
  endif

  let actions = ""
  let start = len(s:earlierActions) - numWanted
  if start < 0
    let start = 0
  endif
  for i in range(start,len(s:earlierActions)-1)
    let actions = actions . s:earlierActions[i]
  endfor

  "echo "OK repeating: " . s:MyEscape(actions)
  " We don't get to see the echo.  Let's use a confirm instead:
  if g:RepeatLast_Confirmation != 0
    let res = confirm("About to do: " . s:MyEscape(actions) . " OK?", "&Yes\n&No")
    if res != 1
      return
    endif
  endif

  " TODO: Do we really need to stop the macro recording?
  " normal q
  exec "normal ".actions
  " Start recording again
  " normal qx
endfunction

" Returns an escaped copy of mapleader which we can use in regexps.
" Currently only fixes \.  Needs work for other strange chars.
function! s:GetEscapedMapLeader()
  let escapedLeader = substitute(&mapleader,"\\","\\","g")
  return escapedLeader
endfunction

" Returns a string with all special chars turned into "#nnn" so we can display
" it with echo without making a mess.
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

map <Leader>? :ShowRecent<Enter>
command! -count=0 ShowRecent call <SID>ShowRecent(<count>)

map <Leader>. :RepeatLast<Enter>
command! -count=0 RepeatLast call <SID>RepeatLast(<count>)

