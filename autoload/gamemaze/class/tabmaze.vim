" Class: gamemaze#class#tabmaze
" Author: lymslive
" Description: a tabpage in vim to play maze game
" Create: 2017-07-13
" Modify: 2017-08-21

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#fantasy#game#old()
let s:class._name_ = 'gamemaze#class#tabmaze'
let s:class._version_ = 1

let s:class.tabname = ''

" the game data
let s:class.game = {}
" side window to display some information
let s:class.wininfo = {}
" main window to play the game
let s:class.winplay = {}

let s:class.playing = v:false

let s:class.constant = {}
" maze generator
let s:class.constant.DEPTH_FIRST = 1
let s:class.constant.KRUSKAL = 2
let s:class.constant.PRIM = 3
" maze target
let s:class.constant.DIRECTION = 1
let s:class.constant.COLLECTION = 2
let s:class.constant.COLLECTSEQ = 3

function! gamemaze#class#tabmaze#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! gamemaze#class#tabmaze#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! gamemaze#class#tabmaze#ctor(this, ...) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this)

    let a:this.tabname = a:1

    let a:this.game = gamemaze#class#tabmaze#DefaultGame()
endfunction "}}}

" DECTOR:
function! gamemaze#class#tabmaze#dector(this) abort "{{{
    unlet! a:this.winplay
    unlet! a:this.wininfo
endfunction "}}}

" ISOBJECT:
function! gamemaze#class#tabmaze#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" DefaultGame: the default game seeting
function! gamemaze#class#tabmaze#DefaultGame() abort "{{{
    let l:game = {}
    let l:game.MazeSize = [10, 10]
    let l:game.CellSize = [2, 3]
    let l:game.Generator = s:class.constant.DEPTH_FIRST
    let l:game.Target = s:class.constant.DIRECTION
    return l:game
endfunction "}}}

" OnStart: 
function! s:class.OnStart() dict abort "{{{
    let self.game.UseTime = 0
    let self.game.UseStep = 0
    let self.game.IdeaStep = 0
    let self.game.IdeaTime = 0
    let self.game.Score = 0
endfunction "}}}

" OnFinish: 
function! s:class.OnFinish() dict abort "{{{
    call self.SolveMaze()
    call self.EvalScore()
endfunction "}}}

" UpdateTime: 
function! s:class.UpdateTime(iSecond) dict abort "{{{
    let self.game.UseTime = a:iSecond
endfunction "}}}

" UpdateStep: 
function! s:class.UpdateStep(iStep) dict abort "{{{
    let self.game.UseStep = a:iStep
endfunction "}}}

" SolveMaze: 
" calculate the idea step (and time) of currnet maze
function! s:class.SolveMaze() dict abort "{{{
    let l:maze = self.winplay.maze
    let l:graph = l:maze.ConvertGraph()

    let l:lsRoomID = ['0,0']
    for l:cell in self.winplay.cell
        let l:id = l:cell[0] . ',' . l:cell[1]
        if l:id !=# '0,0'
            call add(l:lsRoomID, l:id)
        endif
    endfor

    if self.game.Target == self.constant.DIRECTION
        let l:jDist = class#graph#distance#new(l:graph)
        let l:dResult = l:jDist.SolveNoWeight(l:lsRoomID[0], l:lsRoomID[1])
        let self.game.IdeaStep = get(l:dResult, 'dist', 0)
    elseif self.game.Target == self.constant.COLLECTSEQ
        let l:jDist = class#graph#distance#new(l:graph)
        let l:dResult = l:jDist.SequenTravel(l:lsRoomID, v:false)
        let self.game.IdeaStep = get(l:dResult, 'dist', 0)
    elseif self.game.Target == self.constant.COLLECTION
        let l:jDist = class#graph#distance#new(l:graph)
        let l:subGraph = l:jDist.ConnetedGraph(l:lsRoomID, v:false)
        let l:jTravel = class#graph#travel#new(l:subGraph)
        let l:iStepLimit = l:jTravel.LowBound()
        let l:iStepValid = l:jTravel.Greedy()
        let self.game.IdeaStep = (l:iStepLimit + l:iStepValid) / 2
    endif

    if l:self.game.IdeaStep > 0
        let l:fCellMean = (self.game.CellSize[0] + self.game.CellSize[1]) / 2.0 + 1
        let l:fKeyPress = l:self.game.IdeaStep * l:fCellMean
        " say common people press 4 key in evry second
        let self.game.IdeaTime = l:fKeyPress / 4
    endif
endfunction "}}}

" EvalScore: 
function! s:class.EvalScore() dict abort "{{{
    if self.game.IdeaStep <= 0 || self.game.UseStep <= 0
        return
    endif

    let l:fStepDiff = 1.0 * (self.game.UseStep - self.game.IdeaStep) / self.game.IdeaStep
    if l:fStepDiff < 0
        let l:fStepDiff = 0
    endif
    let l:fStepScore = 100 * (1-l:fStepDiff)
    if l:fStepScore < 0
        let l:fStepScore = 0
    endif

    let l:fTimeDiff = 1.0 * (self.game.UseTime - self.game.IdeaTime) / self.game.IdeaTime
    if l:fTimeDiff < 0
        let l:fTimeDiff = 0
    endif
    let l:fTimeScore = 100 * (1-l:fTimeDiff)
    if l:fTimeScore < 0
        let l:fStepScore = 0
    endif

    let l:fStepWeight = 0.8
    let l:fTimeWeight = 0.2
    let l:fScore = l:fStepScore * l:fStepWeight + l:fTimeScore * l:fTimeWeight

    let self.game.Score = 0 + string(l:fScore)
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 gamemaze#class#tabmaze is loading ...'
function! gamemaze#class#tabmaze#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! gamemaze#class#tabmaze#test(...) abort "{{{
    return 0
endfunction "}}}
