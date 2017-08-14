" Class: csviewer#class#table
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-12
" Modify: 2017-08-14

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

let s:FCursor = class#less#cursor#export()

" CLASS:
let s:class = class#buffer#based#old()
let s:class._name_ = 'csviewer#class#table'
let s:class._version_ = 1

let s:class.grid_head = class#new()
let s:class.grid_cell = class#new()

let s:class.move_by_cell = v:true

" the default cell size 1*8
let s:DEFAULT_WIDTH = 8
let s:DEFAULT_HEIGHT = 1

let s:BUFVAR = csviewer#command#BufvarName()

function! csviewer#class#table#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: #new(owner)
function! csviewer#class#table#new(...) abort "{{{
    if a:0 == 0 || !csviewer#class#csv#isobject(a:1)
        : ELOG '[csviewer#class#table#new] expect an object of csv as owner'
        return {}
    endif
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! csviewer#class#table#ctor(this, owner, ...) abort "{{{
    let l:bufnr = bufnr('%')
    : update

    call a:this.SetOwner(a:owner)
    let l:csvname = a:this.owner.source.Name()
    : execute 'edit ' . l:csvname . '.tab' 
    let a:this.bufnr = bufnr('%')
    call a:this.Init()
    call a:this.RegBufvar(s:BUFVAR)
    call csviewer#command#BufTable()

    if l:bufnr > 0
        : execute 'buffer ' . l:bufnr
    endif
endfunction "}}}

" ISOBJECT:
function! csviewer#class#table#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" Init: 
function! s:class.Init() dict abort "{{{
    let l:matCell = self.owner.GetCell()
    if empty(l:matCell)
        : ELOG 'empty cell when init table csv'
        return self
    endif

    let l:iHead = self.owner.headNum
    let l:iCell = len(l:matCell)
    let l:iWidth = len(l:matCell[0])

    if l:iHead > 0
        let self.grid_head = class#fantasy#grid#new(l:iWidth, l:iHead)
        call self.grid_head.SetWidth(s:DEFAULT_WIDTH)
        call self.grid_head.SetHeight(s:DEFAULT_HEIGHT)
    endif

    let self.grid_cell = class#fantasy#grid#new(l:iWidth, l:iCell)
    call self.grid_cell.SetWidth(s:DEFAULT_WIDTH)
    call self.grid_cell.SetHeight(s:DEFAULT_HEIGHT)

    let l:iLine = 1
    if l:iHead > 0
        let l:lsGrid = self.grid_head.Fillout(self.owner.header, l:iLine)
        let l:iLine += len(l:lsGrid)
    endif
    let l:lsGrid = self.grid_cell.Fillout(l:matCell, l:iLine)

    return self
endfunction "}}}

" Redraw: 
function! s:class.Redraw() dict abort "{{{
    : setlocal modifiable
    call self.owner.ParseFile(v:true)
    call self.Init()
    : setlocal nomodifiable
endfunction "}}}

" EnterView: 
function! s:class.EnterView(...) dict abort "{{{
    call self.Focus()
    let [l:row, l:col] = self.owner.GetPosition()
    call self.GotoCell(l:row, l:col, get(a:000, 0, ''))
    return self
endfunction "}}}

" SwitchView: 
function! s:class.SwitchView() dict abort "{{{
    call self.owner.SavePosition(self.GetCellPos())
    call self.owner.source.EnterView()
endfunction "}}}

" SwitchMove: 
function! s:class.SwitchMove() dict abort "{{{
    let self.move_by_cell = !self.move_by_cell
endfunction "}}}

" OnLeft: 
function! s:class.OnLeft() dict abort "{{{
    if self.move_by_cell
        let [l:row, l:col] = self.GetCellPos()
        let l:col -= 1
        call self.GotoCell(l:row, l:col)
    else
        : normal! h
    endif
endfunction "}}}

" OnRight: 
function! s:class.OnRight() dict abort "{{{
    if self.move_by_cell
        let [l:row, l:col] = self.GetCellPos()
        let l:col += 1
        call self.GotoCell(l:row, l:col)
    else
        : normal! l
    endif
endfunction "}}}

" OnDown: 
function! s:class.OnDown() dict abort "{{{
    if self.move_by_cell
        let [l:row, l:col] = self.GetCellPos()
        let l:row += 1
        call self.GotoCell(l:row, l:col)
    else
        : normal! j
    endif
endfunction "}}}

" OnUp: 
function! s:class.OnUp() dict abort "{{{
    if self.move_by_cell
        let [l:row, l:col] = self.GetCellPos()
        let l:row -= 1
        call self.GotoCell(l:row, l:col)
    else
        : normal! k
    endif
endfunction "}}}

" GetCellPos: 
function! s:class.GetCellPos() dict abort "{{{
    let l:iRow = line('.')
    let l:iRow = l:iRow / 2
    if iRow < 1
        let l:iRow = 1
    endif

    let l:lsPart = s:FCursor.SplitLine()
    let l:sPrevCursor = l:lsPart[0]
    if empty(l:sPrevCursor)
        let l:iCol = 1
    else
        let l:lsCell = split(l:sPrevCursor, '[|+]')
        let l:iCol = len(l:lsCell)
    endif
    return [l:iRow, l:iCol]
endfunction "}}}

" GotoCell: 
" a:1, 'b' or 'e' goto begin or end of cell, defaut 'b'
function! s:class.GotoCell(row, col, ...) dict abort "{{{
    let [l:hsize, l:wsize] = self.owner.GetSize()
    if a:row > l:hsize || a:row <= 0
        return
    else
        let l:row = a:row
    endif
    if a:col > l:wsize || a:col <= 0
        return
    else
        let l:col = a:col
    endif

    let l:row = 2 * l:row
    if l:row < 1 || l:row > line('$')
        return
    endif

    " goto begin of row
    : execute 'normal! ' . l:row . 'G^'

    let l:bCellEnd = get(a:000, 0, 'b') =~? '^e'
    if l:col <= 1
        if l:bCellEnd
            : normal! t|
        else
            : normal! w
        endif
    else
        : execute 'normal! ' . (l:col-1) . 'f|w'
        if l:bCellEnd
            : normal! t|
        endif
    endif
endfunction "}}}

" OnEdit: 
function! s:class.OnEdit(cmd) dict abort "{{{
    if a:cmd =~? '^a'
        let l:end = 'e'
    else
        let l:end = 'b'
    endif
    call self.owner.SavePosition(self.GetCellPos())
    call self.owner.source.EnterView(l:end)
endfunction "}}}

" LOAD:
let s:load = 1
function! csviewer#class#table#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! csviewer#class#table#test(...) abort "{{{
    let l:obj = csviewer#class#table#new()
    call class#echo(l:obj)
endfunction "}}}
