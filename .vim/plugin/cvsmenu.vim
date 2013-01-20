" CVSmenu.vim : Vim menu for using CVS			vim:tw=0
" Author : Thorsten Maerz <info@netztorte.de>		vim600:fdm=marker
" $Revision: 1.4 $
" $Date: 2013/01/20 02:42:09 $
" License : LGPL
"
" Tested with Vim 6.0
" Primary site : http://ezytools.sourceforge.net/
" Located in the "VimTools" section
" Thanks to Max Ischenko and Michael Sternberg 
"   for testing and useful tips
"
" TODO: Better support for additional params
" TODO: gettag()/getmodule()

"#############################################################################
" Settings
"#############################################################################
" global variables : may be set in ~/.vimrc	{{{1

" this *may* interfere with :help (inhibits highlighting)
" disable autocheck, if this happens to you.
if ($CVSOPT == '')
  let $CVSOPT='-z9'
endif

if ($CVSCMD == '')
  let $CVSCMD='cvs'
endif

if !exists("g:CVSforcedirectory")
  let g:CVSforcedirectory = 0		" 0:off 1:once 2:forever
endif
if !exists("g:CVSqueryrevision")
  let g:CVSqueryrevision = 0		" 0:fast update 1:query for revisions
endif
if !exists("g:CVSdumpandclose")
  let g:CVSdumpandclose = 2		" 0:new buffer 1:statusline 2:autoswitch
endif
if !exists("g:CVSsortoutput")
  let g:CVSsortoutput = 1		" sort cvs output (group conflicts,updates,...)
endif
if !exists("g:CVScompressoutput")
  let g:CVScompressoutput = 1		" show extended output only if error
endif
if !exists("g:CVSstatusline")
  let g:CVSstatusline = 1		" Notification output to statusline
endif
if !exists("g:CVStitlebar")
  let g:CVStitlebar = 1			" Notification output to titlebar
endif
if !exists("g:CVSofferrevision")
  let g:CVSofferrevision = 1		" Offer current revision on queries
endif
if !exists("g:CVSsavediff")
  let g:CVSsavediff = 1			" save settings when using :diff
endif
if !exists("g:CVSdontswitch")
  let g:CVSdontswitch = 0		" dont switch to diffed file
endif
if !exists("g:CVSautocheck")
  let g:CVSautocheck = 1		" do local status on every read file
endif
if !exists("g:CVSdefaultmsg")
  let g:CVSdefaultmsg = ''		" message to use for commands below
endif
if !exists("g:CVSusedefaultmsg")
  let g:CVSusedefaultmsg = 'aj'		" a:Add, i:Commit, j:Join in, p:Import
endif
if !exists("g:CVSfullstatus")
  let g:CVSfullstatus = 0		" display all fields for fullstatus
endif

" problems with :help on console
if !(has("gui_running"))
  let g:CVSautocheck = 0
endif


" script variables	{{{1
if has('unix')				" path separator
  let s:sep='/'
else
  let s:sep='\'
endif
let s:CVSentries='CVS'.s:sep.'Entries'	" location of 'CVS/Entries' file
let s:cvsmenuhttp="http://cvs.sf.net/cgi-bin/viewcvs.cgi/~checkout~/ezytools/VimTools/"
let s:cvsmenucvs=":pserver:anonymous@cvs.ezytools.sf.net:/cvsroot/ezytools"
let s:CVSupdatequeryonly = 0		" update -n (internal!)
let s:CVSorgtitle = &titlestring	" backup of original title
let g:orgpath = getcwd()
let g:CVSleavediff = 0
let g:CVSdifforgbuf = 0

if exists("loaded_cvsmenu")
  aunmenu CVS
endif

"-----------------------------------------------------------------------------
" Menu entries		{{{1
"-----------------------------------------------------------------------------
" Space before each command to inhibit translation (no one wants a 'cvs Differenz':)
" <esc> in Keyword menus to avoid expansion
" use only TAB between menu item and command (used for MakeLeaderMapping)

amenu &CVS.\ In&fo						:call CVSShowInfo()<cr>
amenu &CVS.\ Settin&gs.\ In&fo\ (buffer)			:call CVSShowInfo(1)<cr>
amenu &CVS.\ Settin&gs.\ Show\ &mappings	                :call CVSShowMapping()<cr>
amenu &CVS.\ Settin&gs.-SEP1-					:
amenu &CVS.\ Settin&gs.\ &Autocheck.&Enable			:call CVSSetAutocheck(1)<cr>
amenu &CVS.\ Settin&gs.\ &Autocheck.&Disable			:call CVSSetAutocheck(0)<cr>
amenu &CVS.\ Settin&gs.\ &Target.File\ in\ &buffer		:call CVSSetForceDir(0)<cr>
amenu &CVS.\ Settin&gs.\ &Target.&Directory			:call CVSSetForceDir(2)<cr>
amenu &CVS.\ Settin&gs.\ &Diff.Stay\ in\ &original		:call CVSSetDontSwitch(1)<cr>
amenu &CVS.\ Settin&gs.\ &Diff.Switch\ to\ &diffed		:call CVSSetDontSwitch(0)<cr>
amenu &CVS.\ Settin&gs.\ &Diff.-SEP1-				:
amenu &CVS.\ Settin&gs.\ &Diff.&Autorestore\ prev\.\ mode	:call CVSSetSaveDiff(1)<cr>
amenu &CVS.\ Settin&gs.\ &Diff.&No\ autorestore			:call CVSSetSaveDiff(0)<cr>
amenu &CVS.\ Settin&gs.\ &Diff.-SEP2-				:
amenu &CVS.\ Settin&gs.\ &Diff.Re&store\ pre-diff\ mode		:call CVSRestoreDiffMode()<cr>
amenu &CVS.\ Settin&gs.\ Revision\ &queries.&Enable		:call CVSSetQueryRevision(1)<cr>
amenu &CVS.\ Settin&gs.\ Revision\ &queries.&Disable		:call CVSSetQueryRevision(0)<cr>
amenu &CVS.\ Settin&gs.\ Revision\ &queries.-SEP1-		:
amenu &CVS.\ Settin&gs.\ Revision\ &queries.&Offer\ current\ rev	:call CVSSetOfferRevision(1)<cr>
amenu &CVS.\ Settin&gs.\ Revision\ &queries.&Hide\ current\ rev		:call CVSSetOfferRevision(0)<cr>
amenu &CVS.\ Settin&gs.\ &Output.N&otifcation.Enable\ &statusline	:call CVSSetStatusline(1)<cr>
amenu &CVS.\ Settin&gs.\ &Output.N&otifcation.Disable\ status&line	:call CVSSetStatusline(0)<cr>
amenu &CVS.\ Settin&gs.\ &Output.N&otifcation.-SEP1-			:
amenu &CVS.\ Settin&gs.\ &Output.N&otifcation.Enable\ &titlebar		:call CVSSetTitlebar(1)<cr>
amenu &CVS.\ Settin&gs.\ &Output.N&otifcation.Disable\ title&bar	:call CVSSetTitlebar(0)<cr>
amenu &CVS.\ Settin&gs.\ &Output.-SEP1-					:
amenu &CVS.\ Settin&gs.\ &Output.To\ new\ &buffer		:call CVSSetDumpAndClose(0)<cr>
amenu &CVS.\ Settin&gs.\ &Output.&Notify\ only			:call CVSSetDumpAndClose(1)<cr>
amenu &CVS.\ Settin&gs.\ &Output.&Autoswitch			:call CVSSetDumpAndClose(2)<cr>
amenu &CVS.\ Settin&gs.\ &Output.-SEP2-				:
amenu &CVS.\ Settin&gs.\ &Output.&Compressed			:call CVSSetCompressOutput(1)<cr>
amenu &CVS.\ Settin&gs.\ &Output.&Full				:call CVSSetCompressOutput(0)<cr>
amenu &CVS.\ Settin&gs.\ &Output.-SEP3-				:
amenu &CVS.\ Settin&gs.\ &Output.&Sorted			:call CVSSetSortOutput(1)<cr>
amenu &CVS.\ Settin&gs.\ &Output.&Unsorted			:call CVSSetSortOutput(0)<cr>
amenu &CVS.\ Settin&gs.-SEP2-					:
amenu &CVS.\ Settin&gs.\ &Install.&Install\ updates		:call CVSInstallUpdates()<cr>
amenu &CVS.\ Settin&gs.\ &Install.&Download\ updates		:call CVSDownloadUpdates()<cr>
amenu &CVS.\ Settin&gs.\ &Install.Install\ buffer\ as\ &help	:call CVSInstallAsHelp()<cr>
amenu &CVS.\ Settin&gs.\ &Install.Install\ buffer\ as\ &plugin	:call CVSInstallAsPlugin()<cr>
amenu &CVS.\ &Keyword.\ &Author					a$Author<esc>a$<esc>
amenu &CVS.\ &Keyword.\ &Date					a$Date<esc>a$<esc>
amenu &CVS.\ &Keyword.\ &Header					a$Header<esc>a$<esc>
amenu &CVS.\ &Keyword.\ &Id					a$Id<esc>a$<esc>
amenu &CVS.\ &Keyword.\ &Name					a$Name<esc>a$<esc>
amenu &CVS.\ &Keyword.\ Loc&ker					a$Locker<esc>a$<esc>
amenu &CVS.\ &Keyword.\ &Log					a$Log<esc>a$<esc>
amenu &CVS.\ &Keyword.\ RCS&file				a$RCSfile<esc>a$<esc>
amenu &CVS.\ &Keyword.\ &Revision				a$Revision<esc>a$<esc>
amenu &CVS.\ &Keyword.\ &Source					a$Source<esc>a$<esc>
amenu &CVS.\ &Keyword.\ S&tate					a$State<esc>a$<esc>
amenu &CVS.\ Director&y.\ &Log					:call CVSSetForceDir(1)<cr>:call CVSlog()<cr>
amenu &CVS.\ Director&y.\ &Status				:call CVSSetForceDir(1)<cr>:call CVSstatus()<cr>
amenu &CVS.\ Director&y.\ S&hort\ status			:call CVSSetForceDir(1)<cr>:call CVSshortstatus()<cr>
amenu &CVS.\ Director&y.\ Lo&cal\ status			:call CVSSetForceDir(1)<cr>:call CVSLocalStatus()<cr>
amenu &CVS.\ Director&y.-SEP1-					:
amenu &CVS.\ Director&y.\ &Query\ update			:call CVSSetForceDir(1)<cr>:call CVSqueryupdate()<cr>
amenu &CVS.\ Director&y.\ &Update				:call CVSSetForceDir(1)<cr>:call CVSupdate()<cr>
amenu &CVS.\ Director&y.-SEP2-					:
amenu &CVS.\ Director&y.\ &Add					:call CVSSetForceDir(1)<cr>:call CVSadd()<cr>
amenu &CVS.\ Director&y.\ Comm&it				:call CVSSetForceDir(1)<cr>:call CVScommit()<cr>
amenu &CVS.\ Director&y.-SEP3-					:
amenu &CVS.\ Director&y.\ Re&move\ from\ repositoy			:call CVSSetForceDir(1)<cr>:call CVSremove()<cr>
amenu &CVS.\ E&xtra.\ &Create\ patchfile.\ &Context		:call CVSdiffcontext()<cr>
amenu &CVS.\ E&xtra.\ &Create\ patchfile.\ &Standard		:call CVSdiffstandard()<cr>
amenu &CVS.\ E&xtra.\ &Create\ patchfile.\ &Uni			:call CVSdiffuni()<cr>
amenu &CVS.\ E&xtra.\ &Diff\ to\ revision			:call CVSdifftorev()<cr>
amenu &CVS.\ E&xtra.\ &Log\ to\ revision			:call CVSlogtorev()<cr>
amenu &CVS.\ E&xtra.-SEP1-					:
amenu &CVS.\ E&xtra.\ Check&out\ revision			:call CVScheckoutrevision()<cr>
amenu &CVS.\ E&xtra.\ &Update\ to\ revision			:call CVSupdatetorev()<cr>
amenu &CVS.\ E&xtra.\ &Merge\ in\ revision			:call CVSupdatemergerev()<cr>
amenu &CVS.\ E&xtra.\ Merge\ in\ revision\ di&ffs		:call CVSupdatemergediff()<cr>
amenu &CVS.\ E&xtra.-SEP2-					:
amenu &CVS.\ E&xtra.\ Comm&it\ to\ revision			:call CVScommitrevision()<cr>
amenu &CVS.\ E&xtra.\ Im&port\ to\ revision			:call CVSimportrevision()<cr>
amenu &CVS.\ E&xtra.\ &Join\ in\ to\ revision			:call CVSjoininrevision()<cr>
amenu &CVS.\ E&xtra.-SEP3-					:
amenu &CVS.\ E&xtra.\ CVS\ lin&ks				:call CVSOpenLinks()<cr>
amenu &CVS.\ E&xtra.\ &Get\ file				:call CVSGet()<cr>
amenu &CVS.\ E&xtra.\ Get\ file\ (pass&word)			:call CVSGet('','','io')<cr>
amenu &CVS.-SEP1-						:
amenu &CVS.\ Ad&min.\ Log&in					:call CVSlogin()<cr>
amenu &CVS.\ Ad&min.\ Log&out					:call CVSlogout()<cr>
amenu &CVS.\ D&elete.\ Re&move\ from\ repository		:call CVSremove()<cr>
amenu &CVS.\ D&elete.\ Re&lease\ workdir			:call CVSrelease()<cr>
amenu &CVS.\ &Tag.\ &Create\ tag				:call CVStag()<cr>
amenu &CVS.\ &Tag.\ &Remove\ tag				:call CVStagremove()<cr>
amenu &CVS.\ &Tag.\ Create\ &branch				:call CVSbranch()<cr>
amenu &CVS.\ &Tag.-SEP1-					:
amenu &CVS.\ &Tag.\ Cre&ate\ tag\ by\ module			:call CVSrtag()<cr>
amenu &CVS.\ &Tag.\ Rem&ove\ tag\ by\ module			:call CVSrtagremove()<cr>
amenu &CVS.\ &Tag.\ Create\ branc&h\ by\ module			:call CVSrbranch()<cr>
amenu &CVS.\ &Watch/Edit.\ &Watchers				:call CVSwatchwatchers()<cr>
amenu &CVS.\ &Watch/Edit.\ Watch\ &add				:call CVSwatchadd()<cr>
amenu &CVS.\ &Watch/Edit.\ Watch\ &remove			:call CVSwatchremove()<cr>
amenu &CVS.\ &Watch/Edit.\ Watch\ o&n				:call CVSwatchon()<cr>
amenu &CVS.\ &Watch/Edit.\ Watch\ o&ff				:call CVSwatchoff()<cr>
amenu &CVS.\ &Watch/Edit.-SEP1-					:
amenu &CVS.\ &Watch/Edit.\ &Editors				:call CVSwatcheditors()<cr>
amenu &CVS.\ &Watch/Edit.\ Edi&t				:call CVSwatchedit()<cr>
amenu &CVS.\ &Watch/Edit.\ &Unedit				:call CVSwatchunedit()<cr>
amenu &CVS.-SEP2-						:
amenu &CVS.\ &Diff						:call CVSdiff()<cr>
amenu &CVS.\ A&nnotate						:call CVSannotate()<cr>
amenu &CVS.\ Histo&ry						:call CVShistory()<cr>
amenu &CVS.\ &Log						:call CVSlog()<cr>
amenu &CVS.\ &Status						:call CVSstatus()<cr>
amenu &CVS.\ S&hort\ status					:call CVSshortstatus()<cr>
amenu &CVS.\ Lo&cal\ status					:call CVSLocalStatus()<cr>
amenu &CVS.-SEP3-						:
amenu &CVS.\ Check&out						:call CVScheckout()<cr>
amenu &CVS.\ &Query\ update					:call CVSqueryupdate()<cr>
amenu &CVS.\ &Update						:call CVSupdate()<cr>
amenu &CVS.\ Re&vert\ changes					:call CVSrevertchanges()<cr>
amenu &CVS.-SEP4-						:
amenu &CVS.\ &Add						:call CVSadd()<cr>
amenu &CVS.\ Comm&it						:call CVScommit()<cr>
amenu &CVS.\ Im&port						:call CVSimport()<cr>
amenu &CVS.\ &Join\ in						:call CVSjoinin()<cr>

