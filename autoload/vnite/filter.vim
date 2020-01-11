" File: filter
" Author: lymslive
" Description: filter the buffer lines
" Create: 2019-11-02
" Modify: 2019-11-02

let s:Context = vnite#Context#class()
let s:Simcli = vnite#Simcli#class()

" store key maps from :Fnoremap
let s:dRemap = {}

" Func: #start 
function! vnite#filter#start() abort
    if !exists('b:VniteContext')
        let b:VniteContext = s:create_filter_context()
    endif

    if empty(b:VniteContext.simcli)
        let b:VniteContext.simcli = s:create_filter_cmdline()
    endif

    call b:VniteContext.simcli.loop()
endfunction

" Func: #noremap 
function! vnite#filter#noremap(...) abort
    let l:lhs = ''
    let l:rhs = ''
    let l:buffer = v:false

    let l:idx = 0
    while l:idx < a:0
        let l:arg = a:000[l:idx]
        let l:idx += 1
        if l:arg ==? '<buffer>'
            let l:buffer = v:true
            continue
        elseif !empty(l:arg) && empty(l:lhs)
            let l:lhs = l:arg
            if l:idx < a:0
                " let l:rhs = a:000[l:idx : ]->join(' ')
                let l:rhs = join(a:000[l:idx : ], ' ')
            endif
            break
        endif
    endwhile

    if empty(l:rhs)
        if l:buffer
            call s:fmaplocal(l:lhs)
        else
            call s:fmaplist(l:lhs)
        endif
    endif

    if l:buffer
        if !exists('b:VniteContext')
            echo 'this buffer donot support filter mode'
        else
            if empty(b:VniteContext.simcli)
                let b:VniteContext.simcli = s:create_filter_cmdline()
            endif
            call b:VniteContext.simlci.add_keymaps(l:key, l:val)
        endif
    else
        let l:key = s:encode_mapkey(l:lhs)
        let l:val = s:encode_mapkey(l:rhs)
        let s:dRemap[l:key] = l:val
    endif
endfunction

" Func: #noremap 
function! vnite#filter#unremap(lhs) abort
    if empty(a:lhs)
        echoerr ':Funremap {lhs}'
        return -1
    endif
    let l:lhs = substitute(a:lhs, '<', '\\<', 'g')
    let l:key = eval(printf('"%s"', l:lhs))
    call remove(s:dRemap, l:key)
endfunction

" Func: #lineup 
function! vnite#filter#lineup() abort
    if line('.') > 1
        normal! k
    endif
    :StartFilter
endfunction

" Func: #lineup 
function! vnite#filter#linedown() abort
    if line('.') < line('$')
        normal! j
    endif
    :StartFilter
endfunction

" Func: #line2end 
function! vnite#filter#line2end() abort
    if line('.') < line('$')
        normal! G
    else
        normal! gg
    endif
    :StartFilter
endfunction

" Func: #lineCR 
function! vnite#filter#lineCR() abort
    call vnite#action#run('CR')
    " donot reenter filter mode
endfunction

" Func: #apply 
function! vnite#filter#apply(cmdline) abort
    if !exists('b:VniteContext') || empty(b:VniteContext.simcli)
        echoerr 'seem not in a filterable buffer'
        return
    endif

    if empty(a:cmdline)
        if line('$') != len(b:VniteContext.messages)
            let b:VniteContext.filtered = []
            :silent 1,$delete
            call setline(1, b:VniteContext.messages)
            match none
        endif
    elseif a:cmdline =~# '^\d\+$'
        if search('^\s*' . a:cmdline, 'cw') == 0
            let l:linenr = str2nr(a:cmdline)
            call cursor(l:linenr, 0)
        endif
    elseif a:cmdline =~# '^-' && len(a:cmdline) >= 2
    elseif len(a:cmdline) < 3
        return
    else
        let b:VniteContext.filtered = []
        :silent 1,$delete

        let l:cmdline = a:cmdline
        let l:filtered = []
        function! s:callback(idx, val) closure abort
            if a:val =~ l:cmdline
                call add(b:VniteContext.filtered, a:idx)
                call add(l:filtered, a:val)
            endif
            return v:true
        endfunction
        call filter(b:VniteContext.messages, funcref('s:callback'))
        call setline(1, l:filtered)
        execute 'silent! match Search /' . escape(l:cmdline, '/') . '/'
    endif
