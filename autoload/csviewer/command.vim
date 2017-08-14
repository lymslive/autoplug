" File: csviewer#command
" Author: lymslive
" Description: 
" Create: 2017-08-12
" Modify: 2017-08-14

let s:BUFVAR = 'csviewer'
" BufvarName: 
function! csviewer#command#BufvarName() abort "{{{
    return s:BUFVAR
endfunction "}}}

" BufSource: command&remap local to source buffer
function! csviewer#command#BufSource() abort "{{{
    if exists('b:ftplugin_csviewer_done')
        return
    endif

    if !has_key(b:, s:BUFVAR) || empty(b:[s:BUFVAR])
        call s:CreateObject(v:false)
    endif

    call s:CommonUI()

    let b:ftplugin_csviewer_done = 1
endfunction "}}}

" BufTable: command&remap local to table buffer
function! csviewer#command#BufTable() abort "{{{
    if exists('b:ftplugin_csviewer_done')
        return
    endif

    call s:CommonUI()

    : setlocal buftype=nowrite
    : setlocal bufhidden=hide
    : setlocal nomodifiable
    : setlocal nonumber
    : setlocal nowrap

    nnoremap <buffer> r :call <SID>Redraw()<CR>
    nnoremap <buffer> i :call <SID>EditCell('i')<CR>i
    nnoremap <buffer> a :call <SID>EditCell('a')<CR>a

    let b:ftplugin_csviewer_done = 1
endfunction "}}}

" CommonUI: command and map share in tow views
function! s:CommonUI() abort "{{{
    command! -buffer -nargs=0 A call s:SwitchView()
    command! -buffer -nargs=0 C call s:SwitchMove()
    command! -buffer -nargs=* Cell call s:GotoCell(<f-args>)

    nnoremap <buffer> h :call <SID>Left()<CR>
    nnoremap <buffer> l :call <SID>Right()<CR>
    nnoremap <buffer> j :call <SID>Down()<CR>
    nnoremap <buffer> k :call <SID>Up()<CR>

    nnoremap <F2> :call <SID>SwitchMove()<CR>

endfunction "}}}

" CreateObject: create 3 object from within '*.csv' buffer
" 1 owner container
" 2 buffer variable
" a:1, determine if also create table view object immediately
function! s:CreateObject(...) abort "{{{
    let l:jSource = csviewer#class#source#new()
    if empty(l:jSource)
        return
    endif

    let l:jOwner = csviewer#class#csv#new(l:jSource)

    if a:0 > 0 && a:1
        let l:jTable = csviewer#class#table#new(l:jCsv)
        let l:jOwner.table = l:jTable
    endif
endfunction "}}}

" SwitchView: 
function! s:SwitchView() abort "{{{
    if has_key(b:, s:BUFVAR) && !empty(b:[s:BUFVAR])
        call b:[s:BUFVAR].SwitchView()
        return
    endif

    let l:ext = expand('%:p:t:e')
    if l:ext !=? 'csv'
        return
    endif

    : update
    call s:CreateObject(v:true)
    call b:[s:BUFVAR].SwitchView()
endfunction "}}}

" handle hljk four base movement

" Left: 
function! s:Left() abort "{{{
    if has_key(b:, s:BUFVAR) && !empty(b:[s:BUFVAR])
        call b:[s:BUFVAR].OnLeft()
    else
        normal! h
    endif
endfunction "}}}

" Right: 
function! s:Right() abort "{{{
    if has_key(b:, s:BUFVAR) && !empty(b:[s:BUFVAR])
        call b:[s:BUFVAR].OnRight()
    else
        normal! l
    endif
endfunction "}}}

" Down: 
function! s:Down() abort "{{{
    if has_key(b:, s:BUFVAR) && !empty(b:[s:BUFVAR])
        call b:[s:BUFVAR].OnDown()
    else
        normal! j
    endif
endfunction "}}}

" Up: 
function! s:Up() abort "{{{
    if has_key(b:, s:BUFVAR) && !empty(b:[s:BUFVAR])
        call b:[s:BUFVAR].OnUp()
    else
        normal! k
    endif
endfunction "}}}

" SwitchMove: 
function! s:SwitchMove() abort "{{{
    call b:[s:BUFVAR].SwitchMove()
endfunction "}}}

" GotoCell: (row, col, end)
" row, col is 1-based index position
" argument (row, col) can be use excel style "A2", reduced one argument
" end is 'b' or 'e', which end of the cell
function! s:GotoCell(...) abort "{{{
    let l:end = 'b'
    if a:0 >= 3
        let l:row = a:1
        let l:col = a:2
        let l:end = a:3
    elseif a:0 == 2
        if a:1 =~# '^\d\+$'
            let l:row = a:1
            let l:col = a:2
        else
            let l:pos = s:ParsePos(a:1)
            let l:row = l:pos[0]
            let l:col = l:pos[1]
            let l:end = a:2
        endif
    elseif a:0 == 1
        let l:pos = s:ParsePos(a:1)
        let l:row = l:pos[0]
        let l:col = l:pos[1]
    endif

    call b:[s:BUFVAR].GotoCell(l:row, l:col, l:end)
endfunction "}}}

" ParsePos: pasre excel stype label 'A2' --> [2, 1]
function! s:ParsePos(pos) abort "{{{
    let l:pattern = '^\([a-zA-Z]\+\)\(\d\+\)$'
    let l:lsMatch = matchlist(a:pos, l:pattern)
    if empty(l:lsMatch)
        : ELOG 'invalid cell position notation as A2, but: ' . a:pos
        return []
    endif

    let l:col = l:lsMatch[1]
    let l:row = l:lsMatch[2]
    let l:Fcvs = class#textfile#csv#class()
    let l:col = l:Fcvs.Letter2Column(l:col)
    let l:col += 1

    return [l:row, l:col]
endfunction "}}}

" Redraw: 
function! s:Redraw() abort "{{{
    call b:[s:BUFVAR].Redraw()
endfunction "}}}

" EditCell: 
function! s:EditCell(cmd) abort "{{{
    call b:[s:BUFVAR].OnEdit(a:cmd)
endfunction "}}}
