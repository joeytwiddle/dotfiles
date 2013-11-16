" This is an alternative thing with a bit of SkyBison like behaviour
" Basically it's what I made after I tried SkyBison but missed my familiar wildmenu.

" It seems to have some significant issues:
" If completion is unavailable (e.g. :set ft=p) then a literal ^Z is inserted.
" This issue is significant enough that I have disabled SkyBisonBeta.
" Actually defining what I want, for all situations, is difficult.
" I think I'm after a fake <Tab> without completion, just to show what is in
" the completion list, in case I was to press Tab again.  I can't have that:
" wildmode: When there is only a single match, it is fully completed in all cases.
" I find this problematic, because I cannot just type words, they get completed for me!
" A fake c_CTRL-D would do the job, except for the annoying "More" prompt on
" large pages.

command! SkyBisonBeta call <SID>SkyBisonBeta()
command! SkyBisonBetaClose call <SID>SkyBisonBetaClose()

function! s:SkyBisonBeta()

  " set wildmenu

  "" This is what I usually use:
  " set wildmode=longest:full,full
  "" This mode works well:
  " set wildmode=list,full
  "" The initial list mode <c-d> is useful for showing lots of results (e.g.
  "" folders), compared to wildmenu which only uses one line.
  "" But it can produce a "More.." pager on really longs lists, which is annoying.
  "" Oh, that can be disabled with: :set nomore

  " The wildchar is disabled from working in macros (and mappings it would
  " appear) but we can use wildcharm.
  " If you only want a list, trigger <c-D> instead of wcm.
  set wildcharm=<c-z>

  if !exists('g:SkyBisonBeta_After_Each_Stroke')
    let g:SkyBisonBeta_After_Each_Stroke = '<c-z>'
    "let g:SkyBisonBeta_After_Each_Stroke = '<c-z><c-l>'
  endif
  let stroke = g:SkyBisonBeta_After_Each_Stroke

  for i in range(65,90)
    let c = nr2char(i)
    exec "cnoremap " . c . " " . c . stroke
  endfor
  for i in range(97,122)
    let c = nr2char(i)
    exec "cnoremap " . c . " " . c . stroke
  endfor
  exec "cnoremap / /" . stroke
  exec "cnoremap . ." . stroke
  exec "cnoremap <Space> <Space>" . stroke
endfunction

function! s:SkyBisonBetaClose()
  for i in range(65,90)
    let c = nr2char(i)
    exec "cunmap ".c
  endfor
  for i in range(97,122)
    let c = nr2char(i)
    exec "cunmap ".c
  endfor
  exec "cunmap /"
  exec "cunmap ."
  exec "cunmap <Space>"
endfunction

" call g:SkyBisonBeta()

