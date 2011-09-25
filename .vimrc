" Make Vim behave in a more useful way (don't be compatible with Vi)
set nocompatible

" Run pathogen to add all plugins
call pathogen#runtime_append_all_bundles()

" Force reloading file type detection. On Debian the system vimrc enables
" file type detection before pathogen has run so reloading is necessary.
filetype off

" Enable file type detection
filetype on

" Load plug-in files for specific file types
filetype plugin on

" Load the indent file for specific file types
filetype indent on

" Force 256 colors if xterm is in use or builtin_gui (vimperator workaround)
if &term == "xterm" || &term == "builtin_gui"
   set t_Co=256
endif

" Allow backspacing over autoindent and over the start of insert
set backspace=indent,start

" Remember marks for the last 20 files, contents of registers (up to 50 lines), registers with more than 100 KB text are
" skipped, restore hlsearch and save them to ~/.viminfo
set viminfo='20,<50,s100,h,n~/.viminfo

" Use enhanced command-line completion mode
set wildmenu
" When more than one match, list all matches and complete till longest common string
set wildmode=list:longest
" Ignore these file extensions
set wildignore=*.o,*.obj,*.exe,*.class,*.pyc,*.jpg,*.png,*.gif,*.pdf

" Set backup directory
set backupdir=~/.vim/backups
" Set swap file directory
let $VIM_SWAP_DIR=expand("~/.vim/swap")
set directory=$VIM_SWAP_DIR

if version >= 703
   set undofile

   let $VIM_UNDO_DIR=expand("~/.vim/undo")
   set undodir=$VIM_UNDO_DIR
endif

" Sets how many lines of history VIM has to remember
set history=500

" Maximum width of text that is being inserted. A longer line will wrap.
set textwidth=120

" Support all three fileformats, in this order
set fileformats=unix,dos,mac

" Ignore changes in amount of white spaces.
set diffopt+=iwhite

" Allow backgrounding buffers without writing them.
set hidden

"
" Indent
"

" Use spaces instead of tabs
set expandtab
" Number of spaces that a <Tab> counts for while performing editing operations
set softtabstop=3
" Number of spaces to use for each step of (auto)indent.
set shiftwidth=3
" Number of spaces that a <Tab> in the file counts for.
set tabstop=3
" Copy indent from current line when starting a new line
set autoindent
" Do smart autoindenting when starting a new line.
set smartindent

"
" UI
"

" Enable syntax highlighting
syntax on
" Show the line and column number of the cursor position
set ruler
" Print the line number in front of each line.
set number
" Always show the status line in the last window
set laststatus=2
" When a bracket is inserted, briefly jump to the matching one
set showmatch
" Tenths of a second to show the matching paren
set matchtime=15
" Show (partial) command in the last line of the screen.
set showcmd
" Try to use colors that look good on a dark background
set background=dark
" Minimal number of screen lines to keep above and below the cursor
set scrolloff=5
" Minimal number of columns to scroll horizontally.
set sidescroll=1
" Turn on folding
set foldenable
" Set colorscheme
if &t_Co == 256 && filereadable(expand("$HOME/.vim/colors/xoria256.vim"))
   colorscheme xoria256
endif
" Set the strings to use in 'list' mode.
set listchars=tab:▸\ ,eol:¬
" Splitting a window will put the new window right of the current one.
set splitright

"
"" GUI
"

if has("gui_running")
   " Remove toolbar
   set guioptions-=T
   " Remove menubar
   set guioptions-=m
   " Remove right-hand scrollbar
   set guioptions-=r
   " Remove left-hand scrollbar when there is a vertically split window
   set guioptions-=L
endif

"
" Custom syntax
"

highlight WhiteSpaceEOL ctermbg=red guibg=red term=bold
syntax match WhiteSpaceEOL /\s\+$\| \+\ze\t/


"
"" Mouse
"

" Enable the use of mouse in all modes
set mouse=a
" Name of the terminal type of which mouse codes are to be recognized.
set ttymouse=xterm2

"
" Status line
"

" Clear statusline
set statusline=
" Append buffer number
set statusline+=%2*%-n
" Append total number of buffers
set statusline+=/%-3.3{CountBuffers()}%0* 
" Append filename
set statusline+=%f
" Append help buffer ([help]), modified flag ([+]), readonly flag ([RO]), preview window flag ([Preview])
set statusline+=\ %(%h%1*%m%r%w%0*%)
" Append filetype
set statusline+=\[%{strlen(&ft)?&ft:'none'},
" Append encoding
set statusline+=%{&encoding},
" Append fileformat
set statusline+=%{&fileformat}
" Append separation point between left and right aligned items and change color to black
set statusline+=]%=%2*
" Set git branch info
set statusline+=%(%{GitBranchInfoString()}\ %)
" Append value of byte under cursor in hexadecimal
set statusline+=0x%-8B
" Append line number, column number, virtual column number, append truncation point
" and percentage through file of displayed window
set statusline+=%-14.(%l,%c%V%)\ %<%P

