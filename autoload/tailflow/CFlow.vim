" Class: tailflow#CFlow
" Author: lymslive
" Description: VimL class frame
" Create: 2018-06-04
" Modify: 2018-06-04

" LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" buffer name 'tail-1', numbered
let s:fname = 'tail'
let s:fid = 0
let s:maxline = 10000

" CLASS:
let s:class = class#old()
let s:class._name_ = 'tailflow#CFlow'
let s:class._version_ = 1

let s:class.cmd = []       " default ['tail', '-f']
let s:class.path = ''      " file path
let s:class.and = []       " regexp list that should match
let s:class.not = []       " regexp list that should not match
let s:class.bufname = ''   " the output buffer name: tail-1
let s:class.bufnr = 0      " the output buffer number
let s:class.job            " the job handled by this object
let s:class.config = {}    " relation config object

function! tailflow#CFlow#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! tailflow#CFlow#new(...) abort "{{{
    if a:0 < 1
        :ELOG 'usage: tailflow#CFlow#new(path)'
    endif
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! tailflow#CFlow#ctor(this, ...) abort "{{{
    let a:this.path = a:1
    let s:fid += 1
    let a:this.bufname = s:fname . '-' . s:fid
    let a:this.and = []
    let a:this.not = []
    let a:this.cmd = ['tail', '-f']
    let a:this.config = {}
endfunction "}}}

" ISOBJECT:
function! tailflow#CFlow#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" SetCommand: 
function! s:class.SetCommand(cmd) dict abort "{{{
    if type(a:cmd) == type([])
        let self.cmd = a:cmd
    elseif type(a:cmd) = type('')
        let self.cmd = split(a:cmd, '\s\+')
    else
        :ELOG 'command expect string or list of string'
    endif
endfunction "}}}

" GetBuffer: 
function! s:class.GetBuffer(...) dict abort "{{{
    if a:0 > 0 && a:1 == 0
        return self.bufnr
    endif
    return self.bufname
endfunction "}}}

" GetFile: 
function! s:class.GetFile() dict abort "{{{
    return self.path
endfunction "}}}

" SetAndList: 
function! s:class.SetAndList(list) dict abort "{{{
    if type(a:list) != type([])
        :ELOG 'argument error, expect a list'
        return -1
    endif
    let self.and = a:list
endfunction "}}}

" AddAndList: 
function! s:class.AddAndList(item) dict abort "{{{
    if index(self.and, a:item) != -1
        return 0
    endif
    call add(self.and, a:item)
endfunction "}}}

" SubAndList: 
function! s:class.SubAndList(item) dict abort "{{{
    let l:idx = index(self.and, a:item)
    if l:idx == -1
        return 0
    endif
    call remove(self.and, l:idx)
endfunction "}}}

" SetNotList: 
function! s:class.SetNotList(list) dict abort "{{{
    if type(a:list) != type([])
        :ELOG 'argument error, expect a list'
        return -1
    endif
    let self.not = a:list
endfunction "}}}

" AddNotList: 
function! s:class.AddNotList(item) dict abort "{{{
    if index(self.not, a:item) != -1
        return 0
    endif
    call add(self.not, a:item)
endfunction "}}}

" SubNotList: 
function! s:class.SubNotList(item) dict abort "{{{
    let l:idx = index(self.not, a:item)
    if l:idx == -1
        return 0
    endif
    call remove(self.not, l:idx)
endfunction "}}}

" OpenBuffer: 
function! s:class.OpenBuffer() dict abort "{{{
    execute 'edit ' . self.bufname
    let self.bufnr = bufnr('%')
endfunction "}}}

" Start: 
function! s:class.Start() dict abort "{{{
    let l:cmd = extend(self.cmd, self.path)
    let l:opt = {}
    let l:opt.out_cb = self.Filter
    let l:opt.err_cb = self.Error
    let self.job = job_start(l:cmd, l:opt)

    if job_status(self.job) ==? 'fail'
        :ELOG 'cannot start job: ' . join(l:cmd, ' ')
        return -1
    endif
    return 0
endfunction "}}}

" Filter: append the stdout from job to the end of buffer
" filtered by the and/not setting
" return v:true if really appended, otherwise v:false
" If cursor on the end, move cursor to the new end too,
" otherwise keep the cursor, say looking around the old output.
function! s:class.Filter(channel, msg) dict abort "{{{
    for l:and in self.and
        if a:msg !~# l:and
            return v:false
        endif
    endfor

    for l:not in self.not
        if a:msg =~# l:not
            return v:false
        endif
    endfor

    " append output to buffer
    let l:bCurBuf = v:true
    if bufnr('%') != self.bufnr
        execute 'hide buffer ' . self.bufnr
        let l:bCurBuf = v:false
    endif

    let l:bCurEnd = v:true
    if line('.') != line('$')
        l:bCurEnd = v:false
    end

    call append(line('$'), a:msg)
    if l:bCurEnd && l:bCurBuf
        normal! G
    endif

    if line('$') > s:maxline
        execute printf('%d,%d delete', 1, float2nr(s:maxline*0.1))
    endif

    " back to origin buffer
    if !l:bCurBuf
        : buffer #
    endif

    return v:true
endfunction "}}}

" Error: 
function! s:class.Error(channel, msg) dict abort "{{{
    :DLOG a:msg
endfunction "}}}

" LOAD:
let s:load = 1
function! tailflow#CFlow#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

" TEST:
function! tailflow#CFlow#test(...) abort "{{{
    let l:obj = tailflow#CFlow#new()
    call class#echo(l:obj)
endfunction "}}}
