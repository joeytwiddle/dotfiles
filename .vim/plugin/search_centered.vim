if exists('g:search_centered') && g:search_centered != 0

	nnoremap n nzz
	nnoremap N Nzz
	nnoremap * *zz
	nnoremap # #zz
	nnoremap g* g*zz
	nnoremap g# g#zz

	" nnoremap <silent> n :set scrolloff=20<Enter>n:set scrolloff=0<Enter>

endif

