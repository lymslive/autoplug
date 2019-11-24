" File: Simcli
" Author: lymslive
" Description: simulation for cmdline
" Create: 2019-11-02
" Modify: 2019-11-02

let s:class = {}
let s:class._ctype_ = 'Simcli'
let s:class.prompt = ''         " prompt string befor cmdline
let s:class.cmdline = []        " a list of characters
let s:class.curpos = 0          " cursor position as index of cmdline
let s:class.keymaps = {}        " refer to global filter mode maps
let s:class.localmaps = {}      " local buffer filter mode maps
let s:class.active = v:false    " activelly in filter mode
let s:class.exitkey = ''        " the reason or which key to exit cmdline

let s:class.notify = {}         " data to control nofity
let s:class.notify.callback = v:null
let s:class.notify.frequency = 200     " every ms time to notify cmdline changed
let s:class.notify.lasttime = v:null
let s:class.notify.cmdline = ''

let s:timer = {}
let s:timer.id = 0
let s:timer.frequency = 200
let s:timer.target = v:null  " the Simcli instance to serve

" Func: #class 
function! vnite#Simcli#class() abort
    return s:class
endfunction

" Method: new 
function! s:class.new(...) dict abort
    let l:object = copy(s:class)
    if a:0 > 0 && !empty(a:1)
        let l:object.prompt = a:1
    endif
    let l:object.cmdline = []
    let l:object.localmaps = {}
    let l:object.notify = copy(s:class.notify)
    return l:object
endfunction

" Method: set_keymaps 
function! s:class.set_keymaps(dict) dict abort
    if type(a:dict) == v:t_dict && !empty(a:dict)
        let self.keymaps = a:dict
    endif
endfunction

" Method: add_keymaps 
function! s:class.add_keymaps(key, val) dict abort
    if !empty(a:key) && !empty(a:val)
        let self.localmaps[a:key] = a:val
    endif
endfunction

" Method: set_notify 
function! s:class.set_notify(option) dict abort
    if type(a:option) == v:t_func
        let self.notify.callback = a:option
    elseif type(a:option) == v:t_number
        let self.notify.frequency = a:option
    elseif type(a:option) == v:t_dict
        if has_key(option, 'callback') && type(a:option.callback) == v:t_func
            let self.notify.callback = a:option.callback
        elseif has_key(option, 'frequency') && type(a:option.frequency) == v:t_number
            let self.notify.frequency = a:option.frequency
        endif
    else
        echoerr 'unknow notify option'
    endif
endfunction

" Method: loop 
function! s:class.loop() dict abort
    try
        let l:save_gcr = &guicursor
        set guicursor=a:invisible
        call self.onEnter()
        call self.do_loop()
    catch /^Vim:Interrupt$/
        let self.exitkey = "\<C-C>"
    finally
        call self.onLeave()
        let &guicursor = l:save_gcr
    endtry
endfunction

" Method: loop 
function! s:class.do_loop() dict abort
    while 1
        " support reenter filter mode
        call self.drawcli()
        redraw

        let l:ch = getchar()
        if type(l:ch) == v:t_number
            let l:char = nr2char(l:ch)
        else
            let l:char = l:ch
        endif

        if l:char ==# "\<CursorHold>"
            call self.check_notify()
            continue
        endif

        if has_key(self.localmaps, l:char)
            let l:remap = self.localmaps[l:char]
            call feedkeys(l:remap, 'n')
            continue
        elseif has_key(self.keymaps, l:char)
            let l:remap = self.keymaps[l:char]
            call feedkeys(l:remap, 'n')
            continue
        endif

        if type(l:ch) == v:t_number && l:ch >= 32 && l:ch < 127
            call self.input(l:char)
        else
            if l:char ==# "\<C-C>"
                break
            elseif l:char ==# "\<Left>" || l:char ==# "\<C-B>"
                call self.toleft()
            elseif l:char ==# "\<Right>" || l:char ==# "\<C-F>"
                call self.toright()
            elseif l:char ==# "\<Home>" || l:char ==# "\<C-A>"
                call self.tobegin()
            elseif l:char ==# "\<End>" || l:char ==# "\<C-E>"
                call self.toend()
            elseif l:char ==# "\<C-K>"
                call self.killtoend()
            elseif l:char ==# "\<C-W>"
                call self.killtobegin()
            elseif l:char ==# "\<BS>" || l:char ==# "\<C-H>"
                call self.deltoleft()
            elseif l:char ==# "\<Del>" || l:char ==# "\<C-D>"
                call self.deltoright()
            elseif l:char ==# "\<C-U>"
                call self.clearall()
            elseif l:char ==# "\<C-R>"
                call self.do_notify()
            elseif l:char ==# "\<Esc>"
                call self.onEsc()
                break
            elseif l:char ==# "\<CR>"
                call self.onCR()
                break
            else
                " ignore
                continue
            endif
        endif

        " call self.check_notify()
    endwhile
endfunction

