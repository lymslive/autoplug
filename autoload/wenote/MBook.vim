" File: MBook
" Author: lymslive
" Description: manage notebook
" Create: 2019-12-13
" Modify: 2019-12-13

let wenote#MBook#space = s:

let s:theBook = v:null

" Func: s:getBook_ 
function! s:getBook_() abort
    if empty(s:theBook)
        let l:dir = expand(g:wenote#config#default_notebook)
        let s:theBook = wenote#CBook#new(l:dir)
    endif
    return s:theBook
endfunction
let s:getBook = function('s:getBook_')

" Func: s:openBook 
function! s:openBook_(...) abort
    let l:dir = get(a:000, 0 , '')
    if !empty(l:dir)
        if !empty(s:theBook)
            call s:saveBook_()
        endif
        let s:theBook = wenote#CBook#new(l:dir)
    else
        call s:getBook_()
    endif
    return s:theBook
endfunction
let s:openBook = function('s:openBook_')

" Func: s:saveBook_ 
function! s:saveBook_() abort
    if !empty(s:theBook)
        call s:theBook.saveNotes()
    endif
endfunction
let s:saveBook = function('s:saveBook_')

" Func: s:closeBook 
function! s:closeBook_() abort
    call s:saveBook_()
    let s:theBook = v:null
endfunction
let s:closeBook = function('s:closeBook_')

" Func: s:newNote_ 
function! s:newNote_(bang, args) abort
    let l:title = ''
    let l:tags = []
    let l:idx = 0
    while l:idx < len(a:args)
        let l:arg = a:args[l:idx]
        let l:idx += 1
        if l:arg ==# '#'
            break
        endif
        call add(l:tags, l:arg)
    endwhile

    if l:idx < len(a:args)
        let l:title = join(a:args[l:idx :], ' ')
    endif

    if empty(l:title)
        let l:title = 'new note without title'
    endif

    let l:notebuf = g:wenote#MNote#space
    if empty(l:tags) && !empty(a:bang)
        if l:notebuf.inbook()
            let l:tags = l:notebuf.current_tags()
        endif
    endif

    call s:getBook_()
    let l:tonew = s:theBook.newNote(l:title, l:tags)
    execute 'edit ' .. l:tonew.notepath
    call setline(1, l:tonew.content)
    call l:notebuf.detect()
endfunction
let s:newNote = function('s:newNote_')

" Func: s:editNote_ 
function! s:editNote_(arg) abort
    call s:getBook_()
    let l:noteid = a:arg
    let l:path = s:theBook.getpath(l:noteid)
    if !empty(l:path) && filereadable(l:path)
        execute 'edit ' .. l:path
    endif
endfunction
let s:editNote = function('s:editNote_')

" Func: s:listNote_ 
function! s:listNote_(args) abort
    call s:getBook_()
    let l:arg = ''
    if !empty(a:args) && !empty(a:args[0])
        let l:arg = a:args[0]
    endif

    " try by tag/date first, then filter full record
    let l:list = s:theBook.getlist(l:arg)
    if empty(l:list)
        let l:list = s:theBook.getlist(l:arg, '?')
    endif

    if exists(':Vnite')
        call vnite#command#output(l:list)
    else
        echo join(l:list, "\n")
    endif
endfunction
let s:listNote = function('s:listNote_')

" Func: s:listTag_ 
function! s:listTag_(args) abort
    call s:getBook_()
    let l:list = s:theBook.getlist('tag')
    if exists(':Vnite')
        call vnite#command#output(l:list)
    else
        echo join(l:list, "\n")
    endif
endfunction
let s:listTag = function('s:listTag_')

" Func: s:scanNote 
function! s:scanNote_(bang, args) abort
    call s:getBook_()
    call s:theBook.rebuild()
    if !empty(a:bang)
        call s:saveBook_()
    endif
endfunction
let s:scanNote = function('s:scanNote_')
