" Swapping two blocks of text (maybe just two words in a sentence or arguments in a function call) is a very common use-case.
"
" Yet it is still a fiddly maneuver in Vim.  In fact, golfing puzzles have been set for it!
"
" But now it is made easy, using the mnemonic: \change - \with - \done
"
"   \ch[motion]   - deletes one block of text (and remembers this location)
"   \wi[motion]   - deletes the other block
"   \do           - pastes them back in the opposite locations (assuming you haven't moved since doing \wi)
"
" Note: Clobbers the 'X' mark, and the 'c' and 'w' registers.

nnoremap \ch mX"cd
nnoremap \wi "wd
nnoremap \do "cP`X"wP

" TODO: Ideally \do would run automatically after the "with" motion has been provided.
"
" TODO: \ch does not work with backwards motions because it stores the mark before the motion, not after.
"       This could be fixed similarly to \do, by reading the motion, executing the delete, and only then setting the mark.