" create key mappings from this script		{{{1
" key mappings : <Leader> (mostly '\' ?), then same as menu hotkeys
" e.g. <ALT>ci = \ci = CVS.Commit
function! CVSMakeLeaderMapping()
  let cvsmenu=expand("$VIM").s:sep.'plugin'.s:sep.'cvsmenu.vim'
  silent! call CVSMappingFromMenu(cvsmenu,',')
  unlet cvsmenu
endfunction

function! CVSMappingFromMenu(filename,...)
  if !filereadable(a:filename)
    return
  endif
  if a:0 == 0
    let leader = '<Leader>'
  else
    let leader = a:1
  endif
  " create mappings from &-chars
  new
  exec 'read '.a:filename
  " leave only amenu defs
  exec 'g!/^\s*amenu/d'
  " delete separators and blank lines
  exec 'g/\.-SEP/d'
  exec 'g/^$/d'
  " count entries
  let entries=line("$")
  " extract menu entries, put in @m
  exec '%s/^\s*amenu\s\([^'."\t".']*\).\+/\1/eg' 
  exec '%y m'
  " extract mappings from '&'
  exec '%s/&\(\w\)[^&]*/\l\1/eg'
  " create cmd, delete to @k
  exec '%s/^\(.*\)$/nmap '.leader.'\1 :em /eg' 
  exec '%d k'
  " restore menu, delete '&'
  normal "mP
  exec '%s/&//eg'
  " visual block inserts failed, when called from script (vim60at)
  " append keymappings
  normal G"kP
  " merge keys/commands, execute
  let curlin=0
  while curlin < entries
    let curlin = curlin + 1
    call setline(curlin,getline(curlin + entries).getline(curlin).'<cr>')
    exec getline(curlin)
  endwhile
  set nomodified
  bwipeout
endfunction

"-----------------------------------------------------------------------------
" show cvs info		{{{1
"-----------------------------------------------------------------------------
" Param : ToBuffer (bool)
function! CVSShowInfo(...)
  if a:0 == 0
    let tobuf = 0
  else
    let tobuf = a:1
  endif
  "exec 'cd '.expand('%:p:h')
  call CVSChDir(expand('%:p:h'))
  " show CVS info from directory
  let cvsroot='CVS'.s:sep.'Root'
  let cvsrepository='CVS'.s:sep.'Repository'
  silent! exec 'split '.cvsroot
  let root=getline(1)
  bwipeout
  silent! exec 'split '.cvsrepository
  let repository=getline(1)
  bwipeout
  unlet cvsroot cvsrepository
  " show settings
  new
  let zbak=@z
  let @z = ''
    \."\n\"CVSmenu $Revision: 1.4 $"
    \."\n\"Current directory : ".expand('%:p:h')
    \."\n\"Current Root : ".root
    \."\n\"Current Repository : ".repository
    \."\n\"\t\t\t\t  set environment var to cvsroot"
    \."\nlet $CVSROOT\t\t= \'"			.$CVSROOT."\'"
    \."\nlet $CVS_RSH\t\t= \'"			.$CVS_RSH."\'"			."\t\" set environment var to rsh/ssh"
    \."\nlet $CVSOPT\t\t= \'"			.$CVSOPT."\'"			."\t\" set cvs options (see cvs --help-options)"
    \."\nlet $CVSCMDOPT\t\t= \'"		.$CVSCMDOPT."\'"		."\t\" set cvs command options"
    \."\nlet $CVSCMD\t\t\= '"			.$CVSCMD."\'"			."\t\" set cvs command"
    \."\nlet g:CVSforcedirectory\t= "		.g:CVSforcedirectory		."\t\" refer to directory instead of current file"
    \."\nlet g:CVSqueryrevision\t= "		.g:CVSqueryrevision		."\t\" Query for revisions (0:no 1:yes)"
    \."\nlet g:CVSdumpandclose\t= "		.g:CVSdumpandclose		."\t\" Output to: 0=buffer 1=notify 2=autoswitch"
    \."\nlet g:CVSsortoutput\t= "		.g:CVSsortoutput		."\t\" Toggle sorting output (0:no sorting)"
    \."\nlet g:CVScompressoutput\t= "		.g:CVScompressoutput		."\t\" Show extended output only if error"
    \."\nlet g:CVStitlebar\t= "			.g:CVStitlebar			."\t\" Notification on titlebar"
    \."\nlet g:CVSstatusline\t= "		.g:CVSstatusline		."\t\" Notification on statusline"
    \."\nlet g:CVSautocheck\t= "		.g:CVSautocheck			."\t\" Get local status when file is read"
    \."\nlet g:CVSofferrevision\t= "		.g:CVSofferrevision		."\t\" Offer current revision on queries"
    \."\nlet g:CVSsavediff\t= "			.g:CVSsavediff			."\t\" Save settings when using :diff"
    \."\nlet g:CVSdontswitch\t= "		.g:CVSdontswitch		."\t\" Dont switch to diffed file"
    \."\nlet g:CVSdefaultmsg\t= \'"		.g:CVSdefaultmsg."\'"		."\t\" message to use for commands below"
    \."\nlet g:CVSusedefaultmsg\t= \'"		.g:CVSusedefaultmsg."\'"	."\t\" a:Add, i:Commit, j:Join in, p:Import"
    \."\nlet g:CVSfullstatus\t= "		.g:CVSfullstatus		."\t\" display all fields for fullstatus"
    \."\n\"----------------------------------------"
    \."\n\" Change above values to your needs."
    \."\n\" To execute a line, put the cursor on it and press <shift-cr> or doubleclick."
    \."\n\" Site: http://ezytools.sf.net/VimTools"
  normal "zP
  let @z=zbak
  normal dd
  if tobuf == 0
    silent! exec '5,$g/^"/d'
    normal dddd
    " dont dump this to titlebar
    let titlebak = g:CVStitlebar
    let g:CVStitlebar = 0
    call CVSDumpAndClose()
    let g:CVStitlebar = titlebak 
    unlet titlebak
  else
    map <buffer> q :bd!<cr>
    map <buffer> <s-cr> :exec getline('.')<cr>:set nomod<cr>:echo getline('.')<cr>
    map <buffer> <2-LeftMouse> <s-cr>
    set syntax=vim
    set nomodified
  endif
  call CVSRestoreDir()
  unlet root repository tobuf 
