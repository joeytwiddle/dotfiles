" Replaces some common Javascript keywords with symbols
" Inspired by Firefly's script

" Suggestions:
"hi Conceal guibg=darkblue guifg=magenta
"hi Conceal guibg=darkmagenta guifg=white
"hi clear Conceal
"hi Conceal guifg=magenta
"hi clear Conceal
"hi link Conceal GentleMaryPurple
"hi link Conceal Statement
"hi Conceal ctermbg=black ctermfg=133 guibg=black guifg=#A576A0

command! JSConcealOn :call s:JSConcealOn()
command! JSConcealOff :call s:JSConcealOff()
command! JSConcealCycle :call s:JSConcealCycle()

let g:JSConcealCrazinessLevel = get(g:, 'JSConcealCrazinessLevel', 3)

function! s:JSConcealCycle()
  let g:JSConcealCrazinessLevel = (g:JSConcealCrazinessLevel + 1) % 11
  call s:JSConcealOn()
  echo "Craziness=".g:JSConcealCrazinessLevel." @: to cycle"
endfunction

function! s:JSConcealOn()
  call s:JSConcealOff()

  let level = g:JSConcealCrazinessLevel

  syn clear javascriptThis
  syn clear javascriptIdentifier
  syn clear jsThis
  " We must use jsThis instead of jsNiceThis because the syntax I am now using (from polyglot) expects that group name, and won't match others.
  syn match   jsThis       /\<this\(\.\|\>\)/ conceal cchar=@
  syn match   jsNicePrototype  /\.prototype\./  conceal cchar=∷
  if level > 0
    syn keyword jsNiceFunction   function skipwhite conceal cchar=λ "𝒇𝑓𝐟𝐅𝑭𝗙𝗳
    syn match   jsNiceArrowFunction /=>/ containedin=jsArrowFunction conceal cchar=⇒
  endif
  if level > 2
    syn keyword jsNiceReturn     return conceal cchar=⤺ "⬑↶↲⏎⇦⤆⇐↩⇤⬅↖⬉⇙⬋≪⬎↵↤↢↩↻⇙⇱◅◀
    syn match   jsNiceApprox     /==/  conceal cchar=≈ "∼∿
    syn match   jsNiceNotApprox  /!=/  conceal cchar=≉
    syn match   jsNiceEqual      /===/ conceal cchar=≡ "=
    syn match   jsNiceNotEqual   /!==/ conceal cchar=≢ "≠
    " ≤ and ≥ and ≺≻≼≽
    syn match   jsNiceKeyword    /\<Math\.PI\>/ conceal cchar=π
    syn match   jsNiceKeyword    /\<Math\.E\>/ conceal cchar=𝑒
    syn match   jsNiceKeyword    /\<Math\.sqrt\>/ conceal cchar=√
    syn match   jsNiceOperator   /\<Infinity\>/ conceal cchar=∞
    syn match   jsNiceTimes      /\<\*\>/ conceal cchar=×
    syn match   jsNiceKeyword    /\<\*\*\>/ conceal cchar=^
  endif
  if level > 5
    syn keyword jsNiceFunction   forEach conceal cchar=∀
    "syn keyword jsNiceBoolean    true  conceal cchar=✔ "☑⊤
    "syn keyword jsNiceBoolean    false conceal cchar=✘ "☒⊥
    syn keyword jsBooleanTrue    true  conceal cchar=✔ "☑⊤
    syn keyword jsBooleanFalse   false conceal cchar=✘ "☒⊥
    syn keyword jsNiceValue      null  conceal cchar=⊘ "∅⊘
    syn keyword jsNiceValue      undefined conceal cchar=⊠ "⊗∄ ? ⊗ ∤
    " floor: ⌊...⌋
    " ceil: ⌈...⌉
    " round: ⌈...⌉
  endif
  if level > 6
    syn match   jsNiceLogic      /||/  conceal cchar=⋎  "∨⋁
    syn match   jsNiceLogic      /&&/  conceal cchar=⋏  "∧⋀
    "syn clear javascriptReserved
    "syn match   jsNiceConsole    /\<debugger\>/ conceal cchar=⌂ "★⚫⚭▀▃▄␣━⎼⌫⊡∎⬅⌦
    syn match   jsNiceConsole    /\<console\.log\>/ conceal cchar=⚐ "⚐⚑☢☣☠
    syn match   jsNiceConsole    /\<console\.info\>/ conceal cchar=⚑
    syn match   jsNiceConsole    /\<console\.warn\>/ conceal cchar=☢
    syn match   jsNiceConsole    /\<console\.error\>/ conceal cchar=☠
    syn match   jsNiceKeyword    /\.includes\>/ conceal cchar=∋ "∍
  endif
  if level > 7
    syn keyword jsNiceVar        var   conceal cchar=𝒗 "𝕧⚫☼✪⚙𝒗𝐕𝑽𝗩𝐯𝘃☀⚪⚫●♰☪☾⚡☪♥♦♝☛♦⚹▶◀⧨◥▾□𝒱
    syn keyword jsNiceVar        const conceal cchar=𝒄 "𝕔∃𝒞
    syn keyword jsNiceVar        let   conceal cchar=𝒍 "𝕝𝒍𝑳
  endif
  if level > 8
    syn clear javascriptAssignVar
    syn clear javascriptAssignment
    " Regardless of level, /=/ must be defined before the other matches on =, or it will override them.
    " OK now we have refined it from /=/ a bit
    syn match   jsNiceAssign     /[^=!<>]==\@!/ms=s+1   conceal cchar=↤ "≐≔←⇐⇦⬅⇤⤙❮«⊛
  endif
  if level > 9
    syn match   jsNiceSemicolon  /;/ conceal cchar=↵ "☺☻
    "syn match   jsNiceComma      /,/ conceal cchar=☺
  endif
  setlocal conceallevel=2
endfunction

function! s:JSConcealOff()
  silent! syn clear jsNiceFunction
  silent! syn clear jsThis
  silent! syn clear jsNicePrototype
  silent! syn clear jsNiceReturn
  silent! syn clear jsNiceAssign
  silent! syn clear jsNiceApprox
  silent! syn clear jsNiceNotApprox
  silent! syn clear jsNiceEqual
  silent! syn clear jsNiceNotEqual
  silent! syn clear jsNiceVar
  silent! syn clear jsBooleanTrue
  silent! syn clear jsBooleanFalse
  silent! syn clear jsNiceLogic
  silent! syn clear jsNiceConsole
  silent! syn clear jsNiceSemicolon
  silent! syn clear jsNiceComma
endfunction

