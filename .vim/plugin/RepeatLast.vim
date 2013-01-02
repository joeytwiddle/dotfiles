" RepeatLast.vim by joeytwiddle
"
" Provides <count>\. to repeat the last group of actions you performed.
"
" The '.' key is fantastic at repeating the last 1 action you made.  But
" sometimes I do three actions, and then want to repeat them again.  Now
" this is just 3\.



" == Usage ==
"
" Assuming your mapleader is '\' (the default):
"
"   \?   Display a list of recently recorded actions
"
"   4\?  Display the last four recorded actions
"
"   4\.  Repeat the last four actions
"
"   \.   Repeat the last action (similar to .)
"
"   3\D  Forget (drop) last 3 actions (useful to get back to earlier state)
"
"   \D   Drops just the last 1 action.
"
" Why is it similar to . but not the same?  Well the main difference is that
" our \. commands also replay *movement* actions.  So if you just moved,
" unlike . , \. will replay the last movement, not the last change!  Use \D
" to discard recently recorded but unwanted movements.
"
"   :RepeatLastOn    Disables action recording, leaves macro record mode.
"
"   :RepeatLastOff   Enables action recording, enters macro record mode.



" == Limitations ==
"
" Unlike '.' we DO want to record movements (as part of a 4-action sequence).
" Unfortunately this means we cannot freely move to a new position between
" repeating our last actions, as that movement will become part of the list!
"
" In other words, you can do do '4\.4\.' just fine, provided your group of
" actions leaves you in the right place for the next.  But if you try to do
" '4\.<some_movement>4\.' the <some_movement> will be recorded as new actions,
" so the second '4\.' will not do the same as the first '4\.'!  We have now
" added \D so that unwanted actions can be removed.
"
" It uses macro recording ALL THE TIME.  The word "recording" will forever be
" displayed in your command-line, hiding any text displayed there.  To see the
" hidden messages, you can set ch=2.
"
" If you want to record your own macro, you will need to disable the plugin
" with :RepeatLastOff.
"
" Also CursorHold events do not fire in macro-recording mode.  Any visual
" tools, taglist updates or so on that require CursorHold will not be
" triggered.  Other events including CursorMove work fine.



" == Bugs and TODOs ==
"
" Using register x, occasionally we do 'qx' to start recording but recording
" is already in progress!  This stops recording and 'x' deletes one char.
" Bad!  We need to detect whether recording is in progress or not.
" We could also use a less harmful register, but that's not the true solution.
" TODO: Since it appears Vim does not currently expose the state of recording,
" moving to a less harmful register, e.g. 'z', might be wise.
"
" DONE: Offer a way to toggle on/off at runtime.
"
" TODO: To deal with recording of movements we don't want, an alternative
" (optional) approach might be to go modal.  After the first use of '4\.' stop
" recording (at the very least movements) so that the user can move around and
" '4\.' in other places.  Perhaps we could re-enable recording with some
" simple heuristic, like if the user makes more than 12 keystrokes without
" re-using '\.'.
"
" TODO: Or we could do something like "do not officially add movement actions
" to the history *until* they are followed by an edit action".  This would
" allow us to move freely after a set of actions, and then repeat them without
" having to worry about the extra movement actions.  However it would also
" *prevent* us from ending an action-group in a movement that might move it to
" the correct place for the next movement.
"
" TODO: We might try to restore CursorHold events by periodically letting Vim
" out of recording mode, but re-enabling recording as soon as CursorHold
" fires!  A downside might be that we would fail to record keystrokes typed
" very quickly after the release (before CursorHold fires).



" == Original development brainstorm ==

" One approach might be to record a macro *all* the time, and then take the
" last few things we need from it, when "\." is called.

" The problem is, the macro might contain 12 keys which actually represent
" only 2 actions.  For example "cwNewWord" is only one action.

" Having to interactively select how much of the macro to use will slow down
" the process, and lose the whole advantage of this feature.

