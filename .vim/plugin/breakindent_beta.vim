" BreakIndent Beta tries to make wrapped lines look neater and less disruptive, by updating showbreak dynamically to match the indent of the current focused line.
"
" Vim's default 'wrap' mode shows wrapped lines unindented:
"
"     This line is indented and also very
" \ long so it was displayed wrapped.
"
" But with BreakIndent Beta, it would appear like this (when focused):
"
"     This line is indented and also very
"     \ long so it was displayed wrapped.
"
" Warning: Because it changes showbreak, it will cause lines to visibly shift left or right, and possibly up or down, when a new indent is applied.  To reduce how often this happens, you can enable breakindent_update_rarely or breakindent_never_shrink.
"
" BreakIndent Beta is a weak approximation of the 'breakindent' patch, which requires recompilation of Vim's source-code.  Unlike the patch, this script *cannot* present a different indent for each line.  Instead it updates the showbreak option to fit the indent of the *current* cursor line.  Unfortunately this means that showbreak can change often, and other lines on the display may not appear at the ideal indent.
"
" Since showbreak is a global, it will affect all windows; this can not be prevented.
"
" Some commands that may be useful when wrapping long lines:
"
"   :set wrap                  " This script does nothing in nowrap mode
"   :set linebreak nolist      " Break lines cleanly at word gaps, hide Tabs
"   :set list                  " Visible Tabs, but breaks words anywhere
"
"   :set formatopts-=ct        " Disable auto-linefeed when typing
"
"   :highlight NonText ctermfg=darkblue       " Theme your indent symbols
"   :nnoremap <Leader>w :set invwrap<Enter>   " Quick keybind to toggle wrap
"
" To get started finding your preferred settings, try out the following.
" You will need to move onto a wrapped line each time to trigger an update.
"
"   :let g:breakindent_char               " Check its current value
"   :let g:breakindent_char = '<'         " Try setting the char used to indent
"   :let g:breakindent_symbol             " Check its current value
"   :let g:breakindent_symbol = ' | '     " Try a flat continuation symbol
"   :let g:breakindent_match_gap = 1      " Enable first-word matching
"   :let g:breakindent_gapchar = '\'      " The symbol used below the word
"   :let g:breakindent_symbol = ' '       " After gapchars just put a space
"   :let g:breakindent_use_first_word = 1   " Use the first word as the symbol
"
" I also forked this script to create a version that sets the breakindent to the deepest (most indented) wrapped line currently on the screen.  This may be preferable if you dislike indents that are too shallow but don't mind indents that are too deep.  That version is in breakindent_beta.never_shallow.vim
"
" Alternative: The real breakindent patch is being kept up-to-date at: https://retracile.net/wiki/VimBreakIndent   (Look for the "Original Format" link at the bottom of the page)

" CONSIDER TODO: New feature.  There are occasionally situations where I would like more indentation than bi_b currently provides.  For example:
"
"     // This C comment contains a list:
"     //   - First item.
"     //   - This particular list item is very very
"            \ long and so it wraps.
"     //   - Another list item.
"
" As you can see, I would like the wrapped indentation to be much deeper than usual, simply because this long line is a list item.
" A simple approach to this would be to indent to the same level as the first alphabetic character.
" A more advanced way would be to allow a regexp (or perhaps for clarity, a list of regexps) to pick out these special lines.  Each regexp might have some extra rules attached about how far to indent.  E.g. some users might prefer the \ to appear under the - in the previous example (depends whether he prefers the words aligned, or likes to see the vertical gap between '-'s).



" If this version of Vim has the breakindent patch, then this plugin isn't needed.
if exists('&breakindent')
  finish
endif



" == Options ==

" This character will be used to display the indent.  I like it blank ' '.
if !exists("g:breakindent_char")
  let g:breakindent_char = ' '
endif

" This string appears after the indent but before the wrapped text, as a marker/indicator of wrapping.  Set it empty '' to match the indentation of the first line.
if !exists("g:breakindent_symbol")
  let g:breakindent_symbol = '\\ '
endif

" This option adds a gap that updates according to the length of the first word in the current line.  This can help to neatly align text following an initial comment symbol such as # or " or //.
if !exists("g:breakindent_match_gap")
  let g:breakindent_match_gap = 0
endif

" Character used to build the gap symbol.
if !exists("g:breakindent_gapchar")
  let g:breakindent_gapchar = ':'
endif

" Instead of matching the *length* of the first word, this actually copies the first word to use as the breakindent symbol (and appends a space).  This can look neat for comments, but can also be misleading: only the colour indicates that the breakindentsymbol is NOT part of the text!  For non-comment wrapped lines it just looks stupid/confusing.  A future improvement could allow a regexp to be provided for which the word would be copied, otherwise only its length would be used.
if !exists("g:breakindent_use_first_word")
  let g:breakindent_use_first_word = 0
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
  let numTabs = len(substitute(indentString, "[^	]*", "", "g"))
  let numSpaces = len(indentString) - numTabs
  let tabwidth = &tabstop
  let screenIndent = numSpaces + tabwidth*numTabs
  let screenLineLength = len(line) - len(indentString) + screenIndent
  " BUG TODO: We compare screenLineLength to winwidth(".") later, but this fails to account for the signs columns (and perhaps similarly fails for fold columns).

  " Calculate the first part, that brings us up to the first line.
  let showIndent = screenIndent
  " Sanity check - never use more than three quarters of the screen!
  let maxIndent = 3 * winwidth(".") / 4
  let showIndent = min([showIndent,maxIndent])

  if g:breakindent_update_rarely && screenLineLength < winwidth(".")
    return
    " BUG: If showbreak is particularly high on entry, then the current line might be wrapped now, even if it wouldn't be with a recalculated showbreak!
  endif

  if g:breakindent_never_shrink
    if showIndent > g:breakindent_max_so_far
      let g:breakindent_max_so_far = showIndent
    endif
    if showIndent < g:breakindent_max_so_far
      " do not reduce showbreak
      return
    endif
  endif

  let bis = g:breakindent_symbol

  if g:breakindent_match_gap || g:breakindent_use_first_word
    " It seems pointless to try to learn a new gap count from a line which is not itself long enough to wrap.
    if screenLineLength <= winwidth(".")
      " Because we don't remember the last bis we set, we avoid updating the indent at all.
      return
    endif
    let lineAfterIndent = substitute(line, "^[ 	]*", "", "")
    let firstWord = substitute(lineAfterIndent, "[ 	].*", "", "")
    if g:breakindent_use_first_word
      let bis = firstWord . ' '
    else
      let gapWidth = len(firstWord)
      " Sanity check - never use more than a quarter of what is left for the gap!
      let maxWidth = (winwidth(".") - showIndent) / 4
      let gapWidth = min([gapWidth,maxWidth])
      let bis = repeat(strpart(g:breakindent_gapchar,0,1), gapWidth) . g:breakindent_symbol
    endif
  endif

  " It's a global, so forget about setlocal :P
  let &showbreak = repeat(strpart(g:breakindent_char,0,1),showIndent) . bis

endfunction

