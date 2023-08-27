" vim: foldmethod=marker:foldlevel=0

" Vundle {{{
" required by Vundle
set nocompatible
filetype off

if isdirectory(expand('~/.vim/bundle/Vundle.vim'))
    " set the runtime path to include Vundle and initialize
    set runtimepath+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    " alternatively, pass a path where Vundle should install plugins
    "call vundle#begin('~/.vim/bundle/')

    " let Vundle manage itself, required
    Plugin 'VundleVim/Vundle.vim'

    Plugin 'ervandew/supertab'
    if executable('ack') || executable('ag')
        Plugin 'mileszs/ack.vim'
    endif
    Plugin 'tpope/vim-commentary'
    Plugin 'tpope/vim-surround'
    Plugin 'tpope/vim-repeat'
    Plugin 'tpope/vim-vinegar'
    Plugin 'fidian/hexmode'
    Plugin 'ciaranm/securemodelines'
    Plugin 'plasticboy/vim-markdown'
    if $USER !=# 'root'
        Plugin 'chikamichi/mediawiki.vim'
        Plugin 'luochen1990/rainbow'
        Plugin 'hynek/vim-python-pep8-indent'
        if has('signs')
            if executable('git')
                Plugin 'airblade/vim-gitgutter'
            endif
            Plugin 'kshenoy/vim-signature'
        endif
        if has('python') || has('python3')
            Plugin 'davidhalter/jedi-vim'
            Plugin 'SirVer/ultisnips'
            Plugin 'honza/vim-snippets'
            if version >= 703
                Plugin 'mbbill/undotree'
            endif
        endif
        if version >= 800 && has('job') && has('channel') && has('timers')
            Plugin 'dense-analysis/ale'
        endif
        if executable('ansible')
            Plugin 'pearofducks/ansible-vim'
        endif
    endif

    " Plugin 'tomasr/molokai' " color scheme
    " Plugin 'trapd00r/neverland-vim-theme' " color scheme
    " Plugin 'tpope/vim-vividchalk' " color scheme
    " Plugin 'sjl/badwolf' " color scheme
    " Plugin 'nanotech/jellybeans.vim' " color scheme
    Plugin 'morhetz/gruvbox' " color scheme
    " Plugin 'candycode.vim' " color scheme
    " Plugin 'wombat256.vim' " color scheme
    " Plugin 'Wombat' " color scheme

    if (filereadable(glob("~/.vim/plugins.local")))
        source ~/.vim/plugins.local
    endif

    " All of your Plugins must be added before the following line
    call vundle#end()

    if $USER !=# systemlist("ls -ld ~/.vim/ | awk 'NR == 1 { print $3 }'")[0]
        " Disable some Vundle commands if ~./vim/ is not owned by the current user.
        " Note: stat would be preferable to parsing ls, if only it was portable.
        delcommand PluginClean
        delcommand PluginInstall
        delcommand PluginUpdate
        delcommand VundleClean
        delcommand VundleInstall
        delcommand VundleUpdate
    endif
endif
filetype plugin indent on
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
" see :h vundle for more details or wiki for FAQ
" }}}

" Looks {{{

" Set the proper codes for italic text.
" This should really be done in a terminfo file, but setting TERM to some
" non-standard values causes too much trouble.
if &term =~# '^xterm'
    exe "set t_ZH=\e[3m"
    exe "set t_ZR=\e[23m"
endif

" Enable 24 bit colour (a.k.a. true colour) support
if has('termguicolors') && &t_Co > 255
    set termguicolors
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

if has("gui") || &t_Co > 255
    " silent! colorscheme candycode
    " silent! colorscheme molokai
    " silent! colorscheme neverland-darker
    " silent! colorscheme neverland2-darker
    " silent! colorscheme vividchalk
    " silent! colorscheme badwolf
    " if !has("gui")
    "     silent! colorscheme wombat256mod
    " else
    "     silent! colorscheme wombat
    " endif
    " let g:jellybeans_use_term_italics = 1
    " silent! colorscheme jellybeans
    let g:gruvbox_italic = 1
    let g:gruvbox_invert_selection = 0
    silent! colorscheme gruvbox
    if has('syntax')
        set cursorline " Highlight the line with the cursors somehow.
        " But disable underline or whatever the colorscheme may set.
        highlight CursorLine gui=NONE cterm=NONE
    endif
