" Enable folding based on functions and if/do/for.
let g:sh_fold_enabled = 5

" Use shellcheck for static code analysis
if executable('shellcheck')
    setlocal makeprg=shellcheck\ -f\ gcc\ %
    if has('autocmd')
        augroup AutoShellcheck
            autocmd! BufWritePre <buffer> let b:modified=&modified
            autocmd! BufWritePost <buffer> if b:modified | silent make | redraw! | cwindow 3
        augroup END
    endif
endif
