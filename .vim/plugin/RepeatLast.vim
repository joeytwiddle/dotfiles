" RepeatLast.vim by joeytwiddle
"
" Provides <count>\. to repeat the last group of actions you performed.
"
" The '.' key is fantastic at repeating the last 1 action you made.  But
" sometimes I do three actions, and then want to repeat them again.  Now
" this is just 3\.
"
" Beware: It has to use macro recording *all the time*, so it sort of
" takes over your Vim in that respect.  :set ch=2 to feel happier



" == Usage ==
"
" Assuming your mapleader is '\' (the default) adds:
"
"   \?   Display a list of recently recorded actions
"
"   4\?  Display the last four recorded actions
"
"   \.   Repeat the last action (similar to . but may replay just a movement)
"
"   4\.  Repeat the last four actions (including movement actions)
"
"   \D   Forget (drop) the last action (e.g. to discard an unwanted movement)
"
"   3\D  Drop the last 3 recorded actions (useful to get back to earlier state)
"
"   \|  or  \#
"
"        Temporarily enable/disable recording for the next few actions
"
"        (Allows free movement without adding new actions to history)
"
"   4\G  Grab the last 4 actions and store in register 'g'
"
"   @g   Repeat the actions stored in register 'g'
"
"   :let @i=@g
"
"        Copy the actions to register 'i', so 'g' may be overwritten.
"
" Commands are also available for the main shortcuts above:
"
"   :ShowRecent   :RepeatLast   :DropLast   :PauseRecording   :GrabLast
"
" Commands to toggle state at runtime:
"
"   :RepeatLastEnable    Disables action recording, leaves macro record mode.
"
"   :RepeatLastDisable   Enables action recording, enters macro record mode.
"
"   :RepeatLast<Ctrl-D>  or  <Tab>      More commands, some toggle info.
"
" New feature - Auto Ignoring:
"
"   After executing a repeat action, action storage will be *temporarily
"   disabled* for the number of actions specified in:
"
"     g:RepeatLast_Ignore_After_Use_For
"
"   This allows you to move to a new location between executing repeats,
"   without recording those movement actions.  (Of course, movement actions in
"   the *original* repeat remain unaffected.)
"
"   Action storage can also be temporarily disabled with \| or \#
"
"   Once you have performed enough actions without executing a repeat, action
"   storage will be re-enabled, and the ignored actions will be added to the
"   history as one large entry.  Although g:RepeatLast_Stop_Ignoring_On_Edit
"   disables this recovery.
"
" Reading this file:
"
"   You may like to try  :FoldNicely



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
" :RepeatLastDisable (or you could try just pressing 'q' for a one-time disable).
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
" TODO: RepeatLast_Stop_Ignoring_On_Edit might not need to pre-clear the
" macro, if we detect it InsertEnter instead of InsertLeave, although that
" might lose the command that started the insert.  :P

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
" moving to a less harmful register, e.g. 'z' or 'm', might be wise.
" CONSIDER: We can at least notice when recording has been disabled, because
" the CursorHold event will eventually fire (it never fires when recording)!
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
"
" CONSIDER: Perhaps more advanced usage, which would also avoid complications
" with *new* recordings might be to save repeated actions in a register, so it
" can be recalled without worry about ignoring new movements/actions.  We
" could even cycle the register used for saving, if we want to remember older
" interesting action groups.



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

" Set to 1 to start recording from startup.  (Otherwise do :RepeatLastEnable)
if !exists("g:RepeatLast_Enabled")
  let g:RepeatLast_Enabled = 1
endif

" Asks for confirmation before performing a set of repeats.
" When 5\. is requested, will first display the actions and ask Y/N.
if !exists("g:RepeatLast_Request_Confirmation")
  let g:RepeatLast_Request_Confirmation = 0
endif
" Ideally: Should not request confirmation if doing the same as last time!
" In fact ideally it might put it on '.' but I haven't worked out how yet.

if !exists("g:RepeatLast_Leader")
  let g:RepeatLast_Leader = '\'
  " let g:RepeatLast_Leader = &mapleader
  " let g:RepeatLast_Leader = ','
endif

" The register used to store macros.  WARNING: May occasionally accidentally
" fire as a normal keypress!  'm' and 'z' are recommended as they are
" non-edits and non-movements. TODO
if !exists("g:RepeatLast_Register")
  let g:RepeatLast_Register = 'm'
endif

" How many actions to record in history before discarding
if !exists("g:RepeatLast_Max_History")
  let g:RepeatLast_Max_History = 60
