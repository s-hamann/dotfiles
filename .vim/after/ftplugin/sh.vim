" Enable folding based on functions and if/do/for.
let g:sh_fold_enabled = 5

" Use shellcheck for static code analysis
if executable('shellcheck')
    setlocal makeprg=shellcheck\ -f\ gcc\ %
    if has('autocmd')
        au BufWritePost * :silent make | redraw! | cwindow 3
    endif
endif
