" BreakIndent Beta tries to make wrapped lines look neater and less disruptive, by updating showbreak to indent them to the same column as the currently focused line.
"
" Warning: Because it changes showbreak, it can cause lines to shift up and down when a new indent is applied.  To reduce this, you can enable breakindent_match_gap, breakindent_update_rarely, or breakindent_never_shrink.
"
" Unlike the original breakindent, it cannot present a different indent for each line.  Instead it updates the showbreak option to fit the indent of the current line.
"
" Naturally this requires :set wrap in order to work.  If you don't need visible tabs, you could also :set nolist .  And now you can finally disable auto-wrapping with :set textwidth=0 wrapmargin=0 or perhaps :set formatops-=cq
"
" BreakIndent Beta is a pure vimscript alternative to the old breakindent patch, which I failed to get working smoothly in modern Vim.

" This SINGLE char will be used to display the indent
if !exists("g:breakindent_char")
  let g:breakindent_char = " "
endif

" This string will be appended after the indent, then the wrapped text will follow
if !exists("g:breakindent_symbol")
  let g:breakindent_symbol = "\\\\ "
endif

" This replaces the symbol with a gap that varies according to the length of the first word in the current line.  This can help text after a leading comment such as // or # or " to align neatly.  This implies breakindent_update_rarely, and disables breakindent_never_shrink.
if !exists("g:breakindent_match_gap")
  let g:breakindent_match_gap = 1
endif

if !exists("g:breakindent_gapchar")
  let g:breakindent_gapchar = "\\"
endif

" This will only update the showbreak setting when we are focused on a line which is wrapping.
" Otherwise it updates every time we stop on a line with a different indent.
if !exists("g:breakindent_update_rarely")
  let g:breakindent_update_rarely = 0
endif

" When set to 1, this will only increase indent to handle deeper lines, and not reduce it when focused on shallower lines.
if !exists("g:breakindent_never_shrink")
  let g:breakindent_never_shrink = 0
endif

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
  let realLineLength = len(line) - len(indentString) + realindent

  if g:breakindent_update_rarely && realLineLength < winwidth(".")
    return
  endif

  if g:breakindent_never_shrink && !g:breakindent_match_gap
    if realindent > g:breakindent_max_so_far
      let g:breakindent_max_so_far = realindent
    endif
    if realindent < g:breakindent_max_so_far
      " do not reduce showbreak
      return
    endif
  endif

  let bis = g:breakindent_symbol

  if g:breakindent_match_gap
    " It seems unwise to try to learn the gap from a line which is not long enough to wrap.
    " Because we don't remember the last bis we set, we avoid setting any indent at all.
    if realLineLength <= winwidth(".")
      return
    endif
    let lineAfterIndent = substitute(line, "^[ 	]*", "", "")
    let firstWord = substitute(lineAfterIndent, "[ 	].*", "", "")
    " let l:bis = repeat(g:breakindent_gapchar, len(firstWord)+1)
    "" Sanity check - never use more than a quarter of what is left!
    let gapWidth = len(firstWord)
    if gapWidth > (winwidth(".") - realindent) / 4
      let gapWidth = 6
    endif
    let bis = repeat(g:breakindent_gapchar, gapWidth) . " "
  endif

  " It's a global, so forget about setlocal :P
  let &showbreak = repeat(g:breakindent_char,realindent) . bis

endfunction

