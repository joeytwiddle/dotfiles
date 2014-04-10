" Keep moving in given direction until we reach a new character under the
" cursor.  (Like Ctrl-Arrow in Excel.)  Bound to Ctrl-Shift-Up/Down for Vim.
"
" I find this most useful for:
"
"   - Jumping to the top or bottom of an indented block based on column
"     (especially the tops of blocks in Coffeescript/Python).
"
"   - Getting to the next file in grep output.
"
"   - Generally getting past or out of large blocks of repetitive lines.

let g:move_stay_in_column   = 1   " Will not stop on shorter lines than the one we started on
let g:move_skip_empty_lines = 1   " Never stop on an empty line (if also unifying, never stop on whitespace)
let g:move_unify_whitespace = 1   " Tab, space and empty-line are all considered the same.
let g:move_once_at_start    = 1   " Don't stop on the very next line just because it has a different char from the current!

nnoremap <silent> <C-S-Up>   :call <SID>FindNextChangeNormal("k")<Enter>
nnoremap <silent> <C-S-Down> :call <SID>FindNextChangeNormal("j")<Enter>
" Attempt to work in Visual mode; failed:
vnoremap <silent> <C-S-Up>   :call <SID>FindNextChangeVisual("k")<Enter>
vnoremap <silent> <C-S-Down> :call <SID>FindNextChangeVisual("j")<Enter>
" On Mac OSX, Mission Control hijacks these keys, so we create a couple more:
nnoremap <silent> g<S-Up>    :call <SID>FindNextChangeNormal("k")<Enter>
nnoremap <silent> g<S-Down>  :call <SID>FindNextChangeNormal("j")<Enter>

function! s:FindNextChangeNormal(moveKey) range
  call s:FindNextChange(a:moveKey, 0, 0, 0)
endfunction
function! s:FindNextChangeVisual(moveKey) range
  call s:FindNextChange(a:moveKey, 1, a:firstline, a:lastline)
endfunction
function! s:FindNextChange(moveKey, in_visual_mode, first_line, last_line)
  " TODO BUG: startCol is always 1 when in_visual_mode and without g:move_once_at_start
  "           But somehow if we do move_once_at_start then it goes where it should be.
  let startRow = line(".")
  let unwatedChar = s:GetCharUnderCursor()
  if g:move_once_at_start
    exec "normal "a:moveKey
  endif
  let startColChars = getpos(".")[2]
  let startCol = wincol()
  let nextCharUnderCursor = s:GetCharUnderCursor()
  if nextCharUnderCursor != unwatedChar
    let unwatedChar = nextCharUnderCursor
  endif
  let lastRow = line(".")
  " echo "start (".startCol.",".lastRow.") ".unwatedChar
  while 1
    exec "normal ".a:moveKey
    let newCol = wincol()
    let newRow = line(".")
    let newCharUnderCursor = s:GetCharUnderCursor()
    " echo "(".newCol.",".newRow.") ".newCharUnderCursor
    if newRow == lastRow
      " Failed to move; better stop trying!  (probably reached a boundary)
      break
    endif
    if g:move_skip_empty_lines && newCharUnderCursor == ""
      " Do nothing, continue to next line
    elseif g:move_stay_in_column && newCol != startCol
      " Likewise
    else
      if newCharUnderCursor != unwatedChar
        " We have found what we were looking for!
        "if g:move_skip_empty_lines && unwatedChar == ""
          "let unwatedChar = newCharUnderCursor
          "" We never usually save empty lines, so the last line must have been the first line.  We don't break on the second line just cos the first is non-empty.
          "" I think this is all wrong now.  With new style, least-confusion says we do want to stop on it!
        "else
          "break
        "endif
        break
      endif
    endif
    let lastRow = newRow
  endwhile
  if a:in_visual_mode
    " Restore visual mode, up to the destination.
    " We don't know if we were in v or V mode (lost during the keymapping) so we just assume v.
    let finalRow = line(".")
    let finalColChars = getpos(".")[2]
    call setpos(".", [0, startRow, startColChars])
    normal v
    call setpos(".", [0, finalRow, finalColChars])
  endif
endfunction

function! s:GetCharUnderCursor()
  let c = strpart(getline("."), col(".") - 1, 1)
  if g:move_unify_whitespace && (c==" " || c=="\t")
    let c = ""
  endif
  return c
endfunction

