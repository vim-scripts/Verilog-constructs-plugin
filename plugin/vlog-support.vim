"#########################################################################################
"
"       Filename:  vlog-support.vim
"  
"    Description:  VERILOG support     (VIM Version 7.0+)
"  
"                  Write VERILOG-scripts by inserting comments, statements, tests, 
"                  variables and builtins.
"  
"  Configuration:  There are some personal details which should be configured 
"                    (see the files README.vlogsupport and vlogsupport.txt).
"                    
"   Dependencies:  The environmnent variables $HOME und $SHELL are used.
"  
"   GVIM Version:  7.0+
"  
"         Author:  T.Anil Kumar, Synplicity Software India Pvt LTD.
"          Email:  anil.tallapragada@gmail.com
"          
"        Version:  see variable  g:VERILOG_Version  below 
"        Created:  11.05.2008
"        License:  Copyright (c) 2008-2010, T.Anil Kumar
"                  This program is free software; you can redistribute it and/or
"                  modify it under the terms of the GNU General Public License as
"                  published by the Free Software Foundation, version 2 of the
"                  License.
"                  This program is distributed in the hope that it will be
"                  useful, but WITHOUT ANY WARRANTY; without even the implied
"                  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                  PURPOSE.
"                  See the GNU General Public License version 2 for more details.
"       Revision:  $Id: vlog-support.vim,v 1.0 2008/05/11 17:52:11 Anilk Exp $
"  
"------------------------------------------------------------------------------
" 
" Prevent duplicate loading: 
" 
if exists("g:VERILOG_Version") || &cp
 finish
endif
let g:VERILOG_Version= "1.0"  						" version number of this script; do not change
"
if v:version < 700
  echohl WarningMsg | echo 'plugin vlog-support.vim needs Vim version >= 7'| echohl None
endif
"
"#########################################################################################
"
"  Global variables (with default values) which can be overridden.
"
"  Key word completion is enabled by the filetype plugin 'verilog.vim'
"  g:VERILOG_Dictionary_File  must be global
" ==========  Linux/Unix  ======================================================

"Change the WINDOWS variables to have no spaces and no backslahes

let s:vim_unix = substitute ( substitute ( $VIM, "\\", "/", "g"), " ", "\\\\ ", "g" )

let s:home_unix = substitute ( substitute ( $HOME, "\\", "/", "g"), " ", "\\\\ ", "g" )

let s:ins_loc_unix = substitute ( substitute ( expand ("%:p"), "\\", "/", "g"), " ", "\\\\ ", "g" )


let s:plugin_dir  = s:vim_unix.'/vimfiles/'

"
"------------------------------------------------------------------------------
"
if !exists("g:VERILOG_Dictionary_File")
	let g:VERILOG_Dictionary_File     = s:plugin_dir.'vlog-support/wordlists/vlog.list'

endif

"
"  Modul global variables (with default values) which can be overridden.
"
let s:VERILOG_AuthorName              = ""
let s:VERILOG_AuthorRef               = ""
let s:VERILOG_Company                 = ""
let s:VERILOG_CopyrightHolder         = ""
let s:VERILOG_Email                   = ""
let s:VERILOG_Project                 = ""
"
let s:VERILOG_CodeSnippets            = s:plugin_dir."vlog-support/codesnippets/"
let s:VERILOG_DoOnNewLine             = 'yes'
let s:VERILOG_LineEndCommColDefault   = 49
let s:VERILOG_LoadMenus               = "yes"
let s:VERILOG_MenuHeader              = "yes"
let s:VERILOG_OutputGvim              = "vim"
let s:VERILOG_Root                    = '&Verilog.'         " the name of the root menu of this plugin
let s:VERILOG_Template_Directory      = s:plugin_dir."vlog-support/templates/"
let s:VERILOG_Template_File           = "vlog-file-header"
let s:VERILOG_Template_Frame          = "vlog-frame"
let s:VERILOG_Template_Function       = "vlog-function-description"
let s:VERILOG_Printheader             = "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"

"
let s:VERILOG_FormatDate						= '%x'
let s:VERILOG_FormatTime						= '%X %Z'
let s:VERILOG_FormatYear						= '%Y'
"
"
"------------------------------------------------------------------------------
"  Some variables for internal use only
"------------------------------------------------------------------------------
let s:VERILOG_Active         = -1                    " state variable controlling the Verilog-menus
let s:VERILOG_Errorformat    = '%f:\ line\ %l:\ %m'
let s:VERILOG_SetCounter     = 0                     " 
let s:VERILOG_Set_Txt        = "SetOptionNumber_"
let s:VERILOG_Shopt_Txt      = "ShoptOptionNumber_"
let s:escfilename         = ' \%#[]'
"

"------------------------------------------------------------------------------
"  Look for global variables (if any), to override the defaults.
"------------------------------------------------------------------------------
function! VERILOG_CheckGlobal ( name )
  if exists('g:'.a:name)
    exe 'let s:'.a:name.'  = g:'.a:name
  endif