" Method: input 
function! s:class.input(char) dict abort
    let l:char = a:char
    let l:length = len(self.cmdline)
    if self.curpos == l:length
        call add(self.cmdline, a:char)
    elseif self.curpos == 0
        let self.cmdline = [l:char] + self.cmdline
    elseif self.curpos > 0 && self.curpos < l:length
        let l:left = self.cmdline[0 : self.curpos - 1]
        let l:right = self.cmdline[self.curpos :]
        let self.cmdline = l:left + [l:char] + l:right
    else
        echoerr 'internal error'
    endif
    let self.curpos += 1
endfunction

" Method: toleft 
function! s:class.toleft() dict abort
    if self.curpos > 0
        let self.curpos -= 1
    endif
endfunction

" Method: toright 
function! s:class.toright() dict abort
    if self.curpos < len(self.cmdline)
        let self.curpos += 1
    endif
endfunction

" Method: tobegin 
function! s:class.tobegin() dict abort
    let self.curpos = 0
endfunction

" Method: toend 
function! s:class.toend() dict abort
    let self.curpos = len(self.cmdline)
endfunction

" Method: killtoright 
function! s:class.killtoend() dict abort
    if self.curpos < len(self.cmdline)
        call remove(self.cmdline, self.curpos, -1)
    endif
endfunction

" Method: killtoleft 
function! s:class.killtobegin() dict abort
    if self.curpos > 0
        let self.cmdline = self.cmdline[self.curpos : ]
        let self.curpos = 0
    endif
endfunction

" Method: cleara 
function! s:class.clearall() dict abort
    let self.cmdline = []
    let self.curpos = 0
    call self.do_notify()
endfunction

" Method: backdel 
function! s:class.deltoleft() dict abort
    if self.curpos > 0
        if self.curpos == 1
            let self.cmdline = self.cmdline[self.curpos : ]
        else
            let l:left = self.cmdline[0 : self.curpos - 1 - 1]
            let l:right = self.cmdline[self.curpos : ]
            let self.cmdline = l:left + l:right
        endif
        let self.curpos -= 1
    endif
endfunction

" Method: forwdel 
function! s:class.deltoright() dict abort
    if self.curpos < len(self.cmdline)
        if self.curpos == 0
            let self.cmdline = self.cmdline[self.curpos+1 : ]
        else
            let l:left = self.cmdline[0 : self.curpos - 1]
            let l:right = self.cmdline[self.curpos+1 : ]
            let self.cmdline = l:left + l:right
        endif
    endif
endfunction

" Method: drawcli 
function! s:class.drawcli() dict abort
    echo ''
    echohl Search | echon self.prompt | echohl NONE
    if empty(self.cmdline)
        echohl Cursor | echon ' ' | echohl NONE
        return
    endif

    let l:left = ''
    let l:cur = ''
    let l:right = ''
    if self.curpos > 0
        " let l:left = self.cmdline[0 : self.curpos - 1]->join('')
        let l:left = join(self.cmdline[0 : self.curpos - 1], '')
    endif
    if self.curpos < len(self.cmdline)
        let l:cur = self.cmdline[self.curpos]
        " let l:right = self.cmdline[self.curpos+1 : ]->join('')
        let l:right = join(self.cmdline[self.curpos+1 : ], '')
    endif

    if !empty(l:left)
        echohl Normal | echon l:left | echohl NONE
    endif
    if !empty(l:cur)
        echohl Cursor | echon l:cur | echohl NONE
    else
        echohl Cursor | echon ' ' | echohl NONE
    endif
    if !empty(l:right)
        echohl Normal | echon l:right | echohl NONE
    endif
endfunction

" Method: onCR 
function! s:class.onCR() dict abort
    let self.exitkey = "\<CR>"
endfunction

" Method: onEsc 
function! s:class.onEsc() dict abort
    let self.exitkey = "\<Esc>"
endfunction

" Method: onEnter 
function! s:class.onEnter() dict abort
    let self.active = v:true
    let self.exitkey = ''
    let self.notify.lasttime = reltime()

    let s:timer.target = self
    if empty(s:timer.id)
        let s:timer.id = timer_start(s:timer.frequency, function('s:check_notify'), {'repeat': -1})
    else
        call timer_pause(s:timer.id, 0)
    endif
endfunction

" Method: onLeave 
function! s:class.onLeave() dict abort
    let self.active = v:false
    call timer_pause(s:timer.id, 1)
endfunction

" Method: check_notify 
" it's more complex to use timer
function! s:class.check_notify() dict abort
    if empty(self.notify.callback)
        return
    endif

    let l:notify = self.notify
    let l:nowline = join(self.cmdline, '')
    if l:nowline !=# l:notify.cmdline
        let l:notify.cmdline = l:nowline
        let l:notify.lasttime = reltime()
        call l:notify.callback(l:notify.cmdline)
        redraw
    endif
endfunction

" Method: do_notify 
" notify by skipping check
function! s:class.do_notify() dict abort
    let l:notify = self.notify
    if !empty(l:notify.callback)
        let l:notify.cmdline = join(self.cmdline, '')
        let l:notify.lasttime = reltime()
        call l:notify.callback(l:notify.cmdline)
    endif
endfunction

" Func: s:check_notify 
function! s:check_notify(timerid) abort
    let l:simcli = s:timer.target
    if !l:simcli.active
        call timer_pause(s:timer.id, 1)
    else
        call s:timer.target.check_notify()
    endif
endfunction
