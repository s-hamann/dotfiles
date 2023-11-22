" enable spell checking
setlocal spell
setlocal spelllang=de_20

" disable folding
setlocal nofoldenable

" disable line numbers
setlocal nonumber
setlocal norelativenumber

" disable persisten undo
setlocal noundofile

if has('gui')
    " disable the menu bar
    setlocal guioptions-=m
    " disable the toolbar
    set guioptions-=T
    " disable all scrollbars
    set guioptions-=r
    set guioptions-=R
    set guioptions-=l
    set guioptions-=L
    set guioptions-=b
endif
