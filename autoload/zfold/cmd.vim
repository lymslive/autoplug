" Func: #nFold 
" For Normal Map: toggle fold open/close or try to zf%, or zj
function! zfold#cmd#nFold() abort "{{{
    if foldlevel(line('.')) > 0
        if foldclosed(line('.')) > 0
            :foldopen
        else
            :foldclose
        endif
    else
        let l:lineBefore = line('.')
        normal %
        let l:lineAfter = line('.')
        if l:lineAfter == l:lineBefore
            normal! zj
            return
        endif

        call s:checkFold()
        if l:lineAfter > l:lineBefore
            return s:foldLines(l:lineBefore, l:lineAfter)
        elseif l:lineAfter < l:lineBefore
            return s:foldLines(l:lineAfter, l:lineBefore)
        endif
    endif
endfunction "}}}

" Func: #vFold 
" For Visual Map: create fold selected lines like v-zf
function! zfold#cmd#vFold() range abort "{{{
    if a:lastline > a:firstline
        call s:checkFold()
        return s:foldLines(a:firstline, a:lastline)
    endif
endfunction "}}}

" Func: #Fold 
" For Command:
function! zfold#cmd#Fold(bang, ...) range abort "{{{
    call s:checkFold()
    if a:bang
        normal! zE
    endif

    let l:firstline = 1
    let l:lastline = line('$')
    if a:lastline > a:firstline
        if a:0 < 1
            return s:foldLines(a:firstline, a:lastline)
        else
            let l:firstline = a:firstline
            let l:lastline = a:lastline
        endif
    endif

    let l:beginReg = ''
    let l:endReg = ''
    if a:0 == 0
        if exists('b:foldReg')
            let l:beginReg = b:foldReg[0]
            let l:endReg = b:foldReg[1]
        else
            " normal zi
            echo 'useage: Fold beginReg endReg'
            return
        endif
    elseif a:0 == 1
        if a:1 ==# '{}'
            let l:beginReg = '{\s*$'
            let l:endReg = '^\s*}'
        elseif a:1 ==# '()'
            let l:beginReg = '(\s*$'
            let l:endReg = '^\s*)'
        elseif a:1 ==# '[]'
            let l:beginReg = '[\s*$'
            let l:endReg = '^\s*]'
        else
            let l:beginReg = a:1
        endif
    elseif a:0 == 2
        let l:beginReg = a:1
        let l:endReg = a:2
    endif

    return s:foldCreate(l:firstline, l:lastline, l:beginReg, l:endReg)
endfunction "}}}

" Func: s:foldCreate 
" fold range lines between /sBegin/ and /sEnd/ regexp, 
" '/' is optional, except '//' maybe usefull to specify empty regexp.
" See s:foldSingle() or s:foldSingleInvert() when only /sBeign/ or /sEnd/
function! s:foldCreate(iFirst, iLast, sBegin, sEnd) abort "{{{
    if a:iFirst >= a:iLast
        echoerr 'fold expect a range'
        return
    endif

    let l:sBegin = s:stripReg(a:sBegin)
    let l:sEnd = s:stripReg(a:sEnd)
    if empty(l:sBegin) && empty(l:sEnd)
        echoerr 'fold expect one or tow non-empty regexp'
        return
    elseif !empty(l:sBegin) && empty(l:sEnd)
        return s:foldSingle(a:iFirst, a:iLast, sBegin)
    elseif empty(l:sBegin) && !empty(l:sEnd)
        return s:foldSingleInvert(a:iFirst, a:iLast, sEnd)
    endif

    let l:foldStack = []
    for l:line in range(a:iFirst, a:iLast)
        let l:text = getline(l:line)
        let l:isBegin = l:text =~# l:sBegin
        let l:isEnd = l:text =~# l:sEnd
        if l:isEnd && !l:isBegin
            if len(l:foldStack) > 0
                let l:foldstart = remove(l:foldStack, -1)
                let l:foldend = l:line
                call s:foldLines(l:foldstart, l:foldend)
            endif
        elseif l:isBegin && !l:isEnd
            call add(l:foldStack, l:line)
        endif
    endfor
endfunction "}}}

" Func: s:foldSingle 
" fold continous lines that match /sReg/
function! s:foldSingle(iFirst, iLast, sReg) abort "{{{
    let l:foldStart = 0
    for l:line in range(a:iFirst, a:iLast)
        let l:text = getline(l:line)
        if l:text =~# a:sReg
            if l:foldStart == 0
                let l:foldStart = l:line
            endif
        else
            if l:foldStart > 0
                call s:foldLines(l:foldStart, l:line-1)
                let l:foldStart = 0
            endif
        endif
    endfor
endfunction "}}}

" Func: s:foldSingleInvert 
" fold continous lines that NOT match /sReg/
function! s:foldSingleInvert(iFirst, iLast, sReg) abort "{{{
    let l:foldStart = 0
    for l:line in range(a:iFirst, a:iLast)
        let l:text = getline(l:line)
        if l:text !~# a:sReg
            if l:foldStart == 0
                let l:foldStart = l:line
            endif
        else
            if l:foldStart > 0
                call s:foldLines(l:foldStart, l:line-1)
                let l:foldStart = 0
            endif
        endif
    endfor
endfunction "}}}

" Func: s:foldLines 
function! s:foldLines(iFirst, iLast) abort "{{{
    if a:iFirst >= a:iLast
        return 0
    endif
    execute a:iFirst . ',' . a:iLast . ' fold'
    return a:iLast - a:iFirst
endfunction "}}}

" Func: s:checkFold 
function! s:checkFold() abort "{{{
    if &foldmethod !=? 'manual'
        set foldmethod=manual
        normal! zE
    endif
endfunction "}}}

" Func: s:stripReg 
" get regexp content quoted in // or specified as a:1 a:2
function! s:stripReg(str, ...) abort "{{{
    if len(a:str) < 2
        return a:str
    endif

    let l:dels = '/'
    let l:dele = '/'
    if a:0 == 1
        let l:dels = a:1
        let l:dele = a:1
    elseif a:0 == 2
        let l:dels = a:1
        let l:dele = a:2
    endif

    if a:str[0] ==# l:dels && a:str[len(a:str)-1] ==# l:dele
        return strpart(a:str, 1, len(a:str) - 2)
    else
        return a:str
    endif
endfunction "}}}
