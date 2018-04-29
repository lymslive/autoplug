" File: golang
" Author: lymslive
" Description: my plugin for golang
" Create: 2018-04-28
" Modify: 2018-04-29

packadd vim-go
let g:go_doc_url='https://golang.google.cn'
let g:go_fmt_command = "goimports"

" load: 
function! golang#plugin#load() abort "{{{
    return 1
endfunction "}}}
