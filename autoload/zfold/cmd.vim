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

    if a:0 == 0
        if exists('b:foldReg')
            let l:beginReg = b:foldReg[0]
            let l:endReg = b:foldReg[1]
        else
            " normal zi
            echo 'useage: Fold beginReg endReg'
            return
        endif
    endif

    let l:beginReg = {}
    let l:endReg = {}
    let l:siblingReg = []
    let l:childReg = []
    let l:idx = 0
    while l:idx < a:0
        let l:arg = a:000[l:idx]
        let l:idx += 1
        if empty(l:arg)
            continue
        elseif l:arg ==# '{}'
            call s:foldCreate(l:firstline, l:lastline, '{\s*$', '^\s*}')
        elseif l:arg ==# '[]'
            call s:foldCreate(l:firstline, l:lastline, '[\s*$', '^\s*]')
        elseif l:arg ==# '()'
            call s:foldCreate(l:firstline, l:lastline, '(\s*$', '^\s*)')
        else
            let l:reg = s:parseReg(l:arg)
            if empty(l:reg.flags)
                if empty(l:beginReg)
                    let l:beginReg = l:reg
                else
                    let l:endReg = l:reg
                endif
            else
                if l:reg.flags ==# '~'
                    call s:foldSingle(l:firstline, l:lastline, l:reg.pattern)
                elseif l:reg.flags ==# '!'
                    call s:foldSingleInvert(l:firstline, l:lastline, l:reg.pattern)
                elseif l:reg.flags ==# '='
                    call s:foldCreate(l:firstline, l:lastline, l:reg, l:reg)
                elseif l:reg.flags ==# '=='
                    call add(l:siblingReg, l:reg.pattern)
                elseif l:reg.flags ==# '=>'
                    call add(l:childReg, l:reg.pattern)
                elseif l:reg.flags =~# '>'
                    let l:endReg = l:reg
                elseif l:reg.flags =~# '<'
                    let l:beginReg = l:reg
                else
                    if empty(l:beginReg)
                        let l:beginReg = l:reg
                    else
                        let l:endReg = l:reg
                    endif
                endif
            endif
        endif

        if !empty(l:beginReg) && !empty(l:endReg)
            call s:foldCreate(l:firstline, l:lastline, l:beginReg, l:endReg)
            let l:beginReg = {}
            let l:endReg = {}
        endif
    endwhile

    if !empty(l:beginReg) && empty(l:endReg)
        call s:foldSingle(l:firstline, l:lastline, l:beginReg.pattern)
    endif

    if !empty(l:siblingReg)
        call s:foldSibling(l:firstline, l:lastline, l:siblingReg)
    endif

    if !empty(l:childReg)
        call s:foldChild(l:firstline, l:lastline, l:childReg)
    endif

endfunction "}}}

" Func: s:foldCreate 
" fold range lines between tow regexp dicts parsed from /sBegin/f and /sEnd/f
" see s:parseReg()
function! s:foldCreate(iFirst, iLast, sBegin, sEnd) abort "{{{
    if a:iFirst >= a:iLast
        echoerr 'fold expect a range'
        return
    endif

    " let l:sBegin = s:stripReg(a:sBegin)
    " let l:sEnd = s:stripReg(a:sEnd)
    let l:sBegin = a:sBegin.pattern
    let l:sEnd = a:sEnd.pattern
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
                call s:foldLines(l:foldstart + a:sBegin.shift, l:foldend + a:sEnd.shift)
            endif
        elseif l:isBegin && !l:isEnd
            call add(l:foldStack, l:line)
        endif
    endfor
endfunction "}}}

" Func: s:foldSingle 
" fold continous lines that match /sReg/, a:sReg is regexp string
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

" Func: s:foldSibling 
" each regexp in {a:liReg} is used to match the end of currnet fold and start of next fold
" but the end fold is shift by one line to avoid overlap fold.
" if the last item in {a:liReg} is /$/, also fold the last remaining unfolded
" lines.
function! s:foldSibling(iFirst, iLast, liReg) abort "{{{
    if empty(a:liReg)
        return
    endif
    let l:final = 0
    if a:liReg[-1] ==# '$'
        let l:final = 1
        call remove(a:liReg, -1)
    endif

    let l:foldStart = 0
    for l:line in range(a:iFirst, a:iLast)
        let l:text = getline(l:line)
        for l:reg in a:liReg
            if l:text =~# l:reg
                if l:foldStart > 0
                    call s:foldLines(l:foldStart, l:line-1)
                endif
                let l:foldStart = l:line
                break
            endif
        endfor
    endfor

    if l:foldStart > 0 && l:foldStart < a:iLast && l:final
        call s:foldLines(l:foldStart, a:iLast)
    endif
endfunction "}}}


" Func: s:foldChild 
" nested fold range based on a list regexp
" some like s:foldSibling, but the regexp in {a:liReg} has level relation
function! s:foldChild(iFirst, iLast, liReg) abort "{{{
    if empty(a:liReg)
        return
    endif
    let l:final = 0
    if a:liReg[-1] ==# '$'
        let l:final = 1
        call remove(a:liReg, -1)
    endif

    let l:foldStart = []
    let l:lenReg = len(a:liReg)
    for l:line in range(a:iFirst, a:iLast)
        let l:text = getline(l:line)
        for l:idx in range(l:lenReg)
            let l:reg = a:liReg[l:idx]
            if l:text =~# l:reg
                let l:foldidx = len(l:foldStart) - 1
                while l:foldidx >= l:idx
                    if l:foldStart[l:foldidx] > 0
                        call s:foldLines(l:foldStart[l:foldidx], l:line-1)
                        let l:foldStart[l:foldidx] = 0
                    endif
                    let l:foldidx -= 1
                endwhile
                let l:foldStart[l:idx] = l:line
                break
            endif
        endfor
    endfor

    if l:final && len(l:foldStart) > 0
        let l:foldidx = len(l:foldStart) - 1
        while l:foldidx >= l:idx
            if l:foldStart[l:foldidx] > 0 && l:foldStart[l:foldidx] < a:iLast
                call s:foldLines(l:foldStart[l:foldidx], a:iLast)
                let l:foldStart[l:foldidx] = 0
            endif
            let l:foldidx -= 1
        endwhile
    endif
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

" Func: s:parseReg 
" parse '/regexp/flags', return a dict with key pattern and flags
function! s:parseReg(arg) abort "{{{
    let l:ret = {'pattern':a:arg, 'flags':'', 'shift':0}
    if len(a:arg) < 2
        return l:ret
    endif

    if a:arg[0] != '/'
        return l:ret
    endif

    let l:endslash = strridx(a:arg, '/')
    if l:endslash <= 0
        let l:ret.pattern = ''
        return l:ret
    endif

    let l:ret.pattern = strpart(a:arg, 1, l:endslash-1)
    let l:ret.flags = strpart(a:arg, l:endslash+1)
    if !empty(l:ret.flags)
        if l:ret.flags =~# '+'
            let l:ret.shift = 1
        elseif l:ret.flags =~# '-'
            let l:ret.shift = -1
        endif
    endif
    return l:ret
endfunction "}}}
