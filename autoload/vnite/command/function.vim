" File: function
" Author: lymslive
" Description: list named functions already defined
" Create: 2019-12-24
" Modify: 2019-12-24

let g:vnite#command#function#space = s:
let s:description = 'list named functions already defined'
let s:actor = vnite#Actor#new('messages')
call s:actor.add('Break', 'B', 'add break point in this function')
            \.add('Verbose', 'S', 'preview verbose definition')

" Func: #CR 
function! vnite#command#function#CR(message) abort
    let l:func = s:extract_name(a:message.text)
    let l:from = s:where_def(l:func)
    if empty(l:from)
        return ''
    else
        return 'EditFLC ' .. l:from.file .. ' ' .. l:from.line
    endif
endfunction

" Func: #Break 
function! vnite#command#function#Break(message) abort
    let l:func = s:extract_name(a:message.text)
    if empty(l:func)
        return ''
    else
        let l:cmd = printf('breakadd func %d %s', 1, l:func)
        return l:cmd
    endif
endfunction

" Func: #Verbose 
function! vnite#command#function#Verbose(message) abort
    let l:func = s:extract_name(a:message.text)
    if empty(l:func)
        return ''
    else
        return 'CM -- verbose function' .. l:func
    endif
endfunction

" Func: s:extract_name 
function! s:extract_name(text) abort
    let l:pattern = '^\s*function \zs\S\+\ze(.*)'
    return matchstr(l:text, l:pattern)
endfunction

" Func: s:where_def 
" :verbose function will print where it from file line
function! s:where_def(func) abort
    let l:cmd = 'verbose function ' .. a:func
    let l:context = vnite#main#cap(l:cmd)
    if empty(l:context)
        return v:null
    endif
    let l:from = get(l:context.messages, 1, '')
    if empty(l:from)
        return v:nul
    endif
    let l:pattern = '^\tLast set from \(.\+\) line \(\d\+\)\s*$'
    let l:matchs = matchlist(l:from, l:pattern)
    if len(l:matchs) < 2
        return v:null
    endif
    let l:file = l:matchs[1]
    let l:line = l:matchs[2]
    return {'file': l:file, 'line': 0+line}
endfunction
let s:Where = function('s:where_def')
