" File: CListfile
" Author: lymslive
" Description: a file to save list, support multiple parts
" Create: 2019-12-10
" Modify: 2019-12-10

let s:class = {}
let s:class._ctype_ = s:class
let s:class.filepath = ''
let s:class.content = v:null

" Func: #class 
function! wenote#lib#CListfile#class() abort
    return s:class
endfunction

" Func: #new 
function! wenote#lib#CListfile#new(filepath) abort
    if empty(a:filepath)
        return v:null
    endif
    let l:object = copy(s:class)
    let l:object.filepath = a:filepath
    return l:object
endfunction

" Method: write 
function! s:class.write() dict abort
    if empty(self.content)
        return
    endif
    if type(self.content) == v:t_list
        call writefile(self.content, self.filepath)
    elseif type(self.content) == v:t_dict
        let l:content = []
        for l:key in sort(keys(self.content))
            let l:list = self.content[l:key]
            if type(l:list) == v:t_list
                let l:head = '# ' .. l:key .. ' #'
                let l:line = repeat('=', len(l:head))
                call add(l:content, l:head)
                call add(l:content, l:line)
                call extend(l:content, l:list)
            endif
            call writefile(l:content, self.filepath)
        endfor
    endif
endfunction

" Method: read 
function! s:class.read() dict abort
    if !filereadable(self.filepath)
        return -1
    endif
    let l:content = readfile(self.filepath)
    if empty(l:content)
        return -2
    endif
    
    let l:line = l:content[0]
    let l:head = matchstr(l:line, '^# \zs.\+\ze #')
    if empty(l:head)
        let self.content = l:content
        return 0
    endif
    
    let self.content = {}
    let l:list = []
    let l:idx = 0 + 1
    let l:iend = len(l:content)
    while l:idx < l:iend
        let l:line = l:content[l:idx]
        let l:idx += 1
        if empty(l:line) || l:line =~# '^=\+$'
            continue
        endif
        let l:new_head = matchstr(l:line, '^# \zs.\+\ze #')
        if !empty(l:new_head)
            if !empty(l:head) && !empty(l:list)
                let self.content[l:head] = l:list
            endif
            let l:list = []
            let l:head = l:new_head
        else
            call add(l:list, l:line)
        endif
    endwhile
endfunction

" Method: get 
function! s:class.get(...) dict abort
    if empty(self.content)
        call self.read()
    endif
    if a:0 == 0 || empty(a:1)
        return self.content
    endif
    if type(self.content) == v:t_list
        return get(self.content, 0 + a:1, [])
    elseif type(self.content) == v:t_dict
        return get(self.content, a:1, [])
    else
        return []
    endif
endfunction

" Method: set 
function! s:class.set(content) dict abort
    if !empty(a:content)
        let self.content = a:content
    endif
    return self
endfunction