else
    silent! colorscheme default
endif

set background=dark " Set colours for a dark background.
set lazyredraw " Don't redraw while running macros.
set ttyfast " Better behaviour
if has('linebreak')
    set linebreak " When (visually) wrapping long lines, do it at a nice position.
endif

if has('autocmd') && has('diff')
    " Make vimdiff respect the global wrap setting
    autocmd FilterWritePre * if &diff | setlocal wrap< | endif
endif
" }}}

" Syntax highlighting settings {{{
if has('syntax')
    syntax enable " Enable syntax highlighting.
    syntax spell toplevel " Do spell checking for all text that is not in a syntax item.
    set synmaxcol=512 " Don't color long lines (too slow).
endif

if has("spell")
    " Highlight spelling errors on the terminal by underlining
    highlight SpellBad cterm=underline
    highlight SpellCap cterm=underline
    highlight SpellLocal cterm=underline
    highlight SpellRare cterm=underline
endif

if (&termencoding ==# 'utf-8' || &encoding ==# 'utf-8') && version >= 700
    set list listchars=trail:·,tab:→\ ,nbsp:␣ " Highlight trailing spaces, tabs and non-breaking spaces.
else
    set list listchars=trail:.,tab:>\  " Highlight trailing spaces and tabs.
endif
" }}}

" Status bar settings {{{
if has('cmdline_info')
    set showcmd " Show command parts and counts in the status bar.
endif
set report=0 " Always show a status message about number of changed lines.

if has('statusline') && has('autocmd')
    " Colours for the statusline {{{
    " Make sure the normal group is set, the default colorscheme does not set
    " it. This is required for bg to work.
    highlight default Normal ctermfg=White ctermbg=Black guifg=white guibg=black
    " Note: Make sure these groups are different, otherwise vim will add ^ to
    " the statusline.
    highlight StatusLine term=NONE cterm=NONE ctermbg=bg ctermfg=White gui=NONE guibg=bg guifg=White
    highlight StatusLineNC term=bold cterm=NONE ctermbg=bg ctermfg=Grey gui=NONE guibg=bg guifg=LightGrey

    " Note: Setting colorscheme or syntax clears the user-defined colours.
    " User1: red
    " User2: green
    " User3: yellow
    " User4: blue
    " User5: purple
    " User6: cyan
    " User9: orange
    if &t_Co > 255 || has("gui_running")
        " Colours for terminals with a fair amount of colours and for gvim.
        highlight User1 guibg=bg guifg=#df0000 ctermbg=bg ctermfg=160
        highlight User2 guibg=bg guifg=#00af00 ctermbg=bg ctermfg=34
        highlight User3 guibg=bg guifg=#dfdf00 ctermbg=bg ctermfg=184
        highlight User4 guibg=bg guifg=#87afdf ctermbg=bg ctermfg=110
        highlight User5 guibg=bg guifg=#af00af ctermbg=bg ctermfg=127
        highlight User6 guibg=bg guifg=#0087af ctermbg=bg ctermfg=31
        highlight User9 guibg=bg guifg=#ff8700 ctermbg=bg ctermfg=208
        highlight StatusLineHelp guibg=#ffdf5f guifg=#000000 ctermbg=221 ctermfg=Black
        highlight StatusLineHelpNC guibg=#ffdf5f guifg=#404040 ctermbg=221 ctermfg=DarkGrey
    else
        " Colours for terminals with few colours, such as 'linux'.
        highlight User1 ctermbg=bg ctermfg=LightRed
        highlight User2 ctermbg=bg ctermfg=DarkGreen
        highlight User3 ctermbg=bg ctermfg=DarkYellow
        highlight User4 ctermbg=bg ctermfg=DarkBlue
        highlight User5 ctermbg=bg ctermfg=DarkMagenta
        highlight User6 ctermbg=bg ctermfg=DarkCyan
        highlight User7 ctermbg=bg ctermfg=LightGrey
        highlight User8 ctermbg=bg ctermfg=DarkGrey
        highlight User9 ctermbg=bg ctermfg=LightYellow
        highlight StatusLineHelp ctermfg=Black ctermbg=LightYellow
        highlight StatusLineHelpNC ctermfg=DarkGrey ctermbg=LightYellow
    endif
    " }}}

    " Statusline configuration {{{
    function! Statusline(winnr)
        " This function runs in the context of the active window.
        " a:winnr is the window whose status line we set now.
        " Check if it's the active one.
        let active = a:winnr == winnr()
        " We use different status lines for different purposes.
        if getwinvar(a:winnr, '&ft') ==# 'help'
            let line=''
            if active
                let line.="%#StatusLineHelp#"
            else
                let line.="%#StatusLineHelpNC#"
            endif
            let line.="%t%h%=%02p%%"
        elseif getwinvar(a:winnr, '&ft') ==# 'man'
            let line="%t%=%l/%L\ (%02p%%)"
        elseif getwinvar(a:winnr, '&buftype') ==# 'quickfix'
            let line='' " clear
            let line.="%q" " quickfix/location window indicator
            let line.="%=" " delimiter between left and right part
            let line.="%l/%L " " line number
            let line.="(%02p%%)" " percentage
        else
            let line='' " clear
            if active
                if $USER ==# 'root'
                    let line.="%1*" " red
                elseif getwinvar(a:winnr, '&readonly') == 0
                    let line.="%2*" " green
                else
                    let line.="%4*" " blue
                endif
            endif
            let line.="%t" " file name (without path)
            let line.="%m" " modified flag
            let line.=' ' " space
            if active
                let line.="%3*" " yellow
            endif
            let line.="%<" " truncation mark
            let line.="%y" " file type
            if active
                let line.="%9*" " orange
            endif
            let line.="[%{strlen(&fenc)?&fenc:&enc}%{&bomb?'-bom':''}]" " file encoding
            let line.="%{&ff=='unix'?'':'['.&ff.']'}" " file format
            if active
                let line.="%5*" " purple
            endif
            let line.="%{&spell?'['.&spelllang.']':''}" " spell setting
            if active
                let line.="%6*" " cyan
            endif
            let line.="%{&paste?'[paste]':''}" " paste indicator
            if active
                let line.="%*" " reset colour
            endif
            let line.="%=" " delimiter between left and right part
            let line.="%c%V," " column number
            let line.="%l/%L " " line number
            let line.="(%02p%%)" " percentage
        endif
        return line
    endfunction
    " }}}

    function! s:RefreshStatusline()
        for nr in range(1, winnr('$'))
            call setwinvar(nr, '&statusline', '%!Statusline('.nr.')')
        endfor
    endfunction

    augroup StatusLine
        autocmd!
        autocmd VimEnter,WinEnter,BufWinEnter,BufUnload * call <SID>RefreshStatusline()
    augroup END

    set laststatus=2 " Always show the status line.
    set fillchars+=stl:\ ,stlnc:\  " Fill spaces in the statusline with, well, spaces.
endif

" }}}

" Tabstop and indenting settings {{{
set autoindent " Automatically indent new lines.
set copyindent " Copy the new indent (i.e. spaces/tabs) from the previous line.
set shiftround " When indenting, round to multiples of shiftwidth.
set shiftwidth=4 " Indent by 4 spaces.
set tabstop=4 " Tabs are equivalent to 4 spaces.
set softtabstop=4
set expandtab " Use spaces for indenting, not tabs.
set smarttab " At the start of a line, use tabs as shiftwidth, not tabstop.
" }}}

" Various settings
set number " Turn on line numbers.
if has('linebreak')
    set numberwidth=3 " If possible, use only 3 columns for line numbers.
endif
if (!has('gui') && has('dialog_con')) || (has('gui') && has('dialog_gui'))
    set confirm " Don't fail in case of unsaved changes, etc., but ask for confirmation.
endif
set scrolloff=4 " Keep the cursor 4 lines from the top and bottom.
set nrformats=hex " Interpret 0x<number> as hex number when in-/decreasing (<C-A>, <C-X>).
if has('xterm_clipboard') || has('gui')
    set clipboard-=autoselect " Don't overwrite the X11 selection when using visual mode.
endif
if $USER !=# 'root'
    set tags=./tags;tags " Files to scan for tags (; - scan parent directories)
endif
let g:tex_flavor='latex' " .tex files are always LaTeX.
set directory=~/.vim/.swp// " Create swap files in ~/.vim/.swp only. They may leak information when scattered around the filesystem
set updatetime=1000 " Update swap files after one second idle time.
set shortmess+=I " Do not show the intro message.

" Persistent undo {{{
if has('persistent_undo') && $USER !=# 'root'
    set undofile " Write undo files.
    set undodir=~/.vim/.undo/ " Store them in a separate directory.
endif
" }}}

" Shortcuts {{{

" Set mapleader
let mapleader=","

" Map F1 to ESC to avoid typos.
noremap <F1> <ESC>
noremap! <F1> <ESC>

set pastetoggle=<F2> " Toggle paste mode with F2.

" Make w!! get the permissions to save the current file.
if !has('gui') && $USER !=# 'root' && executable('sudo') && executable('tee')
    cnoremap w!! w !sudo tee "%" > /dev/null <bar> set nomodified
    "command -nargs=0 W w !sudo tee "%" > /dev/null | set nomodified
endif

" Make . not move the cursor (does not work with repeat plugin).
"nnoremap . .`.

" Make gV select the text just pasted.
noremap gV `[v`]

