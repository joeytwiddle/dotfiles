function! JoeysBufferSwitch()

  let searchStr = input("Type part of buffer then <Tab>: ", '', "buffer")
  "echo "Got: ".searchStr

  " Quick and dirty:
  if searchStr != ""
    silent exec ":b ".searchStr
    return
  endif

  "" TODO: If we can find a visible window displaying that buffer, switch to
  "" the window instead of loading the buffer in the current window.

endfunction

command! JoeysBufferSwitch call JoeysBufferSwitch()

nnoremap <C-B> :JoeysBufferSwitch<Enter>

