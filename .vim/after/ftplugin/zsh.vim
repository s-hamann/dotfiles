" Use zsh -n for syntax checking
if executable('zsh')
    setlocal makeprg=zsh\ -n\ %
    if has('autocmd')
        augroup AutoZshlint
            autocmd! BufWritePre <buffer> let b:modified=&modified
            autocmd! BufWritePost <buffer> if b:modified | silent make | redraw! | cwindow 3
        augroup END
    endif
endif
