" Note that these read the file off disk, not the current (edited) buffer.
:command! JSLintQuickFix execute(":set makeprg=jslint4vimquickfix\\ %") | execute(":silent make") | execute(":copen") | normal 
:command! JSLintQuickFixUpdate execute(":set makeprg=jslint4vimquickfix\\ %") | execute(":silent make!") | normal 

" This works but it is a bit too slow/intrusive to be desirable on large JS files.
"au BufWritePost *.js execute(":JSLintQuickFixUpdate")

