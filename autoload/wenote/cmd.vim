" File: cmd
" Author: lymslive
" Description: command interface of wenote
" Create: 2019-12-13
" Modify: 2019-12-13

let s:mbook = g:wenote#MBook#space

" Func: #NoteBook 
function! wenote#cmd#NoteBook(bang, ...) abort
    if !empty(a:bang) && a:0 == 0
        call s:mbook.closeBook()
        echo 'notebook closed'
        return
    endif

    let l:dir = get(a:000, 0 , '')
    let l:notebook = s:mbook.openBook(l:dir)
    if !empty(l:notebook)
        echo 'working on notebook: ' .. l:notebook.basedir
    else
        echo 'cannot open notebook'
    endif
endfunction

" Func: #NoteNew 
function! wenote#cmd#NoteNew(bang, ...) abort
    call s:mbook.newNote(a:bang, a:000)
endfunction

" Func: #NoteEdit 
function! wenote#cmd#NoteEdit(arg) abort
    call s:mbook.editNote(a:arg)
    " code
endfunction

" Func: #NoteList 
function! wenote#cmd#NoteList(...) abort
    call s:mbook.listNote(a:000)
endfunction

" Func: #NoteTag 
function! wenote#cmd#NoteTag(...) abort
    call s:mbook.listTag(a:000)
endfunction

" Func: #NoteScan 
function! wenote#cmd#NoteScan(bang, ...) abort
    call s:mbook.scanNote(a:bang, a:000)
endfunction

" -------------------------------------------------------------------------------- "
" for buffer local command
let s:mnote = g:wenote#MNote#space

" Func: #NoteDetect 
function! wenote#cmd#NoteDetect() abort
    call s:mnote.detect()
endfunction

" Func: #NoteSave 
function! wenote#cmd#NoteSave() abort
    call s:mnote.onSave()
endfunction

" Func: #NoteJump 
function! wenote#cmd#NoteJump(...) abort
    call s:mnote.smartJump(a:000)
endfunction