endfunction   " ---------- end of function  VERILOG_CheckGlobal  ----------
"
call VERILOG_CheckGlobal("VERILOG_AuthorName            ")
call VERILOG_CheckGlobal("VERILOG_AuthorRef             ")
call VERILOG_CheckGlobal("VERILOG_CodeSnippets          ")
call VERILOG_CheckGlobal("VERILOG_Company               ")
call VERILOG_CheckGlobal("VERILOG_CopyrightHolder       ")
call VERILOG_CheckGlobal("VERILOG_Email                 ")
call VERILOG_CheckGlobal("VERILOG_FormatDate            ")
call VERILOG_CheckGlobal("VERILOG_FormatTime            ")
call VERILOG_CheckGlobal("VERILOG_FormatYear            ")
call VERILOG_CheckGlobal("VERILOG_LineEndCommColDefault ")
call VERILOG_CheckGlobal("VERILOG_LoadMenus             ")
call VERILOG_CheckGlobal("VERILOG_MenuHeader            ")
call VERILOG_CheckGlobal("VERILOG_OutputGvim            ")
call VERILOG_CheckGlobal("VERILOG_Printheader           ")
call VERILOG_CheckGlobal("VERILOG_Project               ")
call VERILOG_CheckGlobal("VERILOG_Root                  ")
call VERILOG_CheckGlobal("VERILOG_Template_Directory    ")
call VERILOG_CheckGlobal("VERILOG_Template_File         ")
call VERILOG_CheckGlobal("VERILOG_Template_Frame        ")
call VERILOG_CheckGlobal("VERILOG_Template_Function     ")
"
" escape the printheader
"
let s:VERILOG_Printheader  = escape( s:VERILOG_Printheader, ' %' )
"
"------------------------------------------------------------------------------
"  VERILOG Menu Initialization
"------------------------------------------------------------------------------
function!	VERILOG_InitMenu ()
	"
	if has("gui_running")
		"===============================================================================================
		"----- Menu : root menu  ---------------------------------------------------------------------
		"===============================================================================================
		if s:VERILOG_Root != ""
			if s:VERILOG_MenuHeader == "yes"
				exe "amenu   ".s:VERILOG_Root.'Verilog         <Esc>'
				exe "amenu   ".s:VERILOG_Root.'-Sep0-        :'
			endif
		endif
		"
		"-------------------------------------------------------------------------------
		" menu Comments
		"-------------------------------------------------------------------------------
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu   ".s:VERILOG_Root.'&Comments.Comments<Tab>Verilog          <Esc>'
			exe "amenu   ".s:VERILOG_Root.'&Comments.-Sep0-              :'
		endif
		exe "amenu           ".s:VERILOG_Root.'&Comments.end-of-&line\ comment               <Esc><Esc>:call VERILOG_LineEndComment()<CR>A'
		exe "vmenu <silent>  ".s:VERILOG_Root.'&Comments.end-of-&line\ comment               <Esc><Esc>:call VERILOG_MultiLineEndComments()<CR>A'
		exe "amenu <silent>  ".s:VERILOG_Root.'&Comments.ad&just\ end-of-line\ com\.         <Esc><Esc>:call VERILOG_AdjustLineEndComm("a")<CR>'
		exe "vmenu <silent>  ".s:VERILOG_Root.'&Comments.ad&just\ end-of-line\ com\.         <Esc><Esc>:call VERILOG_AdjustLineEndComm("v")<CR>'
		exe "amenu <silent>  ".s:VERILOG_Root.'&Comments.&set\ end-of-line\ com\.\ col\.     <Esc><Esc>:call VERILOG_GetLineEndCommCol()<CR>'
		exe "amenu <silent>  ".s:VERILOG_Root.'&Comments.&frame\ comment             <Esc><Esc>:call VERILOG_CommentTemplates("frame")<CR>'
		exe "amenu <silent>  ".s:VERILOG_Root.'&Comments.f&unction\ description      <Esc><Esc>:call VERILOG_CommentTemplates("function")<CR>'
		exe "amenu <silent>  ".s:VERILOG_Root.'&Comments.file\ &header               <Esc><Esc>:call VERILOG_CommentTemplates("header")<CR>'
		exe "amenu ".s:VERILOG_Root.'&Comments.-Sep1-                    :'
		exe "amenu ".s:VERILOG_Root."&Comments.&code->comment            <Esc><Esc>:s@^@\/\/@<CR><Esc>:nohlsearch<CR>j"
		exe "vmenu ".s:VERILOG_Root."&Comments.&code->comment            <Esc><Esc>:'<,'>s@^@\/\/@<CR><Esc>:nohlsearch<CR>j"
		exe "amenu ".s:VERILOG_Root."&Comments.c&omment->code            <Esc><Esc>:s@^\\(\\s*\\)\/\/@\\1@<CR><Esc>:nohlsearch<CR>j"
		exe "vmenu ".s:VERILOG_Root."&Comments.c&omment->code            <Esc><Esc>:'<,'>s@^\\(\\s*\\)\/\/@\\1@<CR><Esc>:nohlsearch<CR>j"
		
		exe "vmenu ".s:VERILOG_Root."&Comments.&Block-Comment            <Esc><Esc>a*/<Esc>gvo<Esc>i/*<Esc>gvo<Esc>lll"
		exe "vmenu ".s:VERILOG_Root."&Comments.Block-&UnComment          <Esc><Esc>:s@\*\/@@<CR><Esc>gvo<Esc>:s@\/\\*@@<CR><Esc>:nohlsearch<CR>l"

		
	
		exe "amenu ".s:VERILOG_Root."&Comments.&end-of-line-attribute                <Esc><Esc>:s@\\(;*\\)\\(\\s*\\)$@ /* synthesis */\\1\\2@<CR><Esc>:nohlsearch<CR>j"
		
		
		exe "amenu ".s:VERILOG_Root.'&Comments.-SEP2-                    :'
		exe " menu ".s:VERILOG_Root.'&Comments.&date                     a<C-R>=VERILOG_InsertDateAndTime("d")<CR>'
		exe "imenu ".s:VERILOG_Root.'&Comments.&date                      <C-R>=VERILOG_InsertDateAndTime("d")<CR>'
		exe " menu ".s:VERILOG_Root.'&Comments.date\ &time               a<C-R>=VERILOG_InsertDateAndTime("dt")<CR>'
		exe "imenu ".s:VERILOG_Root.'&Comments.date\ &time                <C-R>=VERILOG_InsertDateAndTime("dt")<CR>'
		"
		
		exe "amenu ".s:VERILOG_Root.'&Comments.-SEP3-                    :'
		"
		"----- Submenu : VERILOG-Comments : Keywords  ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Comments.\#\ \:&KEYWORD\:.Comments-1<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Comments.\#\ \:&KEYWORD\:.-Sep1-          :'
		endif
		exe "amenu ".s:VERILOG_Root.'&Comments.\#\ \:&KEYWORD\:.&BUG              <Esc><Esc>$<Esc>:call VERILOG_CommentClassified("BUG")     <CR>kgJA'
		exe "amenu ".s:VERILOG_Root.'&Comments.\#\ \:&KEYWORD\:.&TODO             <Esc><Esc>$<Esc>:call VERILOG_CommentClassified("TODO")    <CR>kgJA'
		exe "amenu ".s:VERILOG_Root.'&Comments.\#\ \:&KEYWORD\:.&Note           <Esc><Esc>$<Esc>:call VERILOG_CommentClassified("NOTE")  <CR>kgJA'
		exe "amenu ".s:VERILOG_Root.'&Comments.\#\ \:&KEYWORD\:.&WARNING          <Esc><Esc>$<Esc>:call VERILOG_CommentClassified("WARNING") <CR>kgJA'
		exe "amenu ".s:VERILOG_Root.'&Comments.\#\ \:&KEYWORD\:.&new\ keyword     <Esc><Esc>$<Esc>:call VERILOG_CommentClassified("")        <CR>kgJf:a'
		"
		"----- Submenu : VERILOG-Comments : Tags  ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).Comments-2<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).-Sep1-          :'
		endif
		"
		exe "amenu  ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           a'.s:VERILOG_AuthorName."<Esc>"
		exe "amenu  ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        a'.s:VERILOG_AuthorRef."<Esc>"
		exe "amenu  ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).&COMPANY          a'.s:VERILOG_Company."<Esc>"
		exe "amenu  ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  a'.s:VERILOG_CopyrightHolder."<Esc>"
		exe "amenu  ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).&EMAIL            a'.s:VERILOG_Email."<Esc>"
		exe "amenu  ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).&PROJECT          a'.s:VERILOG_Project."<Esc>"

		exe "imenu  ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           <Esc>a'.s:VERILOG_AuthorName
		exe "imenu  ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        <Esc>a'.s:VERILOG_AuthorRef
		exe "imenu  ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).&COMPANY          <Esc>a'.s:VERILOG_Company
		exe "imenu  ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  <Esc>a'.s:VERILOG_CopyrightHolder
		exe "imenu  ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).&EMAIL            <Esc>a'.s:VERILOG_Email
		exe "imenu  ".s:VERILOG_Root.'&Comments.ta&gs\ (plugin).&PROJECT          <Esc>a'.s:VERILOG_Project
		"
		exe "amenu ".s:VERILOG_Root.'&Comments.&vim\ modeline          <Esc><Esc>:call VERILOG_CommentVimModeline()<CR>'
		"
		"-------------------------------------------------------------------------------
		" menu Statements
		"-------------------------------------------------------------------------------
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Statements.Statements<Tab>Verilog         <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Statements.-Sep0-             :'
		endif
		
		"----- Submenu : VERILOG-Conditional Statements ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.Conditional\ Statements<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.-Sep1-          :'
		endif
		"
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&Initial		<Esc><Esc>:call VERILOG_3FlowControl( "initial",    "begin",  "end",     "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&if			<Esc><Esc>:call VERILOG_3FlowControl( "if (expression)", "begin", "end",       "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.if-&else	    <Esc><Esc>:call VERILOG_4FlowControl( "if (expression) ",        "", "else", "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&else-if		<Esc><Esc>i else if (expression)<CR><Esc>1kA'	
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&case(zx)		<Esc><Esc>:call VERILOG_4FlowControl( "case(zx) (expression)",        "alteranative:expresison", "default:default_expresison", "endcase", "a" )<CR>i' 
        exe "anoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&`if			<Esc><Esc>:call VERILOG_4FlowControl( "`ifdef <macro>", "..", "..", "`endif",       "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.`if-&`else	    <Esc><Esc>:call VERILOG_4FlowControl( "`ifdef <macro>", "\n",   "`else", "`endif", "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&`elsif		<Esc><Esc>i`elsif <macro><CR><Esc>1kA'	
		
		exe "inoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&Initial		<Esc><Esc>:call VERILOG_3FlowControl( "initial",    "begin",  "end",     "a" )<CR>i'
		exe "inoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&if			<Esc><Esc>:call VERILOG_3FlowControl( "if (expression)", "begin", "end",       "a" )<CR>i'
		exe "inoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.if-&else	    <Esc><Esc>:call VERILOG_4FlowControl( "if (expression) ",        "", "else", "a" )<CR>i'
		exe "inoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&case(zx)		<Esc><Esc>:call VERILOG_4FlowControl( "case(zx) (expression)",        "alteranative:expresison", "default:default_expresison", "endcase", "a" )<CR>i' 
        exe "inoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&`if			<Esc><Esc>:call VERILOG_4FlowControl( "`ifdef <macro>", "..", "..", "`endif",       "a" )<CR>i'
		exe "inoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.`if-&`else	    <Esc><Esc>:call VERILOG_4FlowControl( "`ifdef <macro>", "\n",   "`else", "`endif", "a" )<CR>i'

		exe "vnoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&Initial		<Esc><Esc>:call VERILOG_3FlowControl( "initial",    "begin",  "end",     "v" )<CR>'
		exe "vnoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&if			<Esc><Esc>:call VERILOG_3FlowControl( "if (expression)", "begin", "end",       "v" )<CR>'
		exe "vnoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.if-&else	    <Esc><Esc>:call VERILOG_4FlowControl( "if (expression) ",        "", "else", "v" )<CR>'
		exe "vnoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&case(zx)		<Esc><Esc>:call VERILOG_4FlowControl( "case(zx) (expression)",        "alteranative:expresison", "default:default_expresison", "endcase", "v" )<CR>' 
        exe "vnoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.&`if			<Esc><Esc>:call VERILOG_4FlowControl( "`ifdef <macro>", "..", "..", "`endif",       "v" )<CR>'
		exe "vnoremenu ".s:VERILOG_Root.'&Statements.&Conditional-Statements.`if-&`else	    <Esc><Esc>:call VERILOG_4FlowControl( "`ifdef <macro>", "\n",   "`else", "`endif", "v" )<CR>'
		
		"----- Submenu : VERILOG-Loop Statements ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.Loop\ Statements<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.-Sep1-          :'
		endif
		"
			
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.&while		<Esc><Esc>:call VERILOG_3FlowControl( "while (expression)",     "begin",   "end",     "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.&for			<Esc><Esc>:call VERILOG_3FlowControl( "for ( ; ;)",    "begin",   "end",     "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.&repeat		<Esc><Esc>:call VERILOG_3FlowControl( "repeat (expression) ", "begin",   "end",     "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.forever		<Esc><Esc>:call VERILOG_3FlowControl( "forever",     "begin",   "end",     "a" )<CR>i'

		exe "inoremenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.&while		<Esc><Esc>:call VERILOG_3FlowControl( "while (expression)",     "begin",   "end",     "a" )<CR>i'
		exe "inoremenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.&for			<Esc><Esc>:call VERILOG_3FlowControl( "for ( ; ;)",    "begin",   "end",     "a" )<CR>i'
		exe "inoremenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.&repeat		<Esc><Esc>:call VERILOG_3FlowControl( "repeat (expression) ", "begin",   "end",     "a" )<CR>i'
		exe "inoremenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.forever		<Esc><Esc>:call VERILOG_3FlowControl( "forever",     "begin",   "end",     "a" )<CR>i'
		
		exe "vnoremenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.&while		<Esc><Esc>:call VERILOG_3FlowControl( "while (expression)",     "begin",   "end",     "v" )<CR>'
		exe "vnoremenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.&for			<Esc><Esc>:call VERILOG_3FlowControl( "for ( ; ;)",    "begin",   "end",     "v" )<CR>'
		exe "vnoremenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.&repeat		<Esc><Esc>:call VERILOG_3FlowControl( "repeat (expression) ", "begin",   "end",     "v" )<CR>'
		exe "vnoremenu ".s:VERILOG_Root.'&Statements.&Loop-Statements.forever		<Esc><Esc>:call VERILOG_3FlowControl( "forever",     "begin",   "end",     "v" )<CR>'
		"
		"----- Submenu : VERILOG-Generate Statements ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Statements.&Generate-Statements.Generate\ Statements<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Statements.&Generate-Statements.-Sep1-          :'
		endif
		"
			
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Generate-Statements.&generate-for		<Esc><Esc>:call VERILOG_6FlowControl( "genvar <gen-var>;", "", "generate for( ; ; ;)",     "begin:<generate_label>",   "end" ,"endgenerate",     "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Generate-Statements.&generate-cond	<Esc><Esc>:call VERILOG_5FlowControl( "generate", "if(expression)", "else if (expression)",    "else",   "endgenerate",     "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Generate-Statements.&generate-case	<Esc><Esc>:call VERILOG_5FlowControl ("generate", "case  (expression)", "alternative:statement", "default: default_statement", "endcase", "a") <CR>i'

		exe "inoremenu ".s:VERILOG_Root.'&Statements.&Generate-Statements.&generate-for		<Esc><Esc>:call VERILOG_6FlowControl( "genvar <gen-var>;", "", "generate for( ; ; ;)",     "begin:<generate_label>",   "end" ,"endgenerate",     "a" )<CR>i'
		exe "vnoremenu ".s:VERILOG_Root.'&Statements.&Generate-Statements.&generate-for		<Esc><Esc>:call VERILOG_6FlowControl( "genvar <gen-var>;", "", "generate for( ; ; ;)",     "begin:<generate_label>",   "end" ,"endgenerate",     "v" )<CR>'
		
		exe "anoremenu ".s:VERILOG_Root.'&Statements.-SEP2-          :'
        
		"----- Submenu : VERILOG-Always Statements ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Statements.&Always-Statements.always\ Statements<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Statements.&Always-Statements.-Sep1-          :'
		endif
		"
			
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Always-Statements.always-&comb	<Esc><Esc>:call VERILOG_3FlowControl( "alway @( sensitivitylist )",     "begin",   "end",     "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Always-Statements.always-&seq		<Esc><Esc>:call VERILOG_3FlowControl( "alway @( posedge/negedge )",     "begin",   "end",     "a" )<CR>i'
		
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Always-Statements.always-&comb		<Esc><Esc>:call VERILOG_3FlowControl( "alway @( sensitivitylist )",     "begin",   "end",     "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Always-Statements.always-&seq		<Esc><Esc>:call VERILOG_3FlowControl( "alway @( posedge/negedge )",     "begin",   "end",     "a" )<CR>i'

		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Always-Statements.always-&comb		<Esc><Esc>:call VERILOG_3FlowControl( "alway @( sensitivitylist )",     "begin",   "end",     "v" )<CR>'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Always-Statements.always-&seq		<Esc><Esc>:call VERILOG_3FlowControl( "alway @( posedgenegedge )",     "begin",   "end",     "v" )<CR>'

		"
		
		"----- Submenu : VERILOG-Functions/Tasks Statements ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Statements.&Funcs-Tasks.Functions\ Tasks<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Statements.&Funcs-Tasks.-Sep1-          :'
		endif
		"
			
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Funcs-Tasks.&Functions		<Esc><Esc>:call VERILOG_4FlowControl( "function [automatic] [signed] [type] function_name [(function_port_list)];", "func_item_decl;", "func_stmts;",   "endfunction",     "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Statements.&Funcs-Tasks.&Tasks		    <Esc><Esc>:call VERILOG_4FlowControl( "task [automatic] task_name [(task_port_list)];", "task_item_decl;", "task_stmts;",   "endtask",     "a" )<CR>i'

       	"
		if s:VERILOG_CodeSnippets != ""
			exe "amenu  ".s:VERILOG_Root.'&Statements.-SEP3-                    		  :'
			exe "amenu  <silent> ".s:VERILOG_Root.'&Statements.read\ code\ snippet   <C-C>:call VERILOG_CodeSnippets("r")<CR>'
			exe "amenu  <silent> ".s:VERILOG_Root.'&Statements.write\ code\ snippet  <C-C>:call VERILOG_CodeSnippets("w")<CR>'
			exe "vmenu  <silent> ".s:VERILOG_Root.'&Statements.write\ code\ snippet  <C-C>:call VERILOG_CodeSnippets("wv")<CR>'
			exe "amenu  <silent> ".s:VERILOG_Root.'&Statements.edit\ code\ snippet   <C-C>:call VERILOG_CodeSnippets("e")<CR>'
		endif
		"
		"-------------------------------------------------------------------------------
		" menu Operators
		"-------------------------------------------------------------------------------
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Operators.Operators<Tab>Verilog         <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Operators.-Sep0-             :'
		endif
		
		"----- Submenu : Arithmetic Operators ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.Arithmetic\ Operators<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.-Sep1-          :'
		endif
		"
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.&multiply									<Esc>aop1 * op2 <Esc>F2la' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.&divide										<Esc>aop1 / op2 <Esc>F2la' 		
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.&add										<Esc>aop1 + op2 <Esc>F2la'
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.&subtract									<Esc>aop1 - op2 <Esc>F2la' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.&modulus									<Esc>aop1 % op2 <Esc>F2la' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.&power(exponent)							<Esc>aop1 ** op2 <Esc>F2la' 
		
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.&multiply									op1 * op2 <Esc>F2la' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.&divide									op1 / op2 <Esc>F2la' 		
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.&add										op1 + op2 <Esc>F2la'
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.&subtract									op1 - op2 <Esc>F2la' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.&modulus									op1 % op2 <Esc>F2la' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Arithmetic-Operators.&power(exponent)							op1 ** op2 <Esc>F2la' 
		
		"----- Submenu : Logical Operators ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			"exe "amenu ".s:VERILOG_Root.'&Operators.&Logical-Operators.Logical\ Operators<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Operators.&Logical-Operators.-Sep1-          :'
		endif
		"
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Logical-Operators.&negation									<Esc>a!op <Esc>F2pa' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Logical-Operators.&logical\ and								<Esc>aop1 && op2 <Esc>F2la' 		
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Logical-Operators.&logical\ &or								<Esc>aop1 \|\| op2 <Esc>F2la'
		
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Logical-Operators.&negation									!op <Esc>F2pa' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Logical-Operators.&logical\ and								op1 && op2 <Esc>F2la' 		
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Logical-Operators.&logical\ &or								op1 \|\| op2 <Esc>F2la'
	
		"----- Submenu : Relational Operators ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Operators.&Relational-Operators.Relational\ Operators<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Operators.&Relational-Operators.-Sep1-          :'
		endif
		"

		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Relational-Operators.&greater-than							<Esc>aop1 > op2 <Esc>F2la' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Relational-Operators.&less-than								<Esc>aop1 < op2 <Esc>F2la' 		
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Relational-Operators.greater-than&-or-equal					<Esc>aop1 >= op2 <Esc>F2la'
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Relational-Operators.less-than&-or-equal						<Esc>aop1 <= op2 <Esc>F2la' 
		
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Relational-Operators.&greater-than							op1 > op2 <Esc>F2la' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Relational-Operators.&less-than								op1 < op2 <Esc>F2la' 		
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Relational-Operators.greater-than&-or-equal					op1 >= op2 <Esc>F2la'
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Relational-Operators.less-than&-or-equal					op1 <= op2 <Esc>F2la' 

		"----- Submenu : Equality Operators ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Operators.&Equality-Operators.Equality\ Operators<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Operators.&Equality-Operators.-Sep1-          :'
		endif
		"

		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Equality-Operators.&equality						        <Esc>aop1 == op2 <Esc>F2la' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Equality-Operators.&inequality							<Esc>aop1 != op2 <Esc>F2la' 		
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Equality-Operators.&case-equality						<Esc>aop1 === op2 <Esc>F2la'
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Equality-Operators.&case-&inequality						<Esc>aop1 !== op2 <Esc>F2la' 
		
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Equality-Operators.&equality						    op1 == op2 <Esc>F2la' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Equality-Operators.&inequality							op1 != op2 <Esc>F2la' 		
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Equality-Operators.&case-equality						op1 === op2 <Esc>F2la'
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Equality-Operators.&case-&inequality					op1 !== op2 <Esc>F2la' 
		
		"----- Submenu : Bit-Wise Operators ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Operators.&Bitwise-Operators.Bitwise\ Operators<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Operators.&Bitwise-Operators.-Sep1-          :'
		endif
		"

		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Bitwise-Operators.negation						<Esc>a!op <Esc>Fpla' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Bitwise-Operators.and							<Esc>aop1 & op2 <Esc>F2la' 		
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Bitwise-Operators.or						        <Esc>aop1 \| op2 <Esc>F2la'
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Bitwise-Operators.xor						    <Esc>aop1 ^ op2 <Esc>F2la' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Bitwise-Operators.xnor						    <Esc>aop1 ~^ op2 <Esc>F2la' 

	
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Bitwise-Operators.negation						<Esc>a!op <Esc>Fpla' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Bitwise-Operators.and							<Esc>aop1 & op2 <Esc>F2la' 		
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Bitwise-Operators.or						    <Esc>aop1 \| op2 <Esc>F2la'
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Bitwise-Operators.xor						    <Esc>aop1 ^ op2 <Esc>F2la' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Bitwise-Operators.xnor						    <Esc>aop1 ~^ op2 <Esc>F2la' 

		
	
		"----- Submenu : Reduction Operators ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.Reduction\ Operators<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.-Sep1-          :'
		endif
		"

		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.or						    <Esc>a\|op <Esc>Fpla' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.nor							<Esc>a~\|op <Esc>Fpla' 		
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.and						    <Esc>a&op <Esc>Fpla'
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.nand						    <Esc>a~&op <Esc>Fpla' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.xor						    <Esc>a^op <Esc>Fpla' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.xnor						    <Esc>a~^op <Esc>Fpla' 

		
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.or						    \|op <Esc>Fpla' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.nor							~\|op <Esc>Fpla' 		
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.and						    &op <Esc>Fpla'
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.nand						~&op <Esc>Fpla' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.xor						    ^op <Esc>Fpla' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Reduction-Operators.xnor						~^op <Esc>Fpla' 

		
		
		"----- Submenu : Shift Operators ----------------------------------------------------------
		"
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Operators.&Shift-Operators.Shift\ Operators<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Operators.&Shift-Operators.-Sep1-          :'
		endif
		"

		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Shift-Operators.Left\ Shift						    <Esc>aop1 << op2 <Esc>F2la' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Shift-Operators.Right\ Shift 						<Esc>aop1 >> op2 <Esc>F2la' 		
		
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Shift-Operators.Left\ Shift						  op1 << op2 <Esc>F2la' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Shift-Operators.Right\ Shift 					  op1 >> op2 <Esc>F2la' 
		
		"----- Submenu : Concation-Replication Operators ----------------------------------------------------------

		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Operators.&Concat-Replicate.Concation\ Replication<Tab>Verilog      <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Operators.&Concat-Replicate.-Sep1-          :'
		endif
		"

		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Concat-Replicate.&Concatinate				<Esc>a{op1, op2 [,..]} <Esc>F}la' 
		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Concat-Replicate.&Replicate					<Esc>a{n1{op1} [,n2{op2}] [,...]} <Esc>F}la' 		

		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Concat-Replicate.&Concatinate				{op1, op2 [,..]} <Esc>F}la' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Concat-Replicate.&Replicate					{n1{op1} [,n2{op2}] [,...]} <Esc>F}la' 						
		
		exe "anoremenu ".s:VERILOG_Root.'&Operators.-SEP1-          :'

		exe "	noremenu ".s:VERILOG_Root.'&Operators.&Conditional				                    <Esc>acondition_expr?true_exp:false_exp <Esc>Fpla' 
		exe "	inoremenu ".s:VERILOG_Root.'&Operators.&Conditional				                    <Esc>acondition_expr?true_exp:false_exp <Esc>Fpla' 
		"
		"
		"
		
		"-------------------------------------------------------------------------------
		" menu Miscellaneous
		"-------------------------------------------------------------------------------
		if s:VERILOG_MenuHeader == "yes"
			exe "amenu ".s:VERILOG_Root.'&Miscellaneous.Misc<Tab>Verilog         <Esc>'
			exe "amenu ".s:VERILOG_Root.'&Miscellaneous.-Sep0-             :'
		endif
		
		exe "anoremenu ".s:VERILOG_Root.'&Miscellaneous.&force-release		<Esc><Esc>:call VERILOG_3FlowControl( "force",     "signal=value;",   "release signal;",     "a" )<CR>i'
		exe "anoremenu ".s:VERILOG_Root.'&Miscellaneous.&assign-deassign		<Esc><Esc>:call VERILOG_3FlowControl( "assign",     "signal=value;",   "deassign signal;",     "a" )<CR>i'
		
		exe "anoremenu ".s:VERILOG_Root.'&Miscellaneous.-SEP1-          :'
		
		exe "anoremenu ".s:VERILOG_Root.'&Miscellaneous.&translate-off\\translate-on		<Esc><Esc>:call VERILOG_3FlowControl( "/* synthesis translate-off */",     "",   "/* synthesis translate-on */",     "a" )<CR>i'
     	exe "inoremenu ".s:VERILOG_Root.'&Miscellaneous.&translate-off\\translate-on		<Esc><Esc>:call VERILOG_3FlowControl( "/* synthesis translate-off */",     "",   "/* synthesis translate-on */",     "i" )<CR>i'
		exe "vnoremenu ".s:VERILOG_Root.'&Miscellaneous.&translate-off\\translate-on		<Esc><Esc>:call VERILOG_3FlowControl( "/* synthesis translate-off */",     "",   "/* synthesis translate-on */",     "v" )<CR>'
		
		"-------------------------------------------------------------------------------
		" menu Plugin Settings
		"-------------------------------------------------------------------------------
            if s:VERILOG_MenuHeader == "yes"
			exe "amenu <silent> ".s:VERILOG_Root.'&Plugin\ Settings                      <C-C>:call VERILOG_Settings()<CR>'
		endif
		
		"===============================================================================================
		"----- Menu : help  ----------------------------------------------------------------------------
		"===============================================================================================
		"
		if s:VERILOG_Root != ""
			exe "amenu  <silent>  ".s:VERILOG_Root.'&Help\ \(plugin\)        <C-C><C-C>:call Verilog_HelpVerilogsupport()<CR>'
		endif
            
	
		"

				


	endif

endfunction		" ---------- end of function  VERILOG_InitMenu  ----------
"
"------------------------------------------------------------------------------
"  Input after a highlighted prompt
"------------------------------------------------------------------------------
function! VERILOG_Input ( prompt, text )
	echohl Search												" highlight prompt
	call inputsave()										" preserve typeahead
	let	retval=input( a:prompt, a:text )	" read input
	call inputrestore()									" restore typeahead
	echohl None													" reset highlighting
	return retval
endfunction		" ---------- end of function  VERILOG_Input  ----------
"
"------------------------------------------------------------------------------
"  VERILOG_AdjustLineEndComm: adjust line-end comments  
"------------------------------------------------------------------------------
function! VERILOG_AdjustLineEndComm ( mode ) range
	"
	if !exists("b:VERILOG_LineEndCommentColumn")
		let	b:VERILOG_LineEndCommentColumn	= s:VERILOG_LineEndCommColDefault
	endif

	let save_cursor = getpos(".")

	let	save_expandtab	= &expandtab
	exe	":set expandtab"

	if a:mode == 'v'
		let pos0	= line("'<")
		let pos1	= line("'>")
	else
		let pos0	= line(".")
		let pos1	= pos0
	end

	let	linenumber	= pos0
	exe ":".pos0

	while linenumber <= pos1
		let	line= getline(".")
		" look for a Perl comment
		let idx1	= 1 + match( line, '\s*#.*$' )
		let idx2	= 1 + match( line, '#.*$' )

		let	ln	= line(".")
		call setpos(".", [ 0, ln, idx1, 0 ] )
		let vpos1	= virtcol(".")
		call setpos(".", [ 0, ln, idx2, 0 ] )
		let vpos2	= virtcol(".")

		if   ! (   vpos2 == b:VERILOG_LineEndCommentColumn 
					\	|| vpos1 > b:VERILOG_LineEndCommentColumn
					\	|| idx2  == 0 )

			exe ":.,.retab"
			" insert some spaces
			if vpos2 < b:VERILOG_LineEndCommentColumn
				let	diff	= b:VERILOG_LineEndCommentColumn-vpos2
				call setpos(".", [ 0, ln, vpos2, 0 ] )
				let	@"	= ' '
				exe "normal	".diff."P"
			end

			" remove some spaces
			if vpos1 < b:VERILOG_LineEndCommentColumn && vpos2 > b:VERILOG_LineEndCommentColumn
				let	diff	= vpos2 - b:VERILOG_LineEndCommentColumn
				call setpos(".", [ 0, ln, b:VERILOG_LineEndCommentColumn, 0 ] )
				exe "normal	".diff."x"
			end

		end
		let linenumber=linenumber+1
		normal j
	endwhile
	" restore tab expansion settings and cursor position
	let &expandtab	= save_expandtab
	call setpos('.', save_cursor)

endfunction		" ---------- end of function  VERILOG_AdjustLineEndComm  ----------
"
"------------------------------------------------------------------------------
"  Comments : get line-end comment position
"------------------------------------------------------------------------------
function! VERILOG_GetLineEndCommCol ()
	let actcol	= virtcol(".")
	if actcol+1 == virtcol("$")
		let	b:VERILOG_LineEndCommentColumn	= VERILOG_Input( 'start line-end comment at virtual column : ', actcol )
	else
		let	b:VERILOG_LineEndCommentColumn	= virtcol(".") 
	endif
  echomsg "line end comments will start at column  ".b:VERILOG_LineEndCommentColumn
endfunction		" ---------- end of function  VERILOG_GetLineEndCommCol  ----------
"
"------------------------------------------------------------------------------
"  Comments : single line-end comment
"------------------------------------------------------------------------------
function! VERILOG_LineEndComment ()
	if !exists("b:VERILOG_LineEndCommentColumn")
		let	b:VERILOG_LineEndCommentColumn	= s:VERILOG_LineEndCommColDefault
	endif
	" ----- trim whitespaces -----
	exe "s/\s\*$//"
	let linelength= virtcol("$") - 1
	if linelength < b:VERILOG_LineEndCommentColumn
		let diff	= b:VERILOG_LineEndCommentColumn -1 -linelength
		exe "normal	".diff."A "
	endif
	" append at least one blank
	if linelength >= b:VERILOG_LineEndCommentColumn
		exe "normal A "
	endif
	exe "normal A/\/ "
endfunction		" ---------- end of function  VERILOG_LineEndComment  ----------
"
"------------------------------------------------------------------------------
"  Comments : multi line-end comments
"------------------------------------------------------------------------------
function! VERILOG_MultiLineEndComments ()
  if !exists("b:VERILOG_LineEndCommentColumn")
		let	b:VERILOG_LineEndCommentColumn	= s:VERILOG_LineEndCommColDefault
  endif
	"
	let pos0	= line("'<")
	let pos1	= line("'>")
	" ----- trim whitespaces -----
	exe "'<,'>s/\s\*$//"
	" ----- find the longest line -----
	let	maxlength		= 0
	let	linenumber	= pos0
	normal '<
	while linenumber <= pos1
		if  getline(".") !~ "^\\s*$"  && maxlength<virtcol("$")
			let maxlength= virtcol("$")
		endif
		let linenumber=linenumber+1
		normal j
	endwhile
	"
	if maxlength < b:VERILOG_LineEndCommentColumn
	  let maxlength = b:VERILOG_LineEndCommentColumn
	else
	  let maxlength = maxlength+1		" at least 1 blank
	endif
	"
	" ----- fill lines with blanks -----
	let	linenumber	= pos0
	normal '<
	while linenumber <= pos1
		if getline(".") !~ "^\\s*$"
			let diff	= maxlength - virtcol("$")
			exe "normal	".diff."A "
			exe "normal	$A/\/ "
		endif
		let linenumber=linenumber+1
		normal j
	endwhile
	" ----- back to the begin of the marked block -----
	normal '<
endfunction		" ---------- end of function  VERILOG_MultiLineEndComments  ----------
"
"------------------------------------------------------------------------------
"  Substitute tags
"------------------------------------------------------------------------------
function! VERILOG_SubstituteTag( pos1, pos2, tag, replacement )
	" 
	" loop over marked block
	" 
	let	linenumber=a:pos1
	while linenumber <= a:pos2
		let line=getline(linenumber)
		" 
		" loop for multiple tags in one line
		" 
		let	start=0
		while match(line,a:tag,start)>=0				" do we have a tag ?
			let frst=match(line,a:tag,start)
			let last=matchend(line,a:tag,start)
			if frst!=-1
				let part1=strpart(line,0,frst)
				let part2=strpart(line,last)
				let line=part1.a:replacement.part2
				"
				" next search starts after the replacement to suppress recursion
				" 
				let start=strlen(part1)+strlen(a:replacement)
			endif
		endwhile
		call setline( linenumber, line )
		let	linenumber=linenumber+1
	endwhile

endfunction    " ----------  end of function  Verilog_SubstituteTag  ----------
"
"------------------------------------------------------------------------------
"  Verilog-Comments : Insert Template Files
"------------------------------------------------------------------------------
function! VERILOG_CommentTemplates (arg)

	"----------------------------------------------------------------------
	"  VERILOG templates
	"----------------------------------------------------------------------
	if a:arg=='frame'
		let templatefile=s:VERILOG_Template_Directory.s:VERILOG_Template_Frame
	endif

	if a:arg=='function'
		let templatefile=s:VERILOG_Template_Directory.s:VERILOG_Template_Function
	endif

	if a:arg=='header'
		let templatefile=s:VERILOG_Template_Directory.s:VERILOG_Template_File
	endif


	if filereadable(templatefile)
		let	length= line("$")
		let	pos1  = line(".")+1
		let l:old_cpoptions	= &cpoptions " Prevent the alternate buffer from being set to this files
		setlocal cpoptions-=a
		if  a:arg=='header' 
			:goto 1
			let	pos1  = 1
			exe '0read '.templatefile
		else
			exe 'read '.templatefile
		endif
		let &cpoptions	= l:old_cpoptions		" restore previous options
		let	length= line("$")-length
		let	pos2  = pos1+length-1
		"----------------------------------------------------------------------
		"  frame blocks will be indented
		"----------------------------------------------------------------------
		if a:arg=='frame'
			let	length	= length-1
			silent exe "normal =".length."+"
			let	length	= length+1
		endif
		"----------------------------------------------------------------------
		"  substitute keywords
		"----------------------------------------------------------------------
		" 
		call  VERILOG_SubstituteTag( pos1, pos2, '|FILENAME|',        expand("%:t")               )
		call  VERILOG_SubstituteTag( pos1, pos2, '|DATE|',            VERILOG_InsertDateAndTime('d') )
		call  VERILOG_SubstituteTag( pos1, pos2, '|DATETIME|',        VERILOG_InsertDateAndTime('dt'))
		call  VERILOG_SubstituteTag( pos1, pos2, '|TIME|',            VERILOG_InsertDateAndTime('t') )
		call  VERILOG_SubstituteTag( pos1, pos2, '|YEAR|',            VERILOG_InsertDateAndTime('y') )
		call  VERILOG_SubstituteTag( pos1, pos2, '|AUTHOR|',          s:VERILOG_AuthorName     )
		call  VERILOG_SubstituteTag( pos1, pos2, '|EMAIL|',           s:VERILOG_Email          )
		call  VERILOG_SubstituteTag( pos1, pos2, '|AUTHORREF|',       s:VERILOG_AuthorRef      )
		call  VERILOG_SubstituteTag( pos1, pos2, '|PROJECT|',         s:VERILOG_Project        )
		call  VERILOG_SubstituteTag( pos1, pos2, '|COMPANY|',         s:VERILOG_Company        )
		call  VERILOG_SubstituteTag( pos1, pos2, '|COPYRIGHTHOLDER|', s:VERILOG_CopyrightHolder)
		"
		" now the cursor
		"
		exe ':'.pos1
		normal 0
		let linenumber=search('|CURSOR|')
		if linenumber >=pos1 && linenumber<=pos2
			let pos1=match( getline(linenumber) ,"|CURSOR|")
			if  matchend( getline(linenumber) ,"|CURSOR|") == match( getline(linenumber) ,"$" )
				silent! s/|CURSOR|//
				" this is an append like A
				:startinsert!
			else
				silent  s/|CURSOR|//
				call cursor(linenumber,pos1+1)
				" this is an insert like i
				:startinsert
			endif
		endif

	else
		echohl WarningMsg | echo 'template file '.templatefile.' does not exist or is not readable'| echohl None
	endif
	return
endfunction    " ----------  end of function  VERILOG_CommentTemplates  ----------
"
"------------------------------------------------------------------------------
"  Comments : classified comments
"------------------------------------------------------------------------------
function! VERILOG_CommentClassified (class)
  	put = '// :'.a:class.':'.VERILOG_InsertDateAndTime('d').':'.s:VERILOG_AuthorRef.': '
endfunction
"
"------------------------------------------------------------------------------
"  Comments : vim modeline
"------------------------------------------------------------------------------
function! VERILOG_CommentVimModeline ()
  	put = '# vim: set tabstop='.&tabstop.' shiftwidth='.&shiftwidth.': '
endfunction    " ----------  end of function VERILOG_CommentVimModeline  ----------
"

"-------------------------------------------------------------------------------
"   Statements : 3flow control
"-------------------------------------------------------------------------------
function! VERILOG_3FlowControl ( part1, part2, part3, mode )

	if s:VERILOG_DoOnNewLine=='yes'
		let	splt = "\n"
	else
		let	splt = "; "
	end
	if a:mode == 'a'
	        let startline= line(".")
	else     
	        let startline= line("'<")
    end
    
    let spacelength= indent (startline)
    
	let i=1
	let add_space = ""
	let temp = " "
	while i < spacelength
	   let temp = add_space
	   let add_space = temp." "
	   let i = i + 1
	endwhile   
	
	
	let	startposition	= line(".")+1
	"-------------------------------------------------------------------------------
	"   normal mode, insert mode
	"-------------------------------------------------------------------------------
	if a:mode=='a'
		let	zz = add_space.a:part1.splt.add_space.a:part2.splt.add_space."\n".add_space.a:part3
		put =zz
		let	lines = line(".")-startposition+1
		exe ":".startposition
	end
	"-------------------------------------------------------------------------------
	"   visual mode
	"-------------------------------------------------------------------------------
	if a:mode=='v'
		let	lines = line("'>")-line("'<")+1
		let	zz = add_space.a:part1.splt.add_space.a:part2.splt.add_space."\n"
		normal '<
		put! =zz
		let	zz = splt.add_space.a:part3
		exe "'<,'>s/^/\t/"
		normal '>
		put  =zz
		if a:part3 =~ 'else'
			let	lines = lines+1
		end
		if s:VERILOG_DoOnNewLine=='yes'
			let	lines = lines+3
			:'<-2
		else
			let	lines = lines+2
			:'<-1
		end
	end
	"exe "normal ".lines."=="
	normal f_x
endfunction    " ----------  end of function VERILOG_3FlowControl  ----------
"
"
"-------------------------------------------------------------------------------
"   Statements : 4flow control
"-------------------------------------------------------------------------------

function! VERILOG_4FlowControl ( part1, part2, part3,part4, mode )

	if s:VERILOG_DoOnNewLine=='yes'
		let	splt = "\n"
	else
		let	splt = "; "
	end
	if a:mode == 'a'
	        let startline= line(".")
	else     
	        let startline= line("'<")
    end
    
    let spacelength= indent (startline)
    
	let i=1
	let add_space = ""
	let temp = " "
	while i < spacelength
	   let temp = add_space
	   let add_space = temp." "
	   let i = i + 1
	endwhile   
	
	
	let	startposition	= line(".")+1
	"-------------------------------------------------------------------------------
	"   normal mode, insert mode
	"-------------------------------------------------------------------------------
	if a:mode=='a'
		let	zz = add_space.a:part1.splt.add_space.a:part2.splt.add_space."\n".a:part3.splt.add_space."\n".add_space.a:part4
		put =zz
		let	lines = line(".")-startposition+1
		exe ":".startposition
	end
	"-------------------------------------------------------------------------------
	"   visual mode
	"-------------------------------------------------------------------------------
	if a:mode=='v'
		let	lines = line("'>")-line("'<")+1
		let	zz = add_space.a:part1.splt.add_space.a:part2.splt.add_space"\n"
		normal '<
		put! =zz
		let	zz = add_space."\n".add_space.a:part3.splt.add_space."\n".add_space.a:part4
		exe "'<,'>s/^/\t/"
		normal '>
		put  =zz
		if a:part3 =~ 'else'
			let	lines = lines+1
		end
		if s:VERILOG_DoOnNewLine=='yes'
			let	lines = lines+3
			:'<-2
		else
			let	lines = lines+2
			:'<-1
		end
	end
	"exe "normal ".lines."=="
	normal f_x
endfunction    " ----------  end of function VERILOG_4FlowControl  ----------
"
"
"-------------------------------------------------------------------------------
"   Statements : 5flow control
"-------------------------------------------------------------------------------

function! VERILOG_5FlowControl ( part1, part2, part3,part4,part5, mode )

	if s:VERILOG_DoOnNewLine=='yes'
		let	splt = "\n"
	else
		let	splt = "; "
	end
	if a:mode == 'a'
	        let startline= line(".")
	else     
	        let startline= line("'<")
    end
    
    let spacelength= indent (startline)
    
	let i=1
	let add_space = ""
	let temp = " "
	while i < spacelength
	   let temp = add_space
	   let add_space = temp." "
	   let i = i + 1
	endwhile   
	
	
	let	startposition	= line(".")+1
	"-------------------------------------------------------------------------------
	"   normal mode, insert mode
	"-------------------------------------------------------------------------------
	if a:mode=='a'
		let	zz = add_space.a:part1.splt.add_space.a:part2.splt.add_space."\n".a:part3.splt.add_space."\n".add_space.a:part4.add_space."\n".add_space.a:part5
		put =zz
		let	lines = line(".")-startposition+1
		exe ":".startposition
	end
	"-------------------------------------------------------------------------------
	"   visual mode
	"-------------------------------------------------------------------------------
	if a:mode=='v'
		let	lines = line("'>")-line("'<")+1
		let	zz = add_space.a:part1.splt.add_space.a:part2.splt.add_space"\n"
		normal '<
		put! =zz
		let	zz = add_space."\n".add_space.a:part3.splt.add_space."\n".add_space.a:part4.add_space."\n".add_space.a:part5
		exe "'<,'>s/^/\t/"
		normal '>
		put  =zz
		if a:part3 =~ 'else'
			let	lines = lines+1
		end
		if s:VERILOG_DoOnNewLine=='yes'
			let	lines = lines+3
			:'<-2
		else
			let	lines = lines+2
			:'<-1
		end
	end
	"exe "normal ".lines."=="
	normal f_x
endfunction    " ----------  end of function VERILOG_5FlowControl  ----------
"
"

"-------------------------------------------------------------------------------
"   Statements : 6flow control
"-------------------------------------------------------------------------------

function! VERILOG_6FlowControl ( part1, part2, part3,part4,part5,part6, mode )

	if s:VERILOG_DoOnNewLine=='yes'
		let	splt = "\n"
	else
		let	splt = "; "
	end
	if a:mode == 'a'
	        let startline= line(".")
	else     
	        let startline= line("'<")
    end
    
    let spacelength= indent (startline)
    
	let i=1
	let add_space = ""
	let temp = " "
	while i < spacelength
	   let temp = add_space
	   let add_space = temp." "
	   let i = i + 1
	endwhile   
	
	
	let	startposition	= line(".")+1
	"-------------------------------------------------------------------------------
	"   normal mode, insert mode
	"-------------------------------------------------------------------------------
	if a:mode=='a'
		let	zz = add_space.a:part1.splt.add_space.a:part2.splt.add_space.a:part3.splt.add_space.a:part4.splt.add_space."\n".add_space.a:part5.splt.add_space."\n".add_space.a:part6
		put =zz
		let	lines = line(".")-startposition+1
		exe ":".startposition
	end
	"-------------------------------------------------------------------------------
	"   visual mode
	"-------------------------------------------------------------------------------
	if a:mode=='v'
		let	lines = line("'>")-line("'<")+1
		let	zz = add_space.a:part1.splt.add_space.a:part2.splt.add_space.a:part3.splt.add_space.a:part4.splt
		normal '<
		put! =zz
		let	zz = add_space."\n".add_space.a:part5.splt.add_space."\n".add_space.a:part6
		exe "'<,'>s/^/\t/"
		normal '>
		put  =zz
		if a:part3 =~ 'else'
			let	lines = lines+1
		end
		if s:VERILOG_DoOnNewLine=='yes'
			let	lines = lines+3
			:'<-2
		else
			let	lines = lines+2
			:'<-1
		end
	end
	"exe "normal ".lines."=="
	normal f_x
endfunction    " ----------  end of function VERILOG_6FlowControl  ----------
"
"



"------------------------------------------------------------------------------
"  Verilog-Idioms : read / edit code snippet
"------------------------------------------------------------------------------
function! VERILOG_CodeSnippets(arg1)
	if isdirectory(s:VERILOG_CodeSnippets)
		"
		" read snippet file, put content below current line
		"
		if a:arg1 == "r"
			if has("gui_running")
				let	l:snippetfile=browse(0,"read a code snippet",s:VERILOG_CodeSnippets,"")
			else
				let	l:snippetfile=input("read snippet ", s:VERILOG_CodeSnippets, "file" )
			end
			if filereadable(l:snippetfile)
				let	linesread= line("$")
				"
				" Prevent the alternate buffer from being set to this files
				let l:old_cpoptions	= &cpoptions
				setlocal cpoptions-=a
				:execute "read ".l:snippetfile
				let &cpoptions	= l:old_cpoptions		" restore previous options
				"
				let	linesread= line("$")-linesread-1
				if linesread>=0 && match( l:snippetfile, '\.\(ni\|noindent\)$' ) < 0 
					silent exe "normal =".linesread."+"
				endif
			endif
		endif
		"
		" update current buffer / split window / edit snippet file
		" 
		if a:arg1 == "e"
			if has("gui_running")
				let	l:snippetfile=browse(0,"edit a code snippet",s:VERILOG_CodeSnippets,"")
			else
				let	l:snippetfile=input("edit snippet ", s:VERILOG_CodeSnippets, "file" )
			end
			if l:snippetfile != ""
				:execute "update! | split | edit ".l:snippetfile
			endif
		endif
		"
		" write whole buffer or marked area into snippet file 
		" 
		if a:arg1 == "w" || a:arg1 == "wv"
			if has("gui_running")
				let	l:snippetfile=browse(0,"write a code snippet",s:VERILOG_CodeSnippets,"")
			else
				let	l:snippetfile=input("write snippet ", s:VERILOG_CodeSnippets, "file" )
			end
			if l:snippetfile != ""
				if filereadable(l:snippetfile)
					if confirm("File exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
						return
					endif
				endif
				if a:arg1 == "w"
					:execute ":write! ".l:snippetfile
				else
					:execute ":*write! ".l:snippetfile
				end
			endif
		endif

	else
		echo "code snippet directory ".s:VERILOG_CodeSnippets." does not exist (please create it)"
	endif
endfunction		" ---------- end of function  VERILOG_CodeSnippets  ----------
"
"------------------------------------------------------------------------------
"  run : hardcopy
"------------------------------------------------------------------------------
function! VERILOG_Hardcopy (arg1)
	let	Sou		= expand("%")								" name of the file in the current buffer
  if Sou == ""
		redraw
		echohl WarningMsg | echo " no file name " | echohl None
		return
  endif
	let	old_printheader=&printheader
	exe  ':set printheader='.s:VERILOG_Printheader
	" ----- normal mode ----------------
	if a:arg1=="n"
		silent exe	"hardcopy > ".Sou.".ps"		
		echo "file \"".Sou."\" printed to \"".Sou.".ps\""
	endif
	" ----- visual mode ----------------
	if a:arg1=="v"
		silent exe	"*hardcopy > ".Sou.".ps"		
		echo "file \"".Sou."\" (lines ".line("'<")."-".line("'>").") printed to \"".Sou.".ps\""
	endif
	exe  ':set printheader='.escape( old_printheader, ' %' )
endfunction		" ---------- end of function  VERILOG_Hardcopy  ----------
"
"------------------------------------------------------------------------------
"  Run : settings
"------------------------------------------------------------------------------
function! VERILOG_Settings ()
	let	txt	=     "     Verilog-Support settings\n\n"
	let txt = txt."               author name :  \"".s:VERILOG_AuthorName."\"\n"
	let txt = txt."                  initials :  \"".s:VERILOG_AuthorRef."\"\n"
	let txt = txt."              author  email :  \"".s:VERILOG_Email."\"\n"
	let txt = txt."                   company :  \"".s:VERILOG_Company."\"\n"
	let txt = txt."                   project :  \"".s:VERILOG_Project."\"\n"
	let txt = txt."          copyright holder :  \"".s:VERILOG_CopyrightHolder."\"\n"
	let txt = txt."    code snippet directory :  ".s:VERILOG_CodeSnippets."\n"
	let txt = txt."        template directory :  ".s:VERILOG_Template_Directory."\n"
	if g:VERILOG_Dictionary_File != ""
		let ausgabe= substitute( g:VERILOG_Dictionary_File, ",", ",\n                         + ", "g" )
		let txt = txt."        dictionary file(s) :  ".ausgabe."\n"
	endif
	let txt = txt."      current output dest. :  ".s:VERILOG_OutputGvim."\n"
	let txt = txt."\n"
	let	txt = txt." Verilog-Support, Version ".g:VERILOG_Version." / T.Anil Kumar / anil.tallapragada@gmail.com\n\n"
	echo txt
endfunction		" ---------- end of function  VERILOG_Settings  ----------
"
"------------------------------------------------------------------------------
"  run : help vlogsupport 
"------------------------------------------------------------------------------
function! Verilog_HelpVerilogsupport ()
	try
		:help vlogsupport
	catch
		exe ':helptags '.s:plugin_dir.'doc'
		:help vlogsupport
	endtry
endfunction    " ----------  end of function VERILOG_HelpVERILOGsupport ----------

"------------------------------------------------------------------------------
"  date and time
"------------------------------------------------------------------------------
function! VERILOG_InsertDateAndTime ( format )
	if a:format == 'd'
		return strftime( s:VERILOG_FormatDate )
	end
	if a:format == 't'
		return strftime( s:VERILOG_FormatTime )
	end
	if a:format == 'dt'
		return strftime( s:VERILOG_FormatDate ).' '.strftime( s:VERILOG_FormatTime )
	end
	if a:format == 'y'
		return strftime( s:VERILOG_FormatYear )
	end
	
endfunction    " ----------  end of function VERILOG_InsertDateAndTime  ----------
"
"------------------------------------------------------------------------------
"  VERILOG_CreateGuiMenus
"------------------------------------------------------------------------------
let s:VERILOG_MenuVisible = 0								" state : 0 = not visible / 1 = visible
"
function! VERILOG_CreateGuiMenus ()
	if s:VERILOG_MenuVisible != 1
		aunmenu <silent> &Tools.Load\ Verilog\ Support
		amenu   <silent> 40.2000 &Tools.-SEP101- : 
		amenu   <silent> 40.2021 &Tools.Unload\ Verilog\ Support <C-C>:call VERILOG_RemoveGuiMenus()<CR>
		call VERILOG_InitMenu()
		let s:VERILOG_MenuVisible = 1
	endif
endfunction    " ----------  end of function VERILOG_CreateGuiMenus  ----------

"------------------------------------------------------------------------------
"  VERILOG_ToolMenu
"------------------------------------------------------------------------------
function! VERILOG_ToolMenu ()
	amenu   <silent> 40.2000 &Tools.-SEP101- : 
	amenu   <silent> 40.2021 &Tools.Load\ Verilog\ Support <C-C>:call VERILOG_CreateGuiMenus()<CR>
endfunction    " ----------  end of function VERILOG_ToolMenu  ----------

"------------------------------------------------------------------------------
"  VERILOG_RemoveGuiMenus
"------------------------------------------------------------------------------
function! VERILOG_RemoveGuiMenus ()
	if s:VERILOG_MenuVisible == 1
		if s:VERILOG_Root == ""
			aunmenu <silent> Comments
			aunmenu <silent> Statements
			aunmenu <silent> Operators
			aunmenu <silent> Misc
		else
			exe "aunmenu <silent> ".s:VERILOG_Root
		endif
		"
		aunmenu <silent> &Tools.Unload\ Verilog\ Support
		call VERILOG_ToolMenu()
		"
		let s:VERILOG_MenuVisible = 0
	endif
endfunction    " ----------  end of function VERILOG_RemoveGuiMenus  ----------
"

"------------------------------------------------------------------------------
"  show / hide the menus
"  define key mappings (gVim only) 
"------------------------------------------------------------------------------
"
if has("gui_running")
	"
	call VERILOG_ToolMenu()
	"
	if s:VERILOG_LoadMenus == 'yes'
		call VERILOG_CreateGuiMenus()
	endif
	"
	nmap    <silent>  <Leader>lvs             :call VERILOG_CreateGuiMenus()<CR>
	nmap    <silent>  <Leader>uvs             :call VERILOG_RemoveGuiMenus()<CR>
	"
endif
"
"------------------------------------------------------------------------------
"  Automated header insertion
"------------------------------------------------------------------------------
"
if has("autocmd")
	" 
	" Verilog-script : insert header, write file, make it executable
	" 
	autocmd BufNewFile  *.v    call VERILOG_CommentTemplates('header') 	|	:w! 
	"
endif " has("autocmd")
"
"------------------------------------------------------------------------------
"  Avoid a wrong syntax highlighting for $(..) and $((..))
"------------------------------------------------------------------------------
"
let is_verilog	            = 1
"
"------------------------------------------------------------------------------
"  vim: set tabstop=2: set shiftwidth=2: 
