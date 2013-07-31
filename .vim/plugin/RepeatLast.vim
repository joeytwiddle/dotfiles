" RepeatLast.vim by joeytwiddle                  (Hit 'zo' to open this fold)
"
" Provides <count>\. to repeat the last group of actions you performed.
"
"                 "A beautiful monster" -- bairui in #vim
"
" The '.' key is fantastic for repeating the last 1 action you made.  But
" sometimes I do three actions, and then want to repeat them again.  Now
" this is just 3\.
"
" BEWARE: Because it uses macro recording *all the time*, it sort of takes
" over your Vim, and can impact your usual experience.  Be prepared!
"
"   :set ch=2       if the word "recording" hides messages you wanted
"
"   :let g:RepeatLast_TriggerCursorHold = 1  or  0   for GUI fixes
"
" Also: :RepeatLastDisable :RepeatLastEnable :RepeatLastToggleDebugging
"
" ** TODO **: timeSinceLast needs debugging on various systems before publishing
" this version!  reltime() is apparently non-homogenous.



" == Usage ==
"
" Assuming your mapleader is '\' (the default), these |mappings| are created:
"
"   \?   Display a list of recently recorded actions
"
"   4\?  Display the last four recorded actions
"
"   \.   Repeat the last action (similar to . but may replay just a movement)
"
"   4\.  Repeat the last four recorded actions (including movement actions)
"
"   \\.  Replay the last *repeated* action-group (all 4 actions above)
"
"   9\\. Replay the last *repeated* action-group 9 times (producing 9 times 4)
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
"   :let g:RepeatLast_SaveToRegister = 'p'
"
"        Always save any repeated action-group into @p
"
"   :let g:RepeatLast_TriggerCursorHold = 0
"
"        Disable the UI fix.  CursorHold events will not fire.
"
" Commands are also available for the main shortcuts above:
"
"   :ShowRecent   :RepeatLast   :DropLast   :PauseRecording   :GrabLast
"
" Commands to toggle state at runtime:
"
"   :RepeatLastEnable    Enables action recording, enters macro record mode.
"
"   :RepeatLastDisable   Disables action recording, leaves macro record mode.
"
"   :RepeatLast<Ctrl-D>  or  <Ctrl-N>      More commands, some toggle info.
"
" New feature - Auto Ignoring:
"
"   After executing a repeat action, action storage will be *temporarily
"   disabled* for the number of actions specified by:
"
"     let g:RepeatLast_Ignore_After_Use_For = 10
"
"   This allows you to move to a new location between executing repeats,
"   without recording those movement actions.
"
"   Once you have performed enough actions without executing a repeat, action
"   storage will be re-enabled, and the ignored actions will be added to the
"   history as one large entry.  Although g:RepeatLast_Stop_Ignoring_On_Edit
"   prevents this recovery.
"
" Reading this rest of this file:
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
" Because recording is enabled, for commands like `q:` and `q/` you will need
" to press an extra `q` beforehand, and they will not be recorded in history.
"
" If you want to record your own macro, you can disable the plugin with
" :RepeatLastDisable (or you could try just pressing 'q' for a one-time disable).
"
" CursorHold events do not fire in macro-recording mode.  Any visual tools,
" taglist updates, etc. that require CursorHold *will not be triggered*.
" Other events such as CursorMove, InsertLeave, BufWritePost work fine.
" The new option RepeatLast_TriggerCursorHold can now be used to force trigger
" of CursorHold events.  It may not be ideal, but mostly works ok.
"
" == Disadvantages ==
"
" Movements j and k will not return to the original column after passing
" through shorter lines.  (This is only a problem when using
" RepeatLast_TriggerCursorHold.)
"
" Use of some <Tab>-completion plugins may produce unexpected behaviour when
" replaying actions including a <Tab>-completion.  (Although Vim's built-in
" '.' does not suffer from this.)



" == Options ==

" Set to 0 if you don't want recording enabled on startup, then enable later
" with :RepeatLastEnable .
if !exists("g:RepeatLast_Enabled")
  let g:RepeatLast_Enabled = 1
