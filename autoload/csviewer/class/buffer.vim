" Class: csviewer#class#buffer
" Author: lymslive
" Description: VimL class frame
" Create: 2017-08-12
" Modify: 2017-08-12

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#textfile#csv#old()
let s:class._name_ = 'csviewer#class#buffer'
let s:class._version_ = 1

let s:class.bufnr = 0
let s:class.owner = class#new()

function! csviewer#class#buffer#class() abort "{{{
    return s:class
endfunction "}}}

" NEW: create from current buffer
function! csviewer#class#buffer#new(...) abort "{{{
    let l:ext = exand('%:t:e')
    if l:ext !=? 'csv'
        : ELOG '[csviewer#class#buffer#new] current buffer is not csv'
        return {}
    endif
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! csviewer#class#buffer#ctor(this, ...) abort "{{{
    let l:bufnr = bufnr('%')
    let l:path = expand('%:p')
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this, l:path)
    let a:this.bufnr = l:bufnr
endfunction "}}}

" ISOBJECT:
function! csviewer#class#buffer#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" list: 
function! s:class.list() dict abort "{{{
    return getbufline(self.bufnr, 1, '$')
endfunction "}}}

" Name: 
function! s:class.Name() dict abort "{{{
    return fnamemodify(self.path, ':p:t:r')
endfunction "}}}

" LOAD:
let s:load = 1
function! csviewer#class#buffer#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! csviewer#class#buffer#test(...) abort "{{{
    let l:obj = csviewer#class#buffer#new()
    call class#echo(l:obj)
endfunction "}}}
