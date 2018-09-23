" File: rename
" Author: lymslive
" Description: rename vim script
" Create: 2018-09-22
" Modify: 2018-09-22

let s:rtp = class#less#rtp#export()

" VimRename: 
" VimRename(), rename class by file name, maybe moved outside
" VimRename(newname), rename currnet file to newname
" VimRename(oldfile, newfile), rename old file to new
" in all cases, correct the #function name
function! debug#rename#command(...) abort "{{{
    " save current buffer file
    : update

    if a:0 == 0
        return s:FixClassName()
    end

    if a:0 == 1
        let l:pOldFile = expand('%:p')
        let l:pNewFile = a:1
    elseif a:0 == 2
        let l:pOldFile = a:1
        let l:pNewFile = a:2
    endif

    if filereadable(l:pNewFile)
        echoerr 'cannot renmae, target already exists: ' . l:pNewFile
        return -1
    endif
    if !filereadable(l:pOldFile)
        echoerr 'cannot renmae, source not exists: ' . l:pOldFile
        return -1
    endif
    if rename(l:pOldFile, l:pNewFile) == 0
        execute 'edit ' . l:pNewFile
        call s:FixClassName()
    else
        echoerr 'cannot rename to file: ' . l:pNewFile
        return -1
    endif
endfunction "}}}

" FixClassName: fix class name in current buffer
function! s:FixClassName() abort "{{{
    let l:pFileName = expand('%:p:r')
    let l:sAutoName = s:rtp.GetAutoName(l:pFileName)
    if empty(l:sAutoName)
        echom ':ClassTest only execute under autoload director'
        return -1
    endif

    let l:sPattern = 'let\s\+s:class\._name_\s\+=\s\+'
    let l:iLine = search(l:sPattern, 'wn')
    if l:iLine > 0
        let l:sLine = getline(l:iLine)
        let l:sName = matchstr(l:sLine, l:sPattern . '\zs\S\+\ze')
        let l:sName = substitute(l:sName, '[''"]', '', 'g')
    else
        let l:sName = ''
    endif

    if !empty(l:sName)
        " in class file case
        let l:cmd = printf('%%s/%s/%s/g', l:sName, l:sAutoName)
        execute l:cmd
    else
        " non-class file
        let l:cmd = printf('g/^\s*function/s/\zs\w\+\ze#\w\+/%s/', l:sAutoName)
        execute l:cmd
    endif
    return 0
endfunction "}}}

" UpdateModity: 
" automatically update the Modify time in the commet header
" Note: easy to occur merge conflict since change the same line
function! debug#rename#UpdateModity() abort "{{{
    let l:sDate = strftime('%Y-%m-%d')
    let l:iEnd = line('$')
    if l:iEnd > 10
        let l:iEnd = 10
    endif

    let l:cmd = '1,%d g/"\s*Modify:/s/\d\+[-]\d\+[-]\d\+/%s/'
    let l:cmd = printf(l:cmd, l:iEnd, l:sDate)

    let l:save_cursor = getcurpos()
    execute l:cmd
    call setpos('.', l:save_cursor)
endfunction "}}}