" Make Ctrl+u and Ctrl+w undoable.
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

" Open a new window and move to it.
nnoremap <leader>w <C-w>v<C-w>l

" Make Ctrl+h/j/k/l move between windows.
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Make the start and end of the line more reachable.
nnoremap H ^
nnoremap L $
xnoremap H ^
xnoremap L $

" Use Y to yank to the end of a line, instead of the whole line.
nnoremap Y y$
" Use <leader>c to clear the current line.
nnoremap <leader>c 0D
" Use <leader>cd to change to the directory of the currently open file.
nnoremap <leader>cd :lcd %:p:h<CR>:pwd<CR>

if has('clipboard')
    " Make the X11 selection more accessible for copy & paste
    nnoremap <leader>d "*d
    nnoremap <leader>D "*D
    nnoremap <leader>y "*y
    nnoremap <leader>Y "*y$
    nnoremap <leader>p "*p
    nnoremap <leader>P "*P
endif

" }}}

" Auto formatting settings {{{
set formatoptions+=r " Add comment leader when hitting return on a commented line.
set formatoptions+=n " Recognise numbered lists when auto-formatting.
set formatoptions+=j " Remove comment leaders when joining lines.
" }}}

" Search settings {{{
" Use case insensitive search, except when there are capital letters or \C
set ignorecase " Make search case-insensitive by default.
set smartcase " Make search case-sensitive when there are capital letters.
if has('extra_search')
    set incsearch " Search while typing.
    set hlsearch " Highlight search matches.
