" Disable GitGutter
silent! GitGutterDisable
" Disable gundo
let g:gundo_disable = 1

" Remove duplicate empty lines (like less -s does).
silent! g/^\s*$\n\s*$/d
" Move back to the start of the man-page.
norm! 1G

" Set the name of the buffer to the name of the man-page.
let b:pagename=matchstr(getline(1), '\v^[A-Za-z0-9.:_+-]+\([0-9]p?\)')
execute "file ".b:pagename
unlet b:pagename

" Make viewing man-pages with vim look good.
setlocal nonumber
setlocal norelativenumber
setlocal tabstop=8
setlocal shiftwidth=8
setlocal softtabstop=8
setlocal nolist
setlocal nospell
setlocal nocursorline

" Disable folding, it does not play well with the navigation in this mode.
setlocal nofoldenable

" Disable some mappings.
silent! nunmap -

" Disable swapfile, man pages are not modifiable anyway.
setlocal noswapfile
" Disable persistent undo.
setlocal noundofile

" Start/end of file, see macros/less.vim
map <Home> g
map <End> G
