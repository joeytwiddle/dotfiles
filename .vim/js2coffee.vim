" Vim commands to reformat a .js file into a .coffee file.

" Transform the classic for loop:
" :%s/for (\(var\s\|\)\s*\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*=\s*0\s*;\s*\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*<\s*\([a-zA-Z_$][a-zA-Z0-9_$.]*\)\.length\s*;\s*[a-zA-Z_$]++\s*)\s*{/for \2 in [0...\4.length]/g
" Actually we don't actually require .length
silent! %s/for (\(var\s\|\)\s*\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*=\s*0\s*;\s*\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*<\s*\([a-zA-Z_$][a-zA-Z0-9_$.]*\)\s*;\s*[a-zA-Z_$]++\s*)\s*{/for \2 in [0...\4]/g

" Remove all var declarations
silent! %s/^var //
silent! %s/\(\s\)var /\1/
" In loops (probably already cleared above)
silent! %s/(var /(/

" Change //// comments into ## comments (I used to use //// sometimes)
silent! %s/\/\/\/\//##/
" Change // comments into # comments
silent! %s/\/\//#/
" Change /* ... */ comment blocks into ### ... ###
silent! %s/\/\*/###/
silent! %s/\*\//###/

" Remove semicolons
silent! %s/;\(\s*#\|\s*$\)/\1/

" Convert anonymous functions into ->
silent! %s/\<function\s*(\(.*\))\s*{/(\1) ->/
" Conver named functions into ->
silent! %s/\<function\s*\([A-Z"a-z_0-9]*\)(\(.*\))\s*{/\1 = (\2) ->/

" Kill {s and }s around functions, ifs and loops.  Have to trust indentation!
silent! %s/ {$//
" :%s/^\s*}$//
silent! %s/ }$//
silent! %s/[^ 	]*} *//

" TODO: We should probably check for one-liners and convert them into "if ... then" or "while ... then" CS one-liners.
" Drop ()s from if statements
silent! %s/\<if\>\s*(\(.*\))\s*$/if \1/g
" Drop ()s from while statements
silent! %s/\<while\>\s*(\(.*\))\s*$/while \1/g

" Triple-equals is double-equals in CS.  There is no double-equals, so they will be broken (fixed).
silent! %s/\<===\>/==/g

" Change this. to @
silent! %s/\<this\./@/g
" Change this to @ (may uglify comments!)
":%s/\<this\>/@/g

"" TODOS:

" DONE: === to ==.  We could turn == into is to make them stand out.
" (Occasionally we might have expected/wanted type coercion.)

" Optional: Kill ()s around if and while conditions (and switch?)

" Turn "var x;" markers into "x = undefined" markers, before we destroy them.
" Currently we just get "x" on a line by itself, which might not achieve what
" we want (or maybe it does).
" Convert ternary "(a?b:c)" into "(if (a) then (b) else (c))"

" Heredocs /*...*/ inside the ()s of ifs or fors make CS complain when they
" become ###...###.

" DO NOT destroy return statements (unless we are sure they were the last
" statement of a function) because they might be breaking out of the middle of
" a function.

" BUGS:
" `var x;` gets broken, as mentioned above
" `o = {}` becomes `o = `

