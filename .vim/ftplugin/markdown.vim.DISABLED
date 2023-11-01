" Note that vim-polyglot also attempts to do this: https://github.com/sheerun/vim-polyglot/blob/master/ftplugin/markdown.vim

" If buffer is reloaded, then clear the flag so that syntax will be reloaded
let b:syntax_included = 0

function! s:IncludeSyntax()
  " Check to see if the SyntaxRange plugin is loaded
  "if &runtimepath !=~ '\<SyntaxRange\>'
  if empty(globpath(&rtp, 'autoload/SyntaxRange.vim'))
    return
  endif

  if exists('b:syntax_included') && b:syntax_included
    return
  endif
  let b:syntax_included = 1

  echo "Loading SyntaxRange include rules..."
  " This works well
  call SyntaxRange#Include('^```\(sh\|bash\)$', '^```$', 'sh', 'String')
  " But this only works if we source it ourselves, after the buffer has loaded
  " Is there perhaps something during file load that overwrites/breaks it?
  call SyntaxRange#Include('^```js$', '^```$', 'javascript', 'String')
  " This one the same
  call SyntaxRange#Include('^```html$', '^```$', 'html', 'String')
endfunction

" Too early, we don't see the rules or the highlighting
"call s:IncludeSyntax()

" Load the syntax rules a little later
augroup MarkdownIncludeSyntax
  autocmd!
  autocmd CursorHold <buffer> call s:IncludeSyntax()
augroup END