endif

" Asks for confirmation before performing a set of repeats.
" When 5\. is requested, will first display the actions and ask Y/N.
if !exists("g:RepeatLast_Request_Confirmation")
  let g:RepeatLast_Request_Confirmation = 0
endif

if !exists("g:RepeatLast_Leader")
  let g:RepeatLast_Leader = '\'
  " let g:RepeatLast_Leader = &mapleader
  " let g:RepeatLast_Leader = ','
endif

" The register used to store macros when recording, gets clobbered at run-time
" although it will usually appear to be empty when you query it.
" WARNING: May occasionally accidentally fire as a normal keypress!  |accident|
" Therefore 'm' or 'z' is recommended as they are non-edits and non-movements.
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
  let g:RepeatLast_Ignore_After_Use_For = 20
  " Increased this from 10 because we seem to be getting a lot more
  " CursorMoved events than before (or something else was causing the
  " ignoringCount to run out too quickly).
endif

" Useful, shows status of ignoring (provided ch>=2)
if !exists("g:RepeatLast_Show_Ignoring_Info")
  let g:RepeatLast_Show_Ignoring_Info = 1
endif

" For debugging, echoes data about actions as they are recorded.
if !exists("g:RepeatLast_Show_Debug_Info")
  let g:RepeatLast_Show_Debug_Info = 0
endif

" :let g:RepeatLast_TriggerCursorHold = 0  or  1  or  2  or  3  or  4
"
" When enabled, temporarily stops recording to allow Vim's 'CursorHold' event to
" trigger.  This event is used by some scripts to perform visual UI updates or
" lazy actions.  It normally triggers after 'updatetime' but if we wait that
" long, there is a good chance we will fail to record some keystrokes!
"
"   0 - Disabled.  Do not trigger CursorHold events, never lose keystrokes.
"
"   1 - Safe, recommended.  Trigger immediately after a keystroke, unless
"       user is holding down a key (if time since last action is <100ms).  (We
"       could increase this threshold a little for slower machines/users.)
"
"   2 - Simple.  Always trigger immediately after a keystroke, fires many
"       events!
"
"   3 - Lossy compromise.  Triggers after 'updatetime' if user is acting
"       slowly, or immediately if user is acting fast, or not at all if user
"       is holding down a key.  This will frequently fail to record the second
"       action, if the user hits two keys rapidly after a pause.  Pausing to
"       think is normal behaviour when recording a complex macro.  So to avoid
"       tears, train yourself: after a pause, hit the next two keys *slowly*!
"       (In other words, ensure the "recording" message re-appears before you
"       hit the second key.)
"
"   4 - Ugly compromise.  Like 3 but does a sleep instead of pausing recording
"       for updatetime, so no actions will be lost.  Whilst it generally
"       records the second keystroke (which 3 would lose), it will not break
"       out of the sleep, which is visually annoying (Vim acts unresponsive).
"
" BUG: All of the above except 0 can miss a keystroke if Vim is being slow, or
"      waiting for a multi-key, e.g. misses the  <Enter>  in  i<Esc><Enter>
"      In such cases, the keystroke is performed before we re-enter macro
"      recording mode.  "immediately" above actually means we leave recording
"      mode for 1ms, which is lossy if there are keystrokes waiting in the
"      keyboard buffer.
"
" BUG: They can also block recording of actions taken when in visual mode,
"      because CursorHold does not fire then, so our recording is not
"      re-started.  We could fix this by never triggering if we detect we are in
"      visual mode.
"
" BUG: If my <C-J> mapping is present, 4 works fine on  }j  but not on
"      }<Enter>  which gets interpreted as  }<C-J>
"
if !exists("g:RepeatLast_TriggerCursorHold")
  let g:RepeatLast_TriggerCursorHold = 1
endif
"
" Possible future modes (not yet implemented).
"   5 - always trigger with 0 interval (for testing, may fail in gui) (todo)
"   6 - always trigger after a fixed interval (useless)

