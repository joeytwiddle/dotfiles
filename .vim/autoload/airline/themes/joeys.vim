let g:airline#themes#joeys#palette = {}

" Normal Mode
let s:N1 = [ '#00005f' , '#00dfff' , "white", "cyan" ]
let s:N2 = [ '#ffffff' , '#005fff' , "black", "white" ]
let s:N3 = [ '#ffffff' , '#000080' , "blue", "white", "none" ]
"let s:N3 = [ '#000080' , '#ffffff' , 7, 4, "bold,reverse" ]   " Reverse is more readable in xterm, but if we do this, we must also do it for I2, V2, IA2, ... !
let g:airline#themes#joeys#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)
let g:airline#themes#joeys#palette.normal_modified = {
      \ 'airline_c': [ 'white' , '#5f005f' , "magenta", "white" , ''     ] ,
      \ }


" Insert Mode
let s:I1   = [ '#000000' , '#33ff00' , "white", "green" ]
let s:I2   = [ '#000000' , '#22cc00' , "black", "white" ]
let s:I3   = [ '#ffffff' , '#004400' , "blue", "white", "none" ]
let g:airline#themes#joeys#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)
let g:airline#themes#joeys#palette.insert_modified = {
      \ 'airline_c': [ 'white' , '#5f005f' , "magenta", "white" , ''     ] ,
      \ }
let g:airline#themes#joeys#palette.insert_paste = {
      \ 'airline_a': [ s:I1[0]   , '#d78700' , s:I1[2] , 172     , ''     ] ,
      \ }


" Replace mode
let g:airline#themes#joeys#palette.replace = copy(g:airline#themes#joeys#palette.insert)
let g:airline#themes#joeys#palette.replace.airline_a = [ s:I2[0], 'yellow', s:I2[2], 'yellow', '' ]
let g:airline#themes#joeys#palette.replace_modified = g:airline#themes#joeys#palette.insert_modified


" Visual and Select Modes
let s:V1 = [ '#000000' , '#ffaf00' , "white", "red" ]
let s:V2 = [ '#000000' , '#ff5f00' , "black", "white" ]
let s:V3 = [ '#ffffff' , '#5f0000' , "blue", "white", "none" ]
let g:airline#themes#joeys#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)
let g:airline#themes#joeys#palette.visual_modified = {
      \ 'airline_c': [ 'white' , '#5f005f' , "magenta", "white" , ''     ] ,
      \ }


" Inactive window
let s:IA1 = [ '#000000' , '#bbbbbb' , "black", "white" ]
let s:IA2 = [ '#000000' , '#bbbbbb' , "black", "white"  ]
let s:IA3 = [ '#000000' , '#bbbbbb' , "darkgrey", "white", "bold,underline" ]
let g:airline#themes#joeys#palette.inactive = airline#themes#generate_color_map(s:IA1, s:IA2, s:IA3)
let g:airline#themes#joeys#palette.inactive_modified = {
      \ 'airline_c': [ "#cc0000", '#999999' , "red", "white" , '' ] ,
      \ }


let g:airline#themes#joeys#palette.accents = {
      \ 'red': [ '#ff0000' , '' , "red" , "white", "bold" ]
      \ }

