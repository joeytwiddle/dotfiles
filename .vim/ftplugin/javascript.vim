" Some yum here: http://oli.me.uk/2013/06/29/equipping-vim-for-javascript/
" Recommends syntastic, YouCompleteMe and tern

" This one causes a flash but seems to work :)
"iab \f function) {<CR>}<Up><End><Left><Left><Left>
" But with the {} mapping below, it seems we don't need this one.
iab \f function () {<CR><Up><End><Left><Left><Left>
"iab -> function) {ODODOD
" These only trigger with a space before and after them.  =/
"iab ( ()<Left>
"iab { {<CR>}<Up><End>
"iab { {}<Left>
" And then I installed UltiSnips :-P
" and delimitMate
" but still...
inoremap <buffer> {<CR> {<CR><CR>}<Up><Esc>cc

" Grabs the highlighted expression and logs it
" Adds the filename and escapes all '$'s in the string.
"vnoremap <buffer> <Leader>log yoconsole.log("<C-R>":", <C-R>");<Esc>
" We use :silent! in case escaping '"' to '\"' fails because there are no '"'s in the expression.
" ISSUES: Clobbers clipboard (easily fixed)
"         :s clobbers search (@/) so we may want to store and restore it.
let foundSemicolon = search('; *$', 'nw') > 0
if foundSemicolon
  "vnoremap <buffer> <Leader>log yoconsole.log(_QUOTE_[<C-R>=expand('%:t')<Enter>] <C-R>":_QUOTE_<Esc>:silent! s/"/\\"/g <Bar> s/_QUOTE_/"/g<CR>A, <C-R>");<Esc>
  vnoremap <buffer> <Leader>log yoconsole.log(_QUOTE_<C-R>":_QUOTE_<Esc>:silent! s/"/\\"/g <Bar> s/_QUOTE_/"/g<CR>A, <C-R>");<Esc>
else
  "vnoremap <buffer> <Leader>log yoconsole.log(_QUOTE_[<C-R>=expand('%:t')<Enter>] <C-R>":_QUOTE_<Esc>:silent! s/'/\\'/g <Bar> s/_QUOTE_/'/g<CR>A, <C-R>")<Esc>
  vnoremap <buffer> <Leader>log yoconsole.log(_QUOTE_<C-R>":_QUOTE_<Esc>:silent! s/'/\\'/g <Bar> s/_QUOTE_/'/g<CR>A, <C-R>")<Esc>
endif
" viW is *sometimes* preferable, e.g. to catch 'obj.prop[i]' but more often than not it grabs too much, e.g. it catches 'obj.prop[i]);'
nmap <buffer> <Leader>log viw<Leader>log
nmap <buffer> <Leader>Log viW<Leader>log

" Refactoring
" Use `V` to select whole lines when extracting a function
vnoremap <buffer> <Leader>F >gvdOfunction _ () {<CR><Esc>gPi}<Esc>
nmap <buffer> <Leader>F Vip<Leader>F
vnoremap <buffer> <Leader>V sunnamedVar<Esc>Ovar unnamedVar = <Esc>pa;<Esc>

" Select entire function from visual mode ("v in function")
"vnoremap af <Esc>?^\s*function<CR>v/{<CR>%o
vnoremap af <Esc>?\<function\>\s*[A-Za-z0-9_$]*\s*(<CR>v/{<CR>%o

" Like WebStorm, when closing a block, indent all the lines inbetween
" Note that this will also act on '}'s in strings.  It might be inconvenient.
" Note that it also clobbers mark 'z'
" Previously DISABLED because it was not indenting function callbacks correctly when they come after a `).then(`
inoremap <buffer> } }<Esc>mzv%=g`za
" BUG: If we are in the middle of the line (e.g. interpolating inside a template string) returning to the original mark position will be wrong, if the line has changed indentation (that situation is quite rare).  To fix that:
" TODO: We should only do this if the } is at the end of the current line, or perhaps at the beginning of the current line (ignoring whitespace indentation).



" Convenient command for js-beautify
command! -buffer JSBeautify %!js-beautify -f - -s 2
" Attempt at Feross standard style.  For some reason ';+x' gets pulled up onto the line above.
command! -buffer JSBeautifySS %!js-beautify -f - -s 2 | sed 's+;$++ ; s:^\(\s*\)\(/[^/]\|+[^+]\|-[^-]\|[(\[]\):\1;\2:'



" === Indenting ===

" The below address some indenting issues, but disabled for now because I am using pangloss/vim-javascript
" Autodetect pangloss would be great ;)
if 0

" Outstanding issues:
" - When an if condition spans multiple lines, the body and the closing } are indented an additional (unwanted) level.
" - Indent is poor on `key : value,` but fine on `key: value,`.  Can also occur as a result of ({...}) when (...) or {...} work fine.
" - Extra indent after a line with a missing trailing semicolon.  (This can help detect them!)
" - Comments get re-indented; ideally they would be left alone!
" - Ambiguous cases like: foo([bar, \n baz]);

" When indenting, closing )s should match up with the first char of the opening ('s line, not the ( itself
setlocal cinoptions+=m1
" Without this, the list items inside foo.bar([ \n ... \n ]); will be double indented.
setlocal cinoptions+=(1s
" If comments are indenting 3 spaces on the second line, and you don't want that:
"setlocal cinoptions+=c0

function! GetJoeysJavascriptIndent()
  let this_line_num = line('.')
  let cindent = cindent(this_line_num)
  let this_line = getline('.')
  " Vim's default indenting of multi-line lists in Javascript is awful, resulting in this:
  "
  "     var list = [
  "         'a',
  "     'b',
  "     'c'
  "         ];
  "
  " The following two checks detect and prevent those issues.
  " Prevent the unwanted outdent on the second line of a multi-line list
  if this_line_num > 2
    let last_last_line = getline(this_line_num - 2)
    if match(last_last_line, '\[\s*$') >= 0
      let last_line = getline(this_line_num - 1)
      if match(last_line, ',\s*$') >= 0
        let cindent_last_line = cindent(this_line_num - 1)
        if cindent < cindent_last_line
          return cindent_last_line
        endif
      endif
    endif
  endif
  " Prevent the unwanted indent when ending a multi-line list
  if this_line_num > 1
    "if match(this_line, '^\s*\]\s*)*\s*[,;]*\s*$') >= 0
    if match(this_line, '^\s*\]') >= 0
      let cindent_last_line = cindent(this_line_num - 1)
      let expected_cindent = cindent_last_line - &sw
      if cindent > expected_cindent
        return expected_cindent
      endif
    endif
  endif
  return cindent
endfunction
setlocal indentexpr=GetJoeysJavascriptIndent()

endif



" CheckNotCoffee - If the user opens a Javascript file which was generated
" from Coffeescript, lock the buffer so the user cannot modify it (they should
" find and modify the coffee file instead).

" TODO: We may want to move this to a different file, so it can work with a
" variety of file types / extensions and patterns.

" Similar to the checks in plugin/sws.vim

"" This doesn't work the first time round
"" So we call below, hopefully once per JS buffer.
"" That explicit call might make this trigger redundant!
" autocmd BufReadPost *.js call s:CheckNotCoffee()

function! s:CheckNotCoffee()
  let jsName = expand('%')
  let coffeeName = expand('%<') . ".coffee"
  let firstLine = getline(1)
  "let searchPat = "// Generated by CoffeeScript"
  let searchPat = "// Generated by "
  "let searchPat = '\<[Gg]enerated '      " too general
  "" WARNING: If we make a general match, not a specific match, we really
  "" should NOT set autoread below.
  let matched = match(getline(1), searchPat)
  if matched >= 0
    "echo "Locking buffer because it is *generated* source!"
    setlocal nomodifiable
    " I invariably want this too
    setlocal autoread
  endif
endfunction

call s:CheckNotCoffee()

" NPM-compatible gF
" If the user has no custom mapping for gF, let gF find required JS files
" Adapted from my jade.vim magic gF
" Should be refactored so that various filetypes can configure it for their needs.
" NOTE: Vim already supports special seeking behaviour for gf.  See :h gf
if maparg("gF", 'n') == ''
  nnoremap <buffer> gF :call <SID>LoadNodeModule()<CR>
endif
function! s:SeekFile(folders, extensions, fname)
  for folder in a:folders
    for ext in a:extensions
      let fname = folder . "/" . a:fname . ext
      if filereadable(fname)
        return fname
      endif
    endfor
  endfor
endfunction
function! s:LoadNodeModule()
  let cfile = expand("<cfile>")
  let fname = cfile
  " See: https://www.npmjs.com/package/common-js-file-extensions
  let extensions = ['', '.js', '.jsx', '.mjs', '.ts', '.tsx', '.json', '.es', '.es6']
  if !filereadable(fname)
    let fname = s:SeekFile([expand("%:h"), '.', './node_modules'], extensions, cfile)
    " Node looks in <package>/index.js first
    if !filereadable(fname)
      let fname = s:SeekFile(['./node_modules/' . cfile . '/'], extensions, 'index')
    endif
    " But <package>/main.js is quite a common location
    if !filereadable(fname)
      let fname = s:SeekFile(['./node_modules/' . cfile . '/'], extensions, 'main')
    endif
    " And <package>/lib/index.js is quite a common location
    if !filereadable(fname)
      let fname = s:SeekFile(['./node_modules/' . cfile . '/lib'], extensions, 'index')
    endif
    " TODO: In fact the entry point file location is configurable in package.json.
    " We could try to extract it: node --eval 'fs=require("fs");data=JSON.parse(fs.readFileSync("./package.json"));console.log(data.bin)'
    " But perhaps easier: node --eval "console.log( require.resolve('" . cfile . "') )"   (We should run this from the same folder as the current file.)
    " This returns an absolute filename, which we might want to relativise.  Otherwise it will spew an error to stderr, but still exit with exit code 0.
  endif
  if filereadable(fname)
    let fname = simplify(fname)
    "exec "edit ".fname
    call feedkeys(":edit ".fname."\n")
    " Using feedkeys prevents this function from being blamed if any errors/warnings occur!
  else
    " Both of these show "error in function" :P
    normal! gF
    "echoerr "Can't find file ".cfile." in path"
  endif
endfunction

" Instead of FindFileAbove we could probably use findfile(fname, path.';')
function! s:FindFileAbove(fname, path)
  let path = a:path
  while 1
    if filereadable(path . "/" . a:fname)
      return 1
    endif
    if path == "/"
      break
    endif
    let path = fnamemodify(path . "/../", ":p")
  endwhile
  return 0
endfunction

" Use CTRL-] for Tern if possible
if s:FindFileAbove(".tern-project", ".")
  nnoremap <buffer> <silent> <c-]> :TernDef<CR>
endif

" Run eslint on the current file

" Use CMD-SHIFT-L on Mac or CTRL-SHIFT-L on other systems
" I wanted to map D-S-L but it didn't register (in MacVim gui mode)
" BUG: This fires on CTRL-L which already has a useful meaning.
"nnoremap <buffer> <silent> <C-S-L> :<C-U>call <SID>EslintFixCurrentFile()<CR>
" But in my Linux xterm one of these triggers when I just prett <C-L> which is no good
"nnoremap <buffer> <silent> <D-L> :<C-U>call <SID>EslintFixCurrentFile()<CR>
"nnoremap <buffer> <silent> <C-S-L> :<C-U>call <SID>EslintFixCurrentFile()<CR>
" Let's use this instead
nnoremap <buffer> <silent> <Leader>lint :<C-U>call <SID>EslintFixCurrentFile()<CR>

if !get(g:, 'EslintFix_is_reloading_file', 0)
  function! s:EslintFixCurrentFile()
    " TODO: We should cd to the file's folder, to make sure we are running its version of eslint.
    let current_file = expand('%')

    " TODO: If both standard and eslint are available as globals, perhaps we should check for a .eslintrc file to decide which one to use.
    "       (For local installs, standard always pulls in eslint, but we could still do the file check.)
    let lint_command="eslint --fix"
    " We use [:-2] to strip the trailing newline
    let npm_root = system("npm root")[:-2]
    if npm_root != ''
      if filereadable(npm_root . '/.bin/standard')
        let lint_command="npx standard --fix"
      elseif filereadable(npm_root . '/.bin/eslint')
        let lint_command="npx eslint --fix"
      endif
    endif

    noautocmd write
    let output = system(lint_command . " " . shellescape(current_file))
    if v:shell_error != 0
      echo output
    endif
    " When we reload the file, it is likely this script will also be reloaded.
    " That can cause an error: Cannot redefine function ... It is in use
    " I wanted to use noautocmd but the file would end up loading with no syntax!
    " So instead, we use a flag
    let g:EslintFix_is_reloading_file = 1
    silent edit
    unlet g:EslintFix_is_reloading_file
  endfunction
endif
