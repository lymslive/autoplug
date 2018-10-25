" File: tailflow
" Author: lymslive
" Description: 
" Create: 2018-06-04
" Modify: 2018-06-04

command! -nargs=+ -complete=customlist,tailflow#cmdu#complist Tail call tailflow#cmdu#hStart(<f-args>)

" SepLine: append a separate line to view log clearer
function! s:SepLine(...) abort "{{{
    let l:leng = get(a:000, 0, '78')
    let l:char = get(a:000, 1, '-')
    let l:line = repeat(l:char, l:leng)
    call append(line('$'), ['', l:line, ''])
    normal! G
endfunction "}}}
command! -nargs=* SepLine call s:SepLine(<f-args>)

" load: 
function! tailflow#plugin#load() abort "{{{
    return 1
endfunction "}}}