endif

" How much history to display on \? when no count is passed
if !exists("g:RepeatLast_Show_History")
  let g:RepeatLast_Show_History = 16
endif

" Auto-disabled ignoring when an edit is made.  (This feature also necessarily
" disables recovery of ignored events when ignoring times out.)
if !exists("g:RepeatLast_Stop_Ignoring_On_Edit")
  let g:RepeatLast_Stop_Ignoring_On_Edit = 1
endif

if !exists("g:RepeatLast_Ignore_After_Use_For")
  let g:RepeatLast_Ignore_After_Use_For = 10
endif

" Useful, shows status of ignoring (provided ch>=2)
if !exists("g:RepeatLast_Show_Ignoring_Info")
  let g:RepeatLast_Show_Ignoring_Info = 1
endif

" For debugging, echoes data about actions as they are recorded.
if !exists("g:RepeatLast_Show_Debug_Info")
  let g:RepeatLast_Show_Debug_Info = 0
endif

" Experimental:
" May lose actions executed very quickly by user (or when Vim is being slow).
if !exists("g:RepeatLast_TriggerCursorHold")
  let g:RepeatLast_TriggerCursorHold = 0
endif



" == Mappings and Commands ==

nnoremap <Leader>? :ShowRecent<Enter>
command! -count=0 ShowRecent call <SID>ShowRecent(<count>)

nnoremap <Leader>. :RepeatLast<Enter>
command! -count=0 RepeatLast call <SID>RepeatLast(<count>)

nnoremap <Leader>D :DropLast<Enter>
command! -count=0 DropLast call <SID>DropLast(<count>)

nnoremap <Leader>G :GrabLast<Enter>
command! -count=0 GrabLast call <SID>GrabLast(<count>)

"command! RepeatLastOn call <SID>RepeatLastOn()
"command! RepeatLastOff call <SID>RepeatLastOff()
command! RepeatLastEnable call <SID>RepeatLastOn()
command! RepeatLastDisable call <SID>RepeatLastOff()

command! RepeatLastToggleInfo let g:RepeatLast_Show_Ignoring_Info = 1 - g:RepeatLast_Show_Ignoring_Info

command! RepeatLastToggleDebugging let g:RepeatLast_Show_Debug_Info = 1 - g:RepeatLast_Show_Debug_Info | let &ch = 5 - &ch

" Pause recording temporarily (allows movement before executing a repeat)
nnoremap <Leader># :TogglePauseRecording<Enter>
nnoremap <Leader>\| :TogglePauseRecording<Enter>
command! -count=0 TogglePauseRecording call <SID>TogglePauseRecording()

" If requested to show debugging messages, make sure they will be visible!
" (At ch=1 "recording" wil overwrite them immediately.)
if g:RepeatLast_Show_Debug_Info != 0 && &ch < 3
  " Pushed up to 3 because occasionally we echo 2 lines.
  " Not forced for info messages, are echoes but hidden at ch 1.
  set ch=3
endif



" We used to use register x to record the most recent event.
" Now we use whatever is set in g:RepeatLast_Register

" For this to work, we need to have this macro recording on *all the time*!
" This is maintained in EndActionDetected().

" BUG: If we are already recording a macro, 'q' will stop it and then 'x'
" will delete 1 char!  We need to detect whether macro recording is active!



" == Recording Actions ==

" We are going to record a history of recent actions
let s:earlierActions = []
let s:earlierActionTriggers = []   " only used for debugging

" We are going to trigger a function to look for new entries in our macro.
augroup RepeatLast
  autocmd!
  " autocmd CursorHold * call s:EndActionDetected("CursorHold")
  " The CursorHold event is not called whilst in macro recording mode.
  " CursorMoved does the job though.  Not sure if we need InsertLeave.  It
  " appears to always trigger CursorMoved immediately afterwards.
  " InsertLeave now wanted for ignoringCount
  autocmd InsertEnter * call s:EndActionDetected("InsertEnter")
  autocmd InsertLeave * call s:EndActionDetected("InsertLeave")
  autocmd CursorMoved * call s:EndActionDetected("CursorMoved")
  " We may need this later if g:RepeatLast_TriggerCursorHold is set.
  autocmd CursorHold * call s:CursorHoldDone()
  " TODO: More triggers to listen on: ShellCmdPost ShellFilterPost
augroup END

