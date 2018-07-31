" File: onft
" Author: lymslive
" Description: 
" Create: 2018-06-04
" Modify: 2018-06-04

" Flow: as ftpluign for flow buffer
function! tailflow#onft#Flow() abort "{{{
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal textwidth=0

    command! -buffer -nargs=* And  call tailflow#onft#hAnd(<f-args>)
    command! -buffer -nargs=* Not  call tailflow#onft#hNot(<f-args>)
    command! -buffer -nargs=0 Stop call tailflow#onft#hStop()
    command! -buffer -nargs=0 Run  call tailflow#onft#hRun()
    command! -buffer -nargs=* Cmd  call tailflow#onft#hCmd(<f-args>)
    command! -buffer -nargs=* File call tailflow#onft#hFile(<f-args>)
    command! -buffer -nargs=0 Status call tailflow#onft#hStatus(<f-args>)

    " match or not match the word under cursor
    " expect a <CR> to comfirm by user
    nnoremap <buffer> A <Esc>:And <C-R><C-W>
    nnoremap <buffer> X <Esc>:Not <C-R><C-W>
    vnoremap <buffer> A y<Esc>:And <C-R>"
    vnoremap <buffer> X y<Esc>:Not <C-R>"

    " format one line json string in log file
    command! -buffer -nargs=0 JsonBreak call tailflow#logjson#SimpleBreak(<f-args>)
    nnoremap <buffer> J <Esc>:JsonBreak<CR>
    if executable('clang-format')
        nnoremap <buffer> K <Esc>V:!clang-format -style=LLVM<CR>
        vnoremap <buffer> K :!clang-format -style=LLVM<CR>
    endif
endfunction "}}}

" IsFlowBuffer: 
function! s:IsFlowBuffer() abort "{{{
    return exists('b:jFlow')
endfunction "}}}

" And: manage the AND list of flow object
" :And [=|-=|+=] [item1 item2 ...]
" the default operater is '+='
function! tailflow#onft#hAnd(...) abort "{{{
    if !s:IsFlowBuffer()
        return -1
    endif
    if a:0 == 0
        echo b:jFlow.and
    elseif a:0 == 1
        call b:jFlow.AddAndList(a:1)
    else
        let l:operator = a:1
        if l:operator ==# '='
            call b:jFlow.SetAndList(a:000[1:])
        elseif l:operator ==# '+='
            for l:item in a:000[1:]
                call b:jFlow.AddAndList(l:item)
            endfor
        elseif l:operator ==# '-='
            for l:item in a:000[1:]
                call b:jFlow.SubAndList(l:item)
            endfor
        else
            for l:item in a:000
                call b:jFlow.AddAndList(l:item)
            endfor
        endif
    endif
endfunction "}}}

" Not: manage the NOT list of flow object
function! tailflow#onft#hNot(...) abort "{{{
    if !s:IsFlowBuffer()
        return -1
    endif
    if a:0 == 0
        echo b:jFlow.not
    elseif a:0 == 1
        call b:jFlow.AddNotList(a:1)
    else
        let l:operator = a:1
        if l:operator ==# '='
            call b:jFlow.SetNotList(a:000[1:])
        elseif l:operator ==# '+='
            for l:item in a:000[1:]
                call b:jFlow.AddNotList(l:item)
            endfor
        elseif l:operator ==# '-='
            for l:item in a:000[1:]
                call b:jFlow.SubNotList(l:item)
            endfor
        else
            for l:item in a:000
                call b:jFlow.AddNotList(l:item)
            endfor
        endif
    endif
endfunction "}}}

" Stop: 
function! tailflow#onft#hStop() abort "{{{
    if !s:IsFlowBuffer()
        return -1
    endif
    call b:jFlow.Stop()
endfunction "}}}

" File: echo or set log file
function! tailflow#onft#hFile(...) abort "{{{
    if !s:IsFlowBuffer()
        return -1
    endif
    if a:0 < 1
        echo b:jFlow.GetFile()
        return
    endif
    let l:path = a:1
    call b:jFlow.ChangeFile(l:path)
endfunction "}}}

" Cmd: 
function! tailflow#onft#hCmd(...) abort "{{{
    if !s:IsFlowBuffer()
        return -1
    endif
    if a:0 < 1
        echo b:jFlow.GetCmd()
        return 0
    endif
    call b:jFlow.ChangeCmd(a:000)
endfunction "}}}

" Run: 
function! tailflow#onft#hRun() abort "{{{
    if !s:IsFlowBuffer()
        return -1
    endif
    if job_status(b:jFlow.job) ==? 'run'
        :ELOG 'job is already runnig'
        return 0
    endif
    call b:jFlow.Start()
endfunction "}}}

" Status: just show the job status in message 
function! tailflow#onft#hStatus() abort "{{{
    if !s:IsFlowBuffer()
        return -1
    endif
    echomsg b:jFlow.job
endfunction "}}}
