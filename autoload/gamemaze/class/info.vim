" Class: gamemaze#class#info
" Author: lymslive
" Description: VimL class frame
" Create: 2017-07-15
" Modify: 2017-08-11

"LOAD:
if exists('s:load') && !exists('g:DEBUG')
    finish
endif

" CLASS:
let s:class = class#buffer#shield#old()
let s:class._name_ = 'gamemaze#class#info'
let s:class._version_ = 1

let s:class.bufname = ''
let s:class.buffile = {}

function! gamemaze#class#info#class() abort "{{{
    return s:class
endfunction "}}}

" NEW:
function! gamemaze#class#info#new(...) abort "{{{
    let l:obj = class#new(s:class, a:000)
    return l:obj
endfunction "}}}
" CTOR:
function! gamemaze#class#info#ctor(this, ...) abort "{{{
    let l:Suctor = class#Suctor(s:class)
    call l:Suctor(a:this)
    let a:this.bufname = a:1
    let a:this.modified_ = v:false
endfunction "}}}

" ISOBJECT:
function! gamemaze#class#info#isobject(that) abort "{{{
    return class#isobject(s:class, a:that)
endfunction "}}}

" InitWindow: 
function! s:class.InitWindow(pTempfile) dict abort "{{{
    let self.buffile = class#textfile#endmark#new(a:pTempfile)
    call self.buffile.Init()
    call self.InitFilter()
    call self.Draw()
    : setlocal filetype=markdown

    call self.Freeze()
    call self.RegisterKey()
endfunction "}}}

" InitFilter: 
function! s:class.InitFilter() dict abort "{{{
    " fold the sublist begin with ' - '
    call self.buffile.ShowLineReg('^\s\+-\s\+', self.buffile.HIDE)
endfunction "}}}

" Filter: 
function! s:class.Filter() dict abort "{{{
    " start or restart
    if self.owner.playing
        let l:item = self.buffile.GetLine('top:start')
        let l:item.show = 0
        let l:item = self.buffile.GetLine('top:restart')
        let l:item.show = 1
    else
        let l:item = self.buffile.GetLine('top:start')
        let l:item.show = 1
        let l:item = self.buffile.GetLine('top:restart')
        let l:item.show = 0
    endif

    " which game target, show extra line when collect target
    let l:iTarget = 0 + self.buffile.GetSlotValue('ss:target')
    if l:iTarget == 1
        call self.buffile.ShowLine('ss:collect', self.buffile.HIDE, [0, 1, 2, 3])
    else
        call self.buffile.ShowLine('ss:collect', self.buffile.SHOW, [0, 1, 2, 3])
    endif

    " only show help line with current target
    for l:i in range(1, 3)
        let l:name = 'T' . l:i
        if l:i == l:iTarget
            call self.buffile.ShowLine(l:name, self.buffile.SHOW)
        else
            call self.buffile.ShowLine(l:name, self.buffile.HIDE)
        endif
    endfor
endfunction "}}}

" Draw: 
function! s:class.Draw() dict abort "{{{
    call self.Filter()
    let l:lsText = self.buffile.Output()
    call self.Update(l:lsText)
endfunction "}}}

" RegisterKey: 
function! s:class.RegisterKey() dict abort "{{{
    nnoremap <buffer> gg :<C-u>call gamemaze#class#info#OnKey('gg')<CR>
    nnoremap <buffer> <CR> :<C-u>call gamemaze#class#info#OnKey('<lt>CR>')<CR>

    " nnoremap <buffer> q :<C-u>tabclose<CR>
    nnoremap <buffer> q :<C-u>call gamemaze#class#info#OnKey('q')<CR>
    nnoremap <buffer> <tab> :<C-u>wincmd w<CR>

    call self.RegInstance()
endfunction "}}}

" RegInstance: 
let s:object = {}
function! s:class.RegInstance() dict abort "{{{
    let s:object = self
endfunction "}}}

" OnKey: 
" when handler function operate success, return true, otherwise false
function! gamemaze#class#info#OnKey(key) abort "{{{
    if empty(s:object)
        : ELOG 'no registered object'
        return v:false
    else
        return s:object.OnKey(a:key)
    endif
endfunction "}}}

