"" Quick switching between files:
" map <C-Right> :n<Enter>
" map <C-Left> :N<Enter>
" map <C-PageDown> :n<Enter>
" map <C-PageUp> :N<Enter>

"" These two work best with MiniBufExplorer
nnoremap <C-PageDown> :bnext<Enter>
nnoremap <C-PageUp> :bprev<Enter>
inoremap <C-PageDown> <Esc>:bnext<Enter>i
inoremap <C-PageUp> <Esc>:bprev<Enter>i
"" (not working?)
" inoremap <C-PageUp> <Esc><C-PageUp>a
" inoremap <C-PageDown> <Esc><C-PageDown>a

"" These versions work for my Eterm, provided we exported TERM=xterm
"nnoremap [6^ :bn<Enter>
"noremap [5^ :bp<Enter>
"" In hwi (Debian), pod and porridge's (Ubuntu) console, where TERM=linux, PageUp/Down send the same as Ctrl-PageUp/Ctrl-PageDown!
" nnoremap [6~ :bn<Enter>
" nnoremap [5~ :bp<Enter>
nmap [6^ <C-PageDown>
nmap [5^ <C-PageUp>

"" Inside screen on pea, and for xterm on Ubuntu:
"noremap [6;5~ :bn<Enter>
"noremap [5;5~ :bp<Enter>
nmap [6;5~ <C-PageDown>
nmap [5;5~ <C-PageUp>

"" But in the QuickFixList, we want Ctrl-PageUp/PageDown to cycle "cope tabs", not buffers.
"autocmd BufReadPost quickfix nnoremap <buffer> <C-PageDown> :cnewer<CR>
"autocmd BufReadPost quickfix nnoremap <buffer> <C-PageUp> :colder<CR>
" You had better only use these versions if you also load quickfix_title_control.vim!
autocmd BufReadPost quickfix nnoremap <buffer> <silent> <C-PageDown> :cnewer<CR>:call g:RestoreQuickfixTitle()<CR>
autocmd BufReadPost quickfix nnoremap <buffer> <silent> <C-PageUp> :colder<CR>:call g:RestoreQuickfixTitle()<CR>
" TODO: If we push quickfix_title_control.vim into autoload, it may be easier to check if the function exists in advance, allowing us to decide which of the above keybinds to set.

"" Sometimes I want to re-arrange the order of the buffers in my list.  After
"" years of nothing, I now at least found a way to push buffers to the end, by
"" completely removing them first with bwipeout.
"" Loses all undo history.
" TODO: Might belong in its own plugin file.
nnoremap <silent> <C-S-PageDown> :call <SID>MoveCurrentBufferToEndOfList()<Enter>
nnoremap <silent> <C-A-PageDown> :call <SID>MoveCurrentBufferToEndOfList()<Enter>
function! s:MoveCurrentBufferToEndOfList()
	let fname = expand("%")
	" This bwipeout may not succeed if the file has unwritten changes.
	bwipeout
	" TODO: Do we need to escape spaces in filenames with spaces?
	exec "edit ".fname
endfunction
" Since C-S-PageDown never makes it through my xterm, we expose a user command too:
command! MoveBufferToEnd call s:MoveCurrentBufferToEndOfList()
" Oh!  C-A-PageDown does make it through.  :)



" map <F8> :tabprev<Enter>
" map <F9> :tabnext<Enter>
" map <C-[> :tabprev<Enter>
" map <C-]> :tabnext<Enter>
" map <C-[> :N<Enter>
" map <C-]> :n<Enter>

"" I'm sure there must be a better way to do this.
"" I'm trying to make a new command, but really just catching the keys!
map :htab :tabnew<Enter>:h



"" Moving between windows with Ctrl-ArrowKeys
"" Note that we use nmap instead of nnoremap, so that navigation_enhancer can enhance the defaults.
nmap <C-Up> <C-W>k
nmap <C-Down> <C-W>j
nmap <C-Left> <C-W>h
nmap <C-Right> <C-W>l

"" I want them to work in insert mode also (especially with ConqueTerm)
"imap <C-Up> <Esc><C-W>ka
"imap <C-Down> <Esc><C-W>ja
"imap <C-Left> <Esc><C-W>ha
"imap <C-Right> <Esc><C-W>la
"" Except in ConqueTerm I don't neccessarily want to return to Insert mode,
"" if I was not in Insert mode before I entered ConqueTerm.
" TODO: This may be interfering with navigation_enhancer and/or Conque's
" restore-previous-insert-or-normal-mode.
" (When I go up from ConqueTerm in insert mode, I get left in TreeExplorer,
" not editor, or vice-versa, i.e. navigation_enhancer was being ignored.),
" possibly because one of :startinsert or 'a' fails because both conque and
" this bind do that!  Instead consider calling a function to perform the above
" without erroring.
" Just disabled them for now.  I don't think I actually use them!

"" For Eterm.  Caused no problems for xterm the last time I tried it.
nmap Oa <C-W>k
nmap Ob <C-W>j
nmap Od <C-W>h
nmap Oc <C-W>l

"" For Linux console:
nmap [A <C-W>k
nmap [B <C-W>j
nmap [D <C-W>h
nmap [C <C-W>l

"" Inside screen on pea:
nmap [1;5A <C-W>k
nmap [1;5B <C-W>j
nmap [1;5D <C-W>h
nmap [1;5C <C-W>l

"" I was using these to allow Ctrl-Up/Down/Left/Right in Eterm, but they broke
"" normal Up/Down/Left/Right in xterm!
" nmap OA k
" nmap OB j
" nmap OD h
" nmap OC l

" <Tab> doesn't do anything in normal mode.  I can think of something to do with it!
"nmap <Tab> <C-w><Down>
"nmap <S-Tab> <C-w><Up>
" Ooops.  <Tab> and <C-I> are indistinguishable.  And I use <C-I>.  How sad!
" We might be able to apply them only in GUI mode, but that would probably just make me sad out of GUI mode.
" Let's do this like unimpaired does
nmap ]w <C-w><Down>
nmap [w <C-w><Up>
nmap ]W <C-w><Right>
nmap [W <C-w><Left>
" Wow that is so much better than <Ctrl-Down> or <Ctrl-W><Down>!  Although only a minor improvement over <Ctrl-W>j.



"" Step through quickfix list (errors/search results) with Ctrl+N/P
:nnoremap <C-n> :cnext<Enter>
:nnoremap <C-p> :cprev<Enter>
"" =/- get overriden by fold keymaps :P
" :nnoremap = :cnext<Enter>
" :nnoremap - :cprev<Enter>
"" +/_ (Shift equivalent) also get overridden
" :nnoremap + :cnext<Enter>
" :nnoremap _ :cprev<Enter>

"" Navigate wrapped lines in screen space using arrows
nnoremap <Up> gk
nnoremap <Down> gj

" Scroll the page up and down with Ctrl+K/J
" Only moves the cursor when it's near the edge
"" We could prepend a number to the scroll request if desired, e.g. 5<C-K>
"" But not any more.  Now we are auto-prepending 2, manually prepending 5 would result in moving 52 lines!
"noremap <C-K> <C-Y>
"noremap <C-J> <C-E>
inoremap <C-K> <Esc>2<C-Y>a
inoremap <C-J> <Esc>2<C-E>a
"" Since the first two do not always trigger a CursorHold or Moved event, they fail to trigger the highlight_line_after_jump script.  The following attempt to force it fails because on occasions where the event is triggered, the highlight script sees it twice, and unhighlights the line!
" noremap <C-K> <C-Y>:silent! call HL_Cursor_Moved()<Enter>
" noremap <C-J> <C-E>:silent! call HL_Cursor_Moved()<Enter>
"" Simiarly, these also fail to trigger CursorHold/Moved events needed by sexy_scroller.  Let's try triggering them by moving and moving back.
"noremap <C-K> 2<C-Y><BS><Space>
"noremap <C-J> 2<C-E><Space><BS>
"noremap <C-K> 2<C-Y><Down><Up>
"noremap <C-J> 2<C-E><Up><Down>
" I have also swapped the direction.  My fingers aren't sure which is correct.
noremap <C-K> 2<C-E>:call g:SexyScroller_ScrollToCursor()<CR>
noremap <C-J> 2<C-Y>:call g:SexyScroller_ScrollToCursor()<CR>
"" OK that fires sexy_scroller, but why did we ever want it to fire hiline anyway?!  Perhaps when we were doing 10<C-K>
"" Also it exhibits a BUG in sexy_scroller, namely that it will cause horizontal scrolling when moving near a long line whilst `:set nowrap` wrapping is off!
"" There are disadvantages to trying to trigger CursorMoved/Hold this way.  <BS><Space> can fail if we are at the top of the file, or create issues if we are at the start of a line (e.g. temporarily moves a line back, undoing the requested scroll, in a short window when scrolloff is set).  Similarly <Space><BS> can fail on the last char of a line or the last line of a file.  A better solution might be to explicitly call hooks exposed by those specific plugins that we want to trigger.  Alternatively we could call a function to examine the situation and emit whichever of <BS><Space> or <Space><BS> is most appropriate.

"" Split windows "horizontally" (create a new one below) with Ctrl-W s (no need to define - this is a default!)
"nnoremap <C-W>s :split<Enter>
"" Split windows "vertically" (create a new one to the right) with Ctrl-W Shift-S (the default is Ctrl-W v)
nnoremap <C-W>S :vsplit<Enter>

" Resize windows with Ctrl-NumPadPlus/Minus/Divide/Times:
"" We now defer to the implementation in windows_remember_size.vim
"" This was happening automatically before - perhaps their run order changed?
"nnoremap Om :resize -2<Enter>
"nnoremap Ok :resize +2<Enter>
"nnoremap Oo :vert resize -6<Enter>
"nnoremap Oj :vert resize +6<Enter>



" Joey's little trick - maybe belongs elsewhere.
" :e usually clears undo history, so we don't really do :e any more.
" We delete the contents of the buffer, then read the file in, which
" is an operation we can undo.  We must delete the top (empty) line also.
" :map :e<Enter> :%d<Enter>:r<Enter>:0<Enter>dd
" BUG: vim still thinks the file is out of sync with the buffer, so if you
" quit without writing the file, vim complains, which is not how :e behaved.
":map :e<Enter> :%d<Enter>:r<Enter>:0<Enter>dd:w!<Enter>
" Unfortunately the ! in :w! doesn't work
" But `:checktime | w` may be a solution for that.
" This is not needed any more.  Recent versions of Vim support undo through
" file read.

"" Close the current window on Ctrl-W (like browser tabs).
"" This overrides a lot of C-w defaults.  Really I want to wait and see if
"" the use presses anything else.  It is pretty dangerous at the moment!
" nnoremap <C-w> :bdel<Enter>

" nmap <C-X> :vnew \| vimshell bash<CR>

"" Quick access to ConqueTerm
:nnoremap <C-x> :ConqueTermSplit zsh<Enter>
:inoremap <C-x> <Esc>:echo "Hello"<Enter>
" :inoremap <C-x> <Esc>:bdel<Enter>
"" My ConqueTerm settings live in ~/.vimrc

"" I want :q to close the buffer, not the window.
"" Unfortunately this does not quit Vim if we are on the last buffer.
" nmap :q<Enter> :bdel<Enter>
" nmap :wq<Enter> :w<Enter>:bdel<Enter>
"" Meh turns out I don't always want to close the buffer.  I often use :q just
"" to close an extra window I no longer want.



"" F5 and F6 comment and uncomment the current line.
"" TODO: These should go into after/ftplugin/filetype.vim or something, as buffer mappings.  Alternatively we can load them on BufReadPost.  (Neatest, allow zero, one or two mappings to be chosen, and declare a dictioary of filetype => comment ?  Or what is the correct data structure if multiple keys share the same target?)
" echo &filetype
nnoremap <F5> ^i//<Esc>j^
nnoremap <F6> ^2xj^

" We could push these into ftplugins.
" Advantage: it will work if the ft is detected for a file without the given extension.
" Disadvantage: we must define it in a separate file for every relevant ft.
autocmd BufReadPost *.{html,xml,xslt} nnoremap <buffer> <F5> ^i<!-- <End> --><Esc>j^
autocmd BufReadPost *.{html,xml,xslt} nnoremap <buffer> <F6> ^5x$xxxxj^
" ULTIMATE SOLUTION:
" Bind F5 and F6 to custom functions, for all windows.
" Determine the language context from the location in the file, and then lookup the appropriate commenting style.
" This would e.g. allow us to easily comment/uncomment JS, CSS and SVG inside an HTML document.

"" F7 and F8 indent or unindent the current line.
"" (Expects/requires ts=2 sw=2 and noexpandtabs!)
nmap <F7> ^i  <Esc>j^
nmap <F8> 0xj^

"" Shortcut for re-joining lines broken by \n.
"" BUG: Deletes next char if current line is empty!
" map <F7> Js<Return><Esc> 

" C "changes word under cursor" (replaces "change to end of line", c$)
" No, let's keep C acting the same as default
"nmap C ciw
" cd "change to end of line" (because d is letter 4 and $ is shift-4!)
"nmap cd c$
"nmap cd ciw
" No, let's replace cw instead, because Vim maps cw->ce and I always use ce anyway
"nmap cw ciw
" No I don't always use ce!  Leave cw alone and use ciw when you need it.  :P
" Actually since cd does nothing, we can use that.  I doubt I will remember it though.
"nmap cd ciw
" Since I didn't remember it, I disabled it.  Just use ciw lol!  :P

" $d0 leaves the char that was under the cursor; I hate that!
nmap d0 d0x
"nmap d0 v0d
" Delete the whole line, not just from here backwards
"nmap d0 0d$

" Docs actually suggest this, to match with D and C
map Y y$

"" Various failed shortcuts for the 'follow link' command.
" map <C-Enter> <C-]>
" map <C-.> <C-]>
" map <C-#> <C-]>
" map <C-'> <C-]>
" map <C-@> <C-]>
" map <C-;> <C-]>
" map <C-Minus> <C-]>
" map <C-Equals> <C-]>
" map <C-p> <C-]>
" map <C-O> <C-]>
" map <C-p> <C-LeftMouse>
" map <C-p> g<LeftMouse>
" map <C-p> :tag



"" Command-line keymaps.
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
"" In keeping with my shell shortcut keys (loaded by jsh)
"" Word jump
cnoremap <C-D> <C-Left>
cnoremap <C-F> <C-Right>
"" Small-word jump.  But Vim doesn't offer one!
"" In cmdline, S-Left/Right is the same as C-Left/Right
"" So here is a near approximation:
cnoremap <C-R> <Left><Left><Left>
cnoremap <C-T> <Right><Right><Right>
"" Word swallow on Ctrl-X Ctrl-V
cnoremap <C-X> <C-W>
"" This doesn't do what we want, and anyway we want to leave Ctrl-V alone since it does something special in Vim (insert literal char).
" cnoremap <C-V> <C-Right><C-W>
"" Lazy move.  Ctrl-Space just walks over the current char.
"" I must say C-@ instead of C-Space for this to work on the terminal.
cnoremap <C-@> <Right>
inoremap <C-@> <Right>
"" But in GUI mode we need to define the mapping properly.
autocmd GUIEnter * cnoremap <c-Space> <Right>
autocmd GUIEnter * inoremap <c-Space> <Right>
"" Can't map C-Backspace; BS emits C-H with or without Ctrl.
" cnoremap <C-BS> <Left>

"" Now we have muted <C-R> but <C-R> can be useful, so let's make a workaround:
"cnoremap <C-\><C-R> <C-R>
"" But we cannot receive <C-\> on the terminal, so instead use \:
cnoremap \<C-R> <C-R>
"" Example usage (actually just me trying to remember how <C-R> works):
"" To insert the <cword> (word under cursor) on the cmdline, we can now do: <C-\><C-R><C-W> (which would originally have been <C-R><C-W>)
"" And of course, <C-R>q will paste/insert the q register.
"" For all the other <C-R> tricks, see: :help c_CTRL-R_CTRL-F

"" Now the same for Insert-mode?  Well a select few perhaps...
inoremap <C-X> <Esc>dbxi
"" Except we won't do <C-V> because that has a useful meaning already
inoremap <C-D> <Esc>bi
"" And <C-F> already means toggle fullscreen.
"inoremap <C-F> <Esc>ea
inoremap <C-F> <Esc>wi
"inoremap <C-A> <Home>
"inoremap <C-E> <End>
"" By default <C-A> performs the last . which could be pretty handy.
"" Default <C-E> copies 1 char from the cell above (useful in the 80s).

"" Because we overwrote Ctrl-D, we need a new one:
cnoremap <C-L> <C-D>

" This is how my zsh does completion, and it rocks (unless for some reason you
" always want the first match of multiples, then you must always Tab twice).
set wildmode=longest:full,full
" I use the default wildchar=<Tab>


" Make a global mark 'Q' with 'mQ' and jump back to it with 'MQ'.
"nmap M g'
" M usually does to-middle-line-of-window



" When it's time to clear the search, avoid /skldjsdklfj<Enter> and just \/ or Ctrl-L
" Also added :match to hide highlights from highlight_word_under_cursor.vim
nnoremap <silent> <Leader>/      :nohlsearch<CR>:match<CR>
nmap     <silent> <C-L>     <C-L>:nohlsearch<CR>:match<CR>
"nnoremap <silent> <Leader>/ :nohlsearch<CR>:match<CR>:let @/='skj84ksdEKD93Od23423lfs'<CR>



" Forgot to sudo when opening a root file?  No problem, just :w!!
cmap w!! w !sudo tee % >/dev/null



" Quick toggles for most frequently used functions
"nnoremap <Leader>t :Tlist<Enter>
" Because Tlist does not fire autocmds, it causes a bug where dim_inactive_windows dims the current window on startup.  We workaround this by switching window, and switching back again
nnoremap <Leader>t :Tlist<Enter><C-w>w<C-w>p
nnoremap <Leader>w :set invwrap<Enter>

" Quick buffer switching (beyond Ctrl-PageUp/Down)
"" Select buffer by any part of filename and Tab completion or arrows, or by number
"nnoremap <C-E> :ls<CR>:b<space>
nnoremap <C-E> :set nomore <Bar> :ls <Bar> :set more <CR>:b<Space>
"" An interesting alternative, assuming you have MBE as your first window:
"nnoremap <C-E> 1<C-W><C-W>/
"" Select file by filename with completion
" nnoremap <C-E> :ls<CR>:e<space>
"" Select by name with completion or file without (joeys_buffer_switcher.vim)
"nnoremap <Leader>e :JoeysBufferSwitch<Enter>
"" I use <C-E> above for switching buffer now, but this is still useful for switching window!
nnoremap <Leader>W :JoeysBufferSwitch<Enter>
"" Select buffer from list (bufexplorer.vim)
nnoremap <C-B> :BufExplorer<Enter>
"" Select from persistent list of most-recently-used files (mru.vim)
nnoremap <Leader>b :MRU<Enter>
"" Some more alternative buffer switchers:
"" :EasyBuffer (easybuffer.vim)

" vtreeexplorer (nice because it opens file in main window):
nnoremap <Leader>f :VSTreeExploreToggle<Enter>
" NERDTree file explorer (NERD_tree.vim)
nnoremap <Leader>F :NERDTreeToggle<Enter>
" NetRW file explorer (bundled):
"nnoremap <Leader>F :Vexplore<Enter>
nnoremap <Leader>o :Explore .<Enter>
nnoremap <Leader>O :e .<Enter>
" Note that if g:NERDTreeHijackNetrw is not set 0, netrw windows may be
" hijacked by NERDTree!

nnoremap <Leader>s :Sopen<Enter>
nnoremap <Leader>S :SessionList<Enter>

" A common combination (IDE vim!)
nmap <Leader>i <Leader>f<C-w><Right><Leader>t

" Toggle relative line numbers in the margin
"nmap <Leader>l :set invrelativenumber<Enter>

" Been having a nightmare with iskeyword.  Here is a fast way to reset it.
"nnoremap <Leader>k :setlocal iskeyword=65-127<Enter>

" Toggle the paste option (annoying that this doesn't show the current state)
nmap <Leader>p :set invpaste<Enter>

" Disable diff settings
nmap <Leader>d :set nodiff fdc=0<CR>

" Fold everything in the buffer except lines which match the current search pattern (or at second level, the line on either side)
nnoremap <Leader>z :setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=2<CR>
" Alternative, as a command:
"command! -nargs=+ Foldsearch exe "normal /".<q-args>."^M" | setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\|\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=2


" Quickly edit/reload the vimrc file (Derek Wyatt)
"nmap <silent> <leader>ev :e $MYVIMRC<CR>
"nmap <silent> <leader>sv :so $MYVIMRC<CR>



"" Close Current Buffer
"" Ctrl-Q is the unlock terminal code, and the terminal swallows it (does not pass it to vim).
" nnoremap <C-Q> :CloseBuffer<Enter>
"" Ctrl-Z works ok
nnoremap <C-Z> :CloseBuffer<Enter>
"" CloseBuffer is implemented in (kwbd.vim)

" We cannot use <Ctrl-S> for save because many terminals will just swallow
" that as the magic "pause" key.  But shift-S = cc, so let's use that.
"nnoremap S :w<Enter>
" Not a good idea to map 'S' in Insert mode...
"inoremap S <Esc>:w<Enter>i
" Putting a custom mapping on S was a bad idea.  Because if muscle-memory tries to use it on a Vim without my keybinds, I end up clearing part of the current line and entering insert mode, which is probably terrifying for whoever is watching me edit.  Let's retrain the muscles to use Z instead:
nnoremap <silent> S :echohl ErrorMsg <Bar> echo "NOT SAVED!  Press Z to save." <Bar> echohl<Enter>
nnoremap Z :w<Enter>
" Oh damnit Z was a little better, but not much.  Although Z does nothing on default Vim, ZZ is save-and-quit!  :S
" We could instead go for something safer and easier to reach that I never use, e.g. L or H.  (Currently I have l seek forwards and L seek back, but I hardly ever use them.)
" Finally we could go for Ctrl-s which is safe given that I know Ctrl-q.  The difficulty here it ensuring it is executed when vim is started by other programs, e.g. git merge or visudo.
" OK I have now added this in my .vimrc: :silent !stty -ixon
" Perhaps that should be moved to here, since this depends on that, and that is only used for this.
nnoremap <C-s> :w<Enter>
" Similarly I cannot map Ctrl-q
"nnoremap Q :qa<Enter>
" OK this is safer, my MBE settings will require it be hit twice.  And also it can be used to close a window.
nnoremap Q :q<Enter>
" NOTE: If you really do want to use C-s and C-q then do this before loading vim:
"   stty -ixon
" Save for MacVim on normal Mac save key.
" Not needed because MacVim sets this by default!
"if $_system_name == 'OSX'
"	nmap <d-s> <C-s>
"endif

" If there is more than one matching tag, let the user choose.
nnoremap <C-]> g<C-]>
" Occasionally there are multiple results but all pointing to the same place; it still asks the user to choose.  :S
" (I think this is when the file is open, then we get one tag from the 'tags' file, and one from Vim itself, or perhaps from TList.)
" TODO: Would be nice if tags fail, to try gd or gD instead.
"       Or indeed, do a language-sensitive fallback search.
"       E.g. for Javascript, we could search in current file for "function <cword>"
"                            or failing that, try the same search with Grep.

" Execute the line under the cursor in ex
nnoremap <Leader>e :execute getline(".")<CR>
" I would quite like a version that could work on multiple lines (from a visual selection).
" Execute line from clipboard in ex.  But which clipboard?  Let's display them and let the user choose.
nnoremap <Leader>E :registers " + *<CR>:execute @

function! s:SetupKeysForGrep()
	" Now that <F4> is doing a search for the word under the cursor.  <F3> could start empty, waiting for a typed word.  But for the user's convenience, we start them off with the whole-word symbols.
	nnoremap <F3> :Grep<CR><C-U>\<\><Left><Left>
	" If my F3 mapping to grep.vim is working fine, let's skip through all the prompts.
	" Replaces :emenu<Space><Tab>
	"nmap <F4> <F3><CR><CR><CR>
	"nnoremap <F4> :Grep<CR><CR><CR><CR>
	"nnoremap <F4> :Grep<CR><Home>\<<End>\><CR><CR><CR>   " untested
	nnoremap <F4> :Grep \<<cword>\><CR><CR><CR>
	" NOTE: The last <CR> is not always needed.  The |hit-enter| prompt is only displayed when the "Grep in files:" prompt has exceeded |cmdheight| (always true for me, with my huge exclude list).  So an alternative workaround might be for grep.vim to temporarily set ch very high, then reset it afterwards.
	" Avoiding the final <CR> would be desirable because it currently hides any "Error...not found" message that might appear.  And perhaps in some cases it isn't even required (if the command-line is not longer than the screen).

	" WIP: We can avoid all the prompts by passing the filelist, e.g.:
	"nnoremap <F4> :Grep \<<cword>\> . -r<CR>
endfunction

function! s:SetupKeysForCSearch()
	" If using csearch, \< and \> are replaced with \b
	nnoremap <F3> :Grep<CR><C-U>\b\b<Left><Left>
	" And F4 needs one fewer <CR> (because the file/options line is short/empty):
	"nnoremap <F4> :Grep<CR><CR>
	"nnoremap <F4> :Grep<CR><Home>\b<End>\b<CR>   " untested
	nnoremap <F4> :Grep \b<cword>\b<CR>
endfunction

if exists("g:Grep_Using_CodeSearch") && g:Grep_Using_CodeSearch || exists("g:Grep_Path") && match(g:Grep_Path, '^csearch$\|/csearch$') >= 0
	call s:SetupKeysForCSearch()
else
	call s:SetupKeysForGrep()
endif

command! UseGrep    exec "SwitchToGrep"    | call s:SetupKeysForGrep()
command! UseCSearch exec "SwitchToCSearch" | call s:SetupKeysForCSearch()

" Vim's <C-w>W is the opposite of <C-W>w, so why not the same for <C-w>X?
"nnoremap <C-w>X <C-w>W<C-w>x<C-w>w

" However I would quite like both those commands to "follow" the moved window, so:
nnoremap <C-w>x <C-w>x<C-w>w
nnoremap <C-w>X <C-w>W<C-w>x
" Note that these will not do as expected if a <count> is given.

" Comment or uncomment visual selection on leader / or leader shift-/
" By default, comment is //
vnoremap <Leader>/ :s+^\(\s*\)+\1//+<Enter>:set nohlsearch<CR>
vnoremap <D-/>     :s+^\(\s*\)+\1//+<Enter>:set nohlsearch<CR>
vnoremap <Leader>? :s+^\(\s*\)//+\1+<Enter>:set nohlsearch<CR>
vnoremap <D-?>     :s+^\(\s*\)//+\1+<Enter>:set nohlsearch<CR>
" But override for other filetypes:
" TODO: It is better if we put these into ftplugin, and create good rules for detecting filetype.
"       For example the vim comment mappings do not get loaded when we open ~/.vimrc because it does not match the pattern *.vim!
autocmd BufReadPost *.vim              vnoremap <buffer> <Leader>/ :s+^\(\s*\)+\1"+<Enter>:set nohlsearch<CR>
autocmd BufReadPost *.vim              vnoremap <buffer> <D-/>     :s+^\(\s*\)+\1"+<Enter>:set nohlsearch<CR>
autocmd BufReadPost *.vim              vnoremap <buffer> <Leader>? :s+^\(\s*\)"+\1+<Enter>:set nohlsearch<CR>
autocmd BufReadPost *.vim              vnoremap <buffer> <D-?>     :s+^\(\s*\)"+\1+<Enter>:set nohlsearch<CR>
autocmd BufReadPost *.{sh,coffee,conf} vnoremap <buffer> <Leader>/ :s+^\(\s*\)+\1#+<Enter>:set nohlsearch<CR>
autocmd BufReadPost *.{sh,coffee,conf} vnoremap <buffer> <D-/>     :s+^\(\s*\)+\1#+<Enter>:set nohlsearch<CR>
autocmd BufReadPost *.{sh,coffee,conf} vnoremap <buffer> <Leader>? :s+^\(\s*\)#+\1+<Enter>:set nohlsearch<CR>
autocmd BufReadPost *.{sh,coffee,conf} vnoremap <buffer> <D-?>     :s+^\(\s*\)#+\1+<Enter>:set nohlsearch<CR>
autocmd BufReadPost *.css              vnoremap <buffer> <Leader>/ :s+^\(\s*\)\(.*\)+\1/* \2 */+<Enter>:set nohlsearch<CR>
autocmd BufReadPost *.css              vnoremap <buffer> <D-/>     :s+^\(\s*\)\(.*\)+\1/* \2 */+<Enter>:set nohlsearch<CR>
autocmd BufReadPost *.css              vnoremap <buffer> <Leader>? :s+^\(\s*\)/[*]\(.*\)[*]/+\1\2+<Enter>:set nohlsearch<CR>
autocmd BufReadPost *.css              vnoremap <buffer> <D-?>     :s+^\(\s*\)/[*]\(.*\)[*]/+\1\2+<Enter>:set nohlsearch<CR>
" We don't need to define these, because // commenting is the default specified at the top.
"autocmd BufReadPost *.{c,cpp,C,c++,js} vnoremap <buffer> <Leader>/ :s+^\(\s*\)+\1//+<Enter>:set nohlsearch<CR>
"autocmd BufReadPost *.{c,cpp,C,c++,js} vnoremap <buffer> <D-/>     :s+^\(\s*\)+\1//+<Enter>:set nohlsearch<CR>
"autocmd BufReadPost *.{c,cpp,C,c++,js} vnoremap <buffer> <Leader>? :s+^\(\s*\)//+\1+<Enter>:set nohlsearch<CR>
"autocmd BufReadPost *.{c,cpp,C,c++,js} vnoremap <buffer> <D-?>     :s+^\(\s*\)//+\1+<Enter>:set nohlsearch<CR>
" TODO: If we don't want to clobber the search pattern, we could store and retore the value of the @/ variable before and after.
" TODO: We should use a function to generate the above.  That same function could setup F5 and F6 how I currently do in ~/.vim/ftplugin/*.vim
" e.g. :call ThisBufferUsesCommentSymbol("/*", "*/")
"   or :call ThisBufferUsesCommentSymbol("#")
"   or :call RegisterCommentSymbol('coffee', '#')
" We could also inspect &comments, but which one should we choose to use?  :-P

" Make Shift-Insert in GVim work like it does in X-Term
"autocmd GUIEnter * inoremap <S-Insert> <Esc>"*pa
autocmd GUIEnter * inoremap <S-Insert> <C-R>*
autocmd GUIEnter * cnoremap <S-Insert> <C-R>*

" Copy and paste keys on <Ctrl-C> and <Ctrl-V> like all the other editors
" Ctrl-C in Visual mode acts like copy
vnoremap <C-c> "+y
" This version restores visual mode afterwards (retains the selection) which is consistent with other editors, but not especially desirable.
"vnoremap <C-c> "+ygv
"" Ctrl-V in Normal and Insert mode acts like paste
"nnoremap <C-v> "+p
""inoremap <C-v> <C-r>+
"" This version creates its own undo entry (rather than combining with the last) but it doesn't leave the cursor in the right place.
"inoremap <C-v> <Esc>"+pa
"" Ctrl-V in Visual mode pastes over the selection
"vnoremap <C-v> "+P
" Normal behaviour of <C-v> now available on <Leader><C-v>
" But for some reason these don't work!  Likewise \<C-v> didn't work either.
" The \ is always inserted without waiting for a second char.
"nnoremap <Leader><C-v> <C-v>
"inoremap <Leader><C-v> <C-v>
"vnoremap <Leader><C-v> <C-v>

" Select All from Insert mode using <Ctrl-A> (overrides default "Insert previously inserted text").  Finishes in Visual mode.
inoremap <C-a> <Esc>ggvG$
" Same when in Visual mode:
vnoremap <C-a> <Esc>ggvG$

" Faster access to EasyMotion, assuming g:EasyMotion_leader_key == "<Leader><Leader>"
"nmap <Leader>j <Leader><Leader>f
"nmap <Leader>J <Leader><Leader>F
"nmap <C-d> <Leader><Leader>F
"nmap <C-g> <Leader><Leader>f
"omap <C-d> <Leader><Leader>F
"omap <C-g> <Leader><Leader>f
"vmap <C-d> <Leader><Leader>F
"vmap <C-g> <Leader><Leader>f
" Doh.  map == [nov]map !
" I actually find <C-d> easier to hit than <C-g>
" <C-d> is 1-char seek
map <C-d> <Plug>(easymotion-bd-f)
" <C-g> is 0-char jump
" Often requires 2 strokes, in which case why not use <C-d> and the first stroke will be the char already there!
" Might be more efficient if the <C-d> char is very common (more common than words?!)
map <C-g> <Plug>(easymotion-bd-w)
"map <C-g> <Plug>(easymotion-jumptoanywhere)
" Alternative layout: <C-d> is 0-char jump, <C-g> is /-like phrase jump.  For 1-char jump, use f and then flash hinting.
"map <C-d> <Plug>(easymotion-bd-w)
"map  <C-g> <Plug>(easymotion-sn)
"omap <C-g> <Plug>(easymotion-tn)
map <Leader><Leader>^ <Plug>(easymotion-sol-bd-jk)
map <Leader><Leader>$ <Plug>(easymotion-eol-bd-jk)

" PLEASE NOTE: I have setup other EasyMotion keys in my .vimrc

" These might be useful, but unfortunately they are a bit slow:
"map w <Plug>(easymotion-flash-w)
"map b <Plug>(easymotion-flash-b)
"map W <Plug>(easymotion-flash-W)
"map B <Plug>(easymotion-flash-B)
"map e <Plug>(easymotion-flash-e)
"map ge <Plug>(easymotion-flash-ge)
"map E <Plug>(easymotion-flash-E)
"map gE <Plug>(easymotion-flash-gE)

" I rarely use these, but they are here for testing:
map  <Leader><Leader>/ <Plug>(easymotion-sn)
omap <Leader><Leader>/ <Plug>(easymotion-tn)
map  <Leader><Leader><Leader>/ <Plug>(easymotion-flash-tn)
omap <Leader><Leader><Leader>/ <Plug>(easymotion-flash-sn)
map <Leader><Leader><Leader>W <Plug>(easymotion-flash-bd-W)

" In Insert mode, Shift-Enter keeps us on the current line, but pushes an empty line below
inoremap <S-Enter> <Esc>O
" In Xterm, both <S-Enter> and <C-Enter> reach Vim as <Enter>, so we cannot use this.

" Find line easily from High/Middle/Low keys (a far better mnemonic than Home/Middle/Last in the docs)
nmap <silent> H H:set relativenumber<CR>
nmap <silent> M M:set relativenumber<CR>
nmap <silent> L L:set relativenumber<CR>
autocmd CursorHold * set norelativenumber

" When writing a :! shell command, the shortcut %<Tab> can be used to insert the current filename.  But the same does not work when writing a standard Ex : command!
" This naughty workaround should make it work for both, BUT it will always append to the end of the line, regardless where on the line the cursor was.
"cnoremap %<Tab> <Home>!<End>%<C-l><Home><Del><End>
" This one is better; it should insert at the cursor.
cnoremap %<Tab> <C-r>%

" When editing a Vim file, make K lookup Vim's inline :help rather than calling 'man'.
autocmd BufReadPost *.vim setlocal keywordprg=:help

" I'm not sure if this is useful.  It turned out to be no use for the original use-case (I was deleting parts of lines, so they were entering the small delete register, and not the numbered registers).
function! s:CycleYanks()
	let unnamed = @"
	let @" = @1   " Also writes to @0
	let @1 = @2
	let @2 = @3
	let @3 = @4
	let @4 = @5
	let @5 = @6
	let @6 = @7
	let @7 = @8
	let @8 = @9
	let @9 = unnamed
	echo strpart( "Unnamed register is now: " . substitute( substitute(@", '\n', '\\n', 'g'), '\t', '->', 'g' ), 0, &columns - 15 )
endfunction
nnoremap \cy :call <SID>CycleYanks()<CR>

" Search help files.  Don't use this.  Use :helpgrep
" I want the quickfix to open results in the newly created :help or :new window, but I cannot get that to happen!
" One guy attacked this with http://www.vim.org/scripts/script.php?script_id=4778#QFEnter
"command! -n=1 -complete=help SearchHelp help | ...
"command! -n=1 -complete=help SearchHelp new | ...
command! -n=1 -complete=help SearchHelp 99wincmd j | wincmd s | execute "grep! -i <args> $VIMRUNTIME/doc/ -r" | botright copen
" I want to pretend there is a builting command :searchhelp which I will probably seek using :sea<Tab>
nnoremap :sea<Tab> :SearchHelp<Space>
nnoremap :sea<Space> :SearchHelp<Space>
nmap :sea<Up> :SearchHelp<Space><Up>

" Always open the quickfix window after :grep
"autocmd QuickFixCmdPost *grep* cwindow
" Like :grep but skips skip the annoying "Press ENTER or type command to continue" message, and also opens the quickfix window.
command! -bar -nargs=1 Sgrep silent execute "grep <args>" | redraw! | cw

