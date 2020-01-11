" File: map
" Author: lymslive
" Description: list key maps
" Create: 2019-11-28
" Modify: 2019-11-28

let g:vnite#command#map#space = s:
let s:description = 'for map-listing'

let s:actor = vnite#Actor#new('Path')
call s:actor.add('Default', 'CR', 'no suitable action')
            \.add('Yield', 'Y', 'yield the remap command, yank to default register"')
            \.add('Delete', 'D', 'try to delete(unmap) this mapping')

let s:struct = {}
let s:struct.mode = ' '
let s:struct.remappable = v:true
let s:struct.left = ''
let s:struct.right = ''
let s:struct.buffer = v:false
let s:struct.script = v:false

" Func: s:parse_mapping 
function! s:parse_mapping(text) abort
    let l:struct = copy(s:struct)
    let l:text = a:text
    let l:struct.mode = l:text[0]
    let l:text = l:text[1 : ]
    let l:pattern = '^\s*\(\S\+\)\s\+\(.\+\)'
    let l:match = matchlist(l:text, l:pattern)
    if empty(l:match)
        return {}
    endif
    let l:struct.left = l:match[1]
    let l:right = l:match[2]
    if l:right[0] == '*'
        let l:struct.remappable = v:false
        let l:right = l:right[1 : ]
    endif
    if l:right[0] == '@'
        let l:struct.buffer = v:true
        let l:right = l:right[1 : ]
    endif
    if l:right[0] == '&'
        let l:struct.script = v:true
        let l:right = l:right[1 : ]
    endif
    let l:struct.right = l:right
    return l:struct
endfunction

" Method: Yield 
function! s:actor.Yield(message) dict abort
    let l:mapping = s:parse_mapping(a:message.text)
    if empty(l:mapping)
        return ''
    endif
    let l:cmd = 'map'
    if !l:mapping.remappable
        let l:cmd = 'noremap'
    endif
    if l:mapping.mode == '!'
        let l:cmd = l:cmd . l:mapping.mode
    else
        let l:cmd = l:mapping.mode . l:cmd
    endif
    if l:mapping.buffer
        let l:cmd = l:cmd . ' <buffer>'
    endif
    if l:mapping.script
        let l:cmd = l:cmd . ' <script>'
    endif
    let l:cmd = l:cmd . ' ' . l:mapping.left . ' ' . l:mapping.right
    echo l:cmd
    let @m = l:cmd
    return ''
endfunction

" Method: Delete
function! s:actor.Delete(message) dict abort
    let l:mapping = s:parse_mapping(a:message.text)
    if empty(l:mapping)
        return ''
    endif
    let l:cmd = 'unmap'
    if l:mapping.mode == '!'
        let l:cmd = l:cmd . l:mapping.mode
    else
        let l:cmd = l:mapping.mode . l:cmd
    endif
    if l:mapping.buffer
        let l:cmd = l:cmd . ' <buffer>'
    endif
    if l:mapping.script
        let l:cmd = l:cmd . ' <script>'
    endif
    let l:cmd = l:cmd . ' ' . l:mapping.left
    echo l:cmd
    return l:cmd
endfunction

" Func: #CR 
function! vnite#command#map#CR(message) abort
    return s:actor.Yield(a:message)
endfunction
