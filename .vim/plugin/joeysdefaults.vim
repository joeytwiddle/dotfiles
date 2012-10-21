" All system-wide defaults are set in $VIMRUNTIME/debian.vim (usually just
" /usr/share/vim/vimcurrent/debian.vim) and sourced by the call to :runtime
" you can find below.  If you wish to change any of those settings, you should
" do it in this file (/etc/vim/vimrc), since debian.vim will be overwritten
" everytime an upgrade of the vim packages is performed.  It is recommended to
" make changes after sourcing debian.vim since it alters the value of the
" 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
"runtime! debian.vim
" I fear the warning above came from some legacy file, and does not belong.
" Removed from where?  It's causing problems here, and has already been sourced. :P

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
" set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
" syntax on

" set bs=2                " backspace over everything in insert mode
" set ai                  " set autoindent on
" set history=50          " keep 50 lines of command history
" set ruler               " Show the cursor position all the time
" set hls
" set is
" set ts=4
" set et
" set sw=4


" {{{ Syntax highlighting settings
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
" if &t_Co > 2 || has("gui_running")
  " syntax on
    " set hlsearch
    " endif
" }}}


" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
"set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
" if has("autocmd")
"  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
"    \| exe "normal g'\"" | endif
"endif

:set modeline
:set modelines=5

" Uncomment the following to have Vim load indentation rules according to the
" detected filetype. Per default Debian Vim only load filetype specific
" plugins.
if has("autocmd")
  filetype indent on
  filetype plugin indent on
endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd             " Show (partial) command in status line.
set showmatch           " Show matching brackets.
" set ignorecase          " Do case insensitive matching
" set smartcase           " Do smart case matching
set incsearch           " Incremental search
" set autowrite           " Automatically save before commands like :next and :make
set hidden              " Hide buffers when they are abandoned
set mouse=a             " Enable mouse usage (all modes) in terminals

" Although hidden creates a lot of swap files, its advantage is that it keeps
" the undo info for a file even when we have switched away from it.

" " Source a global configuration file if available
" " XXX Deprecated, please move your changes here in /etc/vim/vimrc
" if filereadable("/etc/vim/vimrc.local")
  " source /etc/vim/vimrc.local
" endif

