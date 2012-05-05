" Displays the syntax/highlight group under the cursor.
" Useful if you want to change the highlight rules of the current file.

" From the VimTips wiki

" BUG: I found I had to press it twice to get sensible readings!

map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