" So... can we split up the keys the macro recorded into actions?
"
"   - By parsing the macro from the start, we might be able to.  Hard work.
"
"   - We could watch for mode changes such as InsertEnter, CursorHold, and
"     perhaps use these to split up our macro keys while they are being
"     generated.  Still this will leave us not knowing how to split actions
"     which do not change mode.  But it seems a great many do call
"     CursorMoved.  :)
"
"     We are taking this approach.

" Other alternatives?  Possibly by watching undo history (like UndoTree does)
" or :changes (I'm not sure we can access this), or doing raw diffs on the
" file, we might be able to crudely discover what changes the user has made,
" and convert these into repeatable actions.  Sounds pretty heavy.



" == Options ==
" You may toggle these at runtime

" When 5\. is requested, will first display the actions and ask Y/N.
if !exists("g:RepeatLast_Request_Confirmation")
  let g:RepeatLast_Request_Confirmation = 0
endif
" DO NOT USE THIS yet because...
"
" NASTY BUG: If your window is small enough, the use of a confirm dialog will
" often cause the appearance of the dreaded "Press ENTER or type command to
" continue" message.  Whatever you press to get rid of it _will_be_recorded_!
"
" That stroke will now become part of the next \. you try to use.  Argh!
" You might avoid this by ensuring your window is at least 80 columns wide,
" and by expanding 'cmdheight'.
"
" In future we could add s:skipNextStroke to avoid recording that char,
" although if the message does not appear, it may skip a wanted stroke.  :f
"
" In fact this bug exists even with this disabled.  We sometimes get the
" message from \? and whatever key we press to dismiss it will eventually be
" recorded (although actually not until the next trigger occurs).

" For debugging, echoes data about actions as they are recorded.
if !exists("g:RepeatLast_Show_Recording")
  let g:RepeatLast_Show_Recording = 0
endif



" == Mappings and Commands ==

map <Leader>? :ShowRecent<Enter>
command! -count=0 ShowRecent call <SID>ShowRecent(<count>)

map <Leader>. :RepeatLast<Enter>
command! -count=0 RepeatLast call <SID>RepeatLast(<count>)

map <Leader>D :DropLast<Enter>
command! -count=0 DropLast call <SID>DropLast(<count>)

command! RepeatLastOn if !g:RepeatLast_Enabled | let g:RepeatLast_Enabled = 1 | exec "normal! qx" | echo "RepeatLast enabled." | sleep 800ms | endif
command! RepeatLastOff if g:RepeatLast_Enabled | let g:RepeatLast_Enabled = 0 | exec "normal! q" | echo "RepeatLast disabled." | sleep 800ms | endif
" These sleeps are to ensure the message is seen even if ch=1.  (Otherwise
" in the first case it is immediately hidden by qx "recording" message.)



" == Recording Actions ==

if g:RepeatLast_Show_Recording != 0 && &ch < 3
  " We need this or we won't see the echo because "recording" will overwrite it.
  " Pushed up to 3 because occasionally we echo 2 lines.
  set ch=3
endif

" We will use register x to store our stuff.  Search and replace @x and qx if
" you want.
"
" We want to have this macro recording on ALL THE TIME!  This is achieved in
" EndActionDetected().

" BUG: If we are already recording a macro, 'q' will stop it and then 'x'
" will delete 1 char!  We need to detect whether macro recording is active!

normal! qx

let g:RepeatLast_Enabled = 1

" We are going to record a history of recent actions
let s:earlierActions = []
let s:maxToRecord = 30

" We are going to trigger a function to look for new entries in our macro.
augroup RepeatLast
  autocmd!
  " autocmd CursorHold * call s:EndActionDetected("CursorHold")
  " The CursorHold event is not called whilst in macro recording mode.
  " CursorMoved does the job though.  Not sure if we need InsertLeave.  It
  " appears to always trigger CursorMoved immediately afterwards.
  " autocmd InsertLeave * call s:EndActionDetected("InsertLeave")
  autocmd CursorMoved * call s:EndActionDetected("CursorMoved")
