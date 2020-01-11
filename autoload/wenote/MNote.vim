" File: MNote
" Author: lymslive
" Description: manage functionality for buffer editing note
" Create: 2019-12-13
" Modify: 2019-12-13

let g:wenote#MNote#space = s:
let s:mbook = g:wenote#MBook#space

" Func: s:init_note_buffer 
function! s:init_note_buffer() abort
    call wenote#config#notebuff()
endfunction

" Func: #detect 
function! s:detect_() abort
    let l:inbook = s:inbook_()
    if !l:inbook
        return v:false
    endif
    if !exists('b:notebook')
        let b:notebook = s:mbook.getBook()
        call s:init_note_buffer()
        if 0 && !b:notebook.hasNote('%') " disable this, delay to record new note
            call b:notebook.recordNote(bufnr())
        endif
    endif
    return v:true
endfunction
let s:detect = function('s:detect_')

" Func: s:inbook_ 
function! s:inbook_() abort
    let l:notebook = s:mbook.getBook()
    if empty(l:notebook)
        return v:false
    endif
    let l:notepath = expand('%:p')
    let l:notedir = l:notebook.getpath('')
    return s:path_has_prefix(l:notepath, l:notedir)
endfunction
let s:inbook = function('s:inbook_')

" Func: s:path_has_prefix 
function! s:path_has_prefix(fullpath, basedir) abort
    let l:fullpath = substitute(a:fullpath, '[/\\]', '#', 'g')
    let l:basedir = substitute(a:basedir, '[/\\]', '#', 'g')
    if has('win32') || has ('win64')
        let l:fullpath = tolower(l:fullpath)
        let l:basedir = tolower(l:basedir)
    endif
    if stridx(l:fullpath, l:basedir) == 0
        return v:true
    else
        return v:false
    endif
endfunction

" Func: s:current_tags_ 
function! s:current_tags_() abort
    let l:notebook = s:mbook.getBook()
    if empty(l:notebook)
        return []
    endif
    let l:struct = l:notebook.parseNote(bufnr())
    return l:struct.tags
endfunction
let s:current_tags = function('s:current_tags_')

" Func: s:onSave 
function! s:onSave_() abort
    if !exists('b:notebook')
        return
    endif
    call b:notebook.recordNote(bufnr())
endfunction
let s:onSave = function('s:onSave_')

" Func: s:smartJump 
function! s:smartJump_(args) abort
    if !exists('b:notebook')
        return
    endif
    if empty(a:args) || empty(a:args[0])
        let l:word = expand('<cword>')
    else
        let l:word = a:args[0]
    endif

    if l:word =~# '^\d\+_\d\+'
        let l:notepath = b:notebook.getpath(l:word)
        if filereadable(l:notepath)
            execute 'edit ' .. l:notepath
        endif
    elseif b:notebook.hasTag(l:word)
        if exists(':CM')
            execute 'CM -- NoteList ' .. l:word
        else
            execute 'NoteList ' .. l:word
        endif
    else
        echo 'seams not noteid or tag'
    endif
endfunction
let s:smartJump = function('s:smartJump_')
