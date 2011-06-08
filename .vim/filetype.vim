if exists("did_load_filetypes")
	finish
endif
" I have been writing JoeyBASIC files with the following extensions
augroup filetypedetect
	au! BufRead,BufNewFile *.asm     setfiletype basic
	au! BufRead,BufNewFile *.dim     setfiletype basic
	au! BufRead,BufNewFile *.dims    setfiletype basic
	au! BufRead,BufNewFile *.fns     setfiletype basic
	au! BufRead,BufNewFile *.bas     setfiletype basic
	au! BufRead,BufNewFile *.BAS     setfiletype basic
	au! BufRead,BufNewFile last_file_postproc.txt   setfiletype basic
augroup END
