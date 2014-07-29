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
" Note: Clobbers the 'X' and 'Y' marks, and the 'c' and 'w' registers.
"
" If you prefer the mnemonic "(sw)ap (wi)th" then :%s/\<ch\>/sw/
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
" BUG: If you use it for multiple lines, empty lines are introduced, because
" the placeholder char created its own line when we cut a block.  If it was
" created by a multi-line cut, it should be removed with `dd` instead of `x`.
"
" BUG: We now use the Y mark to move back to the second block at the end,
" which feels more natural for the user, but it doesn't work when the second
" block comes later in the same line as the first block, because the mark does
" not shift when earlier characters are pasted.  (In multi-line cases, Vim's
" mark does shift with the lines, so there is no issue.)
"
" Not the same, but related: http://github.com/vim-scripts/flipwords.vim

" In normal mode, yank the word under the cursor (ciw - change if preferred)
nnoremap \ch "cciw_<Esc>mX
nnoremap \wi "wciw_<Esc>mY"cgPx`X"wgPx`Y

" In visual mode, just yank the selection (c)
vnoremap \ch "cc_<Esc>mX
vnoremap \wi "wc_<Esc>mY"cgPx`X"wgPx`Y
