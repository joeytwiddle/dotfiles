" **fold.vim**  
" 
" 1_MAPS 2_CONSTANTS 3_FUNCTIONS
"  
" Use folding in Vim: hide and unhide fragments of text.                    " 
"                                                                           "
" MAPS:                                                                     "
"                                                                           "
"    Start editing a file, and then use the following maps:                 "
"                                                                           "
"    ,FN   Make a new fold file
"    ,FE   Edit the 'fold file'. This is a temporary file in which you edit  "
"          your text, and in which fragments of text can be folded.         "
"    ,FR   Restore the original file, in which all fold nodes are removed.  "
"          Keep the fold file, however.                                     "
"                                                                           "
"     Use in the fold file:                                                 "
"                                                                           "
"    ,Fn   After linewise visual selection of a fragment of text, hide the  "
"          text and insert a new fold node. Store the text in a fold node   "
"          file.                                                            "
"  
"          Example: a visual selection of the following fragment:
"  
"             This the text that is  
"             hidden behind the fold node 
" 
"          is replaced by:
"  
"             ======>3< This the text that is   
" 
"          In this line, '======>3<' is highlighted red, and may not  
"          be changed. The string 'This is the text that is' may be  
"          edited, if you want to have another name for your node. 
"          The number 3 is an identifier for the filename, where  
"          the hidden text is stored. 
"   
"    ,Fd   Delete a node, and remove the fold node file.                    " 
"    ,FD   Delete all fold nodes.                                           "
"                                                                           "
"    ,Fu   Unfold a node.                                                   "
" 
"          ,Fu on the fold node displayed above (line starting with ======>)
"          expands the node as follows:
"  
"              ------>3< This the text that is 
"              This the text that is  
"              hidden behind the fold node 
"              <------3
"      
"          All the text that is highlighted red may not be changed, the 
"          rest you are free to edit.
"  
"    ,FU   Unfold all nodes.                                                "
"    ,Fo   Fold  a node: hide the text again. This also works if the command
"          is given on any line between the begin and end marks of an 
"          unfolded node.
"    ,FO   Fold all nodes.                                                  "
"                                                                           "
"    ,FF   Toggle fold of a node.                                           "
" 
" NOTES:                                                                    "
"                                                                           "
"     Caution                                                               "
"                                                                           "
"     You must be careful when deleting a node with ,Fd , the file in       "
"     which the contents are stored is also deleted. If you then hit        "
"     u (undo) the node is restored, but the contents are not restored      "
"     to the node file! So you end up with an invalid node. (Todo: make     "
"     a backup of node files.)                                              "
"                                                                           "
"     How does it work                                                      "
"                                                                           "
"     The node-editing takes place in a separate file. Eg. you are          "
"     editing ./myfile.txt, then upon hitting ,FN a file                    "
"     ./FOLDFILES/FOLDFILE.myfile.txt is made, containing a copy of         "
"     ./myfile.txt. Here you can add nodes. The contents of the nodes are   "
"     stored in files ./FOLDFILES/FOLDFILE.myfile.txt.n, where n is the     "
"     identifier displayed as ======>n< . These nodes can be folded and     "
"     unfolded, and the contents can be edited (just edit the text between  "
"     the begin and end mark of an unfolded node. When you are finished     "
"     editing, hitting ,FN will copy ./FOLDFILES/FOLDFILE.myfile.txt        "
"     ./myfile.txt, and all nodes are unfolded and removed, to restore      "
"     complete file.                                                        "
"     
"     Bugs
"  
"     * Problem when subnode directly after parent node
"     * The syntax coloring for the nodes and node titles doesn't work 
"       correctly yet: 
"
"         ======>4< The title
"         ^^^^^^^^^-----------------> node
"
"       The node must be colored red, The Title yellow. To do this, I use 
"       a pattern for the node, and a pattern with offset for The Title. 
"       However, the lc offset given with syn match is a fixed number, 
"       whereas the node number >4< can consist of several numbers. Therefore,
"       I picked such an offset that 2-digit numbers will be colored
"       correctly. For The Title to be colored correctly then, there must be
"       at least one space between the node and The Title.
" 
"     * Folding of all subnodes doesn't work yet.
" 
"     * There is some trouble with folding text that includes the last line
"       of the file. (Use of P and p to 'put' the node.) Leave an extra empty
"       line at the end of the file for now.
" 
" TODO:                                                                     "
"                                                                           "
"   * Remove bugs
"   * Map <cr> in fold file                                                 "
"   * Put =======> inside comment, for compiling a programme partially      "
"   * Make possible general file substitutions, eg: insert                  "
"     <FILE:Myfile.txt> and substitute file contents.                       "
"   * Backup node files for safety                                          "

