" File: breaklist
" Author: lymslive
" Description: list break pionts of VimL script
" Create: 2019-12-25
" Modify: 2019-12-25

let g:vnite#command#breaklist#space = s:
let s:description = 'list break pionts of VimL script'
let s:actor = vnite#Actor#new('breaklist')
call s:actor.add('Default', 'CR', 'default to jump location of this break point')
            \.add('Delete', 'D', 'delete this break point')
            \.add('Clear', 'C', 'delete all break point')

let s:struct = {}
let s:struct.nr = 0
let s:struct.type = '' " func or file
let s:struct.name = '' " name of func or file
let s:struct.line = 0

" <nr> <type> <name> line <line-nr>
let s:pattern = '^\s*\(\d\+\)\s\+\(\w\+\)\s\+\(.\+\)\s\+line\s\+\(\d\+\)\s*$'

" Func: s:parse 
function! s:parse(text) abort
    let l:matchs = matchlist(a:text, s:pattern)
    if empty(l:matchs) || len(l:matchs) < 4
        return v:null
    endif
    let l:obj = copy(s:struct)
    let l:obj.nr = l:matchs[1]
    let l:obj.type = l:matchs[2]
    let l:obj.name = l:matchs[3]
    let l:obj.line = l:matchs[4]
    return l:obj
endfunction

" Func: #CR 
function! vnite#command#breaklist#CR(message) abort
    let l:obj = s:parse(a:message.text)
    if empty(l:obj)
        return ''
    endif
    if l:obj.type ==# 'file'
        return 'EditFLC ' .. l:obj.name .. ' ' .. l:obj.line
    elseif l:obj.type ==# 'func' && l:obj.name !~# '^\d\+'
        let l:function = g:vnite#command#function#space
        let l:from = l:function.Where(l:obj.name)
        if empty(l:from)
            return ''
        else
            let l:file = l:from.file
            let l:line = l:from.line + l:obj.line
            return 'EditFLC ' .. l:file .. ' ' .. l:line
        endif
    else
        return ''
    endif
endfunction

" Func: #Delete 
function! vnite#command#breaklist#Delete(message) abort
    let l:obj = s:parse(a:message.text)
    if empty(l:obj)
        return ''
    endif
    return 'breakdel ' .. l:obj.nr
endfunction

" Func: #Clear 
function! vnite#command#breaklist#Clear(message) abort
    return 'breakdel *'
endfunction