" If set, when you repeat a group, the actions will also be saved in this
" register.  So  5\.20@g  like  5\.20\\.  will repeat 5 actions 21 times.
if !exists("g:RepeatLast_SaveToRegister")
  let g:RepeatLast_SaveToRegister = ''
endif

" The string used to separate commands when displaying the list ("\n" or " ").
" Unfortunately although " " looks nice, we often lose text on the 'recording'
" line, unless we set Show_History very low.
" TODO: That could be fixed by showing only the tail of the list that will fit
" into &ch-1.
if !exists("g:RepeatLast_List_Delimeter")
  let g:RepeatLast_List_Delimeter = "\n"
endif

" Whether to anticipate and ignore a keypress after ShowRecent's |hit-enter|
" prompt.  (Probably wanted.)
if !exists("g:RepeatLast_IgnoreHitEnter")
  let g:RepeatLast_IgnoreHitEnter = 1
endif



" == Mappings and Commands ==
"                                                        *mappings*

nnoremap <Leader>? :ShowRecent<Enter>
command! -count=0 ShowRecent call <SID>ShowRecent(<count>)

nnoremap <Leader>. :RepeatLast<Enter>
command! -count=0 RepeatLast call <SID>RepeatLast(<count>)

nnoremap <Leader>D :DropLast<Enter>
command! -count=0 DropLast call <SID>DropLast(<count>)

nnoremap <Leader>G :GrabLast<Enter>
command! -count=0 GrabLast call <SID>GrabLast(<count>)

nnoremap <Leader><Leader>. :ReRepeat<Enter>
command! -count=0 ReRepeat call <SID>ReRepeat(<count>)

"command! RepeatLastOn call <SID>RepeatLastOn()
"command! RepeatLastOff call <SID>RepeatLastOff()
command! RepeatLastEnable call <SID>RepeatLastOn()
command! RepeatLastDisable call <SID>RepeatLastOff()

command! RepeatLastToggleInfo let g:RepeatLast_Show_Ignoring_Info = 1 - g:RepeatLast_Show_Ignoring_Info

command! RepeatLastToggleDebugging let g:RepeatLast_Show_Debug_Info = 1 - g:RepeatLast_Show_Debug_Info | let &ch = 5 - &ch | if g:RepeatLast_TriggerCursorHold != 0 | echo "Recommend you also :let g:RepeatLast_TriggerCursorHold=0" | endif

" Pause recording temporarily (allows movement before executing a repeat)
nnoremap <Leader># :TogglePauseRecording<Enter>
nnoremap <Leader>\| :TogglePauseRecording<Enter>
command! -count=0 TogglePauseRecording call <SID>TogglePauseRecording()

" If requested to show debugging messages, make sure they will be visible!
" (If ch=1 then "recording" will overwrite them immediately.)
if g:RepeatLast_Show_Debug_Info != 0 && &ch < 3
  " Pushed up to 3 because occasionally we echo 2 lines.
  " Not forced for info messages, are echoes but hidden at ch 1.
  set ch=3
endif



" For this to work, we need to have this macro recording on *all the time*!
" This is maintained in EndActionDetected().
"
" BUG: If we are already recording a macro, 'q' will stop it and then 'x'
" will delete 1 char!  We need to detect whether macro recording is active!
" AFAWK Vim does not currently expose this.
"
" We used to use register x to record the most recent event.  This was not
" 100% harmless.  Now we use whatever is set in g:RepeatLast_Register.



" == Recording Actions ==

" We are going to record a history of recent actions

if !exists("s:earlierActions")       " we retain it through plugin reload
  let s:earlierActions = []
  let s:earlierActionTriggers = []   " only used for debugging
endif

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
  " We may need this if g:RepeatLast_TriggerCursorHold is set later.
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

" TODO: Investigate how this script manages to catch a variety of events using
"       mappings: http://vim.wikia.com/wiki/Modified_undo_behavior

" Sometimes we skip recording events for a while
let s:ignoringCount = 0
" This one drops the first stroke, but keeps the rest of the macro.
let s:ignoreNextKeystroke = 0

let s:currentlyReplaying = 0
let s:old_updatetime = 0   " When non-zero, we have left macro recording mode.

