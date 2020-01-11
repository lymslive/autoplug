" File: Cmdopt
" Author: lymslive
" Description: handle command optional and argument
" Create: 2019-11-06
" Modify: 2019-11-06

" Func: #class 
function! vnite#lib#Cmdopt#class() abort
    return s:class
endfunction

let s:class = {}
let s:class.cmdname = ''
let s:class.options = []
let s:class.shortmap = {}
let s:class.arguments = []
let s:class.mixing = v:false " option may after position argument ?
let s:class.headline = ''
let s:class.footnote = ''
let s:class.errormsg = ''  " any error when parse

" the sctruct of one option
let s:option = {}
let s:option.name = ''
let s:option.short = ''
let s:option.desc = ''
let s:option.arg = 0   " option may have it's own argument
let s:option.default = v:null

" Func: s:new_option 
function! s:new_option(...) abort
    let l:option = copy(s:option)
    let l:option.name = a:1
    let l:option.short = a:2
    let l:option.desc = a:3
    if a:0 >= 4
        let l:option.arg = a:4
    endif
    if a:0 >= 5
        let l:option.default = a:5
    endif
    return l:option
endfunction

let s:argument = {}
let s:argument.name = ''
let s:argument.desc = ''

" Func: #new 
function! vnite#lib#Cmdopt#new(cmdname) abort
    return s:class.new(a:cmdname)
endfunction

" Method: new 
function! s:class.new(cmdname) dict abort
    let l:object = copy(s:class)
    let l:object.cmdname = a:cmdname
    let l:object.options = []
    let l:object.shortmap = {}
    let l:object.arguments = []
    return l:object
endfunction

" Method: mixoption 
function! s:class.mixoption() dict abort
    let self.mixing = v:true
    return self
endfunction

" Method: addoption 
function! s:class.addoption(...) dict abort
    if a:0 == 1 && type(a:1) == v:t_dict
        call add(self.options, a:1)
    elseif a:0 >= 3
        let l:option = call(function('s:new_option'), a:000)
        call add(self.options, l:option)
    endif
    return self
endfunction

" Method: endoption 
function! s:class.endoption() dict abort
    let l:help = s:new_option('help', 'h', 'show this help')
    call add(self.options, l:help)
    for l:opt in self.options
        let self.shortmap[l:opt.short] = l:opt
    endfor
    return self
endfunction

" Method: addargument 
function! s:class.addargument(...) dict abort
    if a:0 == 1 && type(a:1) == v:t_dict
        call add(self.arguments, a:1)
    elseif a:0 >= 2
        call add(self.arguments, {'name': a:1, 'desc': a:2})
    endif
    return self
endfunction

" Method: addhead 
function! s:class.addhead(text) dict abort
    let self.headline = a:text
    return self
endfunction

" Method: addfoot 
function! s:class.addfoot(text) dict abort
    let self.footnote = a:text
    return self
endfunction

" Method: usage 
function! s:class.usage() dict abort
    if !empty(self.errormsg)
        echo 'Error: ' . self.errormsg
    endif

    let l:sopt = '-'
    let l:vopt = ''
    for l:opt in self.options
        if empty(l:opt.arg)
            let l:sopt .= l:opt.short
        else
            let l:aopt = printf('-%s?', l:opt.short)
            if empty(l:vopt)
                let l:vopt = l:aopt
            else
                let l:vopt = l:vopt . ' ' . l:aopt
            endif
        endif
    endfor
    let l:head = self.cmdname
    if !empty(l:sopt)
        let l:head .= printf(' [%s]', l:sopt)
    endif
    if !empty(l:vopt)
        let l:head .= printf(' [%s]', l:vopt)
    endif
    for l:arg in self.arguments
        let l:head .= printf(' {%s}', l:arg.name)
    endfor

    echo 'Usage:'
    echo '  :' . l:head
    if !empty(self.headline)
        echo self.headline
    endif

    echo 'Options:'
    for l:opt in self.options
        let l:line = printf('  -%s --%s', l:opt.short, l:opt.name)
        if !empty(l:opt.arg)
            let l:line .= printf('=%s', l:opt.arg)
        endif
        if !empty(l:opt.default)
            let l:line .= printf('[%s]', l:opt.default)
        endif
        let l:line .= printf("\t%s", l:opt.desc)
        echo l:line
    endfor

    echo 'Arguments:'
    for l:arg in self.arguments
        let l:line = printf("  %s\t%s", l:arg.name, l:arg.desc)
        echo l:line
    endfor

    if !empty(self.footnote)
        echo 'Footnote:'
        echo self.footnote
    endif
endfunction

" Method: parse 
" :Command -s --long=arg real remain arguments
" only short -s support default value, --long default '' in ommit
" return a dict, with keys from long option name, all init with v:false
" then fill the found value in the input a:args.
" plus a key 'arguments' collect all non option arguments in a list
" return empty dict on error
function! s:class.parse(args) dict abort
    let self.errormsg = ''
    let l:result = {}
    let l:result.arguments = []
    for l:opt in self.options
        let l:result[l:opt.name] = v:false
    endfor

    let l:begin = 0
    for l:arg in a:args
        let l:begin += 1
        if l:arg ==# '-' || l:arg ==# '--'
            break
        elseif l:arg =~# '^--.'
            let l:tokens = split(strpart(l:arg,2), '=')
            let l:opt = l:tokens[0]
            let l:val = v:true
            if len(l:tokens) > 1
                let l:val = l:tokens[1]
            endif
            let l:result[l:opt] = l:val
        elseif l:arg =~# '^-.'
            let l:sh = l:arg[1]
            let l:opt = v:null
            if has_key(self.shortmap, l:sh)
                let l:opt = self.shortmap[l:sh]
            else
                let self.errormsg = 'unkonw option: ' . l:sh
                return {}
            endif
            if len(l:arg) == 2
                let l:result[l:opt.name] = v:true
                if !empty(l:opt.default)
                    let l:result[l:opt.name] = l:opt.default
                endif
            elseif len(l:arg) > 2
                if !empty(l:opt.arg)
                    let l:val = strpart(l:arg, 2)
                    let l:result[l:opt.name] = l:val
                else
                    let l:result[l:opt.name] = v:true
                    for l:idx in range(2, len(l:arg)-1)
                        let l:sh = l:arg[l:idx]
                        if has_key(self.shortmap, l:sh)
                            let l:opt = self.shortmap[l:sh]
                            let l:result[l:opt.name] = v:true
                        else
                            let self.errormsg = 'unkonw option: ' . l:sh
                            return {}
                        endif
                    endfor
                endif
            endif
        else
            call add(l:result.arguments, l:arg)
            if empty(self.mixing)
                break
            endif
        endif
    endfor
    if l:begin < len(a:args)
        call extend(l:result.arguments, a:args[l:begin :])
    endif
    return l:result
endfunction

finish
" -------------------------------------------------------------------------------- "
"
" Support Option Format:
" -- or - : end of option, remaining is argument
" -abc    : a,b,c all are options without argument, result value v:true, or
"           defaut value defined
" -aArg   : option a with a argument value 'Arg'
" --long=Arg : long option with argument value 'Arg'
