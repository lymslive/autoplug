" File: tailflow
" Author: lymslive
" Description: 
" Create: 2018-06-04
" Modify: 2018-06-04

command! -nargs=+ -complete=file Tail call tailflow#cmdu#hStart(<f-args>)

" load: 
function! tailflow#plugin#load() abort "{{{
    return 1
endfunction "}}}
