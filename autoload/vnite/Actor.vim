" File: Actor
" Author: lymslive
" Description: class for manage action talbe for a command
" Create: 2019-11-13
" Modify: 2019-11-13

let s:class = {}
let s:class.command = ''
let s:class.actions = []      " list of s:ActionClass object
let s:class.actmaps  = {}     " keep map action name to action index in the list
let s:class._refer_ = v:null  " refer to concrete actor object, like base class
let s:class.parser  = v:null  " callback to extract information from a Message object

" the object stored in s:class.actions
let s:action = {}
let s:action.name = ''
let s:action.keymap = ''
let s:action.description = ''

" Func: s:newAction 
function! s:newAction(name, keymap, description) abort
    let l:object = copy(s:action)
    let l:object.name = a:name
    let l:object.keymap = a:keymap
    let l:object.description = a:description
    return l:object
endfunction

" Func: #class 
function! vnite#Actor#class() abort
    return s:class
endfunction

" Func: #new 
function! vnite#Actor#new(command) abort
    let l:object = copy(s:class)
    let l:object.command = a:command
    let l:object.actions = []
    let l:object.actmaps = {}
    return l:object
endfunction

" Method: add
" add action definition, override that with same name
function! s:class.add(name, keymap, description) dict abort
    let l:object = s:newAction(a:name, a:keymap, a:description)
    if has_key(self.actmaps, a:name)
        let l:idx = self.actmaps[a:name]
        let self.actions[l:idx] = l:object
    else
        call add(self.actions, l:object)
        let self.actmaps[a:name] = len(self.actions) - 1
    endif
    return self
endfunction

" Method: get 
" get a function handler for given action name
function! s:class.get(name) dict abort
    if has_key(self, a:name) && type(self[a:name]) == v:t_func
        return self[a:name]
    elseif !empty(self._refer_) && type(self._refer_) == v:t_dict
        return self._refer_.get(a:name)
    else
        return v:null
    endif
endfunction

" Method: set_parser 
function! s:class.set_parser(parser) dict abort
    if type(a:parser) == v:t_func
        let self.parser = a:parser
    endif
endfunction

" Method: merge 
function! s:class.merge() dict abort
    if empty(self._refer_)
        return self.actions
    endif
    let l:base = self._refer_.merger()
    let l:local = deepcopy(self.actions)
    let l:result = []
    for l:bact in l:base
        let l:override = v:false
        for l:idx in range(len(l:local))
            let l:dact = l:local[l:idx]
            if l:dact.name = l:bact.name
                call add(l:result, deepcopy(l:dact))
                call remove(l:local, l:idx)
                let l:override = v:true
                break
            endif
        endfor
        if !l:override
            call add(l:result, deepcopy(l:bact))
        endif
    endfor
    if !empty(l:local)
        call extend(l:result, l:local)
    endif
    return l:result
endfunction

" Method: display 
function! s:class.display() dict abort
    let l:head = printf('# Availabe actions for command[%s]', self.command)
    if !empty(self._refer_) && has_key(self._refer_, 'name')
        let l:head = l:head . printf(' based on actor[%s]', self._refer_.name)
    endif

    let l:lines = [l:head]
    let l:actions = self.merge()
    for l:action in l:actions
        let l:line = printf("[%s] %s\t%s", l:action.keymap, l:action.name, l:action.description)
        call add(l:lines, l:line)
    endfor

    return l:lines
endfunction

" Method: bindmap 
function! s:class.bindmap() dict abort
    let l:actions = self.merge()
    for l:act in l:actions
        if l:act.name ==? 'Default' || l:act.name ==? 'CR'
            continue
        endif
        if l:act.keymap ==? '<>' || l:act.keymap ==? '<NOP>'
            continue
        endif
        let l:cmd = printf("nnoremap <buffer> %s :call vnite#action#run('%s')<CR>", l:act.keymap, l:act.name)
        execute l:cmd
    endfor
endfunction