" There is some danger here: If we were in recording mode already, we will
" leave it and then execute the register as a normal stroke!        *accident*
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
function! s:GetRegister()                  " originally:  return @x
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

        if g:RepeatLast_Show_Ignoring_Info != 0
          echo "Edits detected by ".a:trigger." - no longer ignoring!"
          sleep 400ms
          " We need the sleep or we never see this echoed!
        endif
      let s:ignoringCount = 0

    else

      " Moving the cursor is exactly the sort of event we want to ignore.
      "if a:trigger != "CursorMoved"
      "endif
      " However, it is also often the only event that reaches here!  So we
      " must use it as an indicator of activity.
      let s:ignoringCount -= 1
      if g:RepeatLast_Show_Debug_Info != 0
        echo "Ignoring action triggered by ".a:trigger." and ".s:ignoringCount." more."
        "sleep 400ms
      endif
      if g:RepeatLast_Stop_Ignoring_On_Edit != 0
        " To avoid our edit being polluted with previous ignored movements, we
        " must clear them pre-emptively.  A limitation demanded by that
        " feature.  Or perhaps we always do want to forget ignored actions!
        " E.g. if we don't do this: \|jjA will record the jj when it shouldn't!
        call s:RestartRecording()
        let s:ignoreNextKeystroke = 0
      endif
      if s:ignoringCount == 0
        if g:RepeatLast_Show_Ignoring_Info != 0
          echo "Now listening again."
          sleep 400ms
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
  "" CONSIDER: Adjust 'shortmess' to suppress 'press ENTER' messages?
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

  if s:ignoreNextKeystroke
    let s:ignoreNextKeystroke = 0
    if g:RepeatLast_Show_Debug_Info != 0
      echo "Ignoring single action \"". s:MyEscape(lastAction[0:0]) ."\" as requested."
    endif
    let lastAction = lastAction[1:]
  endif

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
    if !exists("s:lastActionTime")
      let s:lastActionTime = 0
    endif
    let timeSinceLast = s:gettime() - s:lastActionTime
    let s:lastActionTime = s:gettime()
    " If user is holding down a key (fast repeat) then do not trigger now.
    " But if user is moving slowly, then consider triggering.
    " The disadvantage of this check is if the user doesn't do anything slow
    " after holding down keys, our fake CursorHold will not trigger until they
    " do!
    if g:RepeatLast_TriggerCursorHold==2 || timeSinceLast > 100*1000
      " Delay entering recording mode for a moment, so that CursorHold will fire
      " (which may perform useful visuals tasks for the user).
      if s:old_updatetime == 0
        let s:old_updatetime = &updatetime
      endif
      "if !exists("g:log") | let g:log = "" | endif
      "let g:log .= "timeSinceLast=".timeSinceLast . " s:old_updatetime=".s:old_updatetime."\n"
      if g:RepeatLast_TriggerCursorHold >= 3 && timeSinceLast > 2*s:old_updatetime*1000
        if g:RepeatLast_TriggerCursorHold == 3
          " If user is moving VERY slowly, do a normal slow trigger
          let &updatetime = s:old_updatetime
        else
          " Instead of not recording for 'updatetime', we could force a sleep.
          " However we need to do this on the *return* to recording, because
          " sleeping now will block the display from updating.
          " mode.
          "exec "sleep " . s:old_updatetime . "m"
          "echo "timeSinceLast = ".timeSinceLast
          let &updatetime = 1
          let s:doSleep = 1
        endif
      else
        " Otherwise do a reasonably fast trigger, to avoid losing keystrokes
        " This should catch repeated (held down) keys if < repeat speed
        " Although a user hitting two keys very close to each other might
        " manage it before recording is re-enabled!
        " NOTE: =0 works fine in terminal vim, but in gvim CursorHold never fires!
        "       =1 does.
        "let &updatetime = 0
        let &updatetime = 1
        "let &updatetime = timeSinceLast
        "let &updatetime = g:RepeatLast_TriggerCursorHold
        let s:doSleep = 0
      endif
      " If we don't start recording again, it's possible that another trigger
      " may fire, and re-store the register contents!  (e.g.  InsertLeave,
      " CursorMoved often fire together).  To prevent storing it twice:
      call s:ClearRegister()
      return
    endif
  endif

  " Start recording the next action
  if a:trigger != "InsertEnter"
    call s:StartRecording()
  endif

