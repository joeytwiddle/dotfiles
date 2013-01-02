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
"   \.   Repeat the last action (similar to . but may replay just a movement)
"
"   \D   Forget (drop) the last action (e.g. to discard an unwanted movement)
"
"   3\D  Drop the last 3 recorded actions (useful to get back to earlier state)
"
"   \|  or  \#   Temporarily disable recording of the next few actions.
"
" Commands are also available for the main shortcuts above:
"
"   :ShowRecent   :RepeatLast   :DropLast   :PauseRecording
"
" Commands to toggle state at runtime:
"
"   :RepeatLastOn    Disables action recording, leaves macro record mode.
"
"   :RepeatLastOff   Enables action recording, enters macro record mode.
"
"   :RepeatLast<Tab>  or  :RepeatLast<Ctrl-D>   More commands, to toggle info.
"
" New feature - Auto Ignoring:
"
"   After executing a repeat action, action storage will be *temporarily
"   disabled* for the number of actions specified in:
"
"     g:RepeatLast_Ignore_After_Use_For
"
"   This allows you to move to a new location between executing repeats,
"   without recording those movement actions.  (Movement actions in the
"   *original* executed repeat remain in history so can still be repeated.)
"
"   Action storage can also be temporarily disabled with \| or \#
"
"   Once you have performed enough actions without executing a repeat, action
"   storage will be re-enabled, and the ignored actions will be added to the
"   history as one large entry.



" == Limitations ==
"
" It uses macro recording ALL THE TIME.  The word "recording" will forever be
" displayed in your command-line, hiding any messages usually displayed there
" by Vim's echo.  To make those hidden messages visible, you will need to:
"
"   :set cmdheight=2    or more
"
" (This is preferable to adding frequent calls to sleep, which pause Vim long
" enough to show messages, but can slow down / lock up Vim when we are
" pressing a lot of keys.)
"
" If you want to record your own macro, you can disable the plugin with
" :RepeatLastOff (or you could try just pressing 'q' for a one-time disable).
"
" CursorHold events do not fire in macro-recording mode.  Any visual tools,
" taglist updates, etc. that require CursorHold *will not be triggered*.
" Other events such as CursorMove, InsertLeave, BufWritePost work fine.



" == Old Issue now addressed by "Ignore" feature ==
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
" Now g:RepeatLast_Ignore_After_Use_For mitigates this, unless set to zero.



" == Bugs and TODOs ==
"
" TODO: It would be convenient to add:
"
"   3\X     Delete the 3rd old action from history
"
"   3,7\X   Delete actions 3 to 7 from history (inclusive)
"
"           That stroke may not be allowed.  3\X  5 times should do it.  :-/
"
" TODO: Consider renaming "movement" to "motion" throughout the docs.
"
" Using register x, occasionally we do 'qx' to start recording but recording
" is already in progress!  This stops recording and 'x' deletes one char.
" Bad!  We need to detect whether recording is in progress or not.
" We could also use a less harmful register, but that's not the true solution.
" TODO: Since it appears Vim does not currently expose the state of recording,
" moving to a less harmful register, e.g. 'z', might be wise.
"
" TODO: We could use a way to *start* recording again, if temporary Ignoring
" is enabled but unwanted.  We could just do 10 random movements.  We could
" make \# explicitly toggle (re-enable if ignoring is enabled).  On re-enable
" we may want to clear the current macro; it could well be a mix of unwanted
" and wanted.
"
" DONE: Offer a way to toggle on/off at runtime.
"
" DONE: To deal with recording of movements we don't want, an alternative
" (optional) approach might be to go modal.  After the first use of '4\.' stop
" recording (at the very least movements) so that the user can move around and
" '4\.' in other places.  Perhaps we could re-enable recording with some
" simple heuristic, like if the user makes more than 12 keystrokes without
" re-using '\.'.
"
" CONSIDER: Or we could do something like "do not officially add movement
" actions to the history *until* they are followed by an edit action".  This
" would allow us to move freely after a set of actions, and then repeat them
" without having to worry about the extra movement actions.  However it would
" also *prevent* us from ending an action-group in a movement that might move
" it to the correct place for the next movement.
"
" TODO: We might try to restore CursorHold events by periodically letting Vim
" out of recording mode, but re-enabling recording as soon as CursorHold
" fires!  A downside might be that we would fail to record keystrokes typed
" very quickly after said release (before CursorHold fires).
"
" TODO: Accidentally doing  80\/  instead of  80\?  throws up a lot of error
" messages: "Error detected while processing function
"            MyRepeatedSearch..MyRepeatedSearch..MyRepeatedSearch.."
" This actually comes from joey.vim.  It should fail gracefully when given a
" count.



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
" You may override these defaults in your .vimrc, or change them at runtime

