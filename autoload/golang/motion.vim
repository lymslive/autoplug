" File: motion
" Author: lymslive
" Description: 
" Create: 2018-04-28
" Modify: 2018-04-29

let s:block = {}
let s:block.import = {'regexp' : '^import'}
let s:block.package = {'regexp' : '^package'}
let s:block.const = {'regexp' : '^const'}
let s:block.var = {'regexp' : '^var'}
let s:block.func = {'regexp' : '^func'}
let s:block.struct = {'regexp' : '^type\s\+\(\S\+\)\s\+struct'}
let s:block.interface = {'regexp' : '^type\s\+\(\S\+\)\s\+interface'}

" Start: 开启快捷移动浏览模式
function! golang#motion#Start(block, mark, ...) abort "{{{
    " 先标记原位置
    if len(a:mark) > 0
        let l:cmd = 'm' . a:mark[0]
        execute 'normal!' l:cmd
    endif

    if !has_key(s:block, a:block)
        return
    endif
    let l:regexp = s:block[a:block]['regexp']

     " 记录当前位置
    let l:flag = 's'
    if a:0 > 0
        let l:flag .= a:1
    endif

    call search(l:regexp, l:flag)
    echo 'start motion by block:' a:block

    let b:qmotion = v:true
    let b:qmotion_lastblock = a:block
    if len(a:mark) > 0
        let b:qmotion_lastmark = a:mark[0]
    endif
endfunction "}}}

" Stop: 停止快捷移动，回到之前的标记位置
function! golang#motion#Stop(mark) abort "{{{
    if empty(a:mark)
        let l:cmd = '`' . b:qmotion_lastmark
    else
        let l:cmd = '`' . a:mark[0]
    endif
    execute 'normal!' l:cmd

    let b:qmotion = v:false
    let b:qmotion_lastmark = ''
    let b:qmotion_lastblock = ''
endfunction "}}}

" Next: 继续向下搜索移动
function! golang#motion#Next() abort "{{{
    let l:block = b:qmotion_lastblock
    let l:regexp = s:block[l:block]['regexp']
    call search(l:regexp)
endfunction "}}}

" Prev: 继续向上搜索移动
function! golang#motion#Prev() abort "{{{
    let l:block = b:qmotion_lastblock
    let l:regexp = s:block[l:block]['regexp']
    call search(l:regexp, 'b')
endfunction "}}}
