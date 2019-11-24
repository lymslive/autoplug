" File: Vnite
" Author: lymslive
" Description: list Vnite command
" Create: 2019-11-02
" Modify: 2019-11-02

let g:vnite#command#Vnite#space = s:
let s:description = 'list all supported Vnite command, can edit argument inplace and execute'

command! -nargs=* -complete=custom,vnite#command#Vnite#complete Vnite call vnite#command#Vnite#run(<f-args>)
function! vnite#command#Vnite#run(...) abort
    if a:0 > 0
        for l:cmd in a:000
            call s:display(l:cmd)
        endfor
        return
    endif

    let l:history = vnite#command#hotlist()
    for l:idx in range(len(l:history))
        echo printf('%-15d :%s', l:idx, l:history[l:idx])
    endfor

    let l:paths = globpath(&rtp, 'autoload/vnite/command/**/*.vim', 0, 1)
    for l:path in l:paths
        let l:cmd = fnamemodify(l:path, ":p:t:r")
        call s:display(l:cmd)
    endfor

    if exists('g:vnite#config#extracmdlist') && type(g:vnite#config#extracmdlist) == v:t_list
        for l:line in g:vnite#config#extracmdlist
            let l:cmd = matchstr(l:line, '^\s*\zs\(\w\+\)\ze\s*\|')
            if !empty(l:cmd)
                let l:left = printf('%-15s', l:cmd)
                let l:right = substitute(l:line, '^\s*\w\+\s*', '', '')
                echo l:left . ' ' . l:right
            endif
        endfor
    endif
endfunction

" Func: #CR 
function! vnite#command#Vnite#CR(message) abort
    let l:text = a:message.text
    let l:tokens = split(l:text, '\s\+')
    let l:cmd = l:tokens[0]
    if l:cmd ==# 'Vnite'
        " donot rerun :Vnite
        return ''
    elseif l:cmd =~# '^\d\+:'
        let l:cmd = substitute(l:cmd, ':\s*$', '', 'g')
        return 'CM ' . l:cmd
    endif

    if len(l:tokens) < 2
        return 'CM ' . l:cmd
    endif
    let l:pipe = l:tokens[1]
    if l:pipe == '|"'
        return 'CM ' . l:cmd
    elseif l:pipe == '|'
        echo printf(':%s require arguments, can use C on the first | to edit inplace')
        return ''
    else
        return 'CM ' . l:text
    endif
endfunction

" Func: #complete 
function! vnite#command#Vnite#complete(ArgLead, CmdLine, CursorPos) abort
    let l:paths = globpath(&rtp, 'autoload/vnite/command/**/*.vim', 0, 1)
    call map(l:paths, 'fnamemodify(v:val, ":p:t:r")')
    return join(l:paths, "\n")
endfunction

" Func: s:display 
function! s:display(cmd) abort
    let l:cmd = a:cmd
    let l:space = vnite#command#get_space(l:cmd)
    if empty(l:space)
        return
    endif
    let l:argtips = get(l:space, 'argtips', '')
    let l:description = get(l:space, 'description', '')
    let l:line = printf('%-15s', l:cmd)
    if !empty(l:argtips)
        let l:line = l:line . ' | ' . l:argtips
    endif
    if !empty(l:description)
        let l:line = l:line . ' |" ' . l:description
    endif
    echo l:line
endfunction
