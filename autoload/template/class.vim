" File: class
" Author: lymslive
" Description: template for class, describe as in vimloo
" Create: 2018-09-22
" Modify: 2018-09-22


let s:rtp = class#less#rtp#export()
let s:CBuilder = class#use('class#viml#builder')

" Command Hander Interface:
" 
" ClassNew: open a new file name.vim and fill class frame
function! template#class#hClassNew(name, ...) abort "{{{
    if empty(a:name)
        echom ':ClassNew command need a name as argument'
        return 0
    endif

    if a:name[0] ==# '/'
        let l:pFileName = a:name
    else
        let l:pFileName = getcwd() . '/' . a:name
    endif

    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassNew only execute under autoload director'
        return 0
    endif

    if a:0 > 1 && !empty(a:2)
        let l:jBuilder = s:CBuilder.new(l:sAutoName, a:2)
    else
        let l:jBuilder = s:CBuilder.new(l:sAutoName)
    endif

    if a:0 < 1
        let l:lsContent = jBuilder.ExtractLine('')
    else
        let l:lsContent = jBuilder.ExtractLine(a:1)
    endif

    execute 'edit ' . l:pFileName . '.vim'
    call setline(1, l:lsContent)
endfunction "}}}

" ClassAdd: add class frame to current opened buffer
function! template#class#hClassAdd(...) abort "{{{
    let l:pFileName = expand('%:p:r')
    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassAdd only execute under autoload director'
        return 0
    endif

    let l:jBuilder = s:CBuilder.new(l:sAutoName)
    if a:0 == 0
        let l:lsContent = jBuilder.ExtractLine('')
    else
        let l:lsContent = jBuilder.ExtractLine(a:1)
    endif

    call append(line('$'), l:lsContent)
endfunction "}}}

" ClassTemp: same as ClassAdd but don't care the filename
function! template#class#hClassTemp(...) abort "{{{
    let l:jBuilder = s:CBuilder.new('')

    if a:0 == 0
        let l:lsContent = jBuilder.ExtractLine('')
    else
        let l:lsContent = jBuilder.ExtractLine(a:1)
    endif

    call append(line('$'), l:lsContent)
endfunction "}}}

" ClassPart: 
function! template#class#hClassPart(sFilter) abort "{{{
    let l:pFileName = expand('%:p:r')
    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassPart only execute under autoload director'
        return 0
    endif

    let l:jBuilder = s:CBuilder.new(l:sAutoName)
    let l:lsContent = jBuilder.SelectLine(a:sFilter)

    call append(line('.'), l:lsContent)
endfunction "}}}
