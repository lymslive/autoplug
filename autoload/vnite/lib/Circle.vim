" File: Circle
" Author: lymslive
" Description: class for Circle list
" Create: 2019-11-08
" Modify: 2019-11-08

" the items are stored in a list as reversed order, newer is larger index, 
" when size reach capacity, wrap front index to zero, overwrite oldest.
let s:class = {}
let s:class.capacity = 10
let s:class.vector = []
let s:class.front = 0
let s:class.size = 0
let s:class.equal = v:null

" Func: #instance singleton class
function! vnite#lib#Circle#class() abort
    return s:class
endfunction

" Func: #new 
function! vnite#lib#Circle#new(capacity, ...) abort
    let l:object = copy(s:class)
    let l:object.vector = []
    if a:capacity > 0
        let l:object.capacity = a:capacity
    endif
    if a:0 > 0 && !empty(a:1)
        call l:object.set_equal(a:1)
    endif
    return l:object
endfunction

" Method: set_equal 
function! s:class.set_equal(Func) dict abort
    if type(a:Func) == v:t_func
        let self.equal = a:Func
    endif
endfunction

" Method: get 
function! s:class.get(...) dict abort
    let l:idx = get(a:000, 0, 0)
    if l:idx < 0 || l:idx >= self.size
        return v:null
    endif
    return self.vector[self.front - l:idx]
endfunction

" Method: list 
function! s:class.list() dict abort
    if self.size == 0
        return []
    endif
    let l:vector = []
    for l:idx in range(self.size)
        call add(l:vector, self.get(l:idx))
    endfor
    return l:vector
endfunction

" Method: resize
function! s:class.resize(capacity) dict abort
    if a:capacity <= 0
        return self
    endif

    let l:vector = self.list()
    if a:capacity < len(l:vector)
        let l:vector = l:vector[0 : a:capacity-1]
    endif

    let self.vector = []
    for l:idx in range(len(l:vector)-1, 0, -1)
        call self.push(l:vector[l:idx])
    endfor
    return self
endfunction

" Method: push 
function! s:class.push(item) dict abort
    if empty(a:item)
        return self
    endif

    let l:old = self.find(a:item)
    if l:old >= 0
        return self.rotate(l:old)
    endif

    if empty(self.vector)
        call add(self.vector, a:item)
        let self.size += 1
    elseif self.size < self.capacity
        call add(self.vector, a:item)
        let self.front += 1
        let self.size += 1
    else
        let self.front += 1
        if self.front >= self.capacity
            let self.front = 0
        endif
        let self.vector[self.front] = a:item
    endif
    return self
endfunction

" Method: rotate 
" select idx-th(relative to front) to front, and reserve order for other item
function! s:class.rotate(idx) dict abort
    if a:idx == 0
        return
    endif

    let l:cidx = self.front - a:idx
    if l:cidx < 0
        let l:cidx += self.size
    endif
    let l:item = self.vector[l:cidx]

    while l:cidx != self.front
        let l:nidx = l:cidx + 1
        if l:nidx >= self.size
            let l:nidx = 0
        endif
        let self.vector[l:cidx] = self.vector[l:nidx]
        let l:cidx = l:nidx
    endwhile
    let self.vector[l:cidx] = l:item

    return self
endfunction

" Method: find 
function! s:class.find(item) dict abort
    for l:idx in range(self.size)
        let l:item = self.get(l:idx)
        if !empty(self.equal)
            if self.equal(l:item, a:item)
                return true
            endif
        elseif l:item ==# a:item
            return l:idx
        endif
    endfor
    return -1
endfunction