" Some things we can try to catch more actions:
" Problem: Captures stuff before the ':' but anything typed after it is lost.
" Would probably have trouble with visual selections too.
"nnoremap <silent> : :call <SID>EndActionDetected("CommandEnter")<Enter>:
" Captures a : command when user hits Enter (many commands do not trigger
" CursorMoves).  Works ok on single line commands but...
" Problem: Messes up my Grep.vim F3 bind (acts during confirm()?), and
"          :FoldBlocks.
"cnoremap <silent> <Enter> <Enter>:call <SID>EndActionDetected("CommandLeave")<Enter>

" Sometimes we skip recording events for a while
let s:ignoringCount = 0

let s:currentlyReplaying = 0
let s:old_updatetime = 0   " When non-zero, we have left macro recording mode.

function! s:StartRecording()               " originally:  normal! qx
  if g:RepeatLast_Enabled
    exec "normal! q".g:RepeatLast_Register
    " This was originally in CursorHoldDone() but may as well go here.
    if s:old_updatetime != 0
      let &updatetime = s:old_updatetime
      let s:old_updatetime = 0
    endif
  else
    if g:RepeatLast_Show_Debug_Info != 0
      echo "StartRecording was called but we are disabled."
    endif
  endif
endfunction
function! s:StopRecording()                " originally:  normal! q
  exec "normal! q"
endfunction
function! s:RestartRecording()
  call s:StopRecording()
  call s:StartRecording()
endfunction
function! s:GetRegister()                  " originally:  let latestAction = @x
  return eval("@".g:RepeatLast_Register)
endfunction
function! s:ClearRegister()
  exec "let @".g:RepeatLast_Register." = ''"
endfunction

function! s:EndActionDetected(trigger)

  if !g:RepeatLast_Enabled
    return
  endif
  if s:currentlyReplaying
    return
  endif

  if s:ignoringCount > 0

    " If we want to ignore only movements, but auto-re-enable when edits are
    " detected, we can try this.
    " But in order to separate earlier movements from the insert we must force
    " clearing of the macro for general ignoring below.
    if g:RepeatLast_Stop_Ignoring_On_Edit != 0 && (a:trigger == "InsertLeave" || a:trigger == "InsertEnter")

      " BUG: I never see this echoed!
        if g:RepeatLast_Show_Ignoring_Info != 0
          echo "Edits detected by ".a:trigger." - no longer ignoring!"
          " sleep 400ms
        endif
      let s:ignoringCount = 0

    else

      let s:ignoringCount -= 1
      if g:RepeatLast_Show_Debug_Info != 0
        echo "Ignoring action triggered by ".a:trigger." and ".s:ignoringCount." more."
      endif
      if g:RepeatLast_Stop_Ignoring_On_Edit != 0
        " To avoid our edit being polluted with previous ignored movements, we
        " must clear them pre-emptively.  A limitation demanded by that
        " feature.  Or perhaps we always do want to forget ignored actions!
        " E.g. if we don't do this: \|jjA will record the jj when it shouldn't!
        call s:RestartRecording()
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

  " Stop the macro recording (its register will not be set until then):
  "
  " BUG: If we do this on InsertEnter, it causes a bug where end-of-line edits
  " (from 'A' or 'a') get pushed back a space (presumably by a temporary drop
  " back to normal mode).
  "
  if a:trigger != "InsertEnter"
    call s:StopRecording()
  endif

  let lastAction = s:GetRegister()

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
  " if cleanedAction != lastAction && g:RepeatLast_Show_Debug_Info != 0
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
    "if g:RepeatLast_Show_Debug_Info != 0
      "echo extraReport . "Null action triggered by ".a:trigger
    "endif

  " Now follow checks for actions we DO NOT want to record.
  " Note that unlike '.' we DO want to record movement as an action.
  " TODO: We can use match(2) instead of substitute(4)!=original
  " 1) Detects undo actions
  " 2) Detects redo actions
  elseif substitute(lastAction,"^[0-9]*u$","","") != lastAction ||
       \ substitute(lastAction,"^[0-9]*$","","") != lastAction

    if g:RepeatLast_Show_Debug_Info != 0
      echo extraReport . "Ignoring unwanted action: \"" . s:MyEscape(lastAction) . "\" (triggered by ".a:trigger.")"
    endif

  elseif a:trigger == "InsertEnter"
    " Because we don't stop/start recording on InsertEnter, we should not
    " record the actions either (or we will end up recording the same thing
    " twice!)

    if g:RepeatLast_Show_Debug_Info != 0
      echo extraReport . "Cannot learn during ".a:trigger.", probably duplicated: \"" . s:MyEscape(lastAction) . "\""
    endif

  else

    " OK this is an action we do want to record
    if g:RepeatLast_Show_Debug_Info != 0
      echo extraReport . "Detected action: \"" . s:MyEscape(lastAction) . "\" (triggered by ".a:trigger.")"
    endif
    call add(s:earlierActions,lastAction)
    call add(s:earlierActionTriggers,a:trigger)
    if len(s:earlierActions) > g:RepeatLast_Max_History
      call remove(s:earlierActions,0)
      call remove(s:earlierActionTriggers,0)
    endif

  endif

  if g:RepeatLast_TriggerCursorHold
    if s:old_updatetime == 0
      let s:old_updatetime = &updatetime
    endif
    let &updatetime=0
    " If we don't start recording again, it's possible that another trigger
    " may fire, and re-store the register contents!  (e.g.  InsertLeave,
    " CursorMoved often fire together).  To prevent storing it twice:
    call s:ClearRegister()
    return
  endif

  " Start recording the next action
  if a:trigger != "InsertEnter"
    call s:StartRecording()
  endif