" 1_MAPS
" -----------------------------------------------------------------------------
if !exists("_fold_vim_sourced")
let _fold_vim_sourced=1
" -----------------------------------------------------------------------------
" New fold file
map ,FN :call FoldFileNew()<cr>
" Edit fold file
map ,FE :call FoldFile()<cr>
" Restore fold file to original file
map ,FR :call FoldRestore()<cr>
" New fold node, visually highlighted selection.
vmap ,Fn "zy:call FoldNew()<cr>
" Delete fold node
map ,Fd :call FoldDel()<cr>
" Delete all fold nodes
map ,FD :call FoldDelAll()<cr>
" Unfold node
map ,Fu :call FoldUn()<cr>
" Unfold all
map ,FU :call FoldUnAll()<cr>
" Fold node
map ,Fo :call Fold()<cr>
" Fold all
map ,FO :call FoldAll()<cr>
" Toggle fold
map ,FF :call FoldToggle()<cr>

" 2_CONSTANTS

let fold_f="FOLDFILE"
let fold_dir="FOLDFILES"
let fold_sf="======>"
let fold_su="------>"
let fold_eu="<------"
let fold_nf=strlen(fold_f)
let fold_ndir=strlen(fold_dir)
let fold_nsf=strlen(fold_sf)
let fold_nsu=strlen(fold_su)

if has("unix")
  let dirsep="/"
else
  let dirsep="\\"
end

aug fold
  au! 
  au bufenter FOLDFILE* call FoldSyntax()
aug END

" 3_FUNCTIONS

fu! FoldSyntax()
  exe "syn match Foldnode +^".g:fold_sf.".*<+" 
  exe "syn match Foldnode +^".g:fold_su.".*<+" 
  exe "syn match Foldnode +^".g:fold_eu.".*+" 
  exe "hi Foldnode ctermfg=Red guifg=Red" 
  exe "syn match Foldtitle +^".g:fold_sf.".*<.*$+lc=10" 
  exe "syn match Foldtitle +^".g:fold_su.".*<.*$+lc=10" 
  if has("unix")
    exe "hi Foldtitle guifg=darkblue ctermfg=blue" 
  else
    exe "hi Foldtitle guifg=yellow ctermfg=yellow" 
  end
endf

" Make new directory
fu! Md(name)
  set ch=5
  if !isdirectory(a:name)
    if has("unix")
      exe "!mkdir ".a:name
    else
      exe "!md ".a:name
    end
  end
  set ch=1
endf

" Make new fold file
fu! FoldFileNew()
  let fn=expand("%")
  if match(fn,g:fold_f)==-1
    call Md(g:fold_dir)
    let fn=g:fold_dir.g:dirsep.g:fold_f.".".fn
    exe "w!".fn."|e!".fn
  end
endf

" Edit existing fold file
fu! FoldFile()
  let fn=expand("%")
  if match(fn,g:fold_f)==-1
    let fn=g:fold_dir.g:dirsep.g:fold_f.".".fn
    if !filereadable(fn)
      exe "w!".fn
    end
    exe "e!".fn
  end
endf

" Restore file from fold file and node contents
fu! FoldRestore()
  let fn=expand("%:t")
  if strpart(fn,0,g:fold_nf)==g:fold_f
    let of=strpart(fn,g:fold_nf+1,strlen(fn))
    exe "w!|w!".of."|e!".of
    let i=1 
    wh i<=line("$")
       exe i
       if strpart(getline("."),0,g:fold_nsf)==g:fold_sf
         call FoldUn()
         -1
       end
       if strpart(getline("."),0,g:fold_nsu)==g:fold_su
         let s=getline(".")
         normal dd
         let n1=matchend(s,g:fold_su)
         let n2=match(s,"<")
         let n=strpart(s,n1,n2-n1)
         let i=line(".")-1
         exe "normal /".g:fold_eu.n."\rdd"
       end
       let i=i+1
    endwh
  w!
  end 
