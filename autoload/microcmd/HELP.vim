" HELP.vim
" some help warp command
" Author: lymslive / 2016-08-29

let s:History = []
let s:HistMax = 16

" Public function for command
" > Window, target wind to show help
"   * 'default' or '' empty, done as split
"   * 'vertical' : show in vertical splited windown
"   * 'tab' : show in new tab
" > a:1,
"   * negtive number -1 -2 history help topic
"   * string, as help topic
"    
function! microcmd#HELP#Commander(Window, ...) "{{{
    " get target that prefix to help command
    let l:target = ''
    if !empty(a:Window)
        let l:target = a:Window . ' '
    endif

    " get topic argument or current word under cursor
    if a:0 == 0 || empty(a:1)
        let l:topic = expand('<cword>')
    else
        let l:topic = a:1
    endif

    if empty(a:Window) && tabpagenr('$') > 1
        let l:tabpage = s:FindHelpWinTab()
        if l:tabpage > 0
            execute l:tabpage . 'tabnext'
        endif
    endif

    if l:topic =~ '^[+-]\?\d\+$'
        " argument is number
        let l:hisnum = 0 + l:topic
        let l:histopic = get(s:History, l:hisnum, '') 
        if !empty(l:histopic)
            let l:cmd = l:target . 'help ' . l:histopic
            execute l:cmd
        endif

    else
        " new help topic
        let l:cmd = l:target . 'help ' . l:topic
        let v:errmsg = ""
        execute l:cmd
        if empty(v:errmsg)
            call s:AddHistory(l:topic)
        endif
    endif
endfunction "}}}

function! s:AddHistory(item) "{{{
    call add(s:History, a:item)
    if len(s:History) >= s:HistMax * 2
        let s:History = s:History[0-s:HistMax : -1]
    endif
endfunction "}}}

function! microcmd#HELP#ShowHistory() "{{{
    echo s:History
endfunction "}}}

" FindHelpWinTab: 
" find a help window in any other tabpage
" return tabpage number or 0 if none
" :help will auto jump to help window in current tabpage
function! s:FindHelpWinTab() abort "{{{1
    for l:iTab in range(1, tabpagenr('$'))
        if l:iTab == tabpagenr()
            continue
        endif
        for l:iWin in range(1, tabpagewinnr(l:iTab, '$'))
            if gettabwinvar(l:iTab, l:iWin, '&filetype') == 'help'
                return l:iTab
            endif
        endfor
    endfor
    return 0
endfunction
