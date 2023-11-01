"exec "setlocal iskeyword=" . &iskeyword . ",-"
setlocal iskeyword+=.

" I use logs like this in my sunlogger.js
syntax match logLog /\[log\]/
hi logLog ctermfg=blue guifg=blue
syntax match logWarn /\[warn\]/
hi logWarn ctermfg=yellow guifg=yellow
syntax match logError /\[error\]/
hi logError ctermfg=red guifg=red
syntax match logInfo /\[info\]/
hi logInfo ctermfg=cyan guifg=cyan
