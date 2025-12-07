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

function! s:CompletePartialLine()
    " Get current line up to cursor position
    let seek_text = strpart(getline('.'), 0, col('.') - 1)

    " If seek_text is empty, nothing to do
    if seek_text == ''
        return
    endif

    let longest_match = ''
    let longest_match_after_text = ''
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
            let seek_len = len(seek_text)
            let best_match_len = 0
            let best_match_pos = -1

            " Try all suffixes of seek_text, starting with the longest
            " We break early when we find a match since we want the longest
            for suffix_start in range(0, seek_len - 1)
                let suffix = strpart(seek_text, suffix_start)
                let suffix_len = len(suffix)

                " Skip if this suffix can't be longer than what we already found
                if suffix_len < best_match_len
                    continue
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

            " If we found a match, get the text after it
            if best_match_pos >= 0
                let after_pos = best_match_pos + best_match_len
                let after_text = strpart(check_line, after_pos)

                " Update longest match if this one is longer
                " Or if it is the same length, but the after_text is longer
                if best_match_len > len(longest_match) || best_match_len >= len(longest_match) && len(after_text) >= len(longest_match_after_text)
                    let longest_match = strpart(seek_text, seek_len - best_match_len)
                    let longest_match_after_text = after_text
                endif
            endif
        endfor
    endfor

    " Insert the longest match after text if we found one
    if longest_match_after_text != ''
        " Insert the text at cursor position
        return longest_match_after_text
    endif

    return ''
endfunction

" Create Plug mapping for custom keybindings
inoremap <silent> <Plug>CompletePartialLine <C-R>=<SID>CompletePartialLine()<CR>

" Set default mapping if option is not empty and user hasn't mapped it
if g:CompletePartialLine_Keymap != '' && !hasmapto('<Plug>CompletePartialLine', 'i')
    execute 'inoremap <silent>' g:CompletePartialLine_Keymap '<Plug>CompletePartialLine'
endif
