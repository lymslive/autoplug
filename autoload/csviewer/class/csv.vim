" Class: csviewer#class#csv
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-12
" Modify: 2017-08-14

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#textfile#csv#old()
let s:class._name_ = 'csviewer#class#csv'
let s:class._version_ = 1

" the csv source file buffer
let s:class.source = class#new()
" the tablized view buffer
let s:class.table = class#new()

" current cell [row, col], 1-based index
let s:class.position = []

function! csviewer#class#csv#class() abort "{{{
    return s:class
endfunction "}}}

" the general order to create object:
" source buffer --> this csv owner --> table view buffer
" NEW: #new(source)
function! csviewer#class#csv#new(...) abort "{{{
    if a:0 == 0
        return {}
    endif
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! csviewer#class#csv#ctor(this, ...) abort "{{{
    if csviewer#class#source#isobject(a:1)
        let a:this.source = a:1
        let a:this.source.owner = a:this
    else
        : ELOG 'not csviewer#class#source object'
    endif
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, a:this.source.filepath)
    let a:this.position = [1, 1]
endfunction "}}}

" ISOBJECT:
function! csviewer#class#csv#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" list: 
function! s:class.list() dict abort "{{{
    return self.source.list()
endfunction "}}}

" SavePosition: 
function! s:class.SavePosition(...) dict abort "{{{
    if a:0 >= 2
        let l:row = a:1
        let l:col = a:2
    elseif a:0 == 1
        let l:row = a:1[0]
        let l:col = a:1[1]
    else
        : ELOG '[csv.SavePosition()]: expect (row, col) or [row, col]'
        return self
    endif

    " todo: check valid position
    let self.position = [l:row, l:col]
    return self
endfunction "}}}

" GetPosition: 
function! s:class.GetPosition() dict abort "{{{
    return self.position
endfunction "}}}

" LOAD:
let s:load = 1
function! csviewer#class#csv#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! csviewer#class#csv#test(...) abort "{{{
    let l:obj = csviewer#class#csv#new()
    call class#echo(l:obj)
endfunction "}}}
