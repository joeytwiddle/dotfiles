" :set listchars=tab:>>,trail:>

:set autoindent
:set nowrap
:set background=dark

" Folding
" :set fdc=1
:syn region myFold start="{" end="}" transparent fold
" :syn region myFold2 start="/*" end="*/" transparent fold
" :syn region myFold3 start="^$" end="^$" transparent fold
:syn sync fromstart
:set foldmethod=syntax
:set foldmethod=manual

" :syntax keyword difference jDiff @@>>

" :highlight jDiff ctermbg=Magenta ctermfg=White
:highlight DiffLine ctermbg=Magenta ctermfg=White
:highlight Search ctermbg=White
:highlight ErrorMsg ctermbg=Red ctermfg=Yellow
:highlight Visual ctermfg=Magenta ctermbg=Green
:highlight Comment ctermfg=Magenta
:highlight SpecialChar ctermfg=Red
:highlight String ctermfg=Green

:syntax on

" comment
:nmap <F5> ^i// <Esc>j^
" uncomment
:nmap <F6> ^3xj^
" indent
:nmap <F7> ^i  <Esc>j^
" undent
:nmap <F8> 0xj^

" Make these work for modifiable only - they seriously warp the online help!
":autocmd BufReadPost   *.* set ts=8 | set expandtab | retab | set ts=2 | set noexpandtab | retab!
":autocmd BufWritePre,FilterWritePre     *.* set expandtab | retab!
":set shiftwidth=2
:set ts=2

" GUI:
:colors pablo
:set guifont=-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv
