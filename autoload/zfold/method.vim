" File: method
" Author: lymslive
" Description: maual fold based on other classic fold method
" Create: 2019-04-04
" Modify: 2019-04-04

let s:cmd = zfold#cmd#export()
let s:foldLines = s:cmd.foldLines

" Func: #Fold 
function! zfold#method#Fold(iFirst, iLast, sMethod, ...) abort
    if a:sMethod ==# 'indent'
        return s:indent(a:iFirst, a:iLast, a:000)
    elseif a:sMethod ==# 'xml'
        return s:xml(a:iFirst, a:iLast, a:000)
    endif
endfunction

" Func: s:indent 
function! s:indent(iFirst, iLast, lsArg) abort
    if a:iLast <= a:iFirst
        return -1
    endif

    let l:shiftwidth = shiftwidth()
    let l:stack = []
    let l:idx = a:iFirst
    while l:idx <= a:iLast
        let l:line = l:idx
        let l:text = getline(l:line)
        let l:idx += 1
        if l:text =~# '^\s*$'
            continue
        elseif l:text =~# '^\s*' . &foldignore
            continue
        endif

        let l:iIndent = indent(l:line) / l:shiftwidth
        let l:iLastIndent = empty(l:stack) ? 0 : l:stack[-1][0]
        if l:iIndent > l:iLastIndent
            call add(l:stack, [l:iIndent, l:line])
        else
            while l:iIndent < l:iLastIndent
                let l:item = remove(l:stack, -1)
                let l:iFoldStart = l:item[1]
                call s:foldLines(l:iFoldStart, l:line-1)
                let l:iLastIndent = empty(l:stack) ? 0 : l:stack[-1][0]
            endwhile
        endif
    endwhile

    while !empty(l:stack)
        let l:item = remove(l:stack, -1)
        let l:iFoldStart = l:item[1]
        call s:foldLines(l:iFoldStart, a:iLast)
    endwhile
endfunction

" Func: s:xml 
" fold when <tag> and </tag> stand on its line alone
" fold multiply line comment <!-- with line break \n -->
function! s:xml(iFirst, iLast, lsArg) abort
    if a:iLast <= a:iFirst
        return -1
    endif

    let l:stack = []
    let l:idx = a:iFirst
    while l:idx <= a:iLast
        let l:line = l:idx
        let l:text = getline(l:line)
        let l:idx += 1
        if l:text =~# '^\s*$'
            continue
        endif

        let l:tagName = ''
        let l:tagEnd = v:false

        if l:text =~# '^\s*<!--' && l:text !~# '-->\s*$'
            let l:tagName = '--'
        elseif l:text !~# '^\s*<!--' && l:text =~# '-->\s*$'
            let l:tagName = '--'
            let l:tagEnd = v:true
        elseif l:text =~# '^\s*<!--.*-->\s*$'
            continue
        elseif l:text =~# '^\s*<\w\+.*/>\s*$'
            continue
        elseif l:text =~# '^\s*<?.*>\s*$'
            continue
        else
            let l:matchs = matchlist(l:text, '^\s*<\(\/\)\?\(\w\+\)[^>]*>\s*$')
            if empty(l:matchs)
                continue
            endif
            let l:tagEnd = !empty(l:matchs[1])
            let l:tagName = l:matchs[2]
        endif

        if empty(l:tagName)
            continue
        endif

        if !l:tagEnd
            call add(l:stack, [l:tagName, l:line])
            continue
        endif

        while !empty(l:stack)
            let l:item = remove(l:stack, -1)
            let l:tagLast = l:item[0]
            if l:tagLast ==# l:tagName
                let l:iFoldStart = l:item[1]
                call s:foldLines(l:iFoldStart, l:line)
                break
            endif
        endwhile
    endwhile
endfunction
