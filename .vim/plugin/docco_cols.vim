" Markdown's docco.css color theme for GVim
" Tested on: CoffeeScript, ...
" Not perfect!

function! g:DoccoCols()

  " Start with a general dark on light theme
  :so /usr/share/vim/vim72/colors/delek.vim

  :hi Normal guibg=#F5F5FF guifg=black
  :hi String guifg=#219161
  :hi coffeeObject guifg=#19469D
  :hi Constant guifg=#954121
  :hi link coffeeKeyword Constant
  :hi clear Type
  :hi link Type Constant
  :hi clear Statement
  :hi link Statement Constant
  :hi coffeeRegexpString guifg=#BB6688
  :hi Comment guifg=#888888
  :hi link coffeeComment Comment
  :hi coffeeParens guifg=black
  :hi clear coffeeVar
  :hi link coffeeVar coffeeObject
  :hi clear coffeeAssign
  ":hi link coffeeAssign coffeeObject
  ":hi clear coffeeAssignProperty
  :hi link coffeeAssignProperty coffeeObject
  :hi coffeeEscape guifg=#dd6600

  " :hi Number guifg=#666666
  " :hi Number guifg=#006666
  :hi Number guifg=black

endfunction

command! DoccoCols call g:DoccoCols()