endfunction

" -------------------------------------------------------------------------------- "

" Func: s:create_filter_context 
" make current existed buffer filterable outside vnite command message buffer
" but also require nofile buftype
function! s:create_filter_context() abort
    if &l:buftype !=# 'nofile'
        echoerr 'setlocal buftype=nofile first to enable filter mode'
        return {}
    endif
    let l:context = s:Context.new('StartFilter')
    call l:context.store(getline(1, '$'))
    return l:context
endfunction

" Func: s:create_filter_cmdline 
function! s:create_filter_cmdline() abort
    let l:prompt = get(g:, 'vnite#config#prompt_filter', '|')
    let l:cli = s:Simcli.new(l:prompt)
    call l:cli.set_keymaps(s:dRemap)
    call l:cli.set_notify(function('vnite#filter#apply'))
    return l:cli
endfunction

" Func: s:encode_mapkey 
function! s:encode_mapkey(key) abort
    if a:key !~# '<'
        return a:key
    endif
    let l:key = substitute(a:key, '<', '\\<', 'g')
    let l:key = eval(printf('"%s"', l:key))
    return l:key
endfunction

let s:decode_mapkey = function('vnite#helper#decode_mapkey')

" Func: s:fmaplist 
function! s:fmaplist(...) abort
    if a:0 == 0 || empty(a:1)
        echo len(s:dRemap) 'Fnoremaps:'
        for [l:key, l:val] in items(s:dRemap)
            let l:key = s:decode_mapkey(l:key)
            let l:val = s:decode_mapkey(l:val)
            echo 'Fnoremap' l:key l:val
            unlet l:key  l:val
        endfor
        return
    else
        let l:key = s:encode_mapkey(a:1)
        let l:val = get(s:dRemap, l:key, '')
        if !empty(l:val)
            let l:key = s:decode_mapkey(l:key)
            let l:val = s:decode_mapkey(l:val)
            echo 'Fnoremap' l:key l:val
        else
            echo 'no remap for' l:key
        endif
    endif
endfunction

function! s:fmaplocal(...) abort
    let l:localmap = s:get_localfmap()
    if empty(l:localmap)
        echo 'no buffer local maps for filter mode'
        return
    endif
    if a:0 == 0 || empty(a:1)
        echo len(s:dRemap) 'Fnoremaps:'
        for [l:key, l:val] in items(s:dRemap)
            let l:key = s:decode_mapkey(l:key)
            let l:val = s:decode_mapkey(l:val)
            echo 'Fnoremap <buffer>' l:key l:val
            unlet l:key  l:val
        endfor
        return
    else
        let l:key = s:encode_mapkey(a:1)
        let l:val = get(s:dRemap, l:key, '')
        if !empty(l:val)
            let l:key = s:decode_mapkey(l:key)
            let l:val = s:decode_mapkey(l:val)
            echo 'Fnoremap <buffer>' l:key l:val
        else
            echo 'no remap for' l:key
        endif
    endif
endfunction

" Func: s:get_localfmap 
function! s:get_localfmap() abort
    if !exists('b:VniteContext')
        return {}
    else
        return get(b:VniteContext.simcli, 'localmaps', {})
    endif
endfunction

" -------------------------------------------------------------------------------- "

if !exists(':Fnoremap')
    command! -nargs=* Fnoremap call vnite#filter#noremap(<f-args>)
endif
call vnite#config#filter_maps()
