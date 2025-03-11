" :Vimdiff <file1> <file2>
"
" Opens a new tab, and diffs the two files side-by-side
"
" Original by Joeytwiddle, released into the Public Domain

command! -nargs=* -complete=file Vimdiff call Vimdiff(<f-args>)

function! Vimdiff(file1, file2)
    " Set nodiff on all existing buffers
    let original_buffer = bufnr("%")
    "for buf in range(1, bufnr('$'))
    "    if bufexists(buf)
    "        execute buf . 'b'
    "        setlocal nodiff
    "    endif
    "endfor
    "bufdo let &diff = 0
    bufdo setlocal nodiff
    execute "buffer " . original_buffer

    " Open a new tab for the diff view
    tabnew
    silent execute 'edit ' . a:file1
    diffthis
    vnew
    silent execute 'edit ' . a:file2
    diffthis
endfunction
