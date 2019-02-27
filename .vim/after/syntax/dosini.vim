syn region dosiniSection start="^\s*\[" end="\(\n\+\s*\[\)\@=" contains=dosiniLabel,dosiniHeader,dosiniComment,dosiniNumber keepend fold
setlocal foldmethod=syntax
