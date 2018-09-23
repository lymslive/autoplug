" File: test
" Author: lymslive
" Description: manually test tool
" Create: 2018-09-22
" Modify: 2018-09-22

let s:cmdline = class#use('class#viml#cmdline')
" ClassTest: 
" :ClassTest [-f filename] -- [argument-list-pass-to-#test]
function! debug#test#ClassTest(...) abort "{{{
    let l:jOption = s:cmdline.new('ClassTest')
    call l:jOption.AddPairs('f', 'file', 'the filename witch #test called', '.')
    let l:iRet = l:jOption.ParseCheck(a:000)
    if l:iRet != 0
        return -1
    endif

    let l:lsPostArgv = l:jOption.GetPost()

    if l:jOption.Has('file')
        let l:pFileName = l:jOption.Get('file')
    else
        let l:pFileName = expand('%:p:r')
    endif

    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassTest only execute under autoload director'
        return 0
    endif

    call call(l:sAutoName . '#test', l:lsPostArgv)
endfunction "}}}

" ClassDebug: 
" same as ClassTest, but redir message to locallist
" problem: error abort may confuse the redir
let s:output = ''
function! debug#test#ClassDebug(...) abort "{{{
    let l:jOption = s:cmdline.new('ClassTest')
    call l:jOption.AddPairs('f', 'file', 'the filename witch #test called', '.')
    let l:iRet = l:jOption.ParseCheck(a:000)
    if l:iRet != 0
        return -1
    endif

    let l:lsPostArgv = l:jOption.GetPost()

    if l:jOption.Has('file')
        let l:pFileName = l:jOption.Get('file')
    else
        let l:pFileName = expand('%:p:r')
    endif

    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassTest only execute under autoload director'
        return 0
    endif

    let g:DEBUG = 1
    try
        redir => s:output
        silent call call(l:sAutoName . '#test', l:lsPostArgv)
    catch 
    finally
        redir END

        let l:lsContent = split(s:output, '\n')
        let l:lsQF = []
        let l:bufnr = bufnr('%')
        for l:sLine in l:lsContent
            if l:sLine =~# 'E\d\+'
                let l:item = {'bufnr': l:bufnr, 'lnum': 0, 'text': l:sLine}
            else
                let l:item = {'bufnr': l:bufnr,  'text': l:sLine}
            endif
            call add(l:lsQF, l:item)
        endfor

        let l:winnr = winnr()
        call setloclist(l:winnr, l:lsQF)

        if !empty(l:lsQF)
            :lopen
        endif
    endtry
endfunction "}}}

" MessageRefix: reload last message in quickfix or locallist
" a:count, the line count from message end, like `tail -n`
" a:type, 'qf', or 'll'
function! debug#test#MessageRefix(count, type) abort "{{{
    : redir => s:output
    : silent messages
    : redir END

    let l:lsContent = split(s:output, '\n')
    if a:count > len(l:lsContent)
        let l:count = len(l:lsContent)
    else
        let l:count = a:count + 0
    endif
    let l:lsContent = l:lsContent[-l:count:-1]

    let l:lsQF = []
    let l:bufnr = bufnr('%')
    for l:sLine in l:lsContent
        if l:sLine =~# 'E\d\+'
            let l:item = {'bufnr': l:bufnr, 'lnum': 0, 'text': l:sLine}
        else
            let l:item = {'bufnr': l:bufnr,  'text': l:sLine}
        endif
        call add(l:lsQF, l:item)
    endfor

    if a:type ==? 'qf'
        call setqflist(l:lsQF)
        if !empty(l:lsQF)
            : botright copen
        endif
    elseif a:type ==? 'll'
        let l:winnr = winnr()
        call setloclist(l:winnr, l:lsQF)
        if !empty(l:lsQF)
            : lopen
        endif
    endif

endfunction "}}}

