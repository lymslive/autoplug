" File: cmdu
" Author: lymslive
" Description: 
" Create: 2018-06-04
" Modify: 2018-06-04

" Start: 
function! tailflow#cmdu#hStart(...) abort "{{{
    let l:jFlow = tailflow#CFlow#new(a:1)
    if 0 != l:jFlow.Start()
        return -1
    endif
    call l:jFlow.OpenBuffer()
    if !exists('b:jFlow')
        let b:jFlow = l:jFlow
        call tailflow#onft#Flow()
    endif
endfunction "}}}
