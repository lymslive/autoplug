" Class: csviewer#class#source
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-12
" Modify: 2017-08-13

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

let s:FCursor = class#less#cursor#export()

" CLASS:
let s:class = class#buffer#based#old()
let s:class._name_ = 'csviewer#class#source'
let s:class._version_ = 1

let s:class.filepath = ''

let s:class.move_by_cell = v:false

let s:BUFVAR = csviewer#command#BufvarName()

function! csviewer#class#source#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: create from current buffer
function! csviewer#class#source#new(...) abort "{{{
    let l:ext = exand('%:p:t:e')
    if l:ext !=? 'csv'
        : ELOG '[csviewer#class#source#new] current buffer is not csv'
        return {}
    endif
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! csviewer#class#source#ctor(this, ...) abort "{{{
    let a:this.filepath = expand('%:p')
    let a:this.bufnr = bufnr('%')
    call a:this.RegBufvar(s:BUFVAR)
endfunction "}}}

" ISOBJECT:
function! csviewer#class#source#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" Name: 
function! s:class.Name() dict abort "{{{
    return fnamemodify(self.path, ':p:t:r')
endfunction "}}}

" GetViewTable: 
function! s:class.GetViewTable() dict abort "{{{
    if empty(self.owner.table)
        let self.owner.talbe = csviewer#class#table#ctor(self.owner)
    endif
    return self.owner.table
endfunction "}}}

" SwitchView: 
function! s:class.SwitchView() dict abort "{{{
    call self.GetViewTable().Focus()
endfunction "}}}

" SwitchMove: 
function! s:class.SwitchMove() dict abort "{{{
    let self.move_by_cell = !self.move_by_cell
endfunction "}}}

" OnLeft: 
function! s:class.OnLeft() dict abort "{{{
    if self.move_by_cell
        if s:FCursor.GetChar() ==# ','
            : normal! b
        else
            : normal! F,b
        endif
    else
        : normal! h
    endif
endfunction "}}}

" OnRight: 
function! s:class.OnRight() dict abort "{{{
    if self.move_by_cell
        if s:FCursor.GetChar() ==# ','
            : normal! w
        else
            : normal! f,w
        endif
    else
        : normal! l
    endif
endfunction "}}}

" OnDown: 
function! s:class.OnDown() dict abort "{{{
    if line('.') >= line('$')
        return
    endif

    : normal! j

    if self.move_by_cell
        let l:posCell = self.GetCellPos()
        let l:iCol = l:posCell[1]
        : normal! ^
        if l:iCol > 1
            : execute 'normal! ' . l:iCol - 1 . 'f,w'
        endif
    endif
endfunction "}}}

" OnUp: 
function! s:class.OnUp() dict abort "{{{
    if line('.') <= 1
        return
    endif

    : normal! k

    if self.move_by_cell
        let l:posCell = self.GetCellPos()
        let l:iCol = l:posCell[1]
        : normal! ^
        if l:iCol > 1
            : execute 'normal! ' . l:iCol - 1 . 'f,w'
        endif
    endif
endfunction "}}}

" GetCellPos: 
function! s:class.GetCellPos() dict abort "{{{
    let l:iRow = line('.')
    let l:lsPart = s:FCursor.SplitLine()
    let l:sPrevCursor = l:lsPart[0]
    if empty(l:sPrevCursor)
        let l:iCol = 1
    else
        let l:lsCell = split(l:sPrevCursor, ',')
        let l:iCol = len(l:lsCell)
    endif
    return [l:iRow, l:iCol]
endfunction "}}}

" GotoCell: 
" a:1, 'b' or 'e' goto begin or end of cell, defaut 'b'
function! s:class.GotoCell(row, col, ...) dict abort "{{{
    if a:row < 1 || a:row > line('$')
        return
    endif

    " goto begin of row
    : execute 'normal! ' . a:row . 'G^'

    let l:bCellEnd = get(a:000, 0, 'b') =~? '^e'
    if a:col == 1
        if l:bCellEnd
            : normal! t,
        endif
    else
        : execute 'normal! ' . l:iCol - 1 . 'f,w'
        if l:bCellEnd
            : normal! t,
        endif
    endif
endfunction "}}}

" LOAD:
let s:load = 1
function! csviewer#class#source#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! csviewer#class#source#test(...) abort "{{{
    let l:obj = csviewer#class#source#new()
    call class#echo(l:obj)
endfunction "}}}
