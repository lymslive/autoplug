" implement of most recent list

let g:recent#impl#space = s:
let s:mrgroup = v:null

function! recent#impl#start() abort
    let l:datafile = $VIMHOME . '/autoload/my/recent/save.json'
    let s:mrgroup = recent#group#new(l:datafile)
endfunction

function! recent#impl#record(file) abort
    call s:mrgroup.record_file(a:file)
endfunction

function! recent#impl#save()
    call s:mrgroup.save_json()
endfunction

function! recent#impl#view(...) abort
    let l:arg = 'f'
    if a:0 >0 && !empty(a:1)
        let l:arg = a:1
    endif
    if empty(s:mrgroup)
        return
    endif
    if l:arg =~? '^-\?f'
        call s:view_recent_file()
    elseif l:arg =~? '^-\?d'
        call s:view_recent_dir()
    elseif l:arg =~? '^\.\w\+'
        let l:ext = strpart(l:arg, 1)
        call s:view_recent_ext(l:ext)
    endif
endfunction

" Func: s:view_recent_file 
function! s:view_recent_file() abort
    let l:list = s:mrgroup.mrfile.list()
    call s:view_list(l:list)
endfunction

" Func: s:view_recent_dir 
function! s:view_recent_dir() abort
    let l:list = s:mrgroup.mrdir.list()
    call s:view_list(l:list)
endfunction

" Func: s:view_recent_ext 
function! s:view_recent_ext(ext) abort
    if !has_key(s:mrgroup.mrext, a:ext)
        return
    endif
    let l:list = s:mrgroup.mrext[a:ext].list()
    call s:view_list(l:list)
endfunction

" Func: s:view_list 
function! s:view_list(list) abort
    for l:item in a:list
        echo l:item
    endfor
endfunction