endfunction

" Should return a number in nanoseconds
function! s:gettime()
  let rts = reltimestr(reltime())
  let rts = substitute(rts,'\.','','')
  return str2nr(rts)
  " The code above should be a bit more system independent than that below.
  " However *both* suffer from the fact that vim ints do not have the range to
  " store milliseconds since 1970.  The number we actually get is truncated,
  " which is sufficient for in general, but will very occasionally suffer a
  " rollover bug.
  "let rt = reltime()
  "if len(rt) > 1
  "  return rt[0]*1000000 + rt[1]   " Ubuntu
  "else
  "  return rt[0]                   " Dunno; fallback
  "endif
endfunction

function! s:CursorHoldDone()
  if g:RepeatLast_TriggerCursorHold && s:old_updatetime!=0
    "" Now the CursorHold has triggered, we must start recording which was
    "" postponed earlier.

    "" Before doing so, we could pause briefly, so any visual effects related
    "" to CursorHold can be seen (e.g. blinking_statusline.vim or
    "" highlight_line_after_jump.vim).  Set g:RepeatLast_TriggerCursorHold to
    "" the number of milliseconds you want + 2.
    ""
    "" WARNING: If greater than user's key repeat speed, will likely prevent
    "" recording of repeats.
    ""
    "" Also, looks jerky when holding a key down to scroll or move the cursor.
    "" So we should only do it if the time between the last two actions was
    "" high.
    ""
    ""
    "" Interstingly near the threshold, when I hold <Enter> I get first an
    "" <Enter> but then a few <Ctrl-J>s.  Presumably this is because two
    "" strokes are being sent to the xterm, but the first is lost.
    ""
    "" Issue: Might we sleep before other CursorHold events have fired, losing
    "" their effect?

    call s:StartRecording()

    if g:RepeatLast_TriggerCursorHold >= 4 && exists("s:doSleep") && s:doSleep
      " exec "sleep ".(g:RepeatLast_TriggerCursorHold-2)."m"
      " exec "sleep ".s:old_updatetime."m"
      exec "sleep ".&updatetime."m"
    endif

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
  "" This pause is not too disruptive, because it comes after a request, not
  "" in the middle of editing.  We only need it if low ch would hide it.
  "if &ch == 1 | sleep 400ms | endif
  "" No, it will be hidden at larger ch too, use a dummy line:
  "if &ch>1
    "echo "I will get hidden"
  "endif
  sleep 400ms
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
  " BUG TODO: This will lose any keystrokes which are still lagging in the
  " macro and have not yet been saved as an action.  We should probably save
  " any recorded actions at this point, but just discard the keystrokes from
  " the end that lead to this call.
  " For example, compare `:echo "lost"<Enter>\?` vs `:echo "kept"<Enter>kk\?`
  " NOTE: When changing this, recommend also doing the same in RepeatLast().

  if numWanted > len(s:earlierActions)
    let numWanted = len(s:earlierActions)
  endif

  " let start = len(s:earlierActions) - numWanted
  " for i in range(start,len(s:earlierActions)-1)
    " let howFarBack = len(s:earlierActions) - i

  let report = "Recent actions:" . g:RepeatLast_List_Delimeter
  for howFarBack in range(numWanted,1,-1)
    let i = len(s:earlierActions) - howFarBack
    if g:RepeatLast_Show_Debug_Info
      let report .= "[".howFarBack."]" . " " . s:MyEscape(s:earlierActions[i]) . " (".s:earlierActionTriggers[i].")" . g:RepeatLast_List_Delimeter
    else
      let report .= "[".howFarBack."]" . " " . s:MyEscape(s:earlierActions[i]) . g:RepeatLast_List_Delimeter
    endif
  endfor
  echo report

  if g:RepeatLast_Show_Debug_Info != 0
    echo "Dropped hopefully unwanted action: \"". s:MyEscape(s:GetRegister()) ."\""
    " This kept displaying my *previous* stroke, and not the '\?' until I
    " performed it a second time.  Better info now we echo *after* q qx.
  endif

  if s:ignoringCount > 0
    echo "[Auto-ignoring enabled for another ".s:ignoringCount." events.]"
  endif

  " This almost always causes a |hit-enter| prompt, which usually results in a
  " user press of <Space> or <Enter> which gets recorded!  To prevent that:
  if g:RepeatLast_IgnoreHitEnter
    let s:ignoreNextKeystroke = 1
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

  " FIXED: This problem was solved by using feedkeys() below, and then by
  " using a macro.
  " Problem: normal! will ignore any leading ' ' Space chars when we execute
  " the actions later.
  " Assuming we were in normal mode and Space is not mapped, do the same
  " movement using 'l' instead (although it differs at end of line):
  "let actions = substitute(actions,"^ ","l","")
  " Assuming <Ctrl-L> is not mapped, do that and then our Space.
  "let actions = substitute(actions,"^ "," ","")
  " Assuming 1 is not mapped, do "1 " to start things off:
  "let actions = substitute(actions,"^ ","1 ","")

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

  let g:RepeatLast_LastAction = actions

  if exists("g:RepeatLast_SaveToRegister") && g:RepeatLast_SaveToRegister != ""
    " let @{g:RepeatLast_SaveToRegister} = actions
    " exec "let @".g:RepeatLast_SaveToRegister." = \"".actions."\""
    "" Avoid escaping issues with exec:
    exec "let @".g:RepeatLast_SaveToRegister." = g:RepeatLast_LastAction"
  endif

  if g:RepeatLast_Show_Debug_Info
    echo "Replaying ".numWanted." actions: \"". s:MyEscape(actions) ."\""
    " The qx causes our last echoed line to be emptied, even if ch is large.
    " Let's make it a line we don't need to see!
    echo "I will get hidden"
  endif

  call s:ExecuteActions(actions)

  " But start ignore mode
  call s:PauseRecordingQuietly()

  if g:RepeatLast_Show_Ignoring_Info != 0
    echo "Auto-ignoring the next ".s:ignoringCount." events."
    sleep 400ms
  endif