endfunction

"-----------------------------------------------------------------------------
" syntax, MakeRO/RW		{{{1
"-----------------------------------------------------------------------------

function! CVSUpdateSyntax()
  syn match cvsupdateMerge	'^M .*$'
  syn match cvsupdatePatch	'^P .*$'
  syn match cvsupdateConflict	'^C .*$'
  syn match cvsupdateDelete	'^D .*$'
  syn match cvsupdateUnknown	'^? .*$'
  syn match cvscheckoutUpdate	'^U .*$'
  syn match cvsimportNew	'^N .*$'
  syn match cvstagNew		'^T .*$'
  hi link cvstagNew		Special
  hi link cvsimportNew		Special
  hi link cvscheckoutUpdate	Special
  hi link cvsupdateMerge	Special
  hi link cvsupdatePatch	Constant
  hi link cvsupdateConflict	WarningMsg
  hi link cvsupdateDelete	Statement
  hi link cvsupdateUnknown	Comment

  syn match cvsstatusUpToDate	'^File:\s.*\sStatus: Up-to-date$'
  syn match cvsstatusLocal	'^File:\s.*\sStatus: Locally.*$'
  syn match cvsstatusNeed	'^File:\s.*\sStatus: Need.*$'
  syn match cvsstatusConflict	'^File:\s.*\sStatus: File had conflict.*$'
  syn match cvsstatusUnknown	'^File:\s.*\sStatus: Unknown$'
  hi link cvsstatusUpToDate	Type
  hi link cvsstatusLocal	Constant
  hi link cvsstatusNeed    	Identifier
  hi link cvsstatusConflict    	Warningmsg
  hi link cvsstatusUnknown    	Comment

  syn match cvslocalstatusUnknown	'^unknown:.*'
  syn match cvslocalstatusUnchanged	'^unchanged:.*'
  syn match cvslocalstatusMissing	'^missing:.*'
  syn match cvslocalstatusModified	'^modified:.*'
  hi link cvslocalstatusUnknown		Comment
  hi link cvslocalstatusUnchanged	Type
  hi link cvslocalstatusMissing		Identifier
  hi link cvslocalstatusModified	Constant

  if !filereadable($VIM.s:sep.'syntax'.s:sep.'rcslog')
    syn match cvslogRevision	'^revision.*$'
    syn match cvslogFile	'^RCS file:.*'
    syn match cvslogDate	'^date: .*$'
    hi link cvslogFile		Type
    hi link cvslogRevision	Constant
    hi link cvslogDate		Identifier
  endif
endfunction

function! CVSAddConflictSyntax()
  syn region CVSConflictOrg start="^<<<<<<<" end="^====" contained
  syn region CVSConflictNew start="===$" end="^>>>>>>>" contained
  syn region CVSConflict start="^<<<<<<<" end=">>>>>>>.*" contains=CVSConflictOrg,CVSConflictNew keepend
"  hi link CVSConflict Special
  hi link CVSConflictOrg DiffChange
  hi link CVSConflictNew DiffAdd
endfunction

function! CVSMakeRO()
  set nomodified
  set readonly
  setlocal nomodifiable
endfunction

function! CVSMakeRW()
  set noreadonly
  setlocal modifiable
endfunction

" output window: open file under cursor by <doubleclick> or <shift-cr>
function! CVSUpdateMapping()
  nmap <buffer> <2-LeftMouse> :call CVSFindFile()<cr>
  nmap <buffer> <S-CR> :call CVSFindFile()<cr>
  nmap <buffer> q :bd!<cr>
  nmap <buffer> ? :call CVSShowMapping()<cr>
  nmap <buffer> <Leader>a :call CVSFindFile()<cr>:call CVSadd()<cr>
  nmap <buffer> <Leader>d :call CVSFindFile()<cr>:call CVSdiff()<cr>
  nmap <buffer> <Leader>i :call CVSFindFile()<cr>:call CVScommit()<cr>
  nmap <buffer> <Leader>u :call CVSFindFile()<cr>:call CVSupdate()<cr>
  nmap <buffer> <Leader>s :call CVSFindFile()<cr>:call CVSstatus()<cr>
  nmap <buffer> <Leader>h :call CVSFindFile()<cr>:call CVSshortstatus()<cr>
  nmap <buffer> <Leader>c :call CVSFindFile()<cr>:call CVSlocalstatus()<cr>
  nmap <buffer> <Leader>v :call CVSFindFile()<cr>:call CVSrevertchanges()<cr>
endfunction

function! CVSShowMapping()
  echo 'Mappings in output buffer :'
  echo '<2-LeftMouse> , <SHIFT-CR>      : open file in new buffer'
  echo 'q                               : close output buffer'
  echo '?                               : close output buffer'
  echo '<Leader>a                       : Show this help'
  echo '<Leader>d                       : open file and CVSdiff'
  echo '<Leader>i                       : open file and CVScommit'
  echo '<Leader>u                       : open file and CVSupdate'
  echo '<Leader>s                       : open file and CVSstatus'
  echo '<Leader>h                       : open file and CVSshortstatus'
  echo '<Leader>c                       : open file and CVSlocalstatus'
  echo '<Leader>v                       : open file and CVSrevertchanges'
endfunction

function! CVSFindFile()
  let curdir = getcwd()
  exec 'cd '.g:workdir
  normal 0W
  exec 'cd '.curdir
  unlet curdir
endfunction

"-----------------------------------------------------------------------------
" sort output		{{{1
"-----------------------------------------------------------------------------

" move all lines matching "searchstr" to top
function! CVSMoveToTop(searchstr)
  silent exec 'g/'.a:searchstr.'/m0'
endfunction

" only called by CVSShortStatus
function! CVSSortStatusOutput()
  " allow changes
  call CVSMakeRW()
  call CVSMoveToTop('Status: Unknown$')
  call CVSMoveToTop('Status: Needs Checkout$')
  call CVSMoveToTop('Status: Needs Merge$')
  call CVSMoveToTop('Status: Needs Patch$')
  call CVSMoveToTop('Status: Locally Removed$')
  call CVSMoveToTop('Status: Locally Added$')
  call CVSMoveToTop('Status: Locally Modified$')
  call CVSMoveToTop('Status: File had conflicts on merge$')
endfunction

" called by CVSDoCommand
function! CVSSortOutput()
  " allow changes
  call CVSMakeRW()
  " localstatus
  call CVSMoveToTop('^unknown:')
  call CVSMoveToTop('^unchanged:')
  call CVSMoveToTop('^missing:')
  call CVSMoveToTop('^modified:')
  " org cvs
  call CVSMoveToTop('^? ')	" unknown
  call CVSMoveToTop('^T ')	" tag
  call CVSMoveToTop('^D ')	" delete
  call CVSMoveToTop('^N ')	" new
  call CVSMoveToTop('^U ')	" update
  call CVSMoveToTop('^M ')	" merge
  call CVSMoveToTop('^P ')	" patch
  call CVSMoveToTop('^C ')	" conflict
endfunction

"-----------------------------------------------------------------------------
" status variables		{{{1
"-----------------------------------------------------------------------------

function! CVSSaveOpts()
  let s:CVSROOTbak            = $CVSROOT
  let s:CVS_RSHbak            = $CVS_RSH
  let s:CVSOPTbak             = $CVSOPT
  let s:CVSCMDOPTbak          = $CVSCMDOPT
  let s:CVSCMDbak             = $CVSCMD
  let s:CVSforcedirectorybak  = g:CVSforcedirectory
  let s:CVSqueryrevisionbak   = g:CVSqueryrevision
  let s:CVSdumpandclosebak    = g:CVSdumpandclose
  let g:CVSsortoutputbak	= g:CVSsortoutput
  let g:CVScompressoutputbak	= g:CVScompressoutput
  let g:CVStitlebarbak		= g:CVStitlebar
  let g:CVSstatuslinebak	= g:CVSstatusline
  let g:CVSautocheckbak		= g:CVSautocheck
  let g:CVSofferrevisionbak	= g:CVSofferrevision
  let g:CVSsavediffbak		= g:CVSsavediff
  let g:CVSdontswitchbak	= g:CVSdontswitch
endfunction

