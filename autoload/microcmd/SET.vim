" SET.vim
" quickly toggle settings
" Author: lymslive / 2016-08-29

" Toggle Set history list
let s:History = []
let s:HistMax = 16

" * 0 args: re-execute the last SET toogle command
" * 1 args: numbered args, re-execute SET history command
"           sting, toogle set a boolean option
" * 2 args: toogle set a comma-list option
" * 3 args: toogle set a option between tow values
function! microcmd#SET#Toogle(...) "{{{
    if a:0 == 0
        return s:HistoryCmd(-1)

    elseif a:0 == 1
        if a:1 =~ '^[+-]\?\d\+$'
            return s:HistoryCmd(0 + a:1)
        elseif a:1 =~ '='
            execute 'set ' . a:1
            return 1
        endif

        let l:theset = a:1
        if eval("&" . l:theset)
            execute "set no" .  l:theset
            echo "set no" .  l:theset
        else
            execute "set " . l:theset
            echo "set " . l:theset
        endif
        call s:AddHistory(a:1)

    elseif a:0 == 2
        let l:theset = a:1
        let l:theopt = a:2
        if eval("&" . l:theset) =~# l:theopt
            execute "set " . l:theset . "-=" . l:theopt 
            echo "set " . l:theset . "-=" . l:theopt 
        else
            execute "set " . l:theset . "+=" . l:theopt 
            echo "set " . l:theset . "+=" . l:theopt 
        endif
        call s:AddHistory(a:1 . ' ' . a:2)

    elseif a:0 == 3
        let l:theset = a:1
        let l:theopt = a:2
        let l:thealt = a:3
        if eval("&" . l:theset) != l:theopt
            execute "set " . l:theset . "=" . l:theopt 
            echo "set " . l:theset . "=" . l:theopt 
        else
            execute "set " . l:theset . "=" . l:thealt
            echo "set " . l:theset . "=" . l:thealt
        endif
        call s:AddHistory(a:1 . ' ' . a:2 . ' ' . a:3)

    else
        echo "Too many arguments"
    endif " a:0 cases
endfunction "}}}

" re-execute a history SET command
function! s:HistoryCmd(index) "{{{
    if empty(s:History)
        echo "no history SET command"
    else
        let l:args = get(s:History, a:index, '')
        if !empty(l:args)
            execute 'SET ' . l:args
        else
            echo "invalid index of SET history list"
        endif
    endif
endfunction "}}}

function! s:AddHistory(item) "{{{
    call add(s:History, a:item)
    if len(s:History) >= s:HistMax * 2
        let s:History = s:History[0-s:HistMax : -1]
    endif
endfunction "}}}

function! microcmd#SET#ShowHistory() "{{{
    echo s:History
endfunction "}}}