if !exists("g:RepeatLast_Ignore_After_Use_For")
  let g:RepeatLast_Ignore_After_Use_For = 10
endif

" When 5\. is requested, will first display the actions and ask Y/N.
if !exists("g:RepeatLast_Request_Confirmation")
  let g:RepeatLast_Request_Confirmation = 0
endif
" Hopefully "Ignoring" now suppresses the previous issues we had here.
" (That the key used to dismiss the "Press ENTER or type command to continue"
" message was being recorded.)

" How much history to record before discarding
if !exists("g:RepeatLast_Max_History")
  let g:RepeatLast_Max_History = 50
endif

" How much history to display on \?
if !exists("g:RepeatLast_Show_History")
  let g:RepeatLast_Show_History = 16
endif

" Auto-disabled ignoring when an edit is made.  (This feature also necessarily
" disables recovery of ignored events when ignoring times out.)
if !exists("g:RepeatLast_Stop_Ignoring_On_Edit")
  let g:RepeatLast_Stop_Ignoring_On_Edit = 1
endif

" Useful, shows status of ignoring (provided ch>=2)
if !exists("g:RepeatLast_Show_Ignoring_Info")
  let g:RepeatLast_Show_Ignoring_Info = 1
endif

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

command! RepeatLastToggleDebugging let g:RepeatLast_Show_Recording = 1 - g:RepeatLast_Show_Recording

command! RepeatLastToggleInfo let g:RepeatLast_Show_Ignoring_Info = 1 - g:RepeatLast_Show_Ignoring_Info

" Pause recording temporarily (allows movement before executing a repeat)
map <Leader># :PauseRecording<Enter>
map <Leader>\| :PauseRecording<Enter>
command! -count=0 PauseRecording call <SID>PauseRecordingVerbosely()



" == Recording Actions ==

if g:RepeatLast_Show_Recording != 0 && &ch < 3
  " We need this or we won't see the echo because "recording" will overwrite it.
  " Pushed up to 3 because occasionally we echo 2 lines.
  " Not forced for ignoring info
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

let s:ignoringCount = 0

" We are going to record a history of recent actions
let s:earlierActions = []

" We are going to trigger a function to look for new entries in our macro.
augroup RepeatLast
  autocmd!
  " autocmd CursorHold * call s:EndActionDetected("CursorHold")
  " The CursorHold event is not called whilst in macro recording mode.
  " CursorMoved does the job though.  Not sure if we need InsertLeave.  It
  " appears to always trigger CursorMoved immediately afterwards.
  " InsertLeave now wanted for ignoringCount
  autocmd InsertLeave * call s:EndActionDetected("InsertLeave")
  autocmd CursorMoved * call s:EndActionDetected("CursorMoved")
augroup END

function! s:EndActionDetected(trigger)

  if !g:RepeatLast_Enabled
    return
  endif

  if s:ignoringCount > 0

    " If we want to ignore only movements, but auto-re-enable when edits are
    " detected, we can try this.
    " But in order to separate earlier movements from the insert we must force
    " clearing of the macro for general ignoring below.
    if g:RepeatLast_Stop_Ignoring_On_Edit != 0 && a:trigger == "InsertLeave"

      " BUG: I never see this echoed!
        if g:RepeatLast_Show_Ignoring_Info != 0
          echo "Edits detected - no longer ignoring!"
          " sleep 400ms
        endif
      let s:ignoringCount = 0

    else

      let s:ignoringCount -= 1
      if g:RepeatLast_Show_Recording != 0
        echo "Ignoring action triggered by ".a:trigger." and ".s:ignoringCount." more."
      endif
      if g:RepeatLast_Stop_Ignoring_On_Edit != 0
        " To avoid our edit being polluted with previous ignored movements, we
        " must clear them pre-emptively.  A limitation demanded by that
        " feature.  Or perhaps we always do want to forget ignored actions!
        normal! q
        normal! qx
      endif
      if s:ignoringCount == 0
        if g:RepeatLast_Show_Ignoring_Info != 0
          echo "Now listening again."
          " sleep 400ms
        endif
      endif
      " NOTE: Because we do not clear the macro (by stop/start), these events
      " are still being recorded.  When ignoringCount becomes 0, that whole
      " block will enter the history.
      return

    endif

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
    if len(s:earlierActions) > g:RepeatLast_Max_History
      call remove(s:earlierActions,0)
    endif

  endif

  " Start recording the next action
  normal! qx

