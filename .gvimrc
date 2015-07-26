" Disable annoying cursor blinking in all modes.
set guicursor+=a:blinkon0

" Do not overwrite the X11 selection when using visual mode.
set guioptions-=a
" Disable the toolbar.
set guioptions-=T
" Disable all scrollbars.
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L
set guioptions-=b

if (filereadable(glob("~/.gvimrc.local")))
    source ~/.gvimrc.local
endif
