" To keep 'diff' lines outside the fold, use 0 instead of '>1'
let &foldexpr='getline(v:lnum) =~ "^\\(diff\\|Only in\\) .*" ? ">1" : 1'
set foldmethod=expr fdc=2
