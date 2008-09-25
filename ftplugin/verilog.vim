" Vim filetype plugin file
"
"   Language :  Verilog
"     Plugin :  Verilog-Support.vim
" Maintainer :  Anil Kumar T <anil.tallapragada@gmail.com>
"    Version :  1.0
"   Revision :  $Id: sh.vim,v 1.9 2007/11/18 11:12:31 mehner Exp $
"
" -----------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_BASH_ftplugin")
  finish
endif
let b:did_BASH_ftplugin = 1
"
" ---------- BASH dictionary -----------------------------------
"
" This will enable keyword completion for bash
" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
" 
if exists("g:VERILOG_Dictionary_File")
    silent! exec 'setlocal dictionary+='.g:VERILOG_Dictionary_File
endif    
"

inoremap <s-tab>              <C-X><C-K><C-R>
