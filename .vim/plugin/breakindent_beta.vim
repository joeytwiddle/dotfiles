" BreakIndent Beta tries to make wrapped lines look neater and less disruptive, by updating showbreak dynamically to match the indent of the current focused line.
"
" Warning: Because it changes showbreak, it can cause lines to visibly shift up and down when a new indent is applied.  To reduce how often this happens, you can enable breakindent_update_rarely, breakindent_match_gap or breakindent_never_shrink.
"
" BreakIndent Beta is a pure vimscript alternative to the old breakindent patch, which I failed to get working smoothly in modern Vim.  Unlike the breakindent patch, this vimscript *cannot* present a different indent for each line.  Instead it updates the showbreak option to fit the indent of the current cursor line.  Unfortunately this means that showbreak can change often, and other lines on the display may not appear at the ideal indent.
"
" Since showbreak is a global, it will affect all windows; this can not be prevented.
"
" Some commands that may be useful when wrapping long lines:
"
"   :set wrap                  " This script does nothing in nowrap mode
"   :set linebreak nolist      " Break lines cleanly at word gaps, hides tabs
"   :set list                  " Visible tabs, breaks words anywhere
"
"   :set formatopts-=ct        " Disable auto-linefeed when typing
"
"   :highlight NonText ctermfg=darkblue       " Theme your indent symbols
"   :let g:breakindent_match_gap = 1          " Change breakindent settings
"   :nnoremap <Leader>w :set invwrap<Enter>   " Quick keybind to toggle wrap
"
" See also: https://retracile.net/wiki/VimBreakIndent   (The patch can be downloaded from the Original Format link at the bottom of the page)


" == Options ==

" This character will be used to display the indent.  I like it blank.
if !exists("g:breakindent_char")
  let g:breakindent_char = ' '
endif

" This string appears between the indent and the wrapped text, as a marker/indicator of wrapping.
if !exists("g:breakindent_symbol")
  let g:breakindent_symbol = '\\ '
endif

" This option replaces the symbol with a gap that varies according to the length of the first word in the current line.  This can help to neatly align text following an initial comment symbol such as # or " or //.  It automatically enables breakindent_update_rarely and disables breakindent_never_shrink.
if !exists("g:breakindent_match_gap")
  let g:breakindent_match_gap = 0
endif

" Character used to build the gap symbol.
if !exists("g:breakindent_gapchar")
  let g:breakindent_gapchar = ':'
endif

" This will only update the showbreak setting when we are focused on a line which is being wrapped.
" If set to 0, it updates every time we stop on a line with a different indent, which can be annoying on files with a lot of indent changes.  (If you turn wrapping on only temporarily when you need it, then you will not notice the changes, and showbreak will always be kept up-to-date.)
if !exists("g:breakindent_update_rarely")
  let g:breakindent_update_rarely = 1
endif

" When set to 1, this will only change indent to handle deeper lines, and never reduce it when focused on shallower lines.  If you don't mind over-indentation, but can't stand under-indentation, then this is for you.
" There is no facility at the moment to search for the deepest indent without visiting it.
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
  let numtabs = len(substitute(indentString, "[^	]*", "", "g"))
  let tabwidth = &tabstop
  let screenIndent = len(indentString) - numtabs + tabwidth*numtabs
  let screenLineLength = len(line) - len(indentString) + screenIndent

  let showIndent = screenIndent
  " Sanity check - never use more than a quarter of the screen!
  let maxIndent = winwidth(".") / 4
  let showIndent = min([showIndent,maxIndent])

  if g:breakindent_update_rarely && screenLineLength < winwidth(".")
    return
    " BUG: If showbreak is particularly high on entry, then the current line might be wrapped now, even if it won't be with the new showbreak.
  endif

  if g:breakindent_never_shrink && !g:breakindent_match_gap
    if showIndent > g:breakindent_max_so_far
      let g:breakindent_max_so_far = showIndent
    endif
    if showIndent < g:breakindent_max_so_far
      " do not reduce showbreak
      return
    endif
  endif

  let bis = g:breakindent_symbol

  if g:breakindent_match_gap
    " It seems unwise to try to learn the gap from a line which is not itself long enough to wrap.
    if screenLineLength <= winwidth(".")
      " Because we don't remember the last bis we set, we avoid updating the indent at all.
      return
    endif
    let lineAfterIndent = substitute(line, "^[ 	]*", "", "")
    let firstWord = substitute(lineAfterIndent, "[ 	].*", "", "")
    let gapWidth = len(firstWord)
    " Sanity check - never use more than a quarter of what is left!
    let maxWidth = (winwidth(".") - showIndent) / 4
    let gapWidth = min([gapWidth,maxWidth])
    let bis = repeat(strpart(g:breakindent_gapchar,0,1), gapWidth) . " "
  endif

  " It's a global, so forget about setlocal :P
  let &showbreak = repeat(strpart(g:breakindent_char,0,1),showIndent) . bis

endfunction

