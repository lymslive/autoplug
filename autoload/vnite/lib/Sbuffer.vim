" File: Sbuffer
" Author: lymslive
" Description: class for special buffer
" Create: 2019-11-11
" Modify: 2019-11-11

let s:class = {}
let s:class.name = '_SBUFFER_'
let s:class.bufnr = 0
let s:class.spcmd = 'split'
let s:class.init = v:null  " function callback to init the buffer

" Func: #class 
function! vnite#lib#Sbuffer#class() abort
    return s:class
endfunction

" Func: #new 
function! vnite#lib#Sbuffer#new(name, ...) abort
    let l:object = copy(s:class)
    let l:object.name = a:name
    if a:0 > 0 && !empty(a:1) && type(a:1) == v:t_func
        let l:object.init = a:1
    endif
    return l:object
endfunction

" Method: show 
function! s:class.show() dict abort
    if self.bufnr <= 0
        call self.create()
    endif
    let l:iWinnr = bufwinnr(self.bufnr)
    if l:iWinnr < 0
        execute self.spcmd
        execute 'buffer' self.bufnr
    else
        execute l:iWinnr 'wincmd w'
    endif
endfunction

" Method: try_focus 
function! s:class.try_focus() dict abort
    let l:iWinnr = bufwinnr(self.bufnr)
    if l:iWinnr < 0
        return v:false
    else
        execute l:iWinnr 'wincmd w'
        return v:true
    endif
endfunction

" Method: visible 
function! s:class.visible() dict abort
    return bufwinnr(self.bufnr) > 0
endfunction

" Method: create 
function! s:class.create() dict abort
    execute self.spcmd self.name
    let self.bufnr = bufnr('%')
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal nobuflisted
    if !empty(self.init)
        call self.init()
    endif
endfunction

" Method: setline 
function! s:class.setline(lines) dict abort
    execute '1,$ delete'
    call setbufline(self.bufnr, 1, a:lines)
endfunction