augroup END

function! s:EndActionDetected(trigger)

  if !g:RepeatLast_Enabled
    return
  endif

  " Stop the macro recording (its register will not be set until then)
  normal! q

  let lastAction = @x

  let leadRE = s:GetEscapedMapLeader()
  let extraReport = ""

  "" We do not want to record keystrokes used to invoke this plugin's
  "" features.  We used to clear them out here.
  ""
  "" This is no longer needed as ShowRecent and RepeatLast now forcefully
  "" empty the macro.  We may want to bring this stuff back, if we find
  "" unwanted '\? ' or '\.\n' keystrokes being recorded again.
  ""
  "" If we invoke \? or \. this does not get recorded immediately because no
  "" CursorMoved is triggered.  So we sometimes get a long action starting
  "" with \? but then followed by other stuff.  Let's strip it off the front.
  ""
  "" \? is often followed by a space or \n that is the user's response to
  "" "Please press ENTER or type command to continue".
  ""
  "" The late triggering that allowed us to detect and remove this char could
  "" be considered desirable.  However that char might have been a valid
  "" movement, if the message was not displayed (which we do not know!).
  "
  " let cleanedAction = lastAction
  " let cleanedAction = substitute(cleanedAction,"^[0-9]*". leadRE ."\?[ \r]?","","")
  " let cleanedAction = substitute(cleanedAction,"^[0-9]*". leadRE ."\.[ \r]?","","")
  " if cleanedAction != lastAction && g:RepeatLast_Show_Recording != 0
    " let extraReport = "Cleaned up action: \"". s:MyEscape(lastAction) ."\" now: \"". s:MyEscape(cleanedAction) . "\""
    " echo extraReport
    " " This echo is almost always hidden by "Detected action:" later.  So
    " " that's why we put the string into extraReport so it can display it!
    " let extraReport = extraReport . "\n"
  " endif
  " let lastAction = cleanedAction

  if lastAction == ""

    " This empty action is often triggered from a CursorMoved event
    " immediately after some editing we did.  Another trigger (e.g.
    " InsertLeave) already recorded the action, so CursorMoved has nothing to
    " see.  We don't record or display this empty action.
    "if g:RepeatLast_Show_Recording != 0
      "echo extraReport . "Null action triggered by ".a:trigger
    "endif

  " Now follow checks for actions we DO NOT want to record.
  " Note that unlike '.' we DO want to record movement as an action.
  " TODO: We can use match(2) instead of substitute(4)!=original
  " 1) Detects undo actions
  elseif substitute(lastAction,"^[0-9]*u$","","") != lastAction

    if g:RepeatLast_Show_Recording != 0
      echo extraReport . "Ignoring unwanted action: \"" . s:MyEscape(lastAction) . "\" (triggered by ".a:trigger.")"
    endif

  else

    " OK this is an action we do want to record
    if g:RepeatLast_Show_Recording != 0
      echo extraReport . "Detected action: \"" . s:MyEscape(lastAction) . "\" (triggered by ".a:trigger.")"
    endif
    call add(s:earlierActions,lastAction)
    if len(s:earlierActions) > s:maxToRecord
      call remove(s:earlierActions,0)
    endif

  endif

  " Start recording the next action
  normal! qx

endfunction



" == User Interface ==

