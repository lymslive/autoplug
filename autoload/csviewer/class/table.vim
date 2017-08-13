" Class: csviewer#class#table
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-12
" Modify: 2017-08-13

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

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
function! csviewer#class#table#ctor(this, ...) abort "{{{
    let l:bufnr = bufnr('%')
    : update

    let l:csvname = a:this.owner.source.Name()
    : execute 'edit ' . l:csvname . '.tab' 
    let a:this.bufnr = bufnr('%')
    call a:this.Init()
    call a:this.SetOwner(a:1)
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
    let l:iHead = self.owner.headNum
    let l:iCell = len(l:matCell)
    let l:iWidth = len(l:matCell[0])

    if l:iHead > 0
        let self.grid_head = class#fantasy#grid#new(l:iWidth, l:iHead)
        let self.grid_head.SetWidth(s:DEFAULT_WIDTH)
        let self.grid_head.SetHeight(s:DEFAULT_HEIGHT)
    endif

    let self.grid_cell = class#fantasy#grid#new(l:iWidth, l:iCell)
    let self.grid_cell.SetWidth(s:DEFAULT_WIDTH)
    let self.grid_cell.SetHeight(s:DEFAULT_HEIGHT)

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
    " code
endfunction "}}}

" SwitchView: 
function! s:class.SwitchView() dict abort "{{{
    call self.owner.source.Focus()
endfunction "}}}

" SwitchMove: 
function! s:class.SwitchMove() dict abort "{{{
    let self.move_by_cell = !self.move_by_cell
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
