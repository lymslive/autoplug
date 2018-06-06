" File: normal
" Author: lymslive
" Description: 
" Create: 2018-06-06
" Modify: 2018-06-06

" Unmap: 
function! dynmkey#normal#Unmap(bang, arg) abort "{{{
    if empty(a:arg)
        return 0
    endif

    execute 'unmap ' . a:arg

    if !empty(a:bang)
        return 0
    endif

    " execute a normal! command at the same time
    let l:key = a:arg

    " eg. <CR> escape to "\<CR>"
    if l:key =~ '^<.*>$'
        let l:key = printf('"\%s"', l:key)
        let l:key = eval(l:key)
    endif
    execute 'normal! ' . l:key
endfunction "}}}