endfunction



" == User Interface ==

function! s:ShowRecent(num)

  " ISSUES: If ch is set higher than the list which we display (when very few
  " actions have been recorded), then we see only the first line echoed,
  " "Recent actions are:" but none of the actions themselves!
  "
  " OK we solved that by moving the macro clear 'q qx' above the list echo
  " below.  This now causes a blank line gets display before our list, which
  " perhaps we can live with.

  let numWanted = a:num
  if numWanted == 0
    let numWanted = g:RepeatLast_Show_History   " default
  else
    " Fix because <count> is a range, not just the number we gave it
    let numWanted = numWanted - line(".") + 1
    " TODO: Alternative fix: <bairui> joeytwiddle: :command! -count=1 Foo echo (v:count ? v:count : <count>)
  endif

  " We want to discard the keystrokes that lead to this call.
  " Force an event trigger?
  " call s:EndActionDetected("ShowRecent")
  " No.  Just clear the macro.
  " The qx prints "recording" over our last echoed line, even if ch is large.
  " I don't know why this happens.  Let's make it a line we don't need to see!
  " OK since we moved code around, it seems this is no longer needed.
  "echo "I will get hidden"
  normal! q
  normal! qx

  echo "Recent actions are:"

  if numWanted > len(s:earlierActions)
    let numWanted = len(s:earlierActions)
  endif

  " let start = len(s:earlierActions) - numWanted
  " for i in range(start,len(s:earlierActions)-1)
    " let howFarBack = len(s:earlierActions) - i

  for howFarBack in range(numWanted,1,-1)
    let i = len(s:earlierActions) - howFarBack
    echo howFarBack . " \"" . s:MyEscape(s:earlierActions[i]) . "\"\n"
  endfor

  if g:RepeatLast_Show_Recording != 0
    echo "Dropped hopefully unwanted action: \"". s:MyEscape(@x) ."\""
    " This kept displaying my *previous* stroke, and not the '\?' until I
    " performed it a second time.  Better info now we echo *after* q qx.
  endif

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

  if numWanted > len(s:earlierActions)
    let numWanted = len(s:earlierActions)
  endif

  " for howFarBack in range(numWanted,1,-1)
    " let i = len(s:earlierActions) - howFarBack

  let start = len(s:earlierActions) - numWanted
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

  " Do we need to stop the macro recording before running our actions?  It appears not!
  " OK we do need it now we are listening on InsertLeave.  (Or an InsertLeave
  " triggered by our actions would cause storage of current macro '4\.')
  normal! q
  normal! qx
  let s:ignoringCount = 0
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

  call s:PauseRecordingQuietly()

endfunction

function! s:PauseRecordingQuietly()
  let s:ignoringCount = g:RepeatLast_Ignore_After_Use_For
endfunction

function! s:PauseRecordingVerbosely()
  call s:PauseRecordingQuietly()
  if g:RepeatLast_Show_Ignoring_Info != 0
    echo "Ignoring the next ".s:ignoringCount." events."
    " This pause is not too disruptive, because it comes after a request, not
    " in the middle of editing.  We only need it if low ch would hide it.
    if &ch == 1 | sleep 400ms | endif
  endif
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
      let out = out . '<' . char2nr(char) . '>'
    else
      let out = out . char
    endif
    let i = i+1
  endwhile
  return out
endfunction