endfunction

function! s:CursorHoldDone()
  if g:RepeatLast_TriggerCursorHold && s:old_updatetime!=0
    call s:StartRecording()
  endif
endfunction

function! s:PauseRecordingQuietly()
  let s:ignoringCount = g:RepeatLast_Ignore_After_Use_For
endfunction

function! s:TogglePauseRecording()
  if s:ignoringCount == 0
    call s:PauseRecordingQuietly()
    echo "Ignoring the next ".s:ignoringCount." events."
  else
    let s:ignoringCount = 0
    echo "No longer ignoring events."
  endif
  " This pause is not too disruptive, because it comes after a request, not
  " in the middle of editing.  We only need it if low ch would hide it.
  if &ch == 1 | sleep 400ms | endif
  " Drop the action which requested this call (\| or \#)
  call s:RestartRecording()
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
  call s:RestartRecording()

  echo "Recent actions are:"

  if numWanted > len(s:earlierActions)
    let numWanted = len(s:earlierActions)
  endif

  " let start = len(s:earlierActions) - numWanted
  " for i in range(start,len(s:earlierActions)-1)
    " let howFarBack = len(s:earlierActions) - i

  for howFarBack in range(numWanted,1,-1)
    let i = len(s:earlierActions) - howFarBack
    if g:RepeatLast_Show_Debug_Info
      echo howFarBack . " " . s:MyEscape(s:earlierActions[i]) . "   (".s:earlierActionTriggers[i].")\n"
    else
      echo howFarBack . " " . s:MyEscape(s:earlierActions[i]) . "\n"
    endif
  endfor

  if g:RepeatLast_Show_Debug_Info != 0
    echo "Dropped hopefully unwanted action: \"". s:MyEscape(s:GetRegister()) ."\""
    " This kept displaying my *previous* stroke, and not the '\?' until I
    " performed it a second time.  Better info now we echo *after* q qx.
  endif

  if s:ignoringCount > 0
    echo "[Auto-ignoring enabled for another ".s:ignoringCount." events.]"
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

  " Problem: normal! will ignore any leading ' ' Space chars when we execute
  " the actions later.
  " Assuming we were in normal mode and Space is not mapped, do the same
  " movement using 'l' instead (although it differs at end of line):
  "let actions = substitute(actions,"^ ","l","")
  " Assuming <Ctrl-L> is not mapped, do that and then our Space.
  "let actions = substitute(actions,"^ "," ","")
  " Assuming 1 is not mapped, do "1 " to start things off:
  "let actions = substitute(actions,"^ ","1 ","")
  " This problem is now solved by using feedkeys() below.

  "echo "OK repeating: " . s:MyEscape(actions)
  " We don't get to see the echo.  Let's use a confirm instead:
  if g:RepeatLast_Request_Confirmation != 0
    let res = confirm("About to do: \"" . s:MyEscape(actions) . "\" OK?", "&Yes\n&No")
    if res != 1
      echo "Repeat cancelled."
      " Empty the macro so we won't record the command that invoked us.
      call s:RestartRecording()
      return
    endif
  endif

  if g:RepeatLast_Show_Debug_Info
    echo "Replaying ".numWanted." actions: \"". s:MyEscape(actions) ."\""
    " The qx causes our last echoed line to be emptied, even if ch is large.
    " Let's make it a line we don't need to see!
    echo "I will get hidden"
  endif

  " We want to discard the keystrokes that lead to this call.
  " Clear the currently recorded macro of actions (contains our request action).
  call s:StopRecording()
  let dropped1 = s:MyEscape(s:GetRegister())

  " Replay the actions
  " But prevent triggers (e.g. InsertEnter or InsertLeave) from recording
  " actions, or auto-cancelling ignore.
  let s:currentlyReplaying = 1
  "exec "normal! ".actions
  " TESTING:
  call feedkeys(actions)
  let s:currentlyReplaying = 0

  " Start recording again
  "let dropped2 = s:MyEscape(s:GetRegister())
  call s:StartRecording()

  " But start ignore mode
  call s:PauseRecordingQuietly()

  if g:RepeatLast_Show_Debug_Info != 0
    "echo "Dropped request action: \"". dropped1 ."\" and replayed actions: \"". dropped2 ."\""
    echo "Dropped request action: \"". dropped1 ."\""
    echo "I will get hidden"
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
  let deletedTriggers = remove(s:earlierActionTriggers, len(s:earlierActionTriggers)-numWanted, len(s:earlierActionTriggers)-1)
  if numWanted==1
    let deletedActions = [deletedActions]
  endif

  echo "Deleted last ".numWanted." actions."
  for i in range(0,numWanted-1)
    echo "- \"" . s:MyEscape(deletedActions[i]) . "\""
  endfor

  " This clears our current macro, which is needed.
  " You can remove this call to ShowRecent, but then you should use its macro
  " clearing code!
  call s:ShowRecent(0)