"
" Search
"

" While typing a search command, show where the pattern, as it was typed so far, matches
set incsearch
" When there is a previous search pattern, highlight all its matches
set hlsearch
" Ignore the case of normal letters
set ignorecase
" Override the 'ignorecase' option if the search pattern contains upper case characters
set smartcase

"
" Bells
"

" Don't ring the bell (beep or screen flash) for error messages.
set noerrorbells
" Don't use visual bell instead of beeping.
set novisualbell
" Don't beep or flash
set t_vb=

"
"" Spelling
"
set nospell
set spelllang=en_gb

"
" Functions
"

"
"" Open current line in browser
"
let s:browser="firefox"

function! Browser()
   if exists("s:browser")
      let line = getline(".")
      let line = matchstr(line, "http[^ ]*")
      if strlen(line) > 0
         execute "!".s:browser." ".line
      endif
   endif
endfunction

function! ChangeShellScriptMode()
   if getline(1) =~ "^#!/usr/bin/env [a-z]*sh$"
      silent !chmod u+x <afile>
   endif
endfunction

function! CountBuffers()
   return len(filter(range(1,bufnr('$')),'buflisted(v:val)'))
endfunction

function! ReplaceTextWithFile(filename)
   normal ggVGd
   execute ":read ".a:filename
   normal ggdd
endfunction

