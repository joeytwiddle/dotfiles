" Swapping two blocks of text (maybe just two words in a sentence or two
" parameters in a function call) is a very common use-case.
"
" Yet it is still fiddly to do in Vim.  In fact, golfing puzzles have been set
" for it!  Like: http://www.vimgolf.com/challenges/4fcccb70024f950001000026
"
" We can do better, using the mnemonic "(ch)ange (wi)th":
"
"   \ch   - yanks word under cursor, or visual selection, and remembers this
"           location
"
"   \wi   - yanks word under cursor, or visual selection, then pastes the two
"           yanked blocks back in the opposite locations
"
" Note: Clobbers the 'X' mark, and the 'c' and 'w' registers.
"
" BUG: Does not work well if either block sits at the end of the line, because
"      deleting such a block forces the cursor to move back one char.
"      (Vim's cursor cannot sit *on* the end-of-line in normal mode)
"
" If you prefer the mnemonic "(sw)ap (wi)th" then :%s/\<ch\>/sw/

" In normal mode, yank the word under the cursor (diw - change if preferred)
nnoremap \ch "cdiwmX
nnoremap \wi "wdiw"cP`X"wP

" In visual mode, just yank the selection (d)
vnoremap \ch "cdmX
vnoremap \wi "wd"cP`X"wP
