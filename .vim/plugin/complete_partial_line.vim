" Complete Partial Line - Vim Plugin
" When CTRL-X CTRL-L is pressed in Insert mode, completes the current line
" by finding the longest match from other lines in open buffers.

if exists('loaded_complete_partial_line') || &cp
    finish
endif
let loaded_complete_partial_line = 1

" Option: keymap to trigger completion (default: <C-X><C-L>)
" Set to empty string to disable any mapping
if !exists('g:CompletePartialLine_Keymap')
    let g:CompletePartialLine_Keymap = '<C-X><C-L>'
endif

" Option: if set to 1, instead of just the current buffer, search all open buffers (below the MaxBufferLines limit)
if !exists('g:CompletePartialLine_SearchAllOpenBuffers')
    let g:CompletePartialLine_SearchAllOpenBuffers = 0
endif

" Option: skip buffers with more lines than this (0 = no limit)
if !exists('g:CompletePartialLine_MaxBufferLines')
    let g:CompletePartialLine_MaxBufferLines = 20000
endif

" Option: maximum number of completion results to return
if !exists('g:CompletePartialLine_MaxResults')
    let g:CompletePartialLine_MaxResults = 20
endif

" Compare function for sorting matches (must be global for sort())
function! CompletePartialLine_CompareMatches(a, b)
    if a:a[0] != a:b[0]
        return a:b[0] - a:a[0]  " Longer match length is better
    endif
    return len(a:b[1]) - len(a:a[1])  " Longer after_text is better
endfunction

function! s:FindMatches(seek_text)
    " If seek_text is empty, nothing to do
    if a:seek_text == ''
        return []
    endif

    " Collect all matches with their match length and after_text
    " Each item: [match_len, after_text, match_suffix]
    let matches = []
    let current_buf = bufnr('%')
    let current_line = line('.')

    " Get list of buffers to search
    if g:CompletePartialLine_SearchAllOpenBuffers
        " Get all loaded buffers
        let buffers_to_search = []
        for bufnum in range(1, bufnr('$'))
            if buflisted(bufnum) "&& bufloaded(bufnum)
                call add(buffers_to_search, bufnum)
            endif
        endfor
    else
        let buffers_to_search = [current_buf]
    endif

    " Search through all buffers
    for bufnum in buffers_to_search
        let line_count = len(getbufline(bufnum, 1, '$'))

        " Skip buffers that exceed the maximum line count
        if g:CompletePartialLine_MaxBufferLines > 0 && line_count > g:CompletePartialLine_MaxBufferLines
            continue
        endif

        " Search through all lines in this buffer
        for line_num in range(1, line_count)
            " Skip current line
            if bufnum == current_buf && line_num == current_line
                continue
            endif

            let check_line = getbufline(bufnum, line_num)[0]

            " Find longest match: longest suffix of seek_text that appears in check_line
            let seek_len = len(a:seek_text)
            let best_match_len = 0
            let best_match_pos = -1

            " Try all suffixes of seek_text, starting with the longest
            " We break early when we find a match since we want the longest
            for suffix_start in range(0, seek_len - 1)
                let suffix = strpart(a:seek_text, suffix_start)
                let suffix_len = len(suffix)

                " If all remaining iterations will be smaller than best, then we can give up on this line
                if suffix_len < best_match_len
                    break
                endif

                " Search for this suffix in check_line
                let match_pos = stridx(check_line, suffix)
                if match_pos >= 0
                    " Found a match - this is the longest for this line since we start with longest
                    let best_match_len = suffix_len
                    let best_match_pos = match_pos
                    break
                endif
            endfor

            " If we found a match, get the text after it and add to matches list
            if best_match_pos >= 0
                let after_pos = best_match_pos + best_match_len
                let after_text = strpart(check_line, after_pos)
                let match_suffix = strpart(a:seek_text, seek_len - best_match_len)

                " Add this match to our collection
                call add(matches, [best_match_len, after_text, match_suffix])
            endif
        endfor
    endfor

    " Sort matches by: 1) match length (descending), 2) after_text length (descending)
    " This gives us the best matches first
    if len(matches) > 0
        call sort(matches, 'CompletePartialLine_CompareMatches')
    endif

    " Return top N results (just the after_text strings)
    let results = []
    if len(matches) > 0
        for i in range(0, min([len(matches) - 1, g:CompletePartialLine_MaxResults - 1]))
            call add(results, matches[i][1])
        endfor
    endif

    return results
endfunction

" Vim completefunc: returns start column when findstart=1, or list of matches when findstart=0
" Must be global function for completefunc to work
function! CompletePartialLine_CompleteFunc(findstart, base)
    if a:findstart
        " Return the start column of the text to be completed
        " For line completion, we complete from the cursor position (insert new text)
        return col('.') - 1
    else
        " Return list of completion matches
        " a:base contains the text from start column to cursor (should be empty for our use case)
        " Get the current line up to cursor for our search
        let seek_text = strpart(getline('.'), 0, col('.') - 1)
        let matches = s:FindMatches(seek_text)

        " Convert to completion format: list of dictionaries with 'word' key
        let completions = []
        for match in matches
            call add(completions, {'word': match})
        endfor
        return completions
    endif
endfunction

" Trigger completion using completefunc
function! s:TriggerCompletion()
    " Save current completefunc
    let s:saved_completefunc = &completefunc

    " Set our completefunc
    let &completefunc = 'CompletePartialLine_CompleteFunc'

    " Set up autocmd to restore completefunc when completion is done
    augroup CompletePartialLine_Restore
        autocmd!
        autocmd CompleteDone * let &completefunc = s:saved_completefunc | autocmd! CompletePartialLine_Restore
    augroup END

    " Trigger completion
    return "\<C-X>\<C-U>"
endfunction

" Original function for backward compatibility (returns first result)
function! s:CompletePartialLine()
    let seek_text = strpart(getline('.'), 0, col('.') - 1)
    let matches = s:FindMatches(seek_text)
    if len(matches) > 0
        return matches[0]
    endif
    return ''
endfunction

" Create Plug mapping for custom keybindings
" Use expression mapping to set completefunc and trigger completion
inoremap <expr> <Plug>CompletePartialLine <SID>TriggerCompletion()

" Set default mapping if option is not empty and user hasn't mapped it
if g:CompletePartialLine_Keymap != '' && !hasmapto('<Plug>CompletePartialLine', 'i')
    execute 'inoremap <silent>' g:CompletePartialLine_Keymap '<Plug>CompletePartialLine'
endif