endfunction

function! s:ExecuteActions(actions)

  " We want to discard the keystrokes that lead to this call.
  " Clear the currently recorded macro of actions (contains our request action).
  call s:StopRecording()
  let dropped1 = s:MyEscape(s:GetRegister())

  " Replay the actions
  " But prevent triggers (e.g. InsertEnter or InsertLeave) from recording
  " actions, or auto-cancelling ignore.
  let s:currentlyReplaying = 1
  "exec "normal! ".a:actions
  " FIXED: In the latest version of Vim, these fed keys will be interpreted *later*, after currentlyReplaying has been cleared, and this may cause ignoringCount to be reset prematurely, e.g. by triggering an InsertLeave event.
  " For that reason, we prefer instead to execute the actions immediately through a macro.
  "call feedkeys(a:actions)
  " We clobber macro 'l' but then restore it.
  let macroBeforeClobber = @l
  let @l = a:actions
  normal! @l
  let @l = macroBeforeClobber
  let s:currentlyReplaying = 0

  " Start recording again
  "let dropped2 = s:MyEscape(s:GetRegister())
  call s:StartRecording()

  if g:RepeatLast_Show_Debug_Info != 0
    "echo "Dropped request action: \"". dropped1 ."\" and replayed actions: \"". dropped2 ."\""
    echo "Dropped request action: \"". dropped1 ."\""
    echo "I will get hidden"
  endif

endfunction

