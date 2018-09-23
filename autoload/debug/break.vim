" File: break
" Author: lymslive
" Description: quick add break in current file
" Create: 2018-09-22
" Modify: 2018-09-22

let s:pattern = {}
" match a function definition line, the matchstr is function name
let s:pattern.function_name = '^\s*function!\?\s\+\zs\h[:.#a-zA-Z0-9_]*\ze\s*(.*)'
" s:function
let s:pattern.function_local = '^s:\zs\h\w\+\ze$'
" dict.function \1=dict-name \2=func-name
let s:pattern.function_dict = '^\(.\+\)\.\(\h\w\+\)$'

" Break: add break in current function or script line
" command! -nargs=* -buffer Break call debug#break#command(<f-args>)
function! debug#break#command(...) abort "{{{
    let l:sLine = getline('.')

    let l:sFunction = matchstr(l:sLine, s:pattern.function_name)
    if !empty(l:sFunction) 
        return s:OnFunctionLine(l:sFunction)
    endif

    let [l:sFunction, l:iShiftLine] = s:CheckInFunction()
    if !empty(l:sFunction) 
        return s:OnFunctionLine(l:sFunction, l:iShiftLine)
    endif

    let l:pFileName = expand('%:p')
    let l:iLineNumber = line('.')
    return s:BreakFile(l:pFileName, l:iLineNumber)
endfunction "}}}

" CheckInFunction: check if cursor in a function
" return [function-name, shift-line] if in or ['', 0]
function! s:CheckInFunction() abort "{{{
    let l:NOTIN = ['', 0]
    let l:iLine = line('.')
    let l:iShift = 0
    while l:iLine > 0
        let l:sLine = getline(l:iLine)
        " match endfunction but not endfor
        if l:sLine =~# '\<endf' && l:sLine !~# '\<endfo'
            return l:NOTIN
        endif

        let l:sFunction = matchstr(l:sLine, s:pattern.function_name)
        if !empty(l:sFunction) 
            return [l:sFunction, l:iShift]
        endif

        let l:iShift += 1
        let l:iLine -= 1
    endwhile

    return l:NOTIN
endfunction "}}}

" OnFunctionLine: when cursor on function definition line
" a:sFunction is the function name part
" a:1, is the line under the function header
function! s:OnFunctionLine(sFunction, ...) abort "{{{
    let l:sFunction = a:sFunction
    let l:iShiftLine = get(a:000, 0, 1)
    let l:pFileName = expand('%:p')

    " s:function
    let l:sLocal = matchstr(l:sFunction, s:pattern.function_local)
    if !empty(l:sLocal)
        let l:jSource = class#viml#source#new(l:pFileName)
        let l:sFullName = l:jSource.PrefixSID() . l:sLocal
        call s:BreakFunc(l:sFullName, l:iShiftLine)
        return
    endif

    " s:class.method
    let l:lsMatch = matchlist(l:sFunction, s:pattern.function_dict)
    if !empty(l:lsMatch)
        if l:lsMatch[1] ==# 's:class'
            let l:rtp = class#less#rtp#export()
            let l:sAutoName = l:rtp.GetAutoName(l:pFileName)
            try
                let l:class = eval(l:sAutoName . '#class()')
                let l:method = l:lsMatch[2]
                let l:strMethod = string(l:class[l:method])
                let l:numFunction = matchstr(l:strMethod, '\d\+')
                call s:BreakFunc(l:numFunction, l:iShiftLine)
            catch 
                echomsg 'fails to get function number of method:'
                echoerr v:exception
            endtry
        else
            echomsg 'can only support s:class method now'
        endif
        return
    endif

    " # or global function
    call s:BreakFunc(l:sFunction, l:iShiftLine)
endfunction "}}}

" BreakFunc: 
function! s:BreakFunc(func, ...) abort "{{{
    if a:0 > 0 && a:1 > 0
        let l:cmd = printf('breakadd func %d %s', a:1, a:func)
    else
        let l:cmd = 'breakadd func ' . a:func
    endif
    : execute l:cmd
endfunction "}}}

" BreakFile: 
function! s:BreakFile(file, ...) abort "{{{
    if a:0 > 0 && a:1 > 0
        let l:cmd = printf('breakadd file %d %s', a:1, a:file)
    else
        let l:cmd = 'breakadd file ' . a:file
    endif
    : execute l:cmd
endfunction "}}}

function! debug#break#load(...) abort "{{{
    return 1
endfunction "}}}
