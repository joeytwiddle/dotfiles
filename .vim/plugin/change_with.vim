" Swapping two blocks of text (maybe just two words in a sentence or two
" parameters in a function call) is a very common use-case.
"
" Yet it is still fiddly to do in Vim.  In fact, golfing puzzles have been set
" for it!  Like: http://www.vimgolf.com/challenges/4fcccb70024f950001000026
"
" Here we try to encapsulate the action, using the mnemonic "(ch)ange (wi)th":
"
"   \ch   - yanks word under cursor, or visual selection, and remembers this
"           location
"
"   \wi   - yanks word under cursor, or visual selection, then pastes the two
"           yanked blocks back in the swapped locations
"
" Note: Clobbers the 'X' mark, and the 'c' and 'w' registers.
"
" We replace each word with a placeholder char '_' so that the cursor will not
" be pushed back if we yank a block at the end of a line.  (Vim's cursor
" cannot sit *on* the end-of-line in normal mode but it can sit on the '_'.)
"
" BUG: If you try to replace two words on the same line starting with the
" right one, and the words have different length, then the replacement will
" mis-align because pasting the first word into the position of the second
" will shift the marker.  A function could solve this by comparing the columns
" and doing the replacement in reverse order if need be.
"
" If you prefer the mnemonic "(sw)ap (wi)th" then :%s/\<ch\>/sw/

" In normal mode, yank the word under the cursor (diw - change if preferred)
nnoremap \ch "cciw_<Esc>mX
nnoremap \wi "wciw_<Esc>"cgPx`X"wgPx

" In visual mode, just yank the selection (d)
vnoremap \ch "cc_<Esc>mX
vnoremap \wi "wc_<Esc>"cgPx`X"wgPx
