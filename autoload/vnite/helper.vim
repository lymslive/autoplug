" File: helper
" Author: lymslive
" Description: some helper function/command
" Create: 2019-11-02
" Modify: 2019-11-02

" Func: #edit3 (file, [line, col])
function! vnite#helper#edit3(file, ...) abort
    execute 'edit ' . a:file
    if a:0 >= 1 && a:1 > 0
        execute a:1
    endif
    if a:0 >= 2 && a:2 > 0
        execute 'normal! ' . a:2 . '|'
    endif
endfunction


let s:dSpecialKey = {}
" Func: s:addSpecialKey 
function! s:addSpecialKey(key) abort
    let l:text = toupper(a:key)
    let l:key = "\\" . l:text
    let l:key = eval(printf('"%s"', l:key))
    let s:dSpecialKey[l:key] = l:text
endfunction

" Func: s:initCtrlMap 
function! s:initSpecialKey() abort
    let l:alpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    for l:idx in range(26)
        let l:char = l:alpha[l:idx]
        let l:key = printf('<C-%s>', l:char)
        call s:addSpecialKey(l:key)
    endfor

    call s:addSpecialKey('<CR>')
    call s:addSpecialKey('<Tab>')
    call s:addSpecialKey('<Esc>')
endfunction

" Func: #decode_mapkey 
function! vnite#helper#decode_mapkey(text) abort
    if empty(s:dSpecialKey)
        call s:initSpecialKey()
    endif
    if has_key(s:dSpecialKey, a:text)
        return s:dSpecialKey[a:text]
    endif
    let l:text = a:text
    for [l:key, l:val] in items(s:dSpecialKey)
        let l:text = substitute(l:text, l:key, l:val, 'g')
        unlet l:key 
    endfor
    return l:text
endfunction

" --------------------------------------------------------------------------------
finish

command! -nargs=0 TestKey call vnite#helper#testkey()
" Func: #testkey 
function! vnite#helper#testkey() abort
    let l:ch = getchar()
    let l:type = type(l:ch)
    let l:char = nr2char(l:ch)
    echo 'l:ch' l:ch 'l:type' l:type 'l:char' l:char
endfunction
