" File: NoteList
" Author: lymslive
" Description: vnite interface for wenote
" Create: 2019-12-19
" Modify: 2019-12-19

let g:vnite#command#NoteList#space = s:
let s:description = 'vnite interface for wenote'
let s:actor = vnite#Actor#new('NoteList')
call s:actor.add('New', 'N', 'Create New Note by :NoteNew')
            \.add('Tag', 'T', 'list all tags have used :NoteTag')

" Func: s:getNoteID 
function! s:getNoteID(text) abort
    let l:tokens = split(a:text, '\t')
    if !empty(l:tokens)
        let l:noteid = l:tokens[0]
        if l:noteid =~# '^\s*\d\+_\d\+'
            return l:noteid
        endif
    endif
    return ''
endfunction

" Method: CR 
function! s:actor.CR(message) dict abort
    let l:text = a:message.text
    if col('.') < 10
        let l:noteid = s:getNoteID(l:text)
        if !empty(l:noteid)
            return 'NoteEdit ' .. l:noteid
        endif
    endif
endfunction

" Method: New 
function! s:actor.New(message) dict abort
    let l:text = a:message.text
    let l:tagstr = matchstr(l:text, '|\zs\S\+\ze|$')
    if empty(l:tagstr)
        return 'NoteNew '
    else
        let l:tagstr = substitute(l:tagstr, '|', ' ', 'g')
        return 'NoteNew ' .. l:tagstr
    endif
endfunction

" Method: Tag 
function! s:actor.Tag(message) dict abort
    return 'NoteTag '
endfunction
