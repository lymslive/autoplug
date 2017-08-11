" Author: lymslive @ 2010-5
" Modified: 2016-08-30

let s:debug = 1
if !exists("s:debug") && exists("s:scriploaded")
    finish
endif "
let s:scriploaded = 1

let s:funcloaded = 1
" Wrap: 修饰总函数，用于 mapping 调用 " {{{1
" 参数：prefix、postfix：前缀后缀；  mode:：指示映射模式
function! Wrap#Wrap(prefix, postfix, mode) range " {{{
    if a:mode ==# "n"
        " normal mode mapping
        call s:DewrapOnline(a:prefix, a:postfix)
    elseif a:mode ==# "v"
        " visual mode mapping
        let vmode = visualmode()
        if vmode ==# "v"
            " charwise
            call s:WrapInline(a:prefix, a:postfix)
        elseif vmode ==# "V"
            " linewise
            '<,'>call s:DewrapOnline(a:prefix, a:postfix)
        elseif vmode ==# ""
            " blockwise
            call s:WrapBwline(a:prefix, a:postfix)
        endif
    elseif a:mode ==# "V"
        " 另一种修饰方式要求，只限于 linewise
        if visualmode() ==# "V"
            call s:WrapOutline(a:prefix, a:postfix)
        endif
    elseif a:mode ==# "i"
        call s:WrapInsert(a:prefix, a:postfix)
    endif
endfunction " }}}

" WrapOnline: 以行为单位，在行首尾修饰
function! s:WrapOnline(prefix, postfix) " {{{
    " let nmd = "A" . a:postfix . "\<ESC>I" . a:prefix . "\<ESC>"
    " execute "normal" . " " . nmd
    let str = matchlist(getline('.'), '^\(\s*\)\(.*\)$')
    call setline(".", str[1] . a:prefix . str[2] . a:postfix)
endfunction " }}}

" DewrapOnline: 切换取消行修饰（切换功能只写这一个，其他选择方式麻烦）
function! s:DewrapOnline(prefix, postfix) " {{{
    let line = getline(".")
    let exp = '^\(\s*\)' . a:prefix . '\(.*\)' . a:postfix . '$'
    if line =~ exp
        call setline(".", substitute(line, exp, '\1\2', ''))
    else
        call s:WrapOnline(a:prefix, a:postfix)
    endif "
endfunction "DewrapOnline }}}

" WrapInline: 行内选区修饰
function! s:WrapInline(prefix, postfix) " {{{
    let cols = col("'<")
    let cole = col("'>")
    if &selection == "exclusive"
        let cole -= 1
    endif
    " charwise 选择可能跨行，分别插入postfix与prefix
    let line = getline("'>")
    " 存在多字节问题，exclusive 选择时能正确wrap中文
    " inclusive选择时 cole+2才正确（假设双字节）
    if &selection == "inclusive" && char2nr(line[cole-1]) > 128
        let cole +=2
    endif "
    let leftstr = strpart(line, 0, cole)
    let rightstr = strpart(line, cole)
    call setline("'>", leftstr . a:postfix . rightstr)

    let line = getline("'<")
    let leftstr = strpart(line, 0, cols-1)
    let rightstr = strpart(line, cols-1)
    call setline("'<", leftstr . a:prefix . rightstr)

    return
endfunction " }}}

" WrapBwline: <C-V> blockwise 选区修饰
function! s:WrapBwline(prefix, postfix) " {{{
    " let nmd = "\<ESC>gvA" . a:postfix . "\<ESC>gvI" . a:prefix . "\<ESC>"
    " execute "normal" . " " . nmd
    let cols = col("'<")
    let cole = col("'>")
    if &selection == "exclusive"
        let cole -= 1
    endif
    if cols > cole
        let temp = cols | let cols = cole | let cole = temp
    endif "
    " 对每一行进行字符串提取剪接操作
    let coleconst = cole
    for i in range(line("'<"), line("'>"))
        let line = getline(i)
        if &selection == "inclusive" && char2nr(line[coleconst-1]) > 128
            let cole = coleconst + 2
        else
            let cole = coleconst
        endif "
        let leftstr = strpart(line, 0, cols-1)
        let midlestr = strpart(line, cols-1, cole-cols+1)
        let rightstr = strpart(line, cole)
        call setline(i, leftstr . a:prefix . midlestr . a:postfix . rightstr)
    endfor "
endfunction " }}}

" WrapBwline: linewise 另一种修饰方式，在选区的上下行修饰
function! s:WrapOutline(prefix, postfix) " {{{
    " let nmd = "\<ESC>'>o" . a:postfix . "\<ESC>'<O" . a:prefix . "\<ESC>"
    " execute "normal" . " " . nmd
    call append(line("'>"), a:postfix)
    call append(line("'<")-1, a:prefix)
endfunction " }}}

" WrapInsert: 插入模式
function! s:WrapInsert(prefix, postfix) " {{{
    " let nmd = "\<ESC>a" . a:prefix . a:postfix . "\<ESC>"
    " execute "normal" . " " . nmd
    call setline(getline("."), a:prefix . a:postfix)
    " 将光标前移至 prefix,postfix 之间
    " consider multi-byte character string length
    let postlen = strlen(substitute(a:postfix, ".", "x", "g"))
    if postlen > 0
        if postlen == 1
            normal h
        else
            execute "normal " . postlen . "h"
        endif
    endif
endfunction " }}}
" }}}

" 辅助函数： " {{{1
" 将字符串在指定位置中打断。pos Number-List，断点，有效数字从 1 至 strlen，
" 按左闭右开分串，返回列表，个数比pos多1，下标从0开始
function! Strbreak(str, pos) " {{{
    let p = sort(a:pos, "NumCompare")
    call add(p, strlen(a:str)+1)
    let s = [] | let i = 1
    for j in p
        call add(s, strpart(a:str, i-1, j-i))
        let i = j
    endfor "
    return s
endfunction "Strbreak }}}
" vim sort 默认按字符，自写按数字排序的比较函数
function! NumCompare(n1, n2) " {{{
    let n1 = str2nr(a:n1) | let n2 = str2nr(a:n2)
    return n1 == n2 ? 0 : n1 > n2 ? 1 : -1
endfunction "NumCompare }}}
" 在当前编辑(current buffer)插入一字符串(str)。依例遵循左闭右开（类似大P粘贴）
" 默认在当前光标处，可指定marker或坐标(line,cols)
function! Insertstr(str, ...) " {{{
    if a:0 == 0
        let line = line(".") | let cols = col(".")
    elseif a:0 == 1
        let line = line(a:1) | let cols = col(a:1)
    elseif a:0 == 2
        let line = (a:1 =~ '\d') ? a:1 : line(a:1)
        let cols = (a:2 =~ '\d') ? a:2 : col(a:2)
    else
        echo "function Insertstr() 输入参数过多！"
    endif " a:0 case
    let ls = Strbreak(getline(line), [cols])
    call setline(line, ls[0] . a:str . ls[1])
endfunction "Insertstr }}}
" }}}

" 构造方法: {{{1
" set maps from dictionary
" arguments:
" dict: liks {"rls": [prefix, postfix], ... }
" modes: string,  any combination of "nvi", each corresponding above, "V" is
" excluded as behaviors different
" leader: maybe "<leader>" or other string
" maparg: argument for mapping, such as "<buffer>", allow moer than one,
" please write in one string seprated by space
function! Wrap#BuildWrapMaps(dict, modes, leader, maparg) " {{{
    let rls = ""
    " split modes to individaul characters
    let modelist = split(a:modes, '\zs')
    for rls in keys(a:dict)
        let prefix = get( get(a:dict, rls), 0)
        let postfix = get( get(a:dict, rls), 1)
        for mode in modelist
            let cmd = ""
            " eg. nnoremap <leader>a <ESC>:call Wrap("<a>", "</a>", "n")<CR>
            let cmd = cmd . mode . "noremap " . a:maparg . " " . a:leader . rls . " "
            let cmd = cmd . "\<ESC>:call Wrap('" . prefix . "', '" . postfix . "', '" . mode . "')\<CR>"
            if mode == "i"
                " for insert mode, backto insert mode
                let cmd = cmd . "a"
            endif
            execute cmd
        endfor
    endfor
endfunction " }}}

" 测试脚注：{{{1
" let s:test = 1
if exists("s:debug") && exists("s:test")
    let str = "abcdefghij"
    let pos = [3,6,8]
    echo Strbreak(str,pos)
endif "

finish
================================================================================

