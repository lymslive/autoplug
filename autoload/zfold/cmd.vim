" File: cmd
" Author: lymslive
" Description: implement of zfold command
" Create: 2019-04-03
" Modify: 2019-04-03

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

        call s:checkFold(v:false)
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
        call s:checkFold(v:false)
        return s:foldLines(a:firstline, a:lastline)
    endif
endfunction "}}}

" Func: #Fold 
" For Command:
function! zfold#cmd#Fold(bang, ...) range abort "{{{
    call s:checkFold(a:bang)

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
        return -1
    endif

    return s:foldCommand(l:firstline, l:lastline, a:000)
endfunction "}}}

" Func: #FoldCompl 
" customlist completion for command Z
function! zfold#cmd#FoldCompl(ArgLead, CmdLine, CursorPos) abort "{{{
    let l:ArgLead = ''
    if !empty(a:ArgLead) && a:ArgLead[0] == '$'
        let l:ArgLead = strpart(a:ArgLead, 1)
    else
        return []
    endif

    if !empty(l:ArgLead) && l:ArgLead =~# '^[_A-Z]$'
        let l:envKey = getcompletion(strpart(a:ArgLead, 1), 'environment')
        call map(l:envKey, {key, val -> '$' . val})
        return l:envKey
    endif

    let l:config = g:zfold#set#json
    let l:keys = keys(l:config)
    call filter(l:keys, 'v:val !=# "ft"')
    let l:ft = &filetype
    if has_key(l:config, 'ft') && has_key(l:config.ft, l:ft)
        let l:ftKey = keys(l:config.ft[l:ft])
        call filter(l:ftKey, 'v:val !=# "0"')
        call extend(l:keys, l:ftKey)
    endif
    if !empty(l:keys)
        call uniq(sort(l:keys))
        if !empty(l:ArgLead)
            call filter(l:keys, {key, val -> val =~# '^' . l:ArgLead})
        endif
        call map(l:keys, {key, val -> '$' . val})
    endif
    return l:keys
endfunction "}}}

" Func: s:foldCommand 
function! s:foldCommand(iFirst, iLast, lsRegArg) abort "{{{
    let l:beginReg = {}
    let l:endReg = {}
    let l:siblingReg = []
    let l:childReg = []
    let l:len = len(a:lsRegArg)
    let l:idx = 0
    while l:idx < l:len
        let l:arg = a:lsRegArg[l:idx]
        let l:idx += 1
        if empty(l:arg)
            continue
        elseif l:arg[0] ==# '$'
            call s:foldSpecail(a:iFirst, a:iLast, l:arg)
        elseif l:arg ==# '{}'
            call s:foldCreate(a:iFirst, a:iLast, '{\s*$', '^\s*}')
        elseif l:arg ==# '[]'
            call s:foldCreate(a:iFirst, a:iLast, '[\s*$', '^\s*]')
        elseif l:arg ==# '()'
            call s:foldCreate(a:iFirst, a:iLast, '(\s*$', '^\s*)')
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
                    call s:foldMatch(a:iFirst, a:iLast, l:reg.pattern)
                elseif l:reg.flags ==# '!'
                    call s:foldMatch(a:iFirst, a:iLast, l:reg.pattern, 'invert')
                elseif l:reg.flags ==# '='
                    call s:foldCreate(a:iFirst, a:iLast, l:reg, l:reg)
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
            call s:foldCreate(a:iFirst, a:iLast, l:beginReg, l:endReg)
            let l:beginReg = {}
            let l:endReg = {}
        endif
    endwhile

    if !empty(l:beginReg) && empty(l:endReg)
        call s:foldMatch(a:iFirst, a:iLast, l:beginReg.pattern)
    endif

    if !empty(l:siblingReg)
        call s:foldSibling(a:iFirst, a:iLast, l:siblingReg)
    endif

    if !empty(l:childReg)
        call s:foldChild(a:iFirst, a:iLast, l:childReg)
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
        return s:foldMatch(a:iFirst, a:iLast, sBegin)
    elseif empty(l:sBegin) && !empty(l:sEnd)
        return s:foldMatch(a:iFirst, a:iLast, sEnd, 'invert')
    endif

    let l:sameReg = l:sBegin ==# l:sEnd

    let l:foldStack = []
    for l:line in range(a:iFirst, a:iLast)
        let l:text = getline(l:line)
        if !l:sameReg
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
        else
            let l:isMatch = l:text =~# l:sBegin
            if l:isMatch
                if len(l:foldStack) > 0
                    let l:foldstart = remove(l:foldStack, -1)
                    let l:foldend = l:line
                    call s:foldLines(l:foldstart + a:sBegin.shift, l:foldend + a:sEnd.shift)
                else
                    call add(l:foldStack, l:line)
                endif
            endif
        endif
    endfor
endfunction "}}}

" Func: s:foldMatch 
" fold continous lines that match or NOT match regexp string /sReg/
function! s:foldMatch(iFirst, iLast, sReg, ...) abort "{{{
    let l:invert = v:false
    if a:0 > 0 && !empty(a:1)
        let l:invert = v:true
    endif

    let l:foldStart = 0
    for l:line in range(a:iFirst, a:iLast)
        let l:text = getline(l:line)
        let l:match = (!l:invert) ? (l:text =~# a:sReg) : (l:text !~# a:sReg)
        if l:match
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

" Func: s:foldSpecail 
" a:sName is like '$name' environment or configed name, to do some specific thing.
function! s:foldSpecail(iFirst, iLast, sName) abort "{{{
    if empty(a:sName) || a:sName[0] !=# '$'
        return -1
    endif

    " $ENVIRONMENT
    if exists(a:sName)
        return s:foldCommand(a:iFirst, a:iLast, split(expand(a:sName), '\s\+'))
    endif

    let l:sName = strpart(a:sName, 1)

    " $1 $2 ... $-1 $-2
    if l:sName =~# '^\d\+$'
        let l:level = 0 + l:sName
        execut 'setlocal foldlevel=' . l:level
        return
    elseif l:sName =~# '^-\d\+$'
        let l:level = 0 - l:sName
        execut 'setlocal foldcolumn=' . l:level
        return
    elseif l:sName ==# 'indent' || l:sName ==# 'xml'
        return zfold#method#Fold(a:iFirst, a:iLast, l:sName)
    endif

    " $name from config json
    try
        let l:config = g:zfold#set#json
        if empty(l:sName)
            " $ only, try currnet filetype
            let l:ft = &filetype
            if has_key(l:config, 'ft') && has_key(l:config.ft, l:ft) && has_key(l:config.ft[l:ft], '0')
                let l:regexp = l:config.ft[l:ft]['0']
                call s:foldCommand(a:iFirst, a:iLast, split(l:regexp, '\s\+'))
            endif
        elseif has_key(l:config, l:sName)
            " $golbal_name
            let l:regexp = l:config[l:sName]
            call s:foldCommand(a:iFirst, a:iLast, split(l:regexp, '\s\+'))
        else
            " $filetype_local_name
            let l:ft = &filetype
            if has_key(l:config, 'ft') && has_key(l:config.ft, l:ft) && has_key(l:config.ft[l:ft], l:sName)
                let l:regexp = l:config.ft[l:ft][l:sName]
                call s:foldCommand(a:iFirst, a:iLast, split(l:regexp, '\s\+'))
            endif
        endif
    catch 
        echomsg 'no config named: ' . a:sName
    endtry
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

    let l:lenReg = len(a:liReg)
    let l:foldStart = repeat([0], l:lenReg)

    for l:line in range(a:iFirst, a:iLast)
        let l:text = getline(l:line)
        for l:idx in range(l:lenReg)
            let l:reg = a:liReg[l:idx]
            if l:text =~# l:reg
                let l:foldidx = l:lenReg - 1
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

    if l:final
        let l:foldidx = l:lenReg - 1
        while l:foldidx >= 0
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
    if a:iLast <= a:iFirst
        return -1
    endif
    if foldlevel(a:iFirst) > 0 || foldlevel(a:iLast) > 0
        execute a:iFirst . ',' . a:iLast . ' foldopen!'
    endif
    execute a:iFirst . ',' . a:iLast . ' fold'
    return a:iLast - a:iFirst
endfunction "}}}

" Func: s:checkFold 
function! s:checkFold(bang) abort "{{{
    if &foldmethod !=? 'manual'
        setlocal foldmethod=manual
        echo 'setlocal foldmethod=manual'
    endif
    if a:bang
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
" when no // quoted and not begin with ^ and not end with $, auto prefix ^\s*
function! s:parseReg(arg) abort "{{{
    let l:ret = {'pattern':a:arg, 'flags':'', 'shift':0}
    if len(a:arg) < 2
        return l:ret
    endif

    if a:arg[0] != '/'
        if a:arg[0] != '^' && a:arg[len(a:arg)-1] != '$'
            let l:ret.pattern = '^\s*' . a:arg
        endif
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

" Func: #export 
function! zfold#cmd#export() abort
    if !exists('s:export')
        let s:export = {}
        let s:export.foldLines = function('s:foldLines')
    endif
    return s:export
endfunction
