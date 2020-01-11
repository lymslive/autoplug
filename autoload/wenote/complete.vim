" File: complete
" Author: lymslive
" Description: complete for wenote related commands
" Create: 2019-12-19
" Modify: 2019-12-19

let s:mbook = g:wenote#MBook#space

" Func: s:fromTags 
function! s:fromTags(ArgLead, CmdLine, CursorPos) abort
    let l:notebook = s:mbook.getBook()
    if empty(l:notebook)
        return []
    endif
    let l:tags = l:notebook.listTag()
    call filter(l:tags, {idx, val -> val =~ '^' .. a:ArgLead})
    call sort(l:tags)
    call reverse(l:tags)
    return l:tags
endfunction

" Func: #NoteNew 
function! wenote#complete#NoteNew(ArgLead, CmdLine, CursorPos) abort
    return s:fromTags(a:ArgLead, a:CmdLine, a:CursorPos)
endfunction

" Func: #NoteEdit 
function! wenote#complete#NoteEdit(ArgLead, CmdLine, CursorPos) abort
    let l:notebook = s:mbook.getBook()
    if empty(l:notebook)
        return []
    endif
    let l:noteids = keys(l:notebook.mapid)
    call filter(l:noteids, {idx, val -> val =~ '^' .. a:ArgLead})
    call sort(l:noteids)
    call reverse(l:noteids)
    return l:noteids
endfunction

" Func: #NoteList 
function! wenote#complete#NoteList(ArgLead, CmdLine, CursorPos) abort
    return s:fromTags(a:ArgLead, a:CmdLine, a:CursorPos)
endfunction

" InsertTag: 
" <C-X><C-U> complete support
function! wenote#complete#InsertTag(findstart, base) abort
    let l:notebook = s:mbook.getBook()
    if empty(l:notebook)
        return []
    endif

    if a:findstart
        let l:sLine = getline('.')
        if line('.') != 2 || l:sLine !~ '`'
            " only complete in the 2nd line, and has ``
            return -3
        endif
        let l:iStart = col('.') - 1
        while l:iStart > 0 && l:sLine[l:iStart-1] != '`'
            let l:iStart -= 1
        endwhile
        return l:iStart

    else
        let l:tags = keys(l:notebook.listTag)
        call filter(l:tags, {idx, val -> val =~? '^' .. a:base})
        return l:tags
    endif
endfunction
