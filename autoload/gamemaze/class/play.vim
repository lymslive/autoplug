" Class: gamemaze#class#play
" Author: lymslive
" Description: maze game playing logical
" Create: 2017-07-13
" Modify: 2017-08-11

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#buffer#shield#old()
let s:class._name_ = 'gamemaze#class#play'
let s:class._version_ = 1

let s:class.bufname = ''
let s:class.maze = {}
let s:class.cursor = {}

" the position to put letter, static in one game, a-z or IO
" cursor position, 1-based
let s:class.letter = []
" the room position(row, col) that contain letter
" list index positon, 0-based
let s:class.cell = []

" the collected letter in playing game
let s:class.next_letter = ''
let s:class.list_letter = []

function! gamemaze#class#play#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! gamemaze#class#play#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! gamemaze#class#play#ctor(this, ...) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this)
    let a:this.bufname = a:1
endfunction "}}}

" ISOBJECT:
function! gamemaze#class#play#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" InitWindow: 
function! s:class.InitWindow() dict abort "{{{
    let self.maze = class#fantasy#maze#base#new(10, 10)
    call self.maze.GridWall()
    call self.Draw()
    call self.DrawLetter()
    call self.InitPosition()

    call self.Freeze()
    call self.RegisterKey()
endfunction "}}}

" InitGame: 
function! s:class.InitGame() dict abort "{{{
    let l:height = self.owner.game.MazeSize[0]
    let l:width = self.owner.game.MazeSize[1]

    let l:gen = self.owner.game.Generator
    if l:gen == self.owner.constant.DEPTH_FIRST
        let self.maze = class#fantasy#maze#backer#new(l:height, l:width)
    elseif l:gen == self.owner.constant.KRUSKAL
        let self.maze = class#fantasy#maze#kruskal#new(l:height, l:width)
    elseif l:gen == self.owner.constant.PRIM
        let self.maze = class#fantasy#maze#prim#new(l:height, l:width)
    else
        : ELOG 'invalid maze generator'
        return
    endif

    let l:target = self.owner.game.Target
    if l:target == self.owner.constant.DIRECTION
        call self.FixLetterIO()
    elseif l:target == self.owner.constant.COLLECTION
        call self.RandLetter()
    elseif l:target == self.owner.constant.COLLECTSEQ
        call self.RandLetter()
    endif

    let self.next_letter = 'a'
    let self.list_letter = []

    call self.maze.Generate()
    call self.Draw()
    call self.DrawLetter()
    call self.InitPosition()
endfunction "}}}

" InitPosition: 
function! s:class.InitPosition() dict abort "{{{
    let self.cursor = class#math#position#new(2, 2)
    call setpos('.', [0, self.cursor.row, self.cursor.col, 0, self.cursor.col])
endfunction "}}}

" RegisterKey: 
function! s:class.RegisterKey() dict abort "{{{
    nnoremap <buffer> h :<C-u>call gamemaze#class#play#OnKey('h')<CR>
    nnoremap <buffer> l :<C-u>call gamemaze#class#play#OnKey('l')<CR>
    nnoremap <buffer> j :<C-u>call gamemaze#class#play#OnKey('j')<CR>
    nnoremap <buffer> k :<C-u>call gamemaze#class#play#OnKey('k')<CR>
    nnoremap <buffer> a :<C-u>call gamemaze#class#play#OnKey('h')<CR>
    nnoremap <buffer> d :<C-u>call gamemaze#class#play#OnKey('l')<CR>
    nnoremap <buffer> s :<C-u>call gamemaze#class#play#OnKey('j')<CR>
    nnoremap <buffer> w :<C-u>call gamemaze#class#play#OnKey('k')<CR>

    nnoremap <buffer> x :<C-u>call gamemaze#class#play#OnKey('x')<CR>
    nnoremap <buffer> <Space> :<C-u>call gamemaze#class#play#OnKey('x')<CR>
    nnoremap <buffer> <CR> :<C-u>call gamemaze#class#play#OnKey('x')<CR>

    " nnoremap <buffer> q :<C-u>tabclose<CR>
    nnoremap <buffer> q :<C-u>call gamemaze#class#play#OnKey('q')<CR>
    nnoremap <buffer> <tab> :<C-u>wincmd w<CR>

    nnoremap <buffer> <bar> <Nop>
    nnoremap <buffer> f <Nop>
    nnoremap <buffer> t <Nop>
    nnoremap <buffer> F <Nop>
    nnoremap <buffer> T <Nop>
    nnoremap <buffer> gg <Nop>
    nnoremap <buffer> G <Nop>
    nnoremap <buffer> { <Nop>
    nnoremap <buffer> } <Nop>
    nnoremap <buffer> [[ <Nop>
    nnoremap <buffer> ]] <Nop>
    nnoremap <buffer> / <Nop>
    nnoremap <buffer> ? <Nop>
    nnoremap <buffer> n <Nop>
    nnoremap <buffer> N <Nop>
    nnoremap <buffer> W <Nop>
    nnoremap <buffer> e <Nop>
    nnoremap <buffer> E <Nop>

    call self.RegInstance()
