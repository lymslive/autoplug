" File: onft
" Author: lymslive
" Description: 
" Create: 2018-06-04
" Modify: 2018-06-04

" Flow: 
function! tailflow#onft#Flow() abort "{{{
    setlocal buftype=nofile
    setlocal bufhidden=hide
    command! -buffer -nargs=* And tailflow#onft#hAnd(<f-arg>)
    command! -buffer -nargs=* Not tailflow#onft#hNot(<f-arg>)
endfunction "}}}

" IsFlowBuffer: 
function! s:IsFlowBuffer() abort "{{{
    return exists('b:jFlow')
endfunction "}}}

" And: manage the AND list of flow object
" :And [=|-=|+=] [item1 item2 ...]
" the default operater is '+='
function! tailflow#onft#hAnd(...) abort "{{{
    if !s:IsFlowBuffer()
        return -1
    endif
    if a:0 == 0
        echo b:jFlow.and
    elseif a:0 == 1
        call b:jFlow.AddAndList(a:1)
    else
        let l:operator = a:1
        if l:operator ==# '='
            call b:jFlow.SetAndList(a:000[1:])
        elseif l:operator ==# '+='
            for l:item in a:000[1:]
                call b:jFlow.AddAndList(l:item)
            endfor
        elseif l:operator ==# '-='
            for l:item in a:000[1:]
                call b:jFlow.SubAndList(l:item)
            endfor
        else
            for l:item in a:000
                call b:jFlow.AddAndList(l:item)
            endfor
        endif
    endif
endfunction "}}}

" Not: manage the NOT list of flow object
function! tailflow#onft#hNot(...) abort "{{{
    if !s:IsFlowBuffer()
        return -1
    endif
    if a:0 == 0
        echo b:jFlow.not
    elseif a:0 == 1
        call b:jFlow.AddNotList(a:1)
    else
        let l:operator = a:1
        if l:operator ==# '='
            call b:jFlow.SetNotList(a:000[1:])
        elseif l:operator ==# '+='
            for l:item in a:000[1:]
                call b:jFlow.AddNotList(l:item)
            endfor
        elseif l:operator ==# '-='
            for l:item in a:000[1:]
                call b:jFlow.SubNotList(l:item)
            endfor
        else
            for l:item in a:000
                call b:jFlow.AddNotList(l:item)
            endfor
        endif
    endif
endfunction "}}}
