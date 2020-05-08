" Highlights the currently focused buffer in your file explorer (netrw or NERDTree)

" Some code pulled from: https://codeyarns.com/2014/05/05/how-to-highlight-current-file-in-nerdtree/

if !exists('g:netrw_tweaks_nerdtree_focus_file')
  let g:netrw_tweaks_nerdtree_focus_file = 1
endif

function! s:get_netrw_window()
  return bufwinnr('NetrwTreeListing')
endfunction

function! s:get_nerdtree_window()
  if exists('t:NERDTreeBufName')
    return bufwinnr(t:NERDTreeBufName)
  endif
endfunction

function! s:escape_for_regexp(str)
  return escape(a:str, '^$.*?/\[]')
endfunction

function! s:escape_filename_for_regexp(filename)
  let escaped_filename = s:escape_for_regexp(a:filename)
  "return escaped_filename
  " KNOWN BUG: If there are multiple files matching the filename, they will all be highlighted
  " I wanted to match a space before the filename, but then nothing got matched
  " I couldn't put `\<` at the start, because that fails to match a leading `.`
  " Similarly, the `\>` probably fails to match a trailing `.` but we keep it anyway.
  return escaped_filename . '\>'
endfunction

function! s:update_file_managers()
  " Check if current window contains a modifiable file, with a filename, and we're not in vimdiff
  if &modifiable && strlen(expand('%')) > 0 && !&diff
    " We cannot switch out of the `q:` window, so we had better not try
    if bufname('%') ==# '[Command Line]'
      return
    endif

    let s:original_window = winnr()
    let filename = expand('%:t')

    " Note that the highlight is global, but we can define a separate syntax for each explorer type.
    " Currently we only support one instance of each explorer.

    " If I did NERDTree last, with both netrw and NERDTree open, for some reason NERDTree would scroll up to the top (hiding the file).  So we do NERDTree first.
    let nerdtree_window = s:get_nerdtree_window()
    if nerdtree_window >= 1
      if g:netrw_tweaks_nerdtree_focus_file
        NERDTreeFind
      endif
      noautocmd exec nerdtree_window . ' wincmd w'
      syntax clear CurrentFileInExplorer
      " Unfortunately NERDTreeExecFile didn't seem to cut through; we don't get highlighting on those.
      execute 'syntax match CurrentFileInExplorer /' . s:escape_filename_for_regexp(filename) . '$/ containedin=NERDTreeFile,NERDTreeExecFile'
    endif

    let netrw_window = s:get_netrw_window()
    if netrw_window >= 1
      noautocmd exec netrw_window . ' wincmd w'
      syntax clear CurrentFileInExplorer
      execute 'syntax match CurrentFileInExplorer /' . s:escape_filename_for_regexp(filename) . '$/'
      " TODO: If there is a matching line, but not in view, scroll it into view
    endif

    noautocmd exec s:original_window . ' wincmd w'

    " TODO: This doesn't really belong here, but my colorscheme script keeps clearing it
    highlight CurrentFileInExplorer cterm=bold ctermfg=white gui=bold guifg=white
    " With grey background
    "highlight CurrentFileInExplorer cterm=bold ctermbg=237 ctermfg=white gui=bold guibg=#3a3a3a guifg=white
  endif
endfunction

augroup NetrwTweaks
  autocmd!
  " When we focus a new buffer, highlight it in any open file managers
  autocmd BufEnter,WinEnter * call s:update_file_managers()
augroup END