endfunction "}}}

" RegInstance: 
let s:object = {}
function! s:class.RegInstance() dict abort "{{{
    let s:object = self
endfunction "}}}

" OnKey: 
function! gamemaze#class#play#OnKey(key) abort "{{{
    if empty(s:object)
        : ELOG 'no registered object'
        return v:false
    else
        return s:object.OnKey(a:key)
    endif
endfunction "}}}

" OnKey: 
function! s:class.OnKey(key) dict abort "{{{
    if !self.owner.playing 
        : WLOG 'This maze game is not in playing!!'
        return v:false
    endif

    if stridx('hljk', a:key) != -1
        return self.Move(a:key)
    elseif  a:key == 'x'
        let l:target = self.owner.game.Target
        if l:target == self.owner.constant.COLLECTION || l:target == self.owner.constant.COLLECTSEQ
            return self.Collect()
        else
            return v:false
        endif
    elseif a:key == 'q'
        return self.owner.wininfo.TabClose()
    else
        return v:false
    endif
endfunction "}}}

" Move: move cursor, a:dir is one of 'hljk'
function! s:class.Move(dir) dict abort "{{{
    let l:posCursor = getcurpos()
    let l:row = l:posCursor[1]
    let l:col = l:posCursor[2]
    let l:row_old = l:row
    let l:col_old = l:col

    if a:dir ==# 'h'
        let l:col -= 1
    elseif a:dir ==# 'l'
        let l:col += 1
    elseif a:dir ==# 'j'
        let l:row += 1
    elseif a:dir ==# 'k'
        let l:row -= 1
    else
        return v:false
    endif

    if l:row < 1 || l:row > line('$') || l:col < 1
        : ELOG 'position beyond range'
        return v:false
    endif
    let l:sLine = getline(l:row)
    let l:char = l:sLine[l:col - 1]
    if l:char !=# self.maze.CHAR_HSIDE && l:char !=# self.maze.CHAR_VSIDE && l:char !=# self.maze.CHAR_CROSS
        let self.cursor.row = l:row
        let self.cursor.col = l:col
        call setpos('.', [0, self.cursor.row, self.cursor.col, 0, self.cursor.col])
        call self.CheckStep([l:row_old, l:col_old], [l:row, l:col])
        call self.CheckFinish()
        return v:true
    endif
    
    return v:false
endfunction "}}}

" Collect: 
function! s:class.Collect() dict abort "{{{
    let l:posCursor = getcurpos()
    let l:row = l:posCursor[1]
    let l:col = l:posCursor[2]
    let l:sLine = getline(l:row)
    let l:char = l:sLine[l:col - 1]

    if l:char =~# '[a-z]'
        if self.owner.game.Target == self.owner.constant.COLLECTSEQ
            if char2nr(l:char) != char2nr(self.next_letter)
                : ELOG 'Please collect letter in sequence, now look for: ' . self.next_letter
                return
            endif
        endif
        let self.next_letter = nr2char(char2nr(l:char) + 1)
        call add(self.list_letter, l:char)

        : setlocal modifiable
        execute 'normal! r '
        : setlocal nomodifiable
        call self.NotifyCollect(l:char)
        call self.CheckFinish()
        return v:true
    else
        : WLOG 'Please cursor on letter, and press x!'
        return v:false
    endif
endfunction "}}}

" CheckFinish: 
function! s:class.CheckFinish() dict abort "{{{
    let l:posCursor = getcurpos()
    let l:row = l:posCursor[1]
    let l:col = l:posCursor[2]
    let l:sLine = getline(l:row)
    let l:char = l:sLine[l:col - 1]

    let l:target = self.owner.game.Target
    if l:target == self.owner.constant.DIRECTION
        if l:char ==# 'O'
            call self.SetFinish()
        endif
    elseif l:target == self.owner.constant.COLLECTION
        if len(self.list_letter) == 26
            call self.SetFinish()
        endif
    elseif l:target == self.owner.constant.COLLECTSEQ
        if len(self.list_letter) == 26
            call self.SetFinish()
        endif
    endif
endfunction "}}}

