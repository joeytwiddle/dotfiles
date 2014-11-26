" Language:    CoffeeScript
" Maintainer:  Mick Koch <kchmck@gmail.com>
" URL:         http://github.com/kchmck/vim-coffee-script
" License:     WTFPL

if exists("b:did_coffee_ftpluginn")
  finish
endif

let b:did_coffee_ftplugin = 1

setlocal formatoptions-=t formatoptions+=croql
setlocal comments=s:###,m:\ ,e:###,:#
setlocal commentstring=#\ %s



"" Added by Joey (perhaps futilely trying to undo my config which has not yet run!):
:set ts=2
:set sw=2
:set expandtab
let &comments=":##,".&comments

"" Original simple one-line compiler:
" autocmd BufWritePost,FileWritePost *.coffee silent !coffee -c <afile> &



"" Joey's coffee -> js autocompile on write
"" Now with ShowJSChanges

let g:coffeeAutoCompileAll = get(g:, "coffeeAutoCompileAll", 1)
let g:coffeeShowJSChanges = get(g:, "coffeeShowJSChanges", 0)
" If set, places compiles js files in the given folder.
" Useful to keep compiled files out of the source tree, or to compile into a
" temp dir purely for the Changes feature.
let g:coffeeCompileIntoFolder = get(g:, "coffeeCompileIntoFolder", "")

" DONE: If coffeeShowJSChanges is used in a split window which is not the
" last, when pedit and pclose are used it shrinks grrrr.  Remember and restore
" win height whenever we do pedit/pclose?
"
" DONE: Option to compile to temp/nullfolder to check success and show diff,
" but avoid polluting the coffee source folder with js files.

" TODO: Refactor this so it can be used on other filetypes.
"   e.g. for GorillaScript: :call g:Process_And_Diff('gorillascript %','%<.js')
"               or for SWS: :call g:Process_And_Diff('sws curl','%<')
" or for a complex project: :call g:Process_And_Diff('make','main.js')
" Note that expand() does not work on '%<.js'!
" We would probably want to set it to trigger on a filetype, e.g.:
"   autocmd BufWritePost,FileWritePost *.sws :call g:Process_And_Diff('sws curl %', '%<')

augroup CoffeeAutoCompile_AuGroup

  autocmd!

  "" Synchronous.  BUG: Makes us wait.  Does not release us back to vim cleanly and quickly.
  " autocmd BufWritePost,FileWritePost *.coffee silent !coffee -c <afile>

  "" Backgrounded.  BUG: Sometimes keys are swallowed, and crap appears in the text!
  " autocmd BufWritePost,FileWritePost *.coffee silent !coffee -c <afile> &

  "" No swallowing.  BUG: But still messy!
  " autocmd BufWritePost,FileWritePost *.coffee silent !/bin/sh -c "coffee -c <afile>" &

  "" I didn't find any one-liner which didn't mess up the screen in some way.
  "" But this approach pipes errors to a file, which prevents that.
  autocmd BufWritePost,FileWritePost *.coffee :call <SID>CoffeeAutoCompile_Check(bufname('%'))

augroup END

" TODO: Two options is probably too much.  One option but per-file
" auto-recognition (by checking comments?) might be useful.

" We don't really need to track this.  :pclose seems fine whether it's open or not.
let s:previewWinIsOpen = 0

" We set 'autoread' of the preview window because if the file does change, I
" think it actually complains when we try to repeat `:pedit <file>`.
" (Either that or it happens if we don't :pedit for some reason (shouldn't
" actually happen) but focus the pwindow by moving onto it.)

