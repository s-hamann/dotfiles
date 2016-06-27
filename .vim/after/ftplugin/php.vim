" This sets makeprg to 'php -lq' and sets the proper errorformat.
compiler php

" Enable folding for all { } regions
let php_folding = 2

" Use php -l for syntax checking
if executable('php')
    setlocal makeprg=php\ -l\ %
    if has('autocmd')
        augroup AutoPHPlint
            autocmd! BufWritePre <buffer> let b:modified=&modified
            autocmd! BufWritePost <buffer> if b:modified | silent make | redraw! | cwindow 3
        augroup END
    endif
endif
