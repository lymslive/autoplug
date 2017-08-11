" File: gamemaze/plugin.vim
" Author: lymslive
" Description: global command and map
" Create: 2017-07-24
" Modify: 2017-08-11
"

if exists('s:load') && !exists('g:DEBUG')
    finish
endif

let s:SIDE_WIDTH = 30
let s:SIDE_NAME = 'maze.info'
let s:MAIN_NAME = 'maze.play'
let s:TABP_NAME = 'maze.tab'

let s:SIDE_TEMP = 'mazeside.md'
let s:SIDE_TEMP_PATH = expand('<sfile>:p:h') . '/' . s:SIDE_TEMP

let s:CTabmaze = class#use('gamemaze#class#tabmaze')
let s:CInfomaze = class#use('gamemaze#class#info')
let s:CPlaymaze = class#use('gamemaze#class#play')

" OpenMaze: open a new tabpage to load maze game
function! gamemaze#plugin#OpenMaze() abort "{{{
    : tabnew
    let t:tabname= s:TABP_NAME
    let t:jGame = s:CTabmaze.new(s:TABP_NAME)

    : vsplit
    : wincmd h
    execute 'vertical resize ' . s:SIDE_WIDTH
    execute 'edit ' . s:SIDE_NAME
    let b:jGameInfo = s:CInfomaze.new(s:SIDE_NAME)
    let t:jGame.wininfo = b:jGameInfo
    call b:jGameInfo.SetOwner(t:jGame)
    call b:jGameInfo.InitWindow(s:SIDE_TEMP_PATH)

    : wincmd l
    execute 'edit ' . s:MAIN_NAME
    let b:jGamePlay = s:CPlaymaze.new(s:MAIN_NAME)
    let t:jGame.winplay = b:jGamePlay
    call b:jGamePlay.SetOwner(t:jGame)
    call b:jGamePlay.InitWindow()

    " back to left side window, and goto line 2
    : wincmd h
    : 2
endfunction "}}}

command! GameMaze call gamemaze#plugin#OpenMaze()

" test: 
function! gamemaze#plugin#test() abort "{{{
    call gamemaze#plugin#OpenMaze()
endfunction "}}}

let s:load = 1
function! gamemaze#plugin#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        unlet! s:load
    endif
endfunction "}}}

