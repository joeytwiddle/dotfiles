" source /usr/share/vim/vim71/syntax/basic.vim

" TODO: we should undo all the lowercase matches for BASIC keywords, since BBC
" BASIC only accepts uppercase keywords.

" Things in BBC BASIC that are missing from basic.vim

syn keyword basicStatement	REPEAT UNTIL WHILE DEF ENDPROC TO STEP
syn keyword basicStatement	TRUE FALSE

syn keyword basicFunction	PRINT TAB PRINTTAB VDU MODE CALL
syn keyword basicFunction	MOD DIV

syn keyword basicSpecial	HIMEM TOP LOMEM PAGE

" Conflict on EOR since it is both BASIC and assembly command.