function! CVSRestoreOpts()
  let $CVSROOT                = s:CVSROOTbak          
  let $CVS_RSH                = s:CVS_RSHbak          
  let $CVSOPT                 = s:CVSOPTbak           
  let $CVSCMDOPT              = s:CVSCMDOPTbak        
  let $CVSCMD                 = s:CVSCMDbak           
  let g:CVSforcedirectory     = s:CVSforcedirectorybak
  let g:CVSqueryrevision      = s:CVSqueryrevisionbak 
  let g:CVSdumpandclose       = s:CVSdumpandclosebak  
  let g:CVSsortoutput		= g:CVSsortoutputbak
  let g:CVScompressoutput	= g:CVScompressoutputbak
  let g:CVStitlebar		= g:CVStitlebarbak
  let g:CVSstatusline		= g:CVSstatuslinebak
  let g:CVSautocheck		= g:CVSautocheckbak
  let g:CVSofferrevision	= g:CVSofferrevisionbak
  let g:CVSsavediff		= g:CVSsavediffbak
  let g:CVSdontswitch		= g:CVSdontswitchbak
  unlet g:CVSsortoutputbak g:CVScompressoutputbak g:CVStitlebarbak
  unlet g:CVSstatuslinebak g:CVSautocheckbak g:CVSofferrevisionbak
  unlet g:CVSsavediffbak g:CVSdontswitchbak
  unlet s:CVSROOTbak s:CVS_RSHbak s:CVSOPTbak s:CVSCMDOPTbak s:CVSCMDbak
  unlet s:CVSforcedirectorybak s:CVSqueryrevisionbak s:CVSdumpandclosebak
endfunction

" set scope : file or directory, inform user
function! CVSSetForceDir(value)
  let g:CVSforcedirectory=a:value
  if g:CVSforcedirectory==1
    echo 'CVS:Using current DIRECTORY once'
  elseif g:CVSforcedirectory==2
    echo 'CVS:Using current DIRECTORY'
  else
    echo 'CVS:Using current buffer'
  endif
endfunction

" Set output to statusline, close output buffer
function! CVSSetDumpAndClose(value)
  if a:value > 1
    echo 'CVS:output to status(file) and buffer(dir)'
  elseif a:value > 0
    echo 'CVS:output to statusline'
  else
    echo 'CVS:output to buffer'
  endif
  let g:CVSdumpandclose = a:value
endfunction

" enable/disable revs/branchs queries
function! CVSSetQueryRevision(value)
  if a:value > 0
    echo 'CVS:Enabled revision queries'
  else
    echo 'CVS:Not asking for revisions'
  endif
  let g:CVSqueryrevision = a:value
endfunction

" Sort output (group conflicts,updates,...)
function! CVSSetSortOutput(value)
  if a:value > 0
    echo 'CVS:sorting output'
  else
    echo 'CVS:unsorted output'
  endif
  let g:CVSsortoutput = a:value
endfunction

" compress output to one line
function! CVSSetCompressOutput(value)
  if a:value > 0
    echo 'CVS:compressed output'
  else
    echo 'CVS:full output'
  endif
  let g:CVScompressoutput = a:value
endfunction

" output to statusline
function! CVSSetStatusline(value)
  if a:value > 0
    echo 'CVS:output to statusline'
  else
    echo 'CVS:no output to statusline'
  endif
  let g:CVSstatusline = a:value
endfunction

" output to titlebar
function! CVSSetTitlebar(value)
  if a:value > 0
    echo 'CVS:output to titlebar'
  else
    echo 'CVS:no output to titlebar'
  endif
  let g:CVStitlebar = a:value
endfunction

" show local status (autocheck)
function! CVSSetAutocheck(value)
  if a:value > 0
    echo 'CVS:autochecking each file'
  else
    echo 'CVS:autocheck disabled'
  endif
  let g:CVSautocheck = a:value
endfunction

" show current revision as default, when asking for it
function! CVSSetOfferRevision(value)
  if a:value > 0
    echo 'CVS:offering current revision'
  else
    echo 'CVS:not offering current revision'
  endif
  let g:CVSofferrevision = a:value
endfunction

" CVSDiff : activate original or checked-out
function! CVSSetDontSwitch(value)
  if a:value > 0
    echo 'CVS:switching to compared file'
  else
    echo 'CVS:stay in original when diffing'
  endif
  let g:CVSdontswitch = a:value
endfunction

" save settings when using :diff
function! CVSSetSaveDiff(value)
  if a:value > 0
    echo 'CVS:saving settings for :diff'
  else
    echo 'CVS:not saving settings for :diff'
  endif
  let g:CVSsavediff = a:value
endfunction

function! CVSChDir(path)
  let g:orgpath = getcwd()
  let g:workdir = expand("%:p:h")
  exec 'cd '.a:path
endfunction

function! CVSRestoreDir()
  if isdirectory(g:orgpath)
    exec 'cd '.g:orgpath
  endif
endfunction

"}}}
"#############################################################################
" CVS commands
"#############################################################################
"-----------------------------------------------------------------------------
" CVS call		{{{1
"-----------------------------------------------------------------------------

" return > 0 if is win 95-me
function! CVSIsW9x()
  return (has("win32") && (match($COMSPEC,"command\.com") > -1))
endfunction

function! CVSDoCommand(cmd,...)
  " needs to be called from orgbuffer
  let isfile = CVSUsesFile()
  " change to buffers directory
  "exec 'cd '.expand('%:p:h')
  call CVSChDir(expand('%:p:h'))
  " get file/directory to work on (if not given)
  if a:0 < 1
    if g:CVSforcedirectory>0
      let filename=''
    else
      let filename=expand('%:p:t')
    endif
  else
    let filename = a:1
  endif
  " problem with win98se : system() gives an error
  " cannot open 'F:\WIN98\TEMP\VIo9134.TMP'
  " piping the password also seems to fail (maybe caused by cvs.exe)
  " Using 'exec' creates a confirm prompt - only use this s**t on w9x
  if CVSIsW9x()
    let tmp=tempname()
    exec '!'.$CVSCMD.' '.$CVSOPT.' '.a:cmd.' '.$CVSCMDOPT.' '.filename.'>'.tmp
    exec 'split '.tmp
    let dummy=delete(tmp)
    unlet tmp dummy
  else
    let regbak=@z
    let @z=system($CVSCMD.' '.$CVSOPT.' '.a:cmd.' '.$CVSCMDOPT.' '.filename)
    new
    silent normal "zP
    let @z=regbak
  endif
  call CVSProcessOutput(isfile, filename, a:cmd)
  call CVSRestoreDir()
  unlet filename
endfunction

" also jumped in by CVSLocalStatus
function! CVSProcessOutput(isfile,filename,cmd)
  " delete leading and trainling blank lines
  while (getline(1) == '') && (line("$")>1)
    silent exec '0d'
  endwhile
  while (getline("$") == '') && (line("$")>1)
    silent exec '$d'
  endwhile
  " group conflicts, updates, ....
  if g:CVSsortoutput > 0
    silent call CVSSortOutput()
  endif
  " compress output ?
  if g:CVScompressoutput > 0
    if (g:CVSdumpandclose > 0) && a:isfile
      silent call CVSCompressOutput(a:cmd)
    endif
  endif
  " move to top
  normal gg
  set nowrap
  " reset single shot flag
  if g:CVSforcedirectory==1
    let g:CVSforcedirectory = 0
  endif
  call CVSMakeRO()
  if (g:CVSdumpandclose == 1) || ((g:CVSdumpandclose == 2) && a:isfile)
    call CVSDumpAndClose()
  else
    call CVSUpdateMapping()
    call CVSUpdateSyntax()
  endif
endfunction

" return: 1=file 0=dir
function! CVSUsesFile()
  let filename=expand("%:p:t")
  if    ((g:CVSforcedirectory == 0) && (filename != ''))
   \ || ((g:CVSforcedirectory > 0) && (filename == ''))
    return 1
  else
    return 0
  endif
  unlet filename
endfunction

" compress output
function! CVSCompressOutput(cmd)
    " commit
    if match(a:cmd,"commit") > -1
      let v:errmsg = ''
      silent! exec '/^cvs \[commit aborted]:'
      " only compress, if no error found
      if v:errmsg != ''
	silent! exec 'g!/^new revision:/d'
      endif
    " skip localstatus
    elseif (match(a:cmd,"localstatus") > -1)
    " status
    elseif (match(a:cmd,"status") > -1)
      silent! exec 'g/^=\+$/d'
      silent! exec 'g/^$/d'
      silent! exec '%s/.*Status: //'
      silent! exec '%s/^\s\+Working revision:\s\+\([0-9.]*\).*/W:\1/'
      silent! exec '%s/^\s\+Repository revision:\s\+\([0-9.]*\).*/R:\1/'
      silent! exec '%s/^\s\+Sticky Tag:\s\+/T:/'
      silent! exec '%s/^\s\+Sticky Date:\s\+/D:/'
      silent! exec '%s/^\s\+Sticky Options:\s\+/O:/'
      silent! normal ggJJJJJJ
    endif
endfunction

"#############################################################################
" following commands read from STDIN. Call CVS directly
"#############################################################################

"-----------------------------------------------------------------------------
" CVS login / logout (password prompt)		{{{1
"-----------------------------------------------------------------------------

function! CVSlogin(...)
  if a:0 == 0
    let pwpipe = ''
  else
    let pwpipe = 'echo '
    if !has("unix") 
      if a:1 == ''
        let pwpipe = pwpipe . '.'
      endif
    endif
    let pwpipe = pwpipe . a:1 . '|'
  endif
  if has("unix")
    " show password prompt 
    exec '!'.pwpipe.$CVSCMD.' '.$CVSOPT.' login '.$CVSCMDOPT
  else
    " shell is opened in win32 (dos?)
    silent! exec '!'.pwpipe.$CVSCMD.' '.$CVSOPT.' login '.$CVSCMDOPT
  endif
endfunction

function! CVSlogout()
  silent! exec '!'.$CVSCMD.' '.$CVSOPT.' logout '.$CVSCMDOPT
endfunction

"-----------------------------------------------------------------------------
" CVS release (confirmation prompt)		{{{1
"-----------------------------------------------------------------------------