function! s:CoffeeAutoCompile_Check(coffeefile)

  let doCompile = g:coffeeAutoCompileAll
  " Buffer setting (true or false) overrides global
  if exists("b:coffeeCompileThisBuffer")
    let doCompile = b:coffeeCompileThisBuffer
  endif

  if !doCompile
    " call s:MsgUser("Use :CoffeeAutoCompileAllToggle or :CoffeeAutoCompileBufferToggle")
    return
  endif

  let targetFolder = expand("%:h")
  let jsFile = expand("%<").".js"

  if g:coffeeCompileIntoFolder != ""
    let targetFolder = g:coffeeCompileIntoFolder
    let jsFile = g:coffeeCompileIntoFolder . "/" . expand("%:t:r").".js"
  endif

  if g:coffeeShowJSChanges != 0
    " If this is our first compile, the js file may not exist
    if !filereadable(jsFile)
      " Make an empty file, so we will get a diff anyway.
      silent exec '!touch "'.jsFile.'"'
    endif
    silent exec '!cp -f "'.jsFile.'" "'.jsFile.'.last"'
  endif

  " call s:MsgUser("Compiling...")
  " silent! exec '!coffee -c "%" > /tmp/coffee.log 2> /tmp/coffee.err'
  silent! exec '!coffee -o "' . targetFolder . '" -c "%" > /tmp/coffee.log 2> /tmp/coffee.err'
  let lines = readfile("/tmp/coffee.err")
  if len(lines) == 0

    "" No error

    if g:coffeeShowJSChanges != 0
      " silent exec '!diff "'.jsFile.'.last" "'.jsFile.'" > /tmp/jsdiffs.diff'
      silent exec '!diff "'.jsFile.'.last" "'.jsFile.'" | grep "^[><+-]" > /tmp/jsdiffs.diff'
      let diffLines = readfile("/tmp/jsdiffs.diff")
      if len(diffLines) > 0
        "" Show changes
        if !exists("w:myHeightBeforePedit")
          let w:myHeightBeforePedit = winheight(0)
        endif
        silent! belowright pedit +:set\ ft=diff\ autoread\ nobuflisted\ noswapfile /tmp/jsdiffs.diff
        " Not working: \ filename=JS_changes_\:w_to_clear
        let s:previewWinIsOpen = 1
        return
      endif
    endif

    "" Cleanup old windows
    if s:previewWinIsOpen == 1
      let s:previewWinIsOpen = 0
      pclose
      if exists("w:myHeightBeforePedit")
        exec "resize ".w:myHeightBeforePedit
        unlet w:myHeightBeforePedit
      endif
      " call s:MsgUser("Compilation problems resolved.")
    endif
    " If this is the only message, it won't break with ch=1 but it will be
    " hidden behind the earlier default message from :w somehow, so we still
    " don't see it!
    " call s:MsgUser("Compiled successfully.")
  else
    "" Error!  Show it
    " :r /tmp/coffee.err
    let splitbelowBefore = &splitbelow
    let &splitbelow = 1
    if !exists("w:myHeightBeforePedit")
      let w:myHeightBeforePedit = winheight(0)
    endif
    " silent! is not recommended.  If the swapfile-what-to-do-dialog occurs we
    " won't see it, but Vim will block until we respond to it!
    silent pedit +:set\ autoread\ nobuflisted\ noswapfile /tmp/coffee.err
    let &splitbelow = splitbelowBefore
    let s:previewWinIsOpen = 1
    " call s:MsgUser("There were problems compiling.")
  endif

endfunction

"" In autocmd
"
"      silent! :call    hides errors
"
"      silent :call     hides echo and confirm messages (still pauses on sleep)

"" Optional stuff

" Only needed when debugging:
function! s:MsgUser(msg)
  "call confirm(a:msg,"Press Enter")
  " With ch=1 echo causes a Press Enter message, because :w is verbose too.
  " Umm no that's only if vim's width is small.
  " 1 echo at ch=1 gets hidden behind :w with no message or pause.
  " With ch=2 we can print one message successfully, two with ch=3 ...
  if &ch > 1
    echo a:msg
    "sleep 200ms
  endif
endfunction

" User interface (commands):
function! s:ToggleOption(optName)
  let optName = a:optName
  if !exists(optName)
    let {optName} = 0
  endif
  let {optName} = 1 - {optName}
  call s:MsgUser("Now ".optName." = ".{optName})
  "echo "Now ".optName." = ".{optName}
  "sleep 800ms
endfunction

:command! CoffeeToggleCompileAll call s:ToggleOption("g:coffeeAutoCompileAll")
:command! CoffeeToggleCompileThisBuffer call s:ToggleOption("b:coffeeCompileThisBuffer")
:command! CoffeeToggleShowChangesToJS call s:ToggleOption("g:coffeeShowJSChanges")