endif

" Make <leader>+l clear search highlights.
nnoremap <silent> <leader>l :nohlsearch<CR>

" * and # for selections in visual mode.
function! s:VSetSearch()
    let l:temp = @@ " Unnamed register
    normal! gvy
    " Added \C to force 'noignorecase' while searching the current visual
    " selection. I want to search for the exact string in this case.
    let @/ = '\C' . '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = l:temp
endfunction
xnoremap * :<C-U>call <SID>VSetSearch()<CR>//<CR>
xnoremap # :<C-U>call <SID>VSetSearch()<CR>??<CR>

" Use 'noignorecase' for * and #. See comment in s:VSetSearch() for details.
function! s:NSetSearch()
    let l:cword = expand('<cword>')
    let l:regex = substitute(escape(l:cword, '\'), '\n', '\\n', 'g')
    let @/ = '\C\V'. '\<' . l:regex . '\>'
endfunction
nnoremap * :call <SID>NSetSearch()<CR>//<CR>
nnoremap # :call <SID>NSetSearch()<CR>??<CR>

" }}}

" Folding {{{
if has('folding')
    set foldenable
    set foldmethod=syntax
    set foldlevelstart=99 " Don't autofold
    " In normal mode, use <Space> to toggle folding.
    nnoremap <Space> za
    " In visual mode, use <Space> to create folds.
    xnoremap <expr> <Space> &foldmethod == 'manual' ? 'zf' : ''
    if has('autocmd')
        augroup AutoFoldColumn
            autocmd!
            " Add a foldcolumn for large windows.
            " 'Large' means, at least 80 characters, not counting the number
            " columns. The foldcolumn is not shown when folding is disabled.
            " Note: This does not trigger when resizing windows.
            autocmd VimResized,VimEnter,WinEnter,BufWinEnter *
                    \ if &foldenable && winwidth(0) > 80 + (or(&number, &relativenumber) * max([&numberwidth, &number * strlen(line('$'))])) |
                        \ setlocal foldcolumn=1 |
                    \ else |
                        \ setlocal foldcolumn=0 |
                    \ endif
        augroup END
    endif
endif
" }}}

" Automatically close braces {{{
function! OpenPair(openChar, closeChar)
    let NextChar = strpart(getline('.'), col('.') - 1, 1)
    " Add closing char if not at the beginning of a word.
    if NextChar =~ '\<\|\$'
        return a:openChar
    else
        return a:openChar.a:closeChar."\<Left>"
    endif
endfunction

function! ClosePair(closeChar)
    let NextChar = strpart(getline('.'), col('.') - 1, 1)
    if NextChar == a:closeChar
        return "\<Right>"
    else
        return a:closeChar
    endif
endfunction

" Add ) after every (
inoremap <expr> ( OpenPair('(',')')
" Make a typed ) replace an existing one.
inoremap <expr> ) ClosePair(')')

" Same thing for []
inoremap <expr> [ OpenPair('[',']')
inoremap <expr> ] ClosePair(']')

" Similar magic for {}
inoremap {<CR> {<CR>}<ESC>O
inoremap <expr> } ClosePair('}')
" }}}

" Tab Completion {{{
if has('insert_expand')
    set completeopt+=longest
endif
" Change colors of completion menu.
highlight Pmenu ctermbg=DarkGreen ctermfg=White
highlight PmenuSel ctermbg=DarkGreen ctermfg=Black
" Automatically close the preview window after completion.
if has('autocmd')
    augroup CompletionPreview
        autocmd!
        autocmd CompleteDone * pclose
    augroup END
endif

if has('wildmenu')
    " Completion in command mode.
    set wildmenu " Show a menu.
endif
" Show a list and complete the longest match, then tab through the matches.
set wildmode=list:longest,full
" }}}

" auto chmod script {{{
if has('autocmd') && executable('chmod')
    " From tpope's vim-eunuch
    augroup shebang_chmod
        autocmd!
        autocmd BufNewFile * let b:brand_new_file = 1
        autocmd BufWritePost * unlet! b:brand_new_file
        autocmd BufWritePre *
                \ if exists('b:brand_new_file') |
                \ if getline(1) =~ '^#!' |
                \ let b:chmod_post = '+x' |
                \ endif |
                \ endif
        autocmd BufWritePost,FileWritePost * nested
                \ if exists('b:chmod_post') |
                \ silent! execute '!chmod '.b:chmod_post.' "<afile>"' |
                \ edit |
                \ unlet b:chmod_post |
                \ endif
    augroup END
endif
" }}}

" Protect temporary files from leaking sensitive data
if has('autocmd')
    function! s:unleak()
        " Disable writing to .viminfo
        set viminfo=
        " Disable swap files
        set noswapfile
        " Disable backup files
        set nobackup
        set nowritebackup
        " Disable undo files
        if has('persistent_undo')
            set noundofile
        endif
        echomsg 'Editing a temporary file. Data leaks disabled.'
    endfunction
    augroup temp_file
        autocmd!
        " This list should cover (at least) ansible vaults, pass and zsh
        autocmd VimEnter {/tmp,$TMPDIR,$XDG_RUNTIME_DIR,/dev/shm,/tmp/.ansible/tmp/ansible-local-*}/{tmp*.yml,pass*.txt,zsh*} call s:unleak()
    augroup END
endif

" Plugin Settings {{{

" ALE {{{
augroup readonly
    autocmd!
    autocmd BufReadPost *
                \ if &readonly
                \| let b:ale_enabled = 0
                \| endif
                \| autocmd! readonly
augroup end
" }}}

" ack.vim {{{
" Prefer ag over ack, if available
if executable('ag')
    let g:ackprg = 'ag --vimgrep'
endif
" }}}

" ansible-vim {{{
" improve secondary filetype detection for jinja2 templates
let g:ansible_template_syntaxes = { '*.sh.j2': 'sh', '*.xml.j2': 'xml' }
" }}}

" Signature {{{
" Highlight marks annd markers based on the state of GitGutter.
let g:SignatureMarkTextHLDynamic = 1
let g:SignatureMarkerTextHLDynamic = 1
" }}}

" GitGutter {{{
" Change some mappings.
nmap <leader>hp <Plug>(GitGutterPrevHunk)
nmap <leader>hn <Plug>(GitGutterNextHunk)
nmap <leader>hv <Plug>(GitGutterPreviewHunk)
" }}}

" Secure Modelines {{{
let g:secure_modelines_allowed_items = [
    \ "textwidth",   "tw",
    \ "softtabstop", "sts",
    \ "tabstop",     "ts",
    \ "shiftwidth",  "sw",
    \ "expandtab",   "et",   "noexpandtab", "noet",
    \ "filetype",    "ft",
    \ "foldmethod",  "fdm",
    \ "foldlevel",   "fdl",
    \ "readonly",    "ro",   "noreadonly", "noro",
    \ "rightleft",   "rl",   "norightleft", "norl",
    \ "cindent",     "cin",  "nocindent", "nocin",
    \ "smartindent", "si",   "nosmartindent", "nosi",
    \ "autoindent",  "ai",   "noautoindent", "noai",
    \ "number",      "nu",   "nonumber", "nonu",
    \ "rightleft",   "rl",   "norightleft", "norl",
    \ "fileencoding", "fenc",
    \ "spell",
    \ "spelllang"
    \ ]
" }}}

" Undotree {{{
nnoremap <leader>u :UndotreeToggle<CR>
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_WindowLayout = 2
" }}}

" Rainbow {{{
let g:rainbow_active = 1
let g:rainbow_conf = {
    \ 'guifgs': ['orangered', 'gold1', 'chartreuse', 'LightSlateBlue', 'red1', 'DarkGoldenrod', 'chartreuse4', 'RoyalBlue'],
    \ 'ctermfgs': ['red', 'yellow', 'green', 'blue', 'darkred', 'brown', 'darkgreen', 'darkblue'],
    \ 'operators': '_,_',
    \ 'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
    \ 'separately': {
    \   'help' : 0,
    \   'man' : 0,
    \   'xml' : 0,
    \   'xhtml' : 0,
    \   'html' : 0,
    \   'sh' : {
    \       'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[\@!\[/ end=/\]\@!\]/ fold', 'start=/{/ end=/}/ fold'],
    \   },
    \   'zsh' : {
    \       'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[\@!\[/ end=/\]\@!\]/ fold', 'start=/{/ end=/}/ fold'],
    \   },
    \   'php': {
    \       'parentheses': ['start=/(/ end=/)/ containedin=@htmlPreproc contains=@phpClTop', 'start=/\[/ end=/\]/ containedin=@htmlPreproc contains=@phpClTop', 'start=/{/ end=/}/ containedin=@htmlPreproc contains=@phpClTop'],
    \   },
    \ }
    \}