function! s:ReRepeat(num)

  if !exists("g:RepeatLast_LastAction")
    echoerr 'No last action available!  Need \. before \\.'
    return
  endif

  let numWanted = a:num
  if numWanted == 0
    let numWanted = 1   " default
  else
    " Fix because <count> is a range, not just the number we gave it
    let numWanted = numWanted - line(".") + 1
    " TODO: Alternative fix: <bairui> joeytwiddle: :command! -count=1 Foo echo (v:count ? v:count : <count>)
  endif

  let actions = g:RepeatLast_LastAction

  let actions = repeat(actions,numWanted)

  if g:RepeatLast_Show_Debug_Info
    echo "Replaying last replay ".numWanted." times: \"". s:MyEscape(actions) ."\""
    " The qx causes our last echoed line to be emptied, even if ch is large.
    " Let's make it a line we don't need to see!
    echo "I will get hidden"
  endif

  call s:ExecuteActions(actions)

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

    " We will try to find a nice string to represent the char here
    let next = ""
    let swallowed = 1     " Assume we advance one char.  Adjust below if neccessary.

    if ascnr == 9
      let next = "<Tab>"
    elseif ascnr == 13
      let next = "<Enter>"
    elseif ascnr == 27
      let next = "<Esc>"
    " We only symbolise ' ' if at the start or end.
    elseif ascnr == 32 && ( i==0 || i==len(a:str)-1 )
      let next = "<Space>"
    elseif ascnr == 127
      let next = "<Del>"
    elseif ascnr == 8
      let next = "<Backspace>"
    elseif ascnr >= 32 && ascnr <= 126
      let next = char
    elseif ascnr >= 1 && ascnr <= 26
      let next = "<Ctrl-" . nr2char(65 + ascnr - 1) . ">"
    elseif ascnr == 128
      " <128> sometimes indicates a special key
      " Grab the next two chars if we can (i already advanced)
      if i+2 < len(a:str)
        let nextTwo = a:str[i+1 : i+2]
        let swallowed += 2   " Assume we will consume them
        if nextTwo == "ku"
          let next = "<Up>"
        elseif nextTwo == "kd"
          let next = "<Down>"
        elseif nextTwo == "kP"
          let next = "<PageUp>"
        elseif nextTwo == "kN"
          let next = "<PageDown>"
        elseif nextTwo == "kI"
          let next = "<Insert>"
        elseif nextTwo == "kD"
          let next = "<Delete>"
        elseif nextTwo == "kh"
          let next = "<Home>"
        elseif nextTwo == "@7"
          let next = "<End>"
        elseif nextTwo == "kb"
          let next = "<Backspace>"
        else
          let swallowed -= 2   " We didn't consume them!
        endif
      endif
    endif

    " If we didn't find any way to display the char
    if next == ""
      let next = '<' . char2nr(char) . '>'
    endif

    let out = out . next
    let i += swallowed
  endwhile
  return out
endfunction
" <128>k9<Enter> F9
" <128>k;<Enter> F10
" <128>F1<Enter> F11
" <Esc>[1;5C Ctrl-Right
" <Esc>[1;5D Ctrl-Left
" <Esc>[1;5B Ctrl-Down
" <Esc>[1;5A Ctrl-Up



" == Fold this file nicely ==

command! FoldNicely :call FoldNicely(2)
" I like to run this automatically when I open this file.
" au BufReadPost RepeatLast.vim if $USER == "joey" | :FoldNicely | endif
au BufReadPost RepeatLast.vim :FoldNicely

function! FoldNicely(numBlankLines)

  let oldWrapScan = &wrapscan
  let oldLine = line(".")
  set nowrapscan
  " Clear existing folds and go to top
  set foldmethod=manual
  normal zE
  normal gg

  "" New method, using search()
  let seek = repeat('\n',a:numBlankLines+1)
  let nonBlank = '^.'
  normal v
  while 1
    let line = search(seek)
    if line <= 0
      " Build the last fold (which will drop us out of visual)
      normal G
      normal zf
      break
    endif
    call cursor(line,1)
    normal zf
    normal 
    let blankLine = search(nonBlank)
    if blankLine <= 0 || blankLine<line
      break
    endif
    call cursor(blankLine,1)
    normal v
  endwhile

  "" Old method, always emitted one final error:
  " let @f="/^.v/\\n\\n\\nzf"
  " normal 999@f
  " normal 9999
  " normal zf

  let &wrapscan = oldWrapScan
  exec oldLine.":"

endfunction



" == Bugs and TODOs ==
"
" NOTE: Increasing cmdheight is preferable to adding frequent calls to sleep,
"       which pause Vim long enough to show messages, but can slow down / lock
"       up Vim when we are pressing a lot of keys (unless I find a way to
"       check the key buffer length).  TODO: Yes, getchar(0) can do that!
"
" TODO: Change the timing of RepeatLast_TriggerCursorHold according to the
"       recent typing speed of the user, so we can trigger it slowly when we
"       are confident the user won't interrupt it.  Or better, don't set a
"       longer updatetime, do a longer sleep (yes may cause freeze, but won't
"       lose any keystrokes).
"
" TODO: \| \? \. etc. should probably warn us if RepeatLast is disabled!
"
" TODO: Some of the commands are kinda useless.  Make them optional or remove them!
"
" TODO: Even using large ch and with RepeatLast_TriggerCursorHold disabled,
"       warning messages such as "search hit BOTTOM" are hidden.  At least
"       offer a sleep *option* so we can see these.  Or ... echo "hidden" at
"       more opportune moments.
"
" TODO: Re-enable recording on *any* non-movement might be desirable.  At the
"       moment we only re-enable on InsertEnter changes.
"
" TODO: RepeatLast_TriggerCursorHold completely fails to trigger in GUI!
"       Did it always to this?
"
" TODO: RepeatLast_Stop_Ignoring_On_Edit might not need to pre-clear the
" macro, if we detect it InsertEnter instead of InsertLeave, although that
" might lose the command that started the insert.  :P
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
" DONE: Since it appears Vim does not currently expose the state of recording,
" moving to a less harmful register, e.g. 'z' or 'm', might be wise.
" CONSIDER: We can at least notice when recording has been disabled, because
" the CursorHold event will eventually fire (it never fires when recording)!
"
" DONE: We could use a way to *start* recording again, if temporary Ignoring
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
" DONE: We might try to restore CursorHold events by periodically letting Vim
" out of recording mode, but re-enabling recording as soon as CursorHold
" fires!  A downside might be that we would fail to record keystrokes typed
" very quickly after said release (before CursorHold fires).
"
" TODO (elsewhere): Accidentally doing  80\/  instead of  80\?  throws up a
" lot of error messages: "Error detected while processing function
"            MyRepeatedSearch..MyRepeatedSearch..MyRepeatedSearch.."
" This actually comes from joey.vim.  It should fail gracefully when given a
" count.
"
" DONE: Perhaps more advanced usage, which would also avoid complications
" with *new* recordings might be to save repeated actions in a register, so it
" can be recalled without worry about ignoring new movements/actions.
" CONSIDER: We could even cycle the register used for saving, if we want to
" remember older interesting action groups.
"
" Summary of the problems with "recording" message masking 'echo'-ed lines:
"
"  1. If we start macro recording after 3 echoes but before more echoes, the
"     last of the previous 3 lines will be cleared by "recording" message
"     (although it will also be cleared itself too, by the following echoes).
"     We always see a blank line at that point (after the first 2).
"
"     We can address this by echoing a dumb line beforehand.
"
"  2. If we start macro recording at the end, before returning to the user, the
"     "recording" message appears on the last of your ch lines.  But if you
"     have N ch lines and there were *exactly* N echoes, the last one will be
"     hidden by the "recording" message.  If there were <N echoes no problem,
"     we can see them all.  If there were >N echoes, the overflow message will
"     give us a change to see them all.
"
"     (This summary is slightly inaccurate - the problem also exists if we
"     'qx' and then echo.)
"
"     (Does this problem only exist when we use RepeatLast_TriggerCursorHold?)
"
"     We can also address this by echoing a dumb line beforehand.  This might
"     cause "unnecessary" overflow, but it *is* needed, to see that last echo.
"
"     In either case, a dummy line is pointless if there were no previous
"     echos??
"
"     Whilst we could count our own echos, we cannot count any emitted from
"     Vim or other scripts.



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

