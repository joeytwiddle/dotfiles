" I ended up putting a bunch of things I wanted highlighted into this one type
syntax match javaScriptAssignment /\(=\|+=\|-=\|++\|--\|*=\|\/=\|;\|!=\)/
highlight link javaScriptAssignment javaScriptKeyword

highlight javaScriptNumber cterm=none ctermfg=cyan gui=none guifg=cyan

