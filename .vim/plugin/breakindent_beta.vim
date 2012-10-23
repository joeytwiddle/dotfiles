" BreakIndent beta is a pure vimscript alternative to the old breakindent
" patch, which I failed to get working smoothly in modern Vim.
"
" Unlike the original breakindent, it cannot present a different indent on
" different lines.  Instead it updates the showbreak option to fit the indent
" of the current line.
"
" Naturally this requires :set wrap in order to work.

" When set to 1, this will stop breakindent from changing so often
let g:breakindent_never_shrink = 0

" This string will be appended after the indent
let g:breakindent_symbol = ":::"

" This SINGLE char will be used to display the indent
let g:breakindent_char = ":"

augroup BreakIndent
  autocmd!
  autocmd CursorHold * call s:UpdateBreakIndent()
  autocmd CursorHoldI * call s:UpdateBreakIndent()
augroup END

let g:breakindent_max_so_far = 0

function! s:UpdateBreakIndent()
  let line = getline(".")
  let indentString = substitute(line, "[^ 	].*", "", "")
  echo "Indent length ".len(indentString)
  let numtabs = len(substitute(indentString, "[^	]", "", ""))
  let tabsize = &tabstop
  let realindent = len(indentString) - numtabs + tabsize*numtabs
  if g:breakindent_never_shrink
    if realindent > g:breakindent_max_so_far
      let g:breakindent_max_so_far = realindent
    endif
    if realindent < g:breakindent_max_so_far
      " do not reduce showbreak
      return
    endif
  endif
  let &showbreak = repeat(g:breakindent_char,realindent) . g:breakindent_symbol
endfunction

