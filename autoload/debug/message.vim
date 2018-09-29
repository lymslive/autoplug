" File: message
" Author: lymslive
" Description: view message, jump by call stack in error message
" Create: 2018-09-23
" Modify: 2018-09-23

function! debug#message#package() abort "{{{
    return s:
endfunction "}}}

USE! ./frame.vim

let s:lsMessage = []
let s:MESBUFFER_NAME = '.MESSAGE.buf'
let s:MESBUFFER_HEIGHT = 15

" Func: s:list 
" get all message, return as string list
function! s:list(...) abort "{{{
    let l:cmd = get(a:000, 0, 'messages')

    : redir => s:output
    : execute 'silent' l:cmd
    : redir END

    let s:lsMessage = split(s:output, '\n')
    return s:lsMessage
endfunction "}}}

" Func: s:tail some line `tail -n`
" get a part of message from the end, last recent message.
" s:tail(0), roll back to get all list
" s:tail(n), get the last n items of message list
" s:tail(-n), get the first n items, may like `head -n`
function! s:tail(count) abort "{{{
    let l:list = s:list()
    if a:count == 0
        return copy(l:list)
    elseif a:count > 0
        if a:count >= len(l:list)
            return copy(l:list)
        else
            return l:list[-a:count : -1]
        endif
    else
        if -a:count >= len(l:list)
            return copy(l:list)
        else
            return l:list[0 : -a:count - 1]
        endif
    endif
endfunction "}}}

" Func: s:mesbuf 
function! s:mesbuf() abort "{{{
    if exists('s:MESBUFFER') && !empty(s:MESBUFFER)
        return s:MESBUFFER
    endif

    let l:buffer = package#import('cn#buffer')
    let s:MESBUFFER = l:buffer.auxbuffer(s:MESBUFFER_NAME, {'filetype': 'log'}, function('s:mesmap'))

    return s:MESBUFFER
endfunction "}}}

" Func: s:go_meswin 
function! s:go_meswin() abort "{{{
    let l:wincur = winnr()

    let l:winnr = bufwinnr(s:mesbuf())
    if l:winnr == -1
        botright split
        execute 'buffer' s:mesbuf()
        if winheight(0) > s:MESBUFFER_HEIGHT
            execute 'resize' s:MESBUFFER_HEIGHT
        endif
        let l:winnr = bufwinnr(s:mesbuf())
    endif

    if l:winnr != -1 && l:winnr != l:wincur
        execute l:winnr . 'wincmd w'
    endif

    return l:winnr
endfunction "}}}

" class struct design
let s:CMesWin = {}
let s:CMesWin.Slice = 0
let s:CMesWin.FirstLine = 0
let s:CMesWin.LastLine = 0

" Func: s:mesview 
" load a slice of all `s:lsMessage` to the [Message] window
" will create b:jMessage object to handle the slice range
function! s:mesview(count) abort "{{{
    let l:lsMessage = s:tail(a:count)
    if empty(l:lsMessage)
        return
    endif

    if s:go_meswin() <= 0
        :DLOG 'fails to go message window'
        return
    end

    1,$ delete
    call append(0, l:lsMessage)

    let b:jMessage = copy(s:CMesWin)
    if len(l:lsMessage) >= len(s:lsMessage)
        let b:jMessage.FirstLine = 0
        let b:jMessage.LastLine = len(s:lsMessage) - 1
    elseif a:count > 0
        let b:jMessage.Slice = 1
        let b:jMessage.FirstLine = len(s:lsMessage) - a:count
        let b:jMessage.LastLine = len(s:lsMessage) - 1
    elseif a:count < 0
        let b:jMessage.Slice = 1
        let b:jMessage.FirstLine = 0
        let b:jMessage.LastLine = -a:count - 1
    endif

    return len(l:lsMessage)
endfunction "}}}

" Func: s:mesmap 
function! s:mesmap() abort "{{{
    setlocal iskeyword=a-z,A-Z,48-57,_,[,],>,<
    nnoremap <buffer> q :q<CR>
    nnoremap <buffer> j :call <SID>meskey_j()<CR>
    nnoremap <buffer> k :call <SID>meskey_k()<CR>
    nnoremap <buffer> <CR> :call <SID>meskey_CR()<CR>
    nnoremap <buffer> b :call <SID>meskey_b('<C-R><C-W>')<CR>b
    vnoremap <buffer> b y:call <SID>meskey_b('<C-R>"')<CR>
endfunction "}}}

" Func: s:meskey_k 
" move up, when reach top, try to load more message
function! s:meskey_k() abort "{{{
    if !exists('b:jMessage') || !b:jMessage.Slice
        normal! k
        return
    endif

    let l:line = line('.')
    if l:line > 1
        normal! k
        return
    endif
    if b:jMessage.FirstLine <= 0
        :WLOG 'already load all message'
        return
    endif

    let l:iFirst = b:jMessage.FirstLine - 10
    if l:iFirst < 0
        let l:iFirst = 0
    endif
    let l:lsMore = s:lsMessage[l:iFirst : b:jMessage.FirstLine-1]
    call append(0, l:lsMore)
    normal! k
    let b:jMessage.FirstLine = l:iFirst

    return 1
endfunction "}}}

" Func: s:meskey_j 
function! s:meskey_j() abort "{{{
    if !exists('b:jMessage') || !b:jMessage.Slice
        normal! j
        return
    endif

    let l:line = line('.')
    if l:line < line('$')
        normal! j
        return
    endif

    let l:iEnd = len(s:lsMessage) - 1
    if b:jMessage.FirstLine >= l:iEnd
        :WLOG 'already load all message'
        return
    endif

    let l:iLast = b:jMessage.LastLine + 10
    if l:iLast > l:iEnd
        let l:iLast = l:iEnd
    endif

    let l:lsMore = s:lsMessage[b:jMessage.LastLine+1 : l:iLast]
    call append('$', l:lsMore)
    normal! j
    let b:jMessage.LastLine = l:iLast

    return 1
endfunction "}}}

" Func: s:meskey_b 
function! s:meskey_b(word) abort "{{{
    let [l:sFuncName, l:iFuncLine] = s:func_line(a:word)
    call debug#break#func(l:sFuncName, l:iFuncLine)
    return 1
endfunction "}}}

" Func: s:meskey_CR 
function! s:meskey_CR() abort "{{{
    let l:sLine = getline('.')
    if l:sLine =~# 'function\s\+\S\+\.\.'
        " split <sfile> long call stack into separate line
        let l:sTrace = matchstr(l:sLine, '\zsfunction\s\+\S\+\ze')
        let l:lsTrace = s:stack_list(l:sTrace)
        if len(l:lsTrace) <= 0
            return
        endif
        call map(l:lsTrace, '"[trace] .. " . v:val')
        " add tail message another line
        let l:msg = matchstr(l:sLine, '(function\s\+\S\+)\s\+\zs.*')
        if !empty(l:msg)
            call add(l:lsTrace, '[trace] -- ' .l:msg)
        endif
        call append('.', l:lsTrace)
        normal! j
    elseif l:sLine =~ '^\[trace\] .. '
        " try jump to the source script of this stack
        let l:sTrace = matchstr(l:sLine, '^\[trace\] .. \zs\S\+\ze')
        call s:stack_locate(l:sTrace)
    endif
endfunction "}}}

" Func: #view 
function! debug#message#view(count) abort "{{{
    return s:mesview(a:count)
endfunction "}}}
