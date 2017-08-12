" Class: csviewer#class#csv
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-12
" Modify: 2017-08-12

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#old()
let s:class._name_ = 'csviewer#class#csv'
let s:class._version_ = 1

" the csv source file buffer
let s:class.source = class#new()
" the tablized view buffer
let s:class.table = class#new()

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
    if csviewer#class#buffer#isobject(a:1)
        let a:this.source = a:1
        let a:this.source.owner = a:this
    endif
endfunction "}}}

" ISOBJECT:
function! csviewer#class#csv#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
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