function! s:ShowRecent(num)

  let numWanted = a:num
  if numWanted == 0
    let numWanted = 10   " default
  else
    " Fix because <count> is a range, not just the number we gave it
    let numWanted = numWanted - line(".") + 1
    " TODO: Alternative fix: <bairui> joeytwiddle: :command! -count=1 Foo echo (v:count ? v:count : <count>)
  endif

  echo "Recent actions are:"

  let start = len(s:earlierActions) - numWanted
  if start < 0
    let start = 0
  endif

  for i in range(start,len(s:earlierActions)-1)
    let howFarBack = len(s:earlierActions) - i
    echo howFarBack . " \"" . s:MyEscape(s:earlierActions[i]) . "\"\n"
  endfor

  " We want to discard the keystrokes that lead to this call.
  " Force an event trigger?
  " call s:EndActionDetected("ShowRecent")
  " No.  Just clear the macro.
  if g:RepeatLast_Show_Recording != 0
    echo "Dropping hopefully unwanted action: \"". s:MyEscape(@x) ."\""
    " Curiously, this seemt to keep displaying my *previous* stroke, and not
    " '\?' unless I perform it a second time.
  endif
  " The qx prints "recording" over our last echoed line, even if ch is large.
  " I don't know why this happens.  Let's make it a line we don't need to see!
  echo "I will get hidden"
  normal! q
  normal! qx

endfunction

function! s:RepeatLast(num)

  let numWanted = a:num
  if numWanted == 0
    let numWanted = 1   " default
  else
    " Fix because <count> is a range, not just the number we gave it
    let numWanted = numWanted - line(".") + 1
    " TODO: Alternative fix: <bairui> joeytwiddle: :command! -count=1 Foo echo (v:count ? v:count : <count>)
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
  if g:RepeatLast_Request_Confirmation != 0
    let res = confirm("About to do: \"" . s:MyEscape(actions) . "\" OK?", "&Yes\n&No")
    if res != 1
      echo "Repeat cancelled."
      " Empty the macro so we won't record the command that invoked us.
      normal! q
      normal! qx
      return
    endif
  endif

  " Do we really need to stop the macro recording?  It appears not.
  " normal! q
  exec "normal! ".actions
  " Start recording again
  " normal! qx

  " We want to discard the keystrokes that lead to this call.
  " Force an event trigger?
  " call s:EndActionDetected("ShowRecent")
  " No.  Just clear the macro.
  if g:RepeatLast_Show_Recording != 0
    echo "Dropping hopefully unwanted action: \"". s:MyEscape(@x) ."\""
  endif
  " The qx prints "recording" over our last echoed line, even if ch is large.
  " I don't know why this happens.  Let's make it a line we don't need to see!
  echo "I will get hidden"
  normal! q
  normal! qx

endfunction

function! s:DropLast(num)

  let numWanted = a:num
  if numWanted == 0
    let numWanted = 1   " default
  else
    " Fix because <count> is a range, not just the number we gave it
    let numWanted = numWanted - line(".") + 1
    " TODO: Alternative fix: <bairui> joeytwiddle: :command! -count=1 Foo echo (v:count ? v:count : <count>)
  endif

  if numWanted > len(s:earlierActions)
    let numWanted = len(s:earlierActions)
    echo "Larger count given than possible.  Dropping only ".numWanted
  endif

  let deletedActions = remove(s:earlierActions, len(s:earlierActions)-numWanted, len(s:earlierActions)-1)

  echo "Deleted last ".numWanted." actions."
  for i in range(len(deletedActions))
    echo "- \"" . s:MyEscape(deletedActions[i]) . "\""
  endfor

  " This clears our current macro, which is needed.
  " You can remove this call to ShowRecent, but then you should use its macro
  " clearing code!
  call s:ShowRecent(0)

endfunction



" == Library Functions ==

" Returns an escaped copy of mapleader which we can use in regexps.
" Currently only fixes \ (returning \\).  Needs work for other strange chars.
" Actually if we never re-enable the checks in EndActionDetected() then we
" won't need this.
function! s:GetEscapedMapLeader()
  let current = '\'
  if exists("mapleader")
    let current = mapleader
  endif
  let escapedLeader = substitute(current,'\','\\\\',"g")
  " echo "len Escaped Leader: " . len(escapedLeader)
  return escapedLeader
endfunction

" Returns a string with all special chars turned into "#nnn" so we can display
" it via echo without making a mess.
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

