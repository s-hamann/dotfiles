let b:tex_flavor = 'pdflatex'
compiler tex
setlocal makeprg=pdflatex\ \-file\-line\-error\ \-interaction=nonstopmode\ $*\\\|\ grep\ \-P\ ':\\d{1,5}:\ '
setlocal errorformat=%f:%l:\ %m

" Enable syntax folding.
let g:tex_fold_enabled=1

if exists('g:loaded_surround')
    " vim-surround: q for \enquote{...}
    let b:surround_{char2nr('q')} = "\\enquote{\r}"
endif
