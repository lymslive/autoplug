" File: ls
" Author: lymslive
" Description: action config for ls command
" Create: 2019-11-01
" Modify: 2019-11-01

let g:vnite#command#ls#space = s:
let s:description = 'list all buffers, also :buffers, CR to open the buffer'
let s:actor = vnite#actor#File#new()
call s:actor.add('Delete', 'D', 'delete the buffer')

let s:start_filter = 1

" Func: s:get_bufnr 
function! s:get_bufnr(message) abort
    let l:text = a:message.text
    let l:bufnr = matchstr(l:text, '^\s*\zs\d\+\ze')
    if empty(l:bufnr)
        echo 'cannot find bufnr, it seems not output from ls'
        return 0
    endif
    return str2nr(l:bufnr)
endfunction

" Func: s:parser 
function! s:parser(message) abort
    let l:bufnr = s:get_bufnr(a:message)
    if !empty(l:bufnr)
        return bufname(l:bufnr)
    endif
endfunction
call s:actor.set_parser(function('s:parser'))

" Method: Delete 
function! s:actor.Delete(message) dict abort
    let l:bufnr = s:get_bufnr(a:message)
    if !empty(l:bufnr)
        return 'bdelete ' . l:bufnr
    endif
endfunction

" Method: CR 
function! s:actor.CR(message) dict abort
    let l:bufnr = s:get_bufnr(a:message)
    if !empty(l:bufnr)
        return 'buffer ' . l:bufnr
    endif
endfunction

" Func: #CR 
function! vnite#command#ls#CR(message) abort
    return s:actor.CR(a:message)
endfunction