endfunction

function! s:GrabLast(num)

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

  let grabbedActions = remove(s:earlierActions, len(s:earlierActions)-numWanted, len(s:earlierActions)-1)

  let @g = join(grabbedActions,"")

  echo "Saved macro: @g <- \"" . s:MyEscape(@g) . "\"  Repeat with @g"

endfunction

" These sleeps help the user to see some feedback even if ch=1.
"
" It feels nowhere near as disruptive after calling a command as the sleeps we
" tried during normal mode (which the user expects to be responsive, if they
" are tapping/have strokes stalling).
"
function! s:RepeatLastOn()
  if !g:RepeatLast_Enabled
    let g:RepeatLast_Enabled = 1
    call s:StartRecording()
    echo "RepeatLast recording enabled."
    sleep 800ms
  endif
endfunction
function! s:RepeatLastOff()
  if g:RepeatLast_Enabled
    let g:RepeatLast_Enabled = 0
    call s:StopRecording()
    echo "RepeatLast recording disabled."
    sleep 800ms
  endif
endfunction

" Startup / Init

if g:RepeatLast_Enabled
  call s:StartRecording()
  "" Alternatively:
  " let g:RepeatLastEnabled = 0
  " call s:RepeatLastOn()
endif



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
    let ascnr = char2nr(char)

    if ascnr == 9
      let char = "<Tab>"
    elseif ascnr == 13
      let char = "<Enter>"
    elseif ascnr == 27
      let char = "<Esc>"
    elseif ascnr == 32
      let char = "<Space>"
    elseif ascnr == 127
      let char = "<Del>"
    elseif ascnr == 8
      let char = "<Backspace>"
    elseif ascnr >= 32 && ascnr <= 126
      let char = char
    elseif ascnr >= 1 && ascnr <= 26
      let char = "<Ctrl-" . nr2char(65 + ascnr - 1) . ">"
    else
      let char = '<' . char2nr(char) . '>'
    endif

    let out = out . char
    let i = i+1
  endwhile
  return out
endfunction
" <128>kb<Enter> Backspace
" <128>k9<Enter> F9
" <128>k;<Enter> F10
" <128>F1<Enter> F11
" <Esc>[1;5C Ctrl-Right
" <Esc>[1;5D Ctrl-Left
" <Esc>[1;5B Ctrl-Down
" <Esc>[1;5A Ctrl-Up

au BufReadPost RepeatLast.vim call FoldNicely()
command! FoldNicely :call FoldNicely()
function! FoldNicely()
  let num = 3
  set foldmethod=manual
  normal zE
  normal :0
  let @f="/^.v/\\n\\n\\nzf"
  let oldWrapScan = &wrapscan
  set nowrapscan
  normal 999@f
  normal 9999
  normal zf
  let &wrapscan = oldWrapScan
  echo "Sorry about the error message."
endfunction

