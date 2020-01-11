" File: oldfiles
" Author: lymslive
" Description: action for oldfiles
" Create: 2019-11-01
" Modify: 2019-11-01

let g:vnite#command#oldfiles#space = s:
let s:description = 'list all files stored in viminfo, CR to open one'
let s:actor = vnite#Actor#new('oldfile')
call s:actor.add('Source', 'S', 'source the vim file')

" Func: #CR 
function! vnite#command#oldfiles#CR(message) abort
    let l:text = a:message.text
    let l:file = matchstr(l:text, '^\s*\d\+:\s*\zs.\+\ze')
    if empty(l:file)
        return vnite#action#error('the output seems not a numbered list of file as "%d: %f"')
    endif
    return 'edit ' . l:file
endfunction

" Method: Source 
function! s:actor.Source(message) dict abort
    let l:text = a:message.text
    let l:file = matchstr(l:text, '^\s*\d\+:\s*\zs.\+\ze')
    if !empty(l:file) && l:file =~? '\.vim$'
        return 'source ' . l:file
    endif
    return ''
endfunction
