if v:version >= 700
else
	finish
endif


function! MyTabLine()
	let s = ''

	let s .= '%#TabLineFill# [Vim] %#TabLineBreak# '

	for i in range(tabpagenr('$'))

		" select the highlighting
		if i + 1 == tabpagenr()
			let s .= '%#TabLineSel#'
		else
			let s .= '%#TabLine#'
		endif

		" set the tab page number (for mouse clicks)
		let s .= '%'.(i+1).'T'

		" the label is made by MyTabLabel()
		if i + 1 == tabpagenr()
			let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
			let s .= '%#TabLineInfo#%-0m' " modification status of buffer - unfortunately only works on current tab, sometimes ''
			" tbh if we get really smart, we could change the tab (text) colour depending on modification status
			" if tabpagenr('$') > 1
			" let s .= '%#TabLineClose#%999X[X]'
			" endif
		else
			let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
		endif

		let s .= '%#TabLineBreak# '

	endfor

	" after the last tab fill with TabLineFill and reset tab page nr
	let s .= '%#TabLineFill#%T'

	if tabpagenr('$') > 1
		let s .= '%=%#TabLineBreak# %#TabLineClose#%999X[X]%#TabLineBreak# %#TabLineFill# '
	endif

	"echomsg 's:' . s
	return s
endfunction

function! MyTabLabel(n)
	let buflist = tabpagebuflist(a:n)
	let winnr = tabpagewinnr(a:n)
	let numtabs = tabpagenr('$')
	" account for space padding between tabs, and the "close" button
	let maxlen = ( &columns - ( numtabs * 2 ) - 4 ) / numtabs
	let tablabel = bufname(buflist[winnr - 1])
	while strlen( tablabel ) < 4
		let tablabel = tablabel . " "
	endwhile
	let tablabel = fnamemodify( tablabel, ':t' )
	let tablabel = strpart( tablabel, 0, maxlen )
	" let tablabel .= " ".gettabwinvar(a:n,1,"modified")
	return tablabel
	" changenr()
endfunction

set tabline=%!MyTabLine()

set showtabline=1 " 2=always
" autocmd GUIEnter * hi! TabLineFill term=underline cterm=underline gui=underline
autocmd GUIEnter * hi! TabLineFill term= cterm= gui= ctermfg=green ctermbg=red
autocmd GUIEnter * hi! TabLineSel term=bold,reverse ctermfg=black ctermbg=yellow guifg=#ffff00 guibg=#0000ff gui=


" Joey's colours:
" highlight TabLine cterm=none ctermfg=white ctermbg=blue
" highlight TabLineSel cterm=reverse ctermfg=green ctermbg=black
" highlight TabLineFill cterm=none ctermfg=white ctermbg=black
" 
" highlight TabLine cterm=none ctermfg=black ctermbg=grey
" highlight TabLineSel cterm=none ctermbg=blue ctermfg=white
" " highlight TabLineFill cterm=none ctermfg=black ctermbg=grey

highlight TabLine cterm=none ctermbg=blue ctermfg=white
highlight TabLineSel term=bold cterm=bold ctermfg=black ctermbg=green
" highlight TabLineFill cterm=none ctermbg=blue ctermfg=white
highlight TabLineFill cterm=none ctermbg=white ctermfg=black

highlight TabLineClose cterm=none ctermbg=red ctermfg=white
highlight TabLineBreak cterm=none ctermbg=black ctermfg=blue
highlight TabLineInfo cterm=none ctermbg=red ctermfg=white
