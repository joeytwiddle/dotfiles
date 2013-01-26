
syn match GrmAssignment /=/
" hi GrmAssignment ctermfg=yellow cterm=bold guifg=yellow gui=bold
hi link GrmAssignment Syntax
syn match GrmSyntax /|/
hi link GrmSyntax Syntax
hi Syntax ctermfg=yellow guifg=yellow

syn match GrmStructure /[()\[\]]/
" hi link GrmStructure Function
hi link GrmStructure Function

syn match GrmTrailingSymbol /[\*\+\?]/
hi link GrmTrailingSymbol Syntax

syn match GrmLeadingSymbol /[$]/
hi link GrmLeadingSymbol Syntax

syn match GrmSymbol /[!;,%\^\&\-]/
hi link GrmSymbol Syntax

syn match GrmVarBraces /[<>~/]/
hi link GrmVarBraces Function

" Using a mixture of Syntax and Function; I like Syntax for core structure,
" Function for other known constructs.

" ( ... | ... ) may look odd if colored differently, but it is actually less
" ambiguous, making the grouping clearer.
" If they are all the same color, I tend to glance and see | ... | ... |

"" Whole line
syn match GrmReplacementLine /^[A-Za-z0-9_@$]*:.*/
"" Only highlight the target name (with : or without)
" syn match GrmReplacementLine /^[A-Za-z0-9_@$]*:/he=e-1
" syn match GrmReplacementLine /^[A-Za-z0-9_@$]*:/
"" Which of the above I want strongly depends on what I am working on.  When
"" working on replacement rules, having them multi-colored is useful.  When
"" focusing on the grammar itself, hiding/masking the replacement rules with
"" one color is useful.
"" Perhaps an ideal solution would be to mask all replacement rules *except*
"" the one on the current line, so we can see his syntax if we are focused on
"" him.
hi GrmReplacementLine ctermfg=darkblue guifg=#4444cc

:runtime syntax/conf.vim

