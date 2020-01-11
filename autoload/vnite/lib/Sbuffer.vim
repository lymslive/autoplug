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
let s:class.from = v:null  " where you coming from, which buffer/window

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
    let l:object.from = {}
    return l:object
endfunction

" Method: show 
function! s:class.show() dict abort
    if self.bufnr <= 0
        return self.create()
    endif
    call self.update_from()
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
    call self.update_from()
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

" Method: update_from 
function! s:class.update_from() dict abort
    if bufnr('%') == self.bufnr
        return
    endif
    let self.from.bufnr = bufnr('%')
    let self.from.winid = bufwinid('%')
    let self.from.curfile = expand('%:p')
    let self.from.curpos = getcurpos()
endfunction

" Method: back_from 
function! s:class.back_from() dict abort
    if empty(self.from)
        return
    endif
    let [l:tabnr, l:winnr] = win_id2tabwin(self.from.winid)
    if l:tabnr > 0 && l:winnr > 0
        execute l:tabnr . 'tabnext'
        execute l:winnr . 'wincmd w'
        if bufnr('%') ==  self.from.bufnr
            call setpos('.', self.from.curpos)
        endif
    else
        call s:find_main_window()
    endif
endfunction

" Func: s:find_main_window 
function! s:find_main_window() abort
    let l:wincount = winnr('$')
    if l:wincount < 2
        return
    endif
    let l:maxarea = 0
    let l:mainwin = 0
    for l:winnr in range(1, l:wincount)
        let l:area = winwidth(l:winnr) * winheight(l:winnr)
        if l:area > l:maxarea
            let l:maxarea = l:area
            let l:mainwin = l:winnr
        endif
    endfor
    if l:mainwin > 0
        execute l:mainwin . 'wincmd w'
    endif
endfunction