function! CVSrelease()
  let localtoo=input('Release:Also delete local file [y]:')
  if (localtoo=='y') || (localtoo=='')
    let localtoo='-d '
  else
    let localtoo=''
  endif
  let releasedir=expand('%:p:h')
  "exec ':cd ..'
  call CVSChDir(releasedir.s:sep.'..')
  " confirmation prompt -> dont use CVSDoCommand
  if has("unix")
    " show confirmation prompt
    exec '!'.$CVSCMD.' '.$CVSOPT.' release '.localtoo.releasedir.' '.$CVSCMDOPT
  else
    silent! exec '!'.$CVSCMD.' '.$CVSOPT.' release '.localtoo.releasedir.' '.$CVSCMDOPT
  endif
  call CVSRestoreDir()
  unlet localtoo releasedir
endfunction

"#############################################################################
" from here : use CVSDoCommand wrapper
"#############################################################################

"-----------------------------------------------------------------------------
" CVS diff (diffsplit)		{{{1
"-----------------------------------------------------------------------------

" parm : revision
function! CVSdiff(...)
  if g:CVSsavediff > 0
    call CVSDiffEnter()
  endif
  let orgcwd = getcwd()
  exec 'cd '.expand('%:p:h')
  let outputbak = g:CVSdumpandclose
  let autocheckbak = g:CVSautocheck
  let g:CVSautocheck = 0
  let g:CVSdumpandclose = 0
  let g:CVSautocheck = 0
  let g:CVSdumpandclose = 0
  let orgfiletype = &filetype
  " query revision (if wanted)
  if a:0 != ''
    let rev = a:1
  elseif g:CVSqueryrevision > 0
    let rev=CVSInputRev('Revision (optional):')
  else 
    let rev=''
  endif
  " tempname() would be deleted before diff (linux)!
  " it is also better to show selected revision
  let tmpnam=expand("%").'.'.rev.'_'.localtime().'.dif'
  if rev!=''
    let rev='-r '.rev.' '
  endif
  call CVSDoCommand('update -p '.rev)
  redraw
  " delete stderr ('checking out...')
  call CVSStripHeader()
  call CVSMakeRO()
  " x! did not write before diffing (linux)!
  exec "w! ".tmpnam
  bwipeout
  wincmd _
  " jump to next diff (current buffer)
  silent! nmap <unique> <buffer> <tab> ]c
  silent! nmap <unique> <buffer> <s-tab> [c
  redraw
  exec 'vertical diffsplit '.tmpnam
  let &filetype = orgfiletype
  " jump to next diff (diffed buffer)
  silent! nmap <unique> <buffer> <tab> ]c
  silent! nmap <unique> <buffer> <s-tab> [c
  silent! nmap <unique> <buffer> q :bwipeout<cr>
  let dummy=delete(tmpnam)
  if g:CVSdontswitch > 0
    redraw
    wincmd 
  endif
  exec 'cd '.orgcwd
  let g:CVSdumpandclose = outputbak
  let g:CVSautocheck = autocheckbak 
  unlet outputbak autocheckbak
  unlet tmpnam rev orgfiletype
endfunction

" diff to a specific revision
function! CVSdifftorev()
  " Force revision input
  let rev=CVSInputRev('Revision:')
  if rev==''
    echo "CVS diff to revision: aborted"
    return
  endif
  call CVSdiff(rev)
  unlet rev
endfunction

"-----------------------------------------------------------------------------
" CVS diff / patchfile		{{{1
"-----------------------------------------------------------------------------
function! CVSgetdiff(parm)
  call CVSSaveOpts()
  let g:CVSdumpandclose = 0
  let g:CVStitlebar = 1			" Notification output to titlebar
  " query revision
  let rev=CVSInputRev('Revision (optional):')
  if rev!=''
    let rev=' -r '.rev.' '
  endif
  call CVSDoCommand('diff '.a:parm.rev)
  set syntax=diff
  call CVSRestoreOpts()
  unlet rev
endfunction

function! CVSdiffcontext()
  call CVSgetdiff('-c')
endfunction

function! CVSdiffstandard()
  call CVSgetdiff('')
endfunction

function! CVSdiffuni()
  call CVSgetdiff('-u')
endfunction


"-----------------------------------------------------------------------------
" CVS annotate / log / status / history		{{{1
"-----------------------------------------------------------------------------

function! CVSannotate()
  call CVSDoCommand('annotate',expand('%:p:t'))
  wincmd _
endfunction

function! CVSstatus()
  call CVSDoCommand('status')
endfunction

function! CVShistory()
  call CVSSaveOpts()
  let g:CVSdumpandclose = 0
  call CVSDoCommand('history')
  call CVSRestoreOpts()
endfunction

function! CVSlog()
  call CVSSaveOpts()
  let g:CVSdumpandclose = 0
  if g:CVSqueryrevision > 0
    if g:CVSofferrevision > 0
      let default = '1.1:'.CVSSubstr(b:CVSentry,'/',2)
    else
      let default = ''
    endif
    let rev=input('Revisions (optional): ',default)
  else 
    let rev=''
  endif
  if rev!=''
    let rev=' -r'.rev.' '
  endif
  call CVSDoCommand('log'.rev)
  call CVSRestoreOpts()
endfunction

" log between specific revisions
function! CVSlogtorev()
  let querybak=g:CVSqueryrevision
  let g:CVSqueryrevision = 1
  call CVSlog()
  let g:CVSqueryrevision=querybak
  unlet querybak
endfunction

"-----------------------------------------------------------------------------
" CVS watch / edit : common		{{{1
"-----------------------------------------------------------------------------

function! CVSQueryAction()
  let action=input('Action (e)dit, (u)nedit, (c)ommit, (a)ll, [n]one:')
  if action == 'e'
    let action = '-a edit '
  elseif action == 'u'
    let action = '-a unedit '
  elseif action == 'a'
    let action = '-a all '
  else
    let action = ''
  endif
  return action
endfunction

"-----------------------------------------------------------------------------
" CVS edit		{{{1
"-----------------------------------------------------------------------------

function! CVSwatcheditors()
  call CVSDoCommand('editors')
endfunction

function! CVSwatchedit()
  let action=CVSQueryAction()
  call CVSDoCommand('edit '.action)
  unlet action
endfunction

function! CVSwatchunedit()
  call CVSDoCommand('unedit')
endfunction

"-----------------------------------------------------------------------------
" CVS watch		{{{1
"-----------------------------------------------------------------------------

function! CVSwatchwatchers()
  call CVSDoCommand('watchers')
endfunction

function! CVSwatchadd()
  let action=CVSQueryAction()
  call CVSDoCommand('watch add '.action)
  unlet action
endfunction

function! CVSwatchremove()
  call CVSDoCommand('watch remove')
endfunction

function! CVSwatchon()
  call CVSDoCommand('watch on')
endfunction

function! CVSwatchoff()
  call CVSDoCommand('watch off')
endfunction
                       
"-----------------------------------------------------------------------------
" CVS tag		{{{1
"-----------------------------------------------------------------------------

function! CVSDoTag(usertag,tagopt)
  " force tagname input
  let tagname=escape(input('tagname:'),'"<>|&')
  if tagname==''
    echo 'CVS tag: aborted'
    return
  endif
  " if rtag, force module instead local copy
  if a:usertag > 0
    let tagcmd = 'rtag '
    let module = input('Enter module name:')
    if module == ''
      echo 'CVS rtag: aborted'
      return
    endif
    let target = module
    unlet module
  else
    let tagcmd = 'tag '
    let target = ''
  endif
  " g:CVSqueryrevision ?
  " tag by date, revision or local
  let tagby=input('Tag by (d)ate, (r)evision (default:none):')
  if (tagby == 'd')
    let tagby='-D '
    let tagwhat=input('Enter date:')
  elseif (tagby == 'r')
    let tagby='-r '
    let tagwhat=CVSInputRev('Revision (optional):')
  else 
    let tagby = ''
  endif
  " input date / revision
  if tagby != ''
    if tagwhat == ''
      echo 'CVS tag: aborted'
      return
    else
      let tagwhat = tagby.tagwhat.' '
    endif
  else
    let tagwhat = ''
  endif
  " check if working file is unchanged (if not rtag)
  if a:usertag == 0
    let checksync=input('Override sync check [n]:')
    if (checksync == 'n') || (checksync == '')
      let checksync='-c '
    else
      let checksync=''
    endif
  else
    let checksync=''
  endif
  call CVSDoCommand(tagcmd.' '.a:tagopt.checksync.tagwhat.tagname,target)
  unlet checksync tagname tagcmd tagby tagwhat target
endfunction

" tag local copy (usertag=0)
function! CVStag()
  call CVSDoTag(0,'')
endfunction

function! CVStagremove()
  call CVSDoTag(0,'-d ')
endfunction

function! CVSbranch()
  call CVSDoTag(0,'-b ')
endfunction

" tag module (usertag=1)
function! CVSrtag()
  call CVSDoTag(1,'')
endfunction

function! CVSrtagremove()
  call CVSDoTag(1,'-d ')
endfunction

function! CVSrbranch()
  call CVSDoTag(1,'-b ',)
endfunction

"-----------------------------------------------------------------------------
" CVS update / query update		{{{1
"-----------------------------------------------------------------------------

function! CVSupdate()
  " ask for revisions to merge/join (if wanted)
  if g:CVSqueryrevision > 0
    let rev=CVSInputRev('Revision (optional):')
    if rev!=''
      let rev='-r '.rev.' '
    endif
    let mergerevstart=CVSInputRev('Merge from 1st Revision (optional):')
    if mergerevstart!=''
      let mergerevstart='-j '.mergerevstart.' '
    endif
    let mergerevend=CVSInputRev('Merge from 2nd Revision (optional):')
    if mergerevend!=''
      let mergerevend='-j '.mergerevend.' '
    endif
  else
    let rev = ''
    let mergerevstart = ''
    let mergerevend = ''
  endif
  " update or query
  if s:CVSupdatequeryonly > 0
    call CVSDoCommand('-n update -P '.rev.mergerevstart.mergerevend)
  else
    call CVSDoCommand('update '.rev.mergerevstart.mergerevend)
  endif
  unlet rev mergerevstart mergerevend
endfunction

function! CVSqueryupdate()
  let s:CVSupdatequeryonly = 1
  call CVSupdate()
  let s:CVSupdatequeryonly = 0
endfunction

function! CVSupdatetorev()
  " Force revision input
  let rev=CVSInputRev('Revision:')
  if rev==''
    echo "CVS Update to revision: aborted"
    return
  endif
  let rev='-r '.rev.' '
  " save old state
  call CVSSaveOpts()
  let $CVSCMDOPT=rev
  " call update
  call CVSupdate()
  " restore options
  call CVSRestoreOpts()
  unlet rev
endfunction

function! CVSupdatemergerev()
  " Force revision input
  let mergerevstart=CVSInputRev('Merge from 1st Revision:')
  if mergerevstart==''
    echo "CVS merge revision: aborted"
    return
  endif
  let mergerevstart='-j '.mergerevstart.' '
  " save old state
  call CVSSaveOpts()
  let $CVSCMDOPT=mergerevstart
  " call update
  call CVSupdate()
  " restore options
  call CVSRestoreOpts()
  unlet mergerevstart
endfunction

function! CVSupdatemergediff()
  " Force revision input
  let mergerevstart=CVSInputRev('Merge from 1st Revision:')
  if mergerevstart==''
    echo "CVS merge revision diffs: aborted"
    return
  endif
  let mergerevend=CVSInputRev('Merge from 2nd Revision:')
  if mergerevend==''
    echo "CVS merge revision diffs: aborted"
    return
  endif
  let mergerevstart='-j '.mergerevstart.' '
  let mergerevend='-j '.mergerevend.' '
  " save old state
  call CVSSaveOpts()
  let $CVSCMDOPT=mergerevstart.mergerevend
  " call update
  call CVSupdate()
  " restore options
  call CVSRestoreOpts()
endfunction

"-----------------------------------------------------------------------------
" CVS remove (request confirmation)		{{{1
"-----------------------------------------------------------------------------

function! CVSremove()
  " remove from rep. also local ?
  if g:CVSforcedirectory>0
    let localtoo=input('Remove:Also delete local DIRECTORY [y]:')
  else
    let localtoo=input('Remove:Also delete local file [y]:')
  endif
  if (localtoo=='y') || (localtoo=='')
    let localtoo='-f '
  else
    let localtoo=''
  endif
  " force confirmation
  let confrm=input('Remove:confirm with "y":')
  if confrm!='y'
    echo 'CVS remove: aborted'
    return
  endif
  call CVSDoCommand('remove '.localtoo)
  unlet localtoo
endfunction

"-----------------------------------------------------------------------------
" CVS add		{{{1
"-----------------------------------------------------------------------------

function! CVSadd()
  if (g:CVSusedefaultmsg =~ 'a') && (g:CVSdefaultmsg != '')
    let message = g:CVSdefaultmsg
  else
    " force message input
    let message=escape(input('Message:'),'"<>|&')
  endif
  if message==""
    echo 'CVS add: aborted'
    return
  endif
  call CVSDoCommand('add -m "'.message.'"')
  unlet message
endfunction

"-----------------------------------------------------------------------------
" CVS commit		{{{1
"-----------------------------------------------------------------------------

function! CVScommit()
  if (g:CVSusedefaultmsg =~ 'i') && (g:CVSdefaultmsg != '')
    let message = g:CVSdefaultmsg
  else
    " force message input
    let message=escape(input('Message:'),'"<>|&')
  endif
  if message==''
    echo 'CVS commit: aborted'
    return
  endif
  " query revision (if wanted)
  if g:CVSqueryrevision > 0
    let rev=CVSInputRev('Revision (optional):')
  else 
    let rev=''
  endif
  if rev!=''
    let rev='-r '.rev.' '
  endif
  call CVSDoCommand('commit -m "'.message.'" '.rev)
  unlet message rev
endfunction

function! CVScommitrevision()
  let querybak=g:CVSqueryrevision
  let g:CVSqueryrevision=1
  call CVScommit()
  let g:CVSqueryrevision=querybak
endfunction

"-----------------------------------------------------------------------------
" CVS join in		{{{1
"-----------------------------------------------------------------------------

function! CVSjoinin(...)
  if a:0 == 1
    let message = a:1
  elseif (g:CVSusedefaultmsg =~ 'j') && (g:CVSdefaultmsg != '')
    let message = g:CVSdefaultmsg
  else
    " force message input
    let message=escape(input('Message:'),'"<>|&')
    if message==""
      echo 'CVS add/commit: aborted'
      return
    endif
  endif
  " query revision (if wanted)
  if g:CVSqueryrevision > 0
    let rev=CVSInputRev('Revision (optional):')
  else 
    let rev=''
  endif
  if rev!=''
    let rev='-r '.rev.' '
  endif
  call CVSDoCommand('add -m "'.message.'"')
  call CVSDoCommand('commit -m "'.message.'" '.rev)
  call CVSLocalStatus()
  unlet message rev
endfunction

function! CVSjoininrevision()
  let querybak=g:CVSqueryrevision
  let g:CVSqueryrevision=1
  call CVSjoinin()
  let g:CVSqueryrevision=querybak
endfunction

"-----------------------------------------------------------------------------
" CVS import		{{{1
"-----------------------------------------------------------------------------

function! CVSimport()
  if (g:CVSusedefaultmsg =~ 'p') && (g:CVSdefaultmsg != '')
    let message = g:CVSdefaultmsg
  else
    " force message input
    let message=escape(input('Message:'),'"<>|&')
  endif
  if message==''
    echo 'CVS import: aborted'
    return
  endif
  " query branch (if wanted)
  if g:CVSqueryrevision > 0
    let rev=input('Branch (optional):')
  else 
    let rev=''
  endif
  if rev!=''
    let rev='-b '.rev.' '
  endif
  " query vendor tag
  let vendor=input('Vendor tag:')
  if vendor==''
    echo 'CVS import: aborted'
    return
  endif
  " query release tag
  let release=input('Release tag:')
  if release==''
    echo 'CVS import: aborted'
    return
  endif
  " query module
  let module=input('Module:')
  if module==''
    echo 'CVS import: aborted'
    return
  endif
  " only works on directories
  call CVSDoCommand('import -m "'.message.'" '.rev.module.' '.vendor.' '.release)
  unlet message rev vendor release
endfunction

function! CVSimportrevision()
  let querybak=g:CVSqueryrevision
  let g:CVSqueryrevision=1
  call CVSimport()
  let g:CVSqueryrevision=querybak
endfunction

"-----------------------------------------------------------------------------
" CVS checkout		{{{1
"-----------------------------------------------------------------------------

function! CVScheckout()
  let destdir=expand('%:p:h')
  let destdir=input('Checkout to:',destdir)
  if destdir==''
    return
  endif
  let module=input('Module name:')
  if module==''
    echo 'CVS checkout: aborted'
    return
  endif
  " query revision (if wanted)
  if g:CVSqueryrevision > 0
    let rev=CVSInputRev('Revision (optional):')
  else 
    let rev=''
  endif
  if rev!=''
    let rev='-r '.rev.' '
  endif
  call CVSDoCommand('checkout '.rev.module)
  unlet destdir module rev
endfunction

function! CVScheckoutrevision()
  let querybak=g:CVSqueryrevision
  let g:CVSqueryrevision=1
  call CVScheckout()
  let g:CVSqueryrevision=querybak
endfunction
"}}}
"#############################################################################
" extended commands
"#############################################################################
"-----------------------------------------------------------------------------
" revert changes, shortstatus		{{{1
"-----------------------------------------------------------------------------

function! CVSrevertchanges()
  let filename=expand("%:p:t")
  call CVSChDir(expand("%:p:h"))
  if filename == ''
    echo 'Revert changes:only on files'
    return
  endif
  if delete(filename) != 0
    echo 'Revert changes:could not delete file'
    return
  endif
  call CVSSaveOpts()
  let $CVSCMDOPT='-A '
  call CVSupdate()
  call CVSRestoreOpts()
  call CVSRestoreDir()
endfunction

" get status info, compress it (one line/file), sort by status
function! CVSshortstatus()
  let isfile = CVSUsesFile()
  " save flags
  let filename = expand("%:p:t")
  let savedump = g:CVSdumpandclose
  let forcedirbak = g:CVSforcedirectory
  " output needed
  let g:CVSdumpandclose=0
  silent call CVSstatus()
  call CVSMakeRW()
  silent call CVSCompressStatus()
  if g:CVSsortoutput > 0
    silent call CVSSortStatusOutput()
  endif
  normal gg
  call CVSMakeRO()
  " restore flags
  let g:CVSdumpandclose = savedump
  if forcedirbak == 1
    let g:CVSforcedirectory = 0
  else
    let g:CVSforcedirectory = forcedirbak
  endif
  if   (g:CVSdumpandclose == 1) || ((g:CVSdumpandclose == 2) && isfile)
    call CVSDumpAndClose()
  endif
  unlet savedump forcedirbak filename isfile
endfunction

"-----------------------------------------------------------------------------
" tools: output processing, input query		{{{1
"-----------------------------------------------------------------------------

" Dump output to statusline, close output buffer
function! CVSDumpAndClose()
  " collect in reg. z first, otherwise func
  " will terminate, if user stops output with "q"
  let curlin=1
  let regbak=@z
  let @z = getline(curlin)
  while curlin < line("$")
    let curlin = curlin + 1
    let @z = @z . "\n" . getline(curlin)
  endwhile
  " appends \n on winnt
  "exec ":1,$y z"
  set nomodified
  bwipeout
  if g:CVSstatusline
    redraw
    " statusline may be cleared otherwise
    echo @z
  endif
  if g:CVStitlebar
    let cleantitle = substitute(@z,'\t\|\r\|\s\{2,\}',' ','g')
    let cleantitle = substitute(cleantitle,"\n",' ',"g")
    let &titlestring = '%F - '.cleantitle
    let b:CVSbuftitle = &titlestring
    unlet cleantitle
  endif
  let @z=regbak
endfunction

" leave only leading line with status info (for CVSShortStatus)
function! CVSCompressStatus()
  exec 'g!/^File:\|?/d'
endfunction

" delete stderr ('checking out...')
" CVS checkout ends with ***************(15)
function! CVSStripHeader()
  call CVSMakeRW()
  silent! exec '1,/^\*\{15}$/d'
endfunction

function! CVSInputRev(...)
  if !exists("b:CVSentry")
    let b:CVSentry = ''
  endif
  if a:0 == 1
    let query = a:1
  else
    let query = ''
  endif
  if g:CVSofferrevision > 0
    let default = CVSSubstr(b:CVSentry,'/',2)
  else
    let default = ''
  endif
  return input(query,default)
endfunction

"-----------------------------------------------------------------------------
" quick get file.		{{{1
"-----------------------------------------------------------------------------

function! CVSGet(...)
  " Params :
  " 0:ask file,rep
  " 1:filename
  " 2:repository
  " 3:string:i=login,o=logout
  " 4:string:login password
  " save flags, do not destroy CVSSaveOpts
  let cvsoptbak=$CVSCMDOPT
  let outputbak=g:CVSdumpandclose
    let rep=''
    let log=''
  " eval params
  if     a:0 > 2	" file,rep,logflag[,logpw]
    let fn  = a:1
    let rep = a:2
    let log = a:3
  elseif a:0 > 1	" file,rep
    let fn  = a:1
    let rep = a:2
  elseif a:0 > 0	" file: (use current rep) 
    let fn  = a:1
  endif
  if fn == ''		" no name:query file and rep
    let rep=input("CVSROOT:")
    let fn=input("Filename:")
  endif
  " still no filename : abort
  if fn == ''
    echo "CVS Get: aborted"
  else
    " prepare param
    if rep != ''
      let $CVSOPT = '-d'.rep
    endif
    " no output windows
    let g:CVSdumpandclose=0
    " login
    if match(log,'i') > -1
      if (a:0 == 4)	" login with pw (if given)
        call CVSlogin(a:4)
      else
        call CVSlogin()
      endif
    endif
    " get file
    call CVSDoCommand('checkout -p',fn)
    " delete stderr ('checking out...')
    if !CVSIsW9x()
      call CVSStripHeader()
    endif
    set nomodified
    " logout
    if match(log,'o') > -1
      call CVSlogout()
    endif
  endif
  " restore flags, cleanup
  let g:CVSdumpandclose=outputbak
  let $CVSOPT=cvsoptbak
  unlet fn rep outputbak cvsoptbak
endfunction

"-----------------------------------------------------------------------------
" Download help and install		{{{1
"-----------------------------------------------------------------------------

function! CVSInstallUpdates()
  if confirm("Install updates: Close all buffers, first !", 
           \ "&Cancel\n&Ok") < 2
    echo 'CVS Install updates: aborted'
    return
  endif
  call CVSDownloadUpdates()
  if match(getline(1),'^\*cvsmenu.txt\*') > -1
    call CVSInstallAsHelp('cvsmenu.txt')
    let helpres="Helpfile installed"
  else
    let helpres="Error: Helpfile not installed"
  endif
  bwipeout
  redraw
  if match(getline(1),'^" CVSmenu.vim :') > -1
    call CVSInstallAsPlugin('cvsmenu.vim')
    let plugres="Plugin installed"
  else
    let plugres="Error: Plugin not installed"
  endif
  bwipeout
  redraw
  echo helpres."\n".plugres
  echo "Changes take place in next vim session"
endfunction

function! CVSDownloadUpdates()
  call CVSGet('VimTools/cvsmenu.vim',s:cvsmenucvs,'i','')
  call CVSGet('VimTools/cvsmenu.txt',s:cvsmenucvs,'o','')
endfunction

function! CVSInstallAsHelp(...)
  " ask for name to save as (if not given)
  if (a:0 == 0) || (a:1 == '')
    let dest=input('Helpfilename (clear to abort):')
  else
    let dest=a:1
  endif
  " abort if still no filename
  if dest==''
    echo 'CVS Install help: aborted'
  else
    " create directories "~/.vim/doc" if needed
    call CVSAssureLocalDirs()
    " copy to local doc dir
    exec 'w! '.s:localvimdoc.'/'.dest
    " create tags
    exec 'helptags '.s:localvimdoc
  endif
  unlet dest
endfunction

function! CVSInstallAsPlugin(...)
  " ask for name to save as
  if (a:0 == 0) || (a:1 == '')
    let dest=input('Pluginfilename (clear to abort):',a:1)
  else
    let dest=a:1
  endif
  " abort if still no filename
  if dest==''
    echo 'CVS Install plugin: aborted'
  else
    " copy to plugin dir
    exec 'w! '.$VIMRUNTIME.'/plugin/'.dest
  endif
  unlet dest
endfunction

"-----------------------------------------------------------------------------
" user directories / CVSLinks		{{{1
"-----------------------------------------------------------------------------

function! CVSOpenLinks()
  let links=s:localvim.s:sep.'cvslinks.vim'
  call CVSAssureLocalDirs()
  if !filereadable(links)
    let @z = "\" ~/cvslinks.vim\n"
      \ . "\" move to a command and press <shift-cr> to execute it\n"
      \ . "\" (one-liners only).\n\n"
      \ . "nmap <buffer> <s-cr> :exec getline('.')<cr>\n"
      \ . "finish\n\n"
      \ . "\" add modifications below here\n\n"
      \ . "\" look for a new Vim\n"
      \ . "\" login, get latest Vim README.txt, logout\n"
      \ . "call CVSGet('vim/README.txt', ':pserver:anonymous@cvs.vim.org:/cvsroot/vim', 'io', '')\n\n"
      \ . "\" manual cvsmenu update (-> CVS.Settings.Install buffer as...)\n"
      \ . "\" login, get latest version of cvsmenu.vim\n"
      \ . "call CVSGet('VimTools/cvsmenu.vim',':pserver:anonymous@cvs.ezytools.sf.net:/cvsroot/ezytools','i','')\n"
      \ . "\" get latest cvsmenu.txt, logout\n"
      \ . "call CVSGet('VimTools/cvsmenu.vim',':pserver:anonymous@cvs.ezytools.sf.net:/cvsroot/ezytools','o','')\n\n"
      \ . "\" Get some help on this\n"
      \ . "help CVSFunctions"
    "exec ':cd '.s:localvim
    call CVSChDir(s:localvim)
    new
    normal "zP
    exec ':x '.links
    call CVSRestoreDir()
  endif
  if !filereadable(links)
    echo 'CVSLinks: cannot access '.links
    return
  endif
  exec ':sp '.links
  exec ':so %'
  unlet links
endfunction

function! CVSAssureLocalDirs()
  if !isdirectory(s:localvim)
    silent! exec '!mkdir '.s:localvim
  endif
  if !isdirectory(s:localvimdoc)
    silent! exec '!mkdir '.s:localvimdoc
  endif
endfunction

function! CVSGetFolderNames()
  if has("unix")
    " expands to /home/(user)
    let s:localvim=expand('~').s:sep.'.vim'
  else
    " expands to $HOME (must be set)
    if expand('~') == ''
      let s:localvim=$VIMRUNTIME
    else
      let s:localvim=expand('~').s:sep.'vimfiles'
    endif
  endif
  let s:localvimdoc=s:localvim.s:sep.'doc'
endfunction

"-----------------------------------------------------------------------------
" LocalStatus : read from CVS/Entries		{{{1
"-----------------------------------------------------------------------------

function! CVSLocalStatus()
  " needs to be called from orgbuffer
  let isfile = CVSUsesFile()
  " change to buffers directory
  "exec 'cd '.expand('%:p:h')
  call CVSChDir(expand('%:p:h'))
  if g:CVSforcedirectory>0
    let filename=expand('%:p:h')
  else
    let filename=expand('%:p:t')
  endif
  let regbak=@z
  let @z = CVSCompare(filename)
  new
  " seems to be a vim bug : when executed as autocommand when doing ':help', 
  " vim echoes 'not modidifiable'
  set modifiable
  normal "zP
  call CVSProcessOutput(isfile, filename, '*localstatus')
  let @z=regbak
  call CVSRestoreDir()
  unlet filename
endfunction

" get info from CVS/Entries about given/current buffer/dir
function! CVSCompare(...)
  " return, if no CVS dir
  if !filereadable(s:CVSentries)
    echo 'No '.s:CVSentries.' !'
    return
  endif
  " eval params
  if (a:0 == 1) && (a:1 != '')
    if filereadable(a:1)
      let filename = a:1
      let dirname  = ''
    else
      let filename = ''
      let dirname  = a:1
    endif
  else
    let filename = expand("%:p:t")
    let dirname  = expand("%:p:h")
  endif
  let result = ''
  if filename == ''
    let result = CVSGetLocalDirStatus(dirname)
  else
    let result = CVSGetLocalStatus(filename)
  endif  " filename given
  return result
endfunction

" get info from CVS/Entries about given file/current buffer
function! CVSGetLocalStatus(...)
  if a:0 == 0
    let filename = expand("%:p:t")
  else
    let filename = a:1
  endif
  if filename == ''
    return 'error:no filename'
  endif
  if a:0 > 1
    let entry=a:2
  else
    let entry=CVSGetEntry(filename)
  endif
  let b:CVSentry=entry
  let status = ''
  if entry == ''
    if isdirectory(filename)
      let status = "unknown:   <DIR>\t".filename"
    else
      let status = 'unknown:   '.filename
    endif
  else
    let entryver  = CVSSubstr(entry,'/',2)
    let entryopt  = CVSSubstr(entry,'/',4)
    let entrytag  = CVSSubstr(entry,'/',5)
    let entrytime = CVStimeToStr(entry)
    if (!CVSUsesFile()) || (g:CVSfullstatus > 0)
      let status = filename."\t".entryver." ".entrytime." ".entryopt." ".entrytag
    else
      let status = entryver." ".entrytag." ".entryopt
    endif
    if !filereadable(filename)
      if isdirectory(filename)
        let status = 'directory: '.filename
      else
	if entry[0] == 'D'
          let status = "missing:   <DIR>\t".filename
	else
          let status = 'missing:   '.status
	endif
      endif
    else
      if entrytime == CVSFiletimeToStr(filename)
	let status = 'unchanged: '.status
      else
	let status = 'modified:  '.status
      endif " time identical
    endif " file exists
    if CVSUsesFile()
      let status = substitute(status,':','','g')
      let status = substitute(status,'\s\{2,}',' ','g')
    endif
  endif  " entry found
  unlet entry
  return status
endfunction

" get info on all files from CVS/Entries and given/current directory
" opens CVS/Entries only once, passing each entryline to CVSGetLocalStatus
function! CVSGetLocalDirStatus(...)
  let zbak = @z
  let ybak = @y
  if a:0 == 0
    let dirname = expand("%:p:h")
  else
    let dirname = a:1
  endif
  "exec 'cd '.dirname
  call CVSChDir(dirname)
  if has("unix")
    let @z = glob("*")
  else
    let @z = glob("*.*")
  endif
  new
  silent! exec 'read '.s:CVSentries
  let entrycount = line("$") - 1
  normal k"zP
  if (line("$") == entrycount) && (getline(entrycount) == '')
    " empty directory
    set nomodified
    return
  endif
  let filecount = line("$") - entrycount
  " collect status of all found files in @y
  let @y = ''
  let curlin = 0
  while (curlin < filecount)
    let curlin = curlin + 1
    let fn=getline(curlin)
    if fn != 'CVS'
      let search=escape(fn,'.')
      let v:errmsg = ''
      " find CVSEntry
      silent! exec '/^D\?\/'.search.'\//'
      if v:errmsg == ''
        let entry = getline(".")
	" clear found file from CVS/Entries
	silent! exec 's/.*//eg'
      else
	let entry = ''
      endif
      " fetch info
      let @y = @y . CVSGetLocalStatus(fn,entry) . "\n"
    endif
  endwhile
  " process files from CVS/Entries
  let curlin = filecount
  while (curlin < line("$"))
    let curlin = curlin + 1
    let entry = getline(curlin)
    let fn=CVSSubstr(entry,'/',1)
    if fn != ''
      let @y = @y . CVSGetLocalStatus(fn,entry) . "\n"
    endif
  endwhile
  set nomodified
  let result = @y
  bwipeout
  call CVSRestoreDir()
  let @z = zbak
  let @y = ybak
  unlet zbak ybak
  return result
endfunction

" return info about filename from 'CVS/Entries'
function! CVSGetEntry(filename)
  let result = ''
  if a:filename != ''
    silent! exec 'split '.s:CVSentries
    let v:errmsg = ''
    let search=escape(a:filename,'.')
    silent! exec '/^D\?\/'.search.'\//'
    if v:errmsg == ''
      let result = getline(".")
    endif
    set nomodified
    silent! bwipeout
  endif
  return result
endfunction

" extract and convert timestamp from CVSEntryItem
function! CVStimeToStr(entry)
  return CVSAsctimeToStr(CVSSubstr(a:entry,'/',3))
endfunction
" get and convert filetime
" include local time zone info
function! CVSFiletimeToStr(filename)
  let time=getftime(a:filename)-(GMTOffset() * 60*60)
  return strftime('%Y-%m-%d %H:%M:%S',time)
endfunction

" entry format : ISO C asctime()
function! CVSAsctimeToStr(asctime)
  let mon=strpart(a:asctime, 4,3)
  let DD=CVSLeadZero(strpart(a:asctime, 8,2))
  let hh=CVSLeadZero(strpart(a:asctime, 11,2))
  let nn=CVSLeadZero(strpart(a:asctime, 14,2))
  let ss=CVSLeadZero(strpart(a:asctime, 17,2))
  let YY=strpart(a:asctime, 20,4)
  let MM=CVSMonthIdx(mon)
  " CVS/WinNT : no date given for merge-results
  if MM == ''
    let result = ''
  else
    let result = YY.'-'.MM.'-'.DD.' '.hh.':'.nn.':'.ss
  endif
  unlet YY MM DD hh nn ss mon
  return result
endfunction

" append a leading zero
function! CVSLeadZero(value)
  let nr=substitute(a:value,' ','','g') + 0
  if (nr < 10)
    let nr = '0' . nr
  endif
  return nr
endfunction

" return month (leading zero) from cleartext
function! CVSMonthIdx(month)
  if match(a:month,'Jan') > -1
    return '01'
  elseif match(a:month,'Feb') > -1
    return '02'
  elseif match(a:month,'Mar') > -1
    return '03'
  elseif match(a:month,'Apr') > -1
    return '04'
  elseif match(a:month,'May') > -1
    return '05'
  elseif match(a:month,'Jun') > -1
    return '06'
  elseif match(a:month,'Jul') > -1
    return '07'
  elseif match(a:month,'Aug') > -1
    return '08'
  elseif match(a:month,'Sep') > -1
    return '09'
  elseif match(a:month,'Oct') > -1
    return '10'
  elseif match(a:month,'Nov') > -1
    return '11'
  elseif match(a:month,'Dec') > -1
    return '12'
  else
    return
endfunction

" divide string by sep, return field[index] .start at 0.
function! CVSSubstr(string,separator,index)
  let sub = ''
  let idx = 0
  let bst = 0
  while (bst < strlen(a:string)) && (idx <= a:index)
    if a:string[bst] == a:separator
      let idx = idx + 1
    else
      if (idx == a:index)
        let sub = sub . a:string[bst]
      endif
    endif
    let bst = bst + 1
  endwhile
  unlet idx bst
  return sub
endfunction

"Get difference between local time and GMT
"strftime() returns the adjusted time
"->strftime(0) GMT=00:00:00, GMT+1=01:00:00
"->midyear=summertime: strftime(182*24*60*60)=02:00:00 (GMT+1)
"linux bug:wrong CEST information before 1980
"->use 331257600 = 01.07.80 00:00:00
function! GMTOffset()
  let winter1980 = (10*365+2)*24*60*60      " = 01.01.80 00:00:00
  let summer1980 = winter1980+182*24*60*60  " = 01.07.80 00:00:00
  let summerhour = strftime("%H",summer1980)
  let summerzone = strftime("%Z",summer1980)
  let winterhour = strftime("%H",winter1980)
  let winterday  = strftime("%d",winter1980)
  let curzone    = strftime("%Z",localtime())
  if curzone == summerzone
    let result = summerhour
  else
    let result = winterhour
  endif
  " GMT - x : invert sign
  if winterday == 31
    let result = -1 * result
  endif
  unlet curzone winterday winterhour summerzone summerhour summer1980 winter1980
  return result
endfunction

"-----------------------------------------------------------------------------
" Autocommand : set title, restore diffmode		{{{1
"-----------------------------------------------------------------------------

" restore title
function! CVSBufEnter()
  " set/reset title
  if g:CVStitlebar
    " Joey doesn't like CVSbuftitle so forces CVSorgtitle
    if !exists("b:CVSbuftitle") || 1
      let &titlestring = s:CVSorgtitle
    else
      let &titlestring = b:CVSbuftitle
    endif
  endif
endfunction

" show status, add syntax
function! CVSBufRead(...)
  " query status if wanted, file and CVSdir exist
  if (g:CVSautocheck > 0)
   \ && (expand("%:p:t") != '')
   \ && filereadable(expand("%:p:h").s:sep.s:CVSentries)
    call CVSLocalStatus()
  endif
  " highlight conflicts on every file
  call CVSAddConflictSyntax()
endfunction

" save pre diff settings
function! CVSDiffEnter()
  let g:CVSdifforgbuf = bufnr('%')
  let g:CVSbakdiff 		= &diff
  let g:CVSbakscrollbind 	= &scrollbind
  let g:CVSbakwrap 		= &wrap
  let g:CVSbakfoldcolumn 	= &foldcolumn
  let g:CVSbakfoldenable 	= &foldenable
  let g:CVSbakfoldlevel 	= &foldlevel
  let g:CVSbakfoldmethod 	= &foldmethod
endfunction

" restore pre diff settings
function! CVSDiffLeave()
  call setwinvar(bufwinnr(g:CVSdifforgbuf), '&diff'	  , g:CVSbakdiff	)
  call setwinvar(bufwinnr(g:CVSdifforgbuf), '&scrollbind' , g:CVSbakscrollbind	)
  call setwinvar(bufwinnr(g:CVSdifforgbuf), '&wrap'	  , g:CVSbakwrap	)
  call setwinvar(bufwinnr(g:CVSdifforgbuf), '&foldcolumn' , g:CVSbakfoldcolumn	)
  call setwinvar(bufwinnr(g:CVSdifforgbuf), '&foldenable' , g:CVSbakfoldenable	)
  call setwinvar(bufwinnr(g:CVSdifforgbuf), '&foldlevel'  , g:CVSbakfoldlevel	)
  call setwinvar(bufwinnr(g:CVSdifforgbuf), '&foldmethod' , g:CVSbakfoldmethod	)
endfunction

" save original settings
function! CVSBackupDiffMode()
  let g:CVSorgdiff 		= &diff
  let g:CVSorgscrollbind 	= &scrollbind
  let g:CVSorgwrap 		= &wrap
  let g:CVSorgfoldcolumn 	= &foldcolumn
  let g:CVSorgfoldenable 	= &foldenable
  let g:CVSorgfoldlevel 	= &foldlevel
  let g:CVSorgfoldmethod 	= &foldmethod
endfunction

" restore original settings
function! CVSRestoreDiffMode()
  let &diff       		= g:CVSorgdiff
  let &scrollbind 		= g:CVSorgscrollbind
  let &wrap       		= g:CVSorgwrap
  let &foldcolumn 		= g:CVSorgfoldcolumn
  let &foldenable 		= g:CVSorgfoldenable
  let &foldlevel  		= g:CVSorgfoldlevel
  let &foldmethod 		= g:CVSorgfoldmethod
endfunction
    
" this is useful for mapping
function! CVSSwitchDiffMode()
  if &diff
    call CVSRestoreDiffMode()
  else
    diffthis
  endif
endfunction

" remember restoring prediff mode
function! CVSDiffPrepareLeave()
  if match(expand("<afile>:e"),'dif','i') > -1
    " diffed buffer gets unloaded twice by :vert diffs
    " only react to the second unload
    let g:CVSleavediff = g:CVSleavediff + 1
    " restore prediff settings (see CVSPrepareLeave)
    if (g:CVSsavediff > 0) && (g:CVSleavediff > 1)
      call CVSDiffLeave()
      let g:CVSleavediff = 0
    endif
  endif
endfunction

"-----------------------------------------------------------------------------
" finalization		{{{1
"-----------------------------------------------------------------------------

call CVSGetFolderNames()		" vim user directories
call CVSMakeLeaderMapping()		" create keymappings from menu shortcuts
call CVSBackupDiffMode()		" save pre :diff settings

" provide direct access to CVS commands, using dumping and sorting from this script
command! -nargs=+ -complete=expression -complete=file -complete=function -complete=var CVS call CVSDoCommand(<q-args>)

" highlight conflicts on every file
au BufRead * call CVSBufRead()
" set title
au BufEnter * call CVSBufEnter()
" restore prediff settings
au BufWinLeave *.dif call CVSDiffPrepareLeave()

if !exists("loaded_cvsmenu")
  let loaded_cvsmenu=1
endif


"}}}
