" File: insertion
" Author: lymslive
" Description: 
" Create: 2018-04-29
" Modify: 2018-04-29

" Relaport: 相对于当前文件的 import 路径
function! golang#insertion#Relaport(relative) abort "{{{
    return s:relaport(a:relative)
endfunction "}}}

" relaport: 
function! s:relaport(relative) abort "{{{
    let l:thispath = expand('%:p:h')
    let l:abspath = l:thispath . '/' . a:relative
    let l:abspath = simplify(l:abspath)
    let l:relaport = substitute(l:abspath, '.*src/', '', '')
    return l:relaport
endfunction "}}}

" strip: 剥除引入包名的首尾引用与空白
function! s:strip(package) abort "{{{
    let l:import = a:package
    let l:import = substitute(l:import, '^[" \t]\+', '', '')
    let l:import = substitute(l:import, '[" \t]\+$', '', '')
    return l:import
endfunction "}}}

" ChangeImport: 修改当前行的相对引入
" 如果成功修改了，返回 1，否则按默认返回 0
function! golang#insertion#ChangeImport() abort "{{{
    let l:sLine = getline('.')

    " 一行的 import 
    let l:regexp = '^import\s\+\(.\+\)'
    let l:lsMatch = matchlist(l:sLine, l:regexp)
    if len(l:lsMatch) > 0
        let l:import = s:strip(l:lsMatch[1])
        " 相对引用，以 ./ 或 ../ 开头
        if l:import =~# '^\.\.\?/'
            let l:import = s:relaport(l:import)
            let l:sLine = printf('import "%s"', l:import)
            call setline('.', l:sLine)
            return 1
        endif
        return 0
    endif

    " 缩进的 import 块
    let l:regexp = '^\s\+\(.\+\)'
    let l:lsMatch = matchlist(l:sLine, l:regexp)
    if len(l:lsMatch) > 0
        let l:iLastBlock = search('^\S\+', 'bnW')
        if l:iLastBlock <= 0
            return
        endif
        let l:sLastBlock = getline(l:iLastBlock)
        if l:sLastBlock =~# '^import\s\+('
            let l:import = s:strip(l:lsMatch[1])
            " 相对引用，以 ./ 或 ../ 开头
            if l:import =~# '^\.\.\?/'
                let l:import = s:relaport(l:import)
                let l:sLine = printf("\t" . '"%s"', l:import)
                call setline('.', l:sLine)
                return 1
            endif
        endif
        return 0
    endif

endfunction "}}}

" EnterInsert: 插入模式回车 <CR>
" imap <expr> 表达式不能调用 setline
" 可改用 <C-o>
function! golang#insertion#EnterInsert() abort "{{{
    if golang#insertion#ChangeImport() == 1
        normal! $
        return "\<End>\<CR>"
    else
        return "\<CR>"
    endif
endfunction "}}}

" EscapeInsert: 插入模式回普通模式 <Esc>
function! golang#insertion#EscapeInsert() abort "{{{
    if golang#insertion#ChangeImport() == 1
        normal! $
        return "\<Esc>$"
    else
        return "\<Esc>"
    endif
endfunction "}}}

" ImportSmart: 包装 :GoImport 命令，处理相对引入
" 要求已安装 vim-go
function! golang#insertion#ImportSmart(package) abort "{{{
    let l:import = a:package
    if l:import =~# '^\.\.\?/'
        let l:import = s:relaport(l:import)
    endif

    execute 'GoImport' l:import
endfunction "}}}
