" We cannot check the existence of an autoload function, because it might not be loaded yet!
" But we can check to see if the plugin file exists.
" (Or failing that, we could just try-catch)
"if &runtimepath =~ '\<SyntaxRange\>'
if !empty(globpath(&rtp, 'autoload/SyntaxRange.vim'))
  echo "Loading SyntaxRange include rules..."
  " This works well
  call SyntaxRange#Include('^```sh$', '^```$', 'sh', 'String')
  " But this only works if we source it ourselves, after the buffer has loaded
  " Is there perhaps something during file load that overwrites/breaks it?
  call SyntaxRange#Include('^```js$', '^```$', 'javascript', 'String')
endif
