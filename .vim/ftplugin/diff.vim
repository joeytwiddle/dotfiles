" To keep 'diff' lines outside the fold, use 0 instead of '>1'
set foldexpr=getline(v:lnum)=~'^diff\ .*'?'>1':1 foldmethod=expr fdc=2