" }}}

" jedi-vim {{{
" When using "go to", open new splits (instead of buffers or tabs).
let g:jedi#use_splits_not_buffers = 'right'
" Disable function argument help since it has issues.
let g:jedi#show_call_signatures = 0
" }}}

" SuperTab {{{
" Enable context sensitive completion.
let g:SuperTabDefaultCompletionType = "context"
" Default to <c-n> (instead of <c-p>) if nothing better is available.
let g:SuperTabContextDefaultCompletionType = "<c-n>"
" Enable enhanced longest match completion.
let g:SuperTabLongestEnhanced = 1
" Some additional mappings, not specific to SuperTab.
" Notes:
" * Tab can not be distinguished from Ctrl+I, not even in gvim
" * Ctrl+Tab can not be distinguished from Tab in the terminal
" Make <CR> select the highlighted match if the menu is open.
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
" Make <ESC> close the menu, and makes the arrow keys go crazy.
" inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
" }}}

" UltiSnips {{{
" The trigger used to expand a snippet
let g:UltiSnipsExandTrigger = "<tab>"
" The trigger used to display all snippets that could possibly match
let g:UltiSnipsListSnippets = "<F3>"
" The triger used to jump forward to the next placeholder
let g:UltiSnipsJumpForwardTrigger = "`"
" The trigger used to jump back inside a snippet
let g:UltiSnipsJumpBackwardTrigger = "¬"
" Make Python snippets use google style formatting.
let g:ultisnips_python_style = "google"
" }}}

" }}}

if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif
