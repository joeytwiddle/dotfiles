" Vim commands to reformat a .js file into a .coffee file.

" Transform the classic for loop:
" :%s/for (\(var\s\|\)\s*\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*=\s*0\s*;\s*\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*<\s*\([a-zA-Z_$][a-zA-Z0-9_$.]*\)\.length\s*;\s*[a-zA-Z_$]++\s*)\s*{/for \2 in [0...\4.length]/g
" Actually we don't actually require .length
:%s/for (\(var\s\|\)\s*\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*=\s*0\s*;\s*\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*<\s*\([a-zA-Z_$][a-zA-Z0-9_$.]*\)\s*;\s*[a-zA-Z_$]++\s*)\s*{/for \2 in [0...\4]/g

:%s/^var //
:%s/\([ 	]\)var /\1/
" In loops (although loops need to be dealt with!)
:%s/(var /(/

" Comments
:%s/\/\/\/\//##/
:%s/\/\//#/
:%s/\/\*/###/
:%s/\*\//###/

" Semicolons
:%s/;\([ 	]*#\|[ 	]*$\)/\1/

" Anonymous functions
:%s/\<function[ 	]*(\(.*\))[ 	]*{/(\1) ->/
" Named functions
:%s/\<function[ 	]*\([A-Z"a-z_0-9]*\)(\(.*\))[ 	]*{/\1 = (\2) ->/

" Kill {s and }s around functions, ifs and loops.  Have to trust indentation!
:%s/ {$//
" :%s/^[ 	]*}$//
:%s/ }$//
:%s/[^ 	]*} *//

:%s/\<===\>/==/g

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