function! CallMaven(type, clean, skip_tests)
   set makeprg=mvn
   set errorformat=\%-G[%\\(WARNING]%\\)%\\@!%.%#,
    \%A%[%^[]%\\@=%f:[%l\\,%v]\ %m,
    \%W[WARNING]\ %f:[%l\\,%v]\ %m,
    \%-Z\ %#,
    \%-Clocation\ %#:%.%#,
    \%C%[%^:]%#%m,
    \%-G%.%#

   if a:clean == 1
      let args="clean ".a:type
   else
      let args=a:type
   endif

   if a:skip_tests == 1
      let args.=" -Dmaven.test.skip=true"
   endif

   if exists("g:maven_pom")
      let args.=" -f ".g:maven_pom
   endif

   if exists("g:maven_params")
      let args.=" ".g:maven_params
   endif

   exe ':make '.args
endfunction

"
"" Keyboard mappings
"

" Set mapleader
let mapleader = "\\"
" Set localleader (for plugins)
let maplocalleader = "_"

" Update help
map <leader>uh :call pathogen#helptags()<cr>

" Run ctags
map <silent> <leader>r :!ctags -R --exclude=.svn --exclude=.git --exclude=log *<cr>

" Show invisible characters
nmap <leader>l :set list!<cr>

" Toggle NERDTree plugin
map <silent> <c-b> :NERDTreeToggle<cr>

" Toggle Tag list plugin
map <silent> <c-n> :TlistToggle<cr>

" Disable arrows
map <down> <nop>
map <left> <nop>
map <right> <nop>
map <up> <nop>

imap <down> <nop>
imap <left> <nop>
imap <right> <nop>
imap <up> <nop>

map <c-up> :cprevious<cr>
map <c-down> :cnext<cr>

" Switch to current directory
map <leader>cd :cd %:p:h<cr>

" Detect filetype again
map <leader>fd :filetype detect<cr>

map <leader>m :call CallMaven("install", 0, 0)<cr>
map <leader>mc :call CallMaven("install", 1, 0)<cr>
map <leader>ms :call CallMaven("install", 0, 1)<cr>
map <leader>mcs :call CallMaven("install", 1, 1)<cr>

" Remove the Windows ^M
noremap <leader>M mmHmt:%s/<c-v><cr>//ge<cr>'tzt'm

" Spell toggle
nmap <silent> <leader>s :set spell!<cr>

" Paste toggle
set pastetoggle=<f3>

map <f7> :py set_breakpoint()<cr>
map <s-f7> :py remove_breakpoints()<cr>

" Remove indenting on empty lines
map <f2> :%s/\s*$//g<cr>:set nohlsearch <cr>''

" Toggle line numbers
map <f1> :set number!<cr>

" Open current line in browser
map <silent> <leader>w :call Browser()<cr>

" Calculate line with bc
map <silent> <leader>c "pyy"pp!!bc<cr>kgJa=<esc>

" Move line up
nnoremap <A-k> :m-2<cr>
" Move line down
nnoremap <A-j> :m+<cr>
" Move visual selection up
vnoremap <A-k> :m-2<cr>gv
" Move visual selection down
vnoremap <A-j> :m'>+<cr>gv

" Redraw the screen and remove any search highlighting
nnoremap <silent> <C-l> :nohl<cr><C-l>


"
"" Autocommands
"

" Make sure autocommands are loaded only once
if !exists("autocommands_loaded") && has("autocmd")
   " Set noexpandtab automatically when editing makefiles
   autocmd FileType make setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
   autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
   autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
   autocmd FileType html setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
   autocmd FileType htmldjango setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
   " Reload vimrc after editing
   autocmd BufWritePost ~/.vimrc source ~/.vimrc
   " Commit todo-list after write
   autocmd BufWritePost ~/todo/todo.otl !git --git-dir=$HOME/todo/.git --work-tree=$HOME/todo commit -a --message="Updated todo list"
   " Automatically make shell scripts executable
   autocmd BufWritePost *.sh call ChangeShellScriptMode()
   " Enable spelling for *.txt files
   autocmd BufRead,BufNewFile *.txt set spell
   " JSON
   autocmd BufRead,BufNewFile *.json setfiletype json
   " Prevent losing syntax after new syntax file is loaded
   autocmd Syntax * syntax match WhiteSpaceEOL /\s\+$\| \+\ze\t/

   let autocommands_loaded=1
endif


"
"" Tip 80
"
" When we reload, tell vim to restore the cursor to the saved position
augroup JumpCursorOnEdit
 autocmd!
 autocmd BufReadPost *
 \ if expand("<afile>:p:h") !=? $TEMP |
 \ if line("'\"") > 1 && line("'\"") <= line("$") |
 \ let JumpCursorOnEdit_foo = line("'\"") |
 \ let b:doopenfold = 1 |
 \ if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
 \ let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
 \ let b:doopenfold = 2 |
 \ endif |
 \ exe JumpCursorOnEdit_foo |
 \ endif |
 \ endif
 " Need to postpone using "zv" until after reading the modelines.
 autocmd BufWinEnter *
 \ if exists("b:doopenfold") |
 \ exe "normal zv" |
 \ if(b:doopenfold > 1) |
 \ exe "+".1 |
 \ endif |
 \ unlet b:doopenfold |
 \ endif
augroup END

"
"" Create backup, swap and undo directories
"
if !isdirectory(&backupdir)
   call mkdir(&backupdir)
endif

if exists("$VIM_SWAP_DIR") && !isdirectory($VIM_SWAP_DIR)
   call mkdir($VIM_SWAP_DIR)
endif

if exists("$VIM_UNDO_DIR") && !isdirectory($VIM_UNDO_DIR)
   call mkdir($VIM_UNDO_DIR)
endif


"
"" NERDTree plugin
"

let NERDTreeQuitOnOpen = 1
let NERDTreeShowHidden = 1
let NERDTreeIgnore = ['\.o$', '\.obj$', '\.exe$', '\.class$', '\.pyc$', '\.jpg$', '\.png$', '\.gif$', '\.pdf$']

"
"" Git branch plugin
"

" Don't show any message when there is no git repository on the current dir
let g:git_branch_status_nogit=""
" Don't show any text before branch name.
let g:git_branch_status_text=""
" Show just the current head branch name.
let g:git_branch_status_head_current=1
" Characters to put around the branch strings.
let g:git_branch_status_around="[]"

"
"" VimClojure plugin
"

" Highlight clojure's builtin functions
let g:clj_highlight_builtins=1
" Highlight clojure-contrib's builtin functions
let g:clj_highlight_contrib=1
" Highlight differing levels of parenthesisations
let g:clj_paren_rainbow=1
" Set path to nailgun client
let s:ngclient=expand("$HOME/bin/ng")

if exists("s:ngclient") && filereadable(s:ngclient)
   " Activate the interactive interface
   let clj_want_gorilla=1
   " Set path to nailgun client
   let vimclojure#NailgunClient=s:ngclient
endif

"
"" Haskell syntax
"
let hs_highlight_boolean=1
let hs_highlight_types=1

"
" TagList plugin
"
let Tlist_Exit_OnlyWindow = 1


"
"" vimdiff
"

if &diff
   " Jump backwards to the previous start of a change.
   map <up> [c
   " Jump forwards to the next start of a change.
   map <down> ]c
   " Modify the current buffer to undo difference with another buffer.
   map <left> :diffget<cr>
   " Modify another buffer to undo difference with the current buffer.
   map <right> :diffput<cr>
   " Update the diff highlighting and folds
   map <f5> :diffupdate<cr>
endif

"
"" Commands
"

command! -complete=help -nargs=? Vhelp vert help <args>
command! Wsu w !sudo tee %
command! Q confirm qall
command! -complete=file -nargs=1 R :call ReplaceTextWithFile('<args>')