endf

" Fold contents of register z
fu! FoldNew()
  let fn=expand("%")
  if match(fn,g:fold_f)>-1
    let n=match(@z,"\n")
    if n==-1
      echo "Must select at least one line."
    else
      set ch=5
      let i=1|let tf=fn.".".i
      wh filereadable(tf)
        let i=i+1|let tf=fn.".".i
      endwh
      let @z=g:fold_sf.i."<".strpart(@z,0,n)."\n"
      exe "norm gv:w ".tf."\rgvx\"zP"
      set ch=1
    end
  end
endf

fu! FoldDel()
  let fn=expand("%")
  if match(fn,g:fold_f)>-1
    if strpart(getline("."),0,g:fold_nsu)==g:fold_su
      call Fold()
    end
    let s=getline(".")
    if strpart(s,0,g:fold_nsf)==g:fold_sf
      let n1=matchend(s,g:fold_sf)
      let n2=match(s,"<")
      let fn=fn.".".strpart(s,n1,n2-n1)
      norm ddk
      exe "r ".fn
      call delete(fn)
    else
      echo "Must be on a node !!!"
    end
  end
endf

fu! FoldDelAll()
  if match(expand("%"),g:fold_f)>-1
    let i=1
    wh i<=line("$")
      exe i
      let s=getline(".")
      if ((strpart(s,0,g:fold_nsf)==g:fold_sf)||(strpart(s,0,g:fold_nsu)==g:fold_su))
        call FoldDel()
      end
      let i=i+1
    endwh
  end
endf

fu! FoldUn()
  let s=getline(".")
  if strpart(s,0,g:fold_nsf)==g:fold_sf
    call setline(line("."),g:fold_su.strpart(s,g:fold_nsf,strlen(s)))
    let n1=matchend(s,g:fold_sf)
    let n2=match(s,"<")
    if match(expand("%"),g:fold_dir)<0
      let fn=g:fold_dir.g:dirsep.g:fold_f.".".expand("%:t").".".strpart(s,n1,n2-n1)
    else
      let fn=expand("%").".".strpart(s,n1,n2-n1)
    end
    let @z=g:fold_eu.strpart(s,n1,n2-n1)."\n"
    norm "zpk
    exe "r ".fn
  else
    echo "Must be on node !!!"
  end
endf

fu! FoldUnAll()
  if match(expand("%"),g:fold_f)>-1
    let i=1
    wh i<=line("$")
      exe i
      if strpart(getline("."),0,g:fold_nsf)==g:fold_sf
        call FoldUn()
      end
      let i=i+1
    endwh
  end
endf

fu! Fold()
  let fn=expand("%")
  if match(fn,g:fold_f)>-1
    let s=getline(".")
    if strpart(s,0,g:fold_nsu)==g:fold_su
      call setline(line("."),g:fold_sf.strpart(s,g:fold_nsu,strlen(s)))
      let n1=matchend(s,g:fold_su)
      let n2=match(s,"<")
      let fn=fn.".".strpart(s,n1,n2-n1)
      set ch=4
      +1
      exe "norm V/".g:fold_eu.strpart(s,n1,n2-n1)."\rk:w! ".fn."\rgvxddk"
      set ch=1
    else
      if ((strpart(s,0,g:fold_nsf)!=g:fold_sf)&&(strpart(s,0,g:fold_nsu)!=g:fold_su))
        exe "norm ?".g:fold_sf."\\|".g:fold_su."\r"
        call Fold()
      end
    end
  end
endf

fu! FoldAll()
  if match(expand("%"),g:fold_f)>-1
    let i=1
    wh i<=line("$")
      exe i
      if strpart(getline("."),0,g:fold_nsu)==g:fold_su
        call Fold()
      end
      let i=i+1
    endwh
  end
endf

fu! FoldToggle()
  if match(expand("%"),g:fold_f)>-1
    if strpart(getline("."),0,g:fold_nsf)==g:fold_sf
      call FoldUn()
    else 
      call Fold()
    end
  end
endf
" -----------------------------------------------------------------------------
endif
" -----------------------------------------------------------------------------