" SetFinish: 
function! s:class.SetFinish() dict abort "{{{
    : WLOG 'You finish this maze game!'
    let self.owner.playing = v:false
    call self.NotifyFinish()
endfunction "}}}

" CheckStep: 
function! s:class.CheckStep(posOld, posNew) dict abort "{{{
    let l:row_old = a:posOld[0] -1
    let l:col_old = a:posOld[1] -1
    let l:row_new = a:posNew[0] -1
    let l:col_new = a:posNew[1] -1
    let l:hCell = self.owner.game.CellSize[0] +1
    let l:wCell = self.owner.game.CellSize[1] +1

    let l:bStep = v:false
    if l:row_old / l:hCell != l:row_new / l:hCell || l:col_old / l:wCell != l:col_new / l:wCell
        let l:bStep = v:true
        call self.NotifyStep()
    endif
endfunction "}}}

" NotifyCollect: 
function! s:class.NotifyCollect(char) dict abort "{{{
    : wincmd w
    call self.owner.wininfo.OnCollect(a:char)
    : wincmd w
endfunction "}}}

" NotifyStep: 
function! s:class.NotifyStep() dict abort "{{{
    : wincmd w
    call self.owner.wininfo.OnStep()
    : wincmd w
endfunction "}}}

" NotifyFinish: 
function! s:class.NotifyFinish() dict abort "{{{
    : wincmd w
    call self.owner.wininfo.OnFinish()
endfunction "}}}

" Draw: 
function! s:class.Draw() dict abort "{{{
    let l:height = self.owner.game.CellSize[0]
    let l:width = self.owner.game.CellSize[1]
    let l:lsMaze = self.maze.DrawMap(l:height, l:width)
    call self.Update(l:lsMaze)
endfunction "}}}

" FixLetterIO: left-top is I, and right-bottom is O
function! s:class.FixLetterIO() dict abort "{{{
    let l:inPos = [2, 2]
    let l:game = self.owner.game
    let l:outRow = l:game.MazeSize[0] * l:game.CellSize[0] + (l:game.MazeSize[0] + 1) - 1
    let l:outCol = l:game.MazeSize[1] * l:game.CellSize[1] + (l:game.MazeSize[1] + 1) - 1
    let l:outPos = [l:outRow, l:outCol]
    let self.letter = [l:inPos, l:outPos]
    let self.cell = [[0,0], [l:game.MazeSize[0]-1, l:game.MazeSize[1]-1]]
endfunction "}}}

" RandLetter: 
function! s:class.RandLetter() dict abort "{{{
    let l:height = self.owner.game.MazeSize[0]
    let l:width = self.owner.game.MazeSize[1]
    let l:hCell = self.owner.game.CellSize[0]
    let l:wCell = self.owner.game.CellSize[1]

    let self.letter = []
    let self.cell = []
    let l:iCellCnt = l:height * l:width
    if l:iCellCnt < 26
        : ELOG 'the maze is too small'
        return
    endif

    let l:rand = class#math#randit#new(l:iCellCnt)
    for l:i in range(26)
        let l:iRandCell = l:rand.Next()
        let l:iRandCell -= 1
        let l:iRowCell = l:iRandCell / l:width
        let l:iColCell = l:iRandCell % l:width
        let l:iRowPos = l:iRowCell * (l:hCell+1) + 1
        let l:iColPos = l:iColCell * (l:wCell+1) + 1
        let l:iPos = [l:iRowPos + 1, l:iColPos + 1]
        call add(self.letter, l:iPos)
        call add(self.cell, [l:iRowCell, l:iColCell])
    endfor
endfunction "}}}

" DrawLetter: 
function! s:class.DrawLetter() dict abort "{{{
    if empty(self.letter)
        return
    endif

    : setlocal modifiable

    let l:len = len(self.letter)
    if l:len == 2
        call setpos('.', [0, self.letter[0][0], self.letter[0][1], 0, 0])
        : normal! rI
        call setpos('.', [0, self.letter[1][0], self.letter[1][1], 0, 0])
        : normal! rO

    elseif l:len == 26
        let l:alpha = 'abcdefghijklmnopqrstuvwxyz'
        for l:i in range(len(self.letter))
            call setpos('.', [0, self.letter[l:i][0], self.letter[l:i][1], 0, 0])
            execute 'normal! r' . l:alpha[l:i]
        endfor

    else
        : ELOG 'error in letter position list'
    endif

    : setlocal nomodifiable
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 gamemaze#class#play is loading ...'
function! gamemaze#class#play#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! gamemaze#class#play#test(...) abort "{{{
    return 0
endfunction "}}}
