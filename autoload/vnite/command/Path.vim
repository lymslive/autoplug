" File: Path
" Author: lymslive
" Description: command Path
" Create: 2019-11-14
" Modify: 2019-11-14

let g:vnite#command#Path#space = s:

if !exists(':Path')
    command! -nargs=* -complete=dir Path call vnite#command#Path#run(<f-args>)
endif

let s:description = 'list common path such as &rtp'
let s:cmdopt = vnite#lib#Cmdopt#new('Path')
call s:cmdopt.addhead(s:description)
            \.addoption('find', 'f', '&path for find file')
            \.addoption('rtp', 'r', '&rtp for vim runtime script')
            \.addoption('pack', 'k', 'pack dir candidate for packadd')
            \.endoption()

let s:actor = vnite#Actor#new('Path')
call s:actor.add('Default', 'CR', 'default to open, list by :File')
            \.add('Files', 'F', 'recursively list by :File -r')
            \.add('Chdir', 'C', 'lcd to the directory')
            \.add('Packadd', 'A', 'add this package')

" Func: #run 
function! vnite#command#Path#run(...) abort
    let l:path = []
    if a:0 == 0
        let l:path = s:all()
    endif
    if empty(l:path)
        return
    endif
    call vnite#command#output(l:path)
endfunction

" Func: s:rtp 
function! s:rtp() abort
    return split(&rtp, ',')
endfunction

" Func: s:packs 
function! s:packs() abort
    return globpath(&packpath, 'pack/*/*/*', 0, 1)
endfunction

" Func: s:fpaths 
function! s:fpaths() abort
    return filter(split(&path, ','), 'v:val =~# "." && v:val =~# ""')
endfunction

" Func: s:all 
function! s:all() abort
    let l:all = []

    let l:head = '# &rtp to autoload vim runtime files'
    call add(l:all, l:head)
    let l:rtp = s:rtp()
    call extend(l:all, l:rtp)

    let l:head = '# &packpath/* for packadd'
    call add(l:all, '')
    call add(l:all, l:head)
    let l:packs = s:packs()
    call extend(l:all, l:packs)

    let l:head = '# &path to find file'
    call add(l:all, '')
    call add(l:all, l:head)
    let l:fpaths = s:fpaths()
    call extend(l:all, l:fpaths)

    return l:all
endfunction

" Method: CR 
function! s:actor.CR(message) dict abort
    let l:text = a:message.text
    if l:text =~# '^#' || !isdirectory(l:text)
        return
    endif
    return 'CM File ' . l:text
endfunction

" Method: Files 
function! s:actor.Files(message) dict abort
    let l:text = a:message.text
    if l:text =~# '^#' || !isdirectory(l:text)
        return
    endif
    return 'CM -- File -r ' . l:text
endfunction

" Method: CR 
function! s:actor.Chdir(message) dict abort
    let l:text = a:message.text
    if l:text =~# '^#' || !isdirectory(l:text)
        return
    endif
    return 'lcd ' . l:text
endfunction

" Method: CR 
function! s:actor.Packadd(message) dict abort
    let l:text = a:message.text
    if l:text =~# '^#' || !isdirectory(l:text)
        return
    endif
    let l:name = fnamemodify(l:text, ':t')
    if empty(l:name)
        " dir/ end with a slash
        let l:name = fnamemodify(l:text, ':h:t')
    endif
    return 'packadd ' . l:name
endfunction
