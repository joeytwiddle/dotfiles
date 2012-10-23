" BreakIndent Beta tries to make wrapped lines look neater and less disruptive, by updating showbreak to indent them to the same column as the currently focused line.
"
" Warning: Because it changes showbreak, it can cause lines to shift up and down when a new indent is applied.  Either enable breakindent_never_shrink or put up with it!
"
" Unlike the original breakindent, it cannot present a different indent for each line.  Instead it updates the showbreak option to fit the indent of the current line.
"
" Naturally this requires :set wrap in order to work.  If you don't need visible tabs, you could also :set nolist .  And now you can finally disable auto-wrapping with :set textwidth=0 wrapmargin=0 or perhaps :set formatops-=cq
"
" BreakIndent Beta is a pure vimscript alternative to the old breakindent patch, which I failed to get working smoothly in modern Vim.

" When set to 1, this will stop breakindent from changing so often
let g:breakindent_never_shrink = 0

" This SINGLE char will be used to display the indent
let g:breakindent_char = " "

" This string will be appended after the indent, then the line will follow
let g:breakindent_symbol = "\\\\ "

" This replaces the symbol with a gap that varies according to the length of the first word in the current line.  This can help text after a // or # or " comment to align neatly.  Not for use with breakindent_never_shrink.  Also worth noting this restricts updates to occur only when focused on lines which wrap.
let g:breakindent_match_gap = 0
let g:breakindent_gapchar = "\\"

augroup BreakIndent
  autocmd!
  autocmd CursorHold * call s:UpdateBreakIndent()
  autocmd CursorHoldI * call s:UpdateBreakIndent()
augroup END

let g:breakindent_max_so_far = 0

function! s:UpdateBreakIndent()

  let line = getline(".")
  let indentString = substitute(line, "[^ 	].*", "", "")
  " echo "Indent length ".len(indentString)
  let numtabs = len(substitute(indentString, "[^	]", "", ""))
  let tabwidth = &tabstop
  let realindent = len(indentString) - numtabs + tabwidth*numtabs

  if g:breakindent_never_shrink
    if realindent > g:breakindent_max_so_far
      let g:breakindent_max_so_far = realindent
    endif
    if realindent < g:breakindent_max_so_far
      " do not reduce showbreak
      return
    endif
  endif

  let l:bis = g:breakindent_symbol

  if g:breakindent_match_gap
    let realLineLength = len(line) - len(indentString) + realindent
    " It seems unwise to try to learn the gap from a line which is not long enough to wrap.
    " Because we don't remember the last bis we set, we avoid setting any indent at all.
    " Although the same might be said for learning indentation itself, but less so.
    if realLineLength <= winwidth(".")
      return
    endif
    let lineAfterIndent = substitute(line, "^[ 	]*", "", "")
    let firstWord = substitute(lineAfterIndent, "[ 	].*", "", "")
    " let l:bis = repeat(g:breakindent_gapchar, len(firstWord)+1)
    "" Sanity check
    if len(firstWord) > winwidth(".")/3
      firstWord = "    "
    endif
    let l:bis = repeat(g:breakindent_gapchar, len(firstWord)) . " "
  endif

  let &showbreak = repeat(g:breakindent_char,realindent) . l:bis

endfunction