" OnKey: 
function! s:class.OnKey(key) dict abort "{{{
    let l:iWinPre = winnr()

    if a:key ==# 'gg'
        call self.GotoTop()
    elseif a:key ==? '<CR>'
        call self.OnEnter()
    elseif a:key ==# 'q'
        return self.TabClose()
    else
        : ELOG 'cannot handle this key: ' . a:key
        return v:false
    endif

    let l:iWinPost = winnr()
    if l:iWinPre && l:iWinPost && self.modified_
        call self.Draw()
        let self.modified_ = v:false
    endif

    return v:true
endfunction "}}}

" TabClose: 
function! s:class.TabClose() dict abort "{{{
    if has_key(self, 'timer_')
        call timer_stop(self.timer_)
    endif

    call class#delete(self.owner)
    : tabclose
    return v:true
endfunction "}}}

" GotoTop: 
function! s:class.GotoTop() dict abort "{{{
    : normal! gg
    return search('^#\s\+')
endfunction "}}}

" OnEnter: 
function! s:class.OnEnter() dict abort "{{{
    let l:iLine = line('.')
    let l:sLine = getline('.')
    if l:iLine >= 1 && l:iLine <= 3 && (l:sLine =~# '^=\+' || l:sLine =~# '^#\s\+')
        return self.StartGame()
    elseif l:sLine =~# '^+\s\+'
        return self.ExpandOption(l:iLine, l:sLine)
    elseif l:sLine =~# '^\s\+-\s\+'
        return self.SelectOption(l:iLine, l:sLine)
    endif
    return v:false
endfunction "}}}

" StartGame: goto the other play window, and start game
function! s:class.StartGame() dict abort "{{{
    call self.ParseConfig()
    let self.owner.playing = v:true
    call self.OnStart()
    call self.Draw()
    : wincmd w
    return self.owner.winplay.InitGame()
endfunction "}}}

" ParseConfig: parse the 4 game settings
function! s:class.ParseConfig() dict abort "{{{
    let l:sMazeSize = self.buffile.GetSlotText('ss:maze')
    let l:lsMatch = matchlist(l:sMazeSize, '\(\d\+\)x\(\d\+\)')
    if empty(l:lsMatch)
        : ELOG 'text format error, expect: ddxdd'
        continue
    endif
    let self.owner.game.MazeSize = [str2nr(l:lsMatch[1]), str2nr(l:lsMatch[2])]

    let l:sCellSize = self.buffile.GetSlotText('ss:cell')
    let l:lsMatch = matchlist(l:sCellSize, '\(\d\+\)x\(\d\+\)')
    if empty(l:lsMatch)
        : ELOG 'text format error, expect: ddxdd'
        continue
    endif
    let self.owner.game.CellSize = [str2nr(l:lsMatch[1]), str2nr(l:lsMatch[2])]

    let l:iGenerator = 0 + self.buffile.GetSlotValue('ss:generate')
    let self.owner.game.Generator = l:iGenerator

    let l:iTarget = 0 + self.buffile.GetSlotValue('ss:target')
    let self.owner.game.Target = l:iTarget
endfunction "}}}

" ExpandOption: 
function! s:class.ExpandOption(iLine, sLine) dict abort "{{{
    let l:item = self.buffile.view[a:iLine-1]
    let l:line = l:item.line - 1
    let l:lineNext = l:line + 1
    while self.buffile.array[l:lineNext].text =~# '^\s\+-\s\+'
        let self.buffile.array[l:lineNext].show = self.buffile.SHOW
        let l:lineNext += 1
    endwhile

    : normal! j
    let self.modified_ = v:true
    return v:true
endfunction "}}}

" SelectOption: 
function! s:class.SelectOption(iLine, sLine) dict abort "{{{
    let l:item = self.buffile.view[a:iLine-1]
    let l:line = l:item.line - 1

    let l:lsMatch = matchlist(l:item.text, '^\s\+-\s\+\[\(\d\)\]\s*\(.*\)')
    if empty(l:lsMatch)
        : ELOG 'text format error'
        break
    endif
    let l:iOption = l:lsMatch[1]
    let l:sOption = l:lsMatch[2]

    let l:lineNext = l:line
    while self.buffile.array[l:lineNext].text =~# '^\s\+-\s\+'
        let self.buffile.array[l:lineNext].show = self.buffile.HIDE
        let l:lineNext += 1
    endwhile

    let l:linePrev = l:line - 1
    while v:true
        if self.buffile.array[l:linePrev].text =~# '^\s\+-\s\+'
            let self.buffile.array[l:linePrev].show = self.buffile.HIDE
        elseif self.buffile.array[l:linePrev].text =~# '^+\s\+'
            let l:name = self.buffile.array[l:linePrev].name
            call self.buffile.UpdateSlot(l:name, l:sOption, l:iOption)
            let l:iShift = l:line - l:linePrev
            execute 'normal! ' . l:iShift . 'k'
            break
        endif
        let l:linePrev -= 1
    endwhile

    let self.modified_ = v:true
    return v:true
endfunction "}}}

" OnStart: 
function! s:class.OnStart() dict abort "{{{
    call self.buffile.UpdateSlot('l:time', 0)
    call self.buffile.UpdateSlot('l:step', 0)
    call self.buffile.UpdateSlot('l:theory', 0)
    call self.buffile.UpdateSlot('l:score', 0)

    " collect letter back to low case
    let l:item = self.buffile.GetLine('l:letter1')
    let l:sReplace = substitute(l:item.text, '[A-Z]', '\L&', 'g')
    let l:item.text = l:sReplace

    let l:item = self.buffile.GetLine('l:letter2')
    let l:sReplace = substitute(l:item.text, '[A-Z]', '\L&', 'g')
    let l:item.text = l:sReplace

    if has('timers')
        let self.timer_ = timer_start(5000, self.OnUpdataTime, {'repeat': -1})
    endif

    let self.time_start_ = reltime()

    call self.owner.OnStart()
endfunction "}}}

" OnUpdataTime: 
function! s:class.OnUpdataTime(timer) dict abort "{{{
    if !has('timers')
        return
    endif
    let l:iTime = 0 + self.buffile.GetSlotText('l:time')
    let l:iTime += 5
    call self.buffile.UpdateSlot('l:time', l:iTime)

    call self.owner.UpdateTime(l:iTime)

    call self.Draw()
endfunction "}}}

" OnCollect: 
function! s:class.OnCollect(char) dict abort "{{{
    " collect letter trans to up case
    let l:item = self.buffile.GetLine('l:letter1')
    let l:sReplace = substitute(l:item.text, a:char, '\U&', '')
    let l:item.text = l:sReplace

    let l:item = self.buffile.GetLine('l:letter2')
    let l:sReplace = substitute(l:item.text, a:char, '\U&', '')
    let l:item.text = l:sReplace

    call self.Draw()
endfunction "}}}

" OnStep: 
function! s:class.OnStep() dict abort "{{{
    let l:iStep = 0 + self.buffile.GetSlotText('l:step')
    let l:iStep += 1
    call self.buffile.UpdateSlot('l:step', l:iStep)
    
    call self.owner.UpdateStep(l:iStep)

    call self.Draw()
endfunction "}}}

" OnFinish: 
function! s:class.OnFinish() dict abort "{{{
    if has_key(self, 'timer_')
        call timer_stop(self.timer_)
    endif

    let l:iTime = reltime(self.time_start_)[0]
    call self.buffile.UpdateSlot('l:time', l:iTime)
    call self.owner.UpdateTime(l:iTime)

    call self.owner.OnFinish()
    if self.owner.game.IdeaStep > 0
        call self.buffile.UpdateSlot('l:theory', self.owner.game.IdeaStep)
        call self.buffile.UpdateSlot('l:score', self.owner.game.Score)
        call self.Draw()
    endif

    let l:iLine = self.buffile.GetShowNumber('l:score')
    if l:iLine > 0
        call cursor(l:iLine, 0)
        : normal! $b
    endif
endfunction "}}}

" LOAD:
let s:load = 1
:DLOG '-1 gamemaze#class#info is loading ...'
function! gamemaze#class#info#load(...) abort "{{{
    if a:0 > 0 && !empty(a:1) && exists('s:load')
        unlet s:load
        return 0
    endif
    return s:load
endfunction "}}}

" TEST:
function! gamemaze#class#info#test(...) abort "{{{
    return 0
endfunction "}}}
