" File: cmdu
" Author: lymslive
" Description: 
" Create: 2021-05-21
" Modify: 2021-05-23

let s:focus_log = ''

" Func: s:getLogList 
function! s:getLogList(logname) abort
    let l:logname = a:logname
    if empty(l:logname)
        let l:logname = s:focus_log
    endif
    if empty(l:logname)
        return []
    endif
    let l:lsFile = glob(l:logname . '*.log', 0, 1)
    return sort(l:lsFile)
endfunction

" ELog:
function! logview_7#cmdu#hElog(...) abort
    if a:0 < 1
        echoerr 'ElogList expect an argument'
        return -1
    endif

    if a:0 >= 2
        return logview_7#cmdu#hElogList(a:1, a:2)
    endif

    let l:lsFile = s:getLogList(a:1)
    if empty(l:lsFile)
        echomsg 'no log with this name'
        return 0
    endif

    let l:lastFile = l:lsFile[-1]
    execute 'edit ' . l:lastFile
    return 0
endfunction

" ELogList:
function! logview_7#cmdu#hElogList(...) abort
    if a:0 < 1
        echoerr 'ElogList expect an argument'
        return -1
    endif

    let l:logname = a:1
    let l:lsFile = s:getLogList(l:logname)
    if empty(l:lsFile)
        return 0
    endif
    let s:focus_log = l:logname

    let l:nTailCount = 10
    if a:0 >= 2
        let l:nInputCount = str2nr(a:2)
        if l:nInputCount > 0
            let l:nTailCount = l:nInputCount
        endif
    endif

    let l:nTotalCount = len(l:lsFile)
    if l:nTotalCount > l:nTailCount
        call remove(l:lsFile, 0, l:nTotalCount - l:nTailCount - 1)
    elseif l:nTailCount > l:nTotalCount
        let l:nTailCount = l:nTotalCount
    endif

    let l:headIdx = 0
    while l:headIdx < l:nTailCount
        let l:ridx = l:nTailCount - l:headIdx - 1
        let l:val = l:lsFile[l:headIdx]
        let l:lsFile[l:headIdx] = printf("%d\t%s", l:ridx, l:val)
        let l:headIdx += 1
    endwhile

    let l:strOutput = join(l:lsFile, "\n")
    echo l:strOutput
    let l:strInput = input("which file number to open, default 0, cancle -1\n:Elog ", 0)
    let l:ridx = str2nr(l:strInput)
    if l:ridx >= 0
        let l:idx = l:nTailCount - l:ridx - 1
        let l:showLine = l:lsFile[l:idx]
        let l:lsSplit = split(l:showLine, "\t")
        if len(l:lsSplit) >= 2
            let l:file = l:lsSplit[1]
            execute 'edit ' . l:file
        else
            echoerr 'something wrong, invaild filename'
        endif
    else
        echomsg 'invalid file number, cancle open'
    endif

    return 0
endfunction

" ELogNext:
function! logview_7#cmdu#hElogNext(...) abort
    let l:nShift = 1
    if a:0 > 0
        let l:nShiftInput = str2nr(a:1)
        if l:nShiftInput > 1
            let l:nShift = l:nShiftInput
        endif
    endif

    let l:thisFile = expand('%:t')
    let l:logname = s:extract_basename(l:thisFile)
    let l:lsFile = s:getLogList(l:logname)
    if empty(l:lsFile)
        echoerr 'something wrong, not found current filelist?'
        return -1
    endif

    let l:idx = index(l:lsFile, l:thisFile)
    if l:idx == -1
        echoerr 'something wrong, not found current file?'
        return -1
    endif

    let l:idx += l:nShift
    if l:idx < len(l:lsFile)
        let l:file = l:lsFile[l:idx]
        execute 'edit ' . l:file
        return 0
    else
        echomsg 'no more next file with shift ' . l:nShift
        return -1
    endif
endfunction

" ELogPrev:
function! logview_7#cmdu#hElogPrev(...) abort
    let l:nShift = 1
    if a:0 > 0
        let l:nShiftInput = str2nr(a:1)
        if l:nShiftInput > 1
            let l:nShift = l:nShiftInput
        endif
    endif

    let l:thisFile = expand('%:t')
    let l:logname = s:extract_basename(l:thisFile)
    let l:lsFile = s:getLogList(l:logname)
    if empty(l:lsFile)
        echoerr 'something wrong, not found current filelist?'
        return -1
    endif

    let l:idx = index(l:lsFile, l:thisFile)
    if l:idx == -1
        echoerr 'something wrong, not found current file?'
        return -1
    endif

    let l:idx -= l:nShift
    if l:idx >= 0
        let l:file = l:lsFile[l:idx]
        execute 'edit ' . l:file
        return 0
    else
        echomsg 'no more prev file with shift ' . l:nShift
        return -1
    endif
endfunction

" Func: s:extract_basename 
function! s:extract_basename(logname) abort
    return substitute(a:logname, '\d\d.*$', '', 'g')
endfunction

" Func: s:uniq 
" in vim7.4 uniq() function is not avaiable
function! s:uniq(list) abort
    if empty(a:list)
        return a:list
    endif

    let l:headIdx = 0
    let l:tailIdx = 1
    let l:length = len(a:list)
    let l:headVal = a:list[l:headIdx]
    while l:tailIdx < l:length
        if a:list[l:tailIdx] != a:list[l:headIdx]
            let l:headIdx += 1
            if l:headIdx != l:tailIdx
                let a:list[l:headIdx] = a:list[l:tailIdx]
            endif
        endif
        let l:tailIdx += 1
    endwhile

    if l:headIdx + 1 < l:length
        call remove(a:list, l:headIdx + 1, -1)
    endif
endfunction

" Func: #complist 
function! logview_7#cmdu#complist(ArgLead, CmdLine, CursorPos) abort
    let l:lsFile = glob(a:ArgLead . '*.log', 0, 1)
    call map(l:lsFile, 's:extract_basename(v:val)')
    call sort(l:lsFile)
    call s:uniq(l:lsFile)
    return l:lsFile
endfunction
