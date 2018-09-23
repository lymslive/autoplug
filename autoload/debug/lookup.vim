" File: lookup
" Author: lymslive
" Description: lookup function definition
" Create: 2018-09-22
" Modify: 2018-09-22

let s:rtp = class#less#rtp#export()

" GotoSharpFunc: path#to#file#Func
function! debug#lookup#GotoSharpFunc(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:name = expand('<cword>')
    else
        let l:name = a:1
    endif

    " the #function is in current file?
    let l:sPattern = '^\s*fu[nction]*!\?\s\+%s\>'
    let l:sPattern = printf(l:sPattern, l:name)
    if search(l:sPattern, 'scew') > 0
        return line('.')
    endif

    let l:lsPart = split(l:name, '#')
    let l:sFuncName = remove(l:lsPart, -1)
    let l:sAutoName = join(l:lsPart, '#')

    " find in &rtp
    let l:pScriptFile = s:rtp.FindAutoScript(l:sAutoName)
    if !empty(l:pScriptFile) && filereadable(l:pScriptFile)
        " let l:cmd = 'edit +/%s %s'
        " let l:cmd = printf(l:cmd, l:name, l:pScriptFile)
        normal! m'
        execute 'edit' l:pScriptFile
        if search(l:sPattern, 'cew') <= 0
            :ELOG 'cannot find function: ' . l:name
        endif
        return line('.')
    endif

    " find in &packpath/opt
    let l:pScriptFile = s:rtp.FindAoptScript(l:sAutoName, 1)
    if !empty(l:pScriptFile) && filereadable(l:pScriptFile)
        normal! m'
        execute 'edit' l:pScriptFile
        if search(l:sPattern, 'cew') <= 0
            :ELOG 'cannot find function: ' . l:name
        endif
        return line('.')
    endif

    :ELOG 'cannot find function: ' . l:name
    return 0
endfunction "}}}

" GotoLocalFunc: s:Func
function! debug#lookup#GotoLocalFunc(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:name = expand('<cword>')
    else
        let l:name = a:1
    endif

    if l:name !~# '^s:'
        let l:name = 's:' . l:name
    endif

    let l:sPattern = '^\s*function!\?\s\+%s\>'
    let l:sPattern = printf(l:sPattern, l:name)
    return search(l:sPattern, 'scew')
endfunction "}}}

" GotoClassFunc: s:class.Func
function! debug#lookup#GotoClassFunc(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:name = expand('<cword>')
    else
        let l:name = a:1
    endif

    if l:name =~# '^self\.'
        let l:name = substitute(l:name, '^self\.', 's:class.', '')
    elseif l:name =~# '^s:class\.'
        " pass
    else
        let l:name = 's:class.' . l:name
    endif

    return search(l:name . '\>', 'scew')
endfunction "}}}

" GotoDefineFunc: 
" try to jump to a vim function definition by search source files
" add current to jumplist if can jump
" at last also try :tag 
function! debug#lookup#GotoDefineFunc(...) abort "{{{
    if a:0 == 0 || empty(a:1)
        let l:cursor = class#less#cursor#export()
        let l:name = l:cursor.GetWord('.', '#', ':')
        " let l:name = expand('<cword>')
    else
        let l:name = a:1
    endif

    if l:name =~# '#'
        return debug#lookup#GotoSharpFunc(l:name)
    elseif l:name =~# '^s:'
        return debug#lookup#GotoLocalFunc(l:name)
    elseif l:name =~# '^self\.'
        return debug#lookup#GotoClassFunc(l:name)
    else
        execute 'tag .' l:name
    endif
endfunction "}}}

" ClassView: 
" :ClassView [filename]
function! debug#lookup#ClassView(...) abort "{{{
    if a:0 > 0 && !empty(a:1)
        let l:pFileName = s:rtp.Absolute(a:1)
    else
        let l:pFileName = expand('%:p:r')
    endif

    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassView only execute under autoload director'
        return 0
    endif

    call call('class#echo', [l:sAutoName, '-am'])
endfunction "}}}

