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
    " Each item: [match_len, after_text, match_suffix, filename, line_num]
    " We'll keep this sorted as we go for efficient threshold checking
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

    let seek_len = len(a:seek_text)

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

            " Quick optimization: if we already have MaxResults matches, check if this line
            " can potentially improve our results by checking if it contains a suffix
            " at least as long as our current worst match
            if len(matches) >= g:CompletePartialLine_MaxResults
                let min_match_len = matches[g:CompletePartialLine_MaxResults - 1][0]
                " If the line doesn't contain the minimum length suffix, it can't improve
                " (since longer matches are better, and we'll find them during processing if they exist)
                if min_match_len <= seek_len
                    let min_suffix = strpart(a:seek_text, seek_len - min_match_len)
                    if stridx(check_line, min_suffix) < 0
                        continue
                    endif
                endif
            endif

            " Find longest match: longest suffix of seek_text that appears in check_line
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
                " Get filename for this buffer
                let filename = bufname(bufnum)
                if filename == ''
                    let filename = '[No Name]'
                else
                    " Get just the filename without path
                    let filename = fnamemodify(filename, ':t')
                endif

                " Add this match to our collection and keep it sorted
                " Insert in sorted order (by match_len descending, then after_text length descending)
                " Only add if we don't have MaxResults yet, or if this is better than the worst one
                let should_add = 0
                if len(matches) < g:CompletePartialLine_MaxResults
                    let should_add = 1
                else
                    " Check if this match is better than the worst one (last in sorted list)
                    let worst = matches[g:CompletePartialLine_MaxResults - 1]
                    if best_match_len > worst[0] || (best_match_len == worst[0] && len(after_text) >= len(worst[1]))
                        let should_add = 1
                    endif
                endif

                if should_add
                    " Find the right position to insert (keep sorted)
                    let inserted = 0
                    for i in range(len(matches))
                        let existing = matches[i]
                        " Check if this match is better than existing[i]
                        if best_match_len > existing[0] || (best_match_len == existing[0] && len(after_text) >= len(existing[1]))
                            call insert(matches, [best_match_len, after_text, match_suffix, filename, line_num], i)
                            let inserted = 1
                            break
                        endif
                    endfor
                    if !inserted
                        call add(matches, [best_match_len, after_text, match_suffix, filename, line_num])
                    endif

                    " Keep only the top MaxResults matches
                    if len(matches) > g:CompletePartialLine_MaxResults
                        call remove(matches, g:CompletePartialLine_MaxResults, -1)
                    endif
                endif
            endif
        endfor
    endfor

    return matches
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

        " Convert to completion format: list of dictionaries with 'word', 'abbr', and 'menu' keys
        " 'word' is the full text to insert, 'abbr' is the truncated display version
        let completions = []
        for match in matches
            let match_len = match[0]
            let after_text = match[1]
            let match_suffix = match[2]
            let filename = match[3]
            let line_num = match[4]
            let after_text_len = len(after_text)
            "let meta_info = printf('partial|%s:%d|%d,%d', filename, line_num, match_len, after_text_len)
            if g:CompletePartialLine_SearchAllOpenBuffers
                let meta_info = printf('%s:%d', filename, line_num)
            else
                let meta_info = printf('%d', line_num)
            endif

            " If we display the metadata on the right, in order to see it, we may need to truncate the display text
            "let max_display_width = winwidth(0) / 2
            "let display_text = after_text
            "if len(after_text) > max_display_width
            "    let display_text = strpart(after_text, 0, max_display_width - 3) . '...'
            "endif
            "call add(completions, {'word': after_text, 'abbr': after_text, 'menu': meta_info})

            " Display the metadata on the left (in abbr, instead of in menu)
            call add(completions, {'word': after_text, 'abbr': meta_info, 'menu': match_suffix . after_text})
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
        return matches[0][1]
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
