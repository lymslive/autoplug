" Author: lymslive
" Create: 2016-08-13
" Last Modify: 2016-08-13
"
" some helpful function for string operation in vimL

let s:DEBUG = 1

" Data Declaration: {{{1
" Enumeration of motion type
let s:EMotion = {
    \ 'Unknown' : -1,
    \ 'Blank' : 0,
    \ 'Comment' : 1,
    \ 'Function' : 2,
    \ 'LongName' : 3,
    \ 'Operand' : 4,
    \ 'Operator' : 5,
    \ 'FlowJump' : 6,
    \ 'Case' : 7,
    \ 'IfElse' : 8,
    \ 'Delimeter' : 9,
    \ }

" travel search the same character of delimeters
let s:CatchDelimeter = '#{},;'

let s:PairBlocks = ['()', '{}', '[]', '<>', '""', "''"]

" current detected motion type
let s:nMotionType = s:EMotion.Unknown

" the initial cursor position when triggle qcmotion
let s:nStartLine = 0
let s:nStartCol = 0

" the line text and char under cursor
let s:strLine = ''
let s:char = ''

" Public function for normal map
function! qcmotion#func#NormalMove() "{{{1
    call s:CheckMotionType('.')
	" mark the last position
    " call setpos("'`", [0, s:nStartLine, s:nStartCol])
	normal! m`
    call s:DoMoveNext()
    return s:nMotionType
endfunction

" Public function for visual selection map
function! qcmotion#func#VisualMove() " {{{1
    call s:CheckMotionType("'>")

	call cursor(s:nStartLine, s:nStartCol)
    call s:DoMoveNext()

    let l:nEndLine = line('.')
    let l:nEndCol = col('.')
    call setpos("'>", [0, l:nEndLine, l:nEndCol])
    normal! gv
endfunction

" Public function for operator-pending map
function! qcmotion#func#OpendMove() "{{{1
    call s:CheckMotionType('.')
    call s:DoSelectOpend()
    return s:nMotionType
endfunction

function! s:CheckMotionType(pos) "{{{1
    let s:nStartLine = line(a:pos)
    let s:nStartCol = col(a:pos)
    let s:strLine = getline(a:pos)
    let s:char = strpart(s:strLine, s:nStartCol-1, 1)
    let s:nMotionType = s:EMotion.Unknown

    let l:word = expand('<cword>')

    if match(s:strLine, '^\s*$') == 0
        call s:SetMotionType("Blank")

    elseif s:IsInComment()
        call s:SetMotionType("Comment")
        
    elseif s:IsCatchedDelemter()
        call s:SetMotionType("Delimeter")

    elseif s:nStartCol == col('$') -1
        call s:SetMotionType("FlowJump")

    elseif s:nStartCol == 1
        call s:SetMotionType("Function")

    elseif s:NotOnWord()
        call s:SetMotionType("Operator")

    else
        if s:OnKeyword(['break', 'continue', 'return'])
            call s:SetMotionType("FlowJump")
        elseif s:OnKeyword(['case', 'switch'])
            call s:SetMotionType("Case")
        elseif s:OnKeyword(['if', 'else'])
            call s:SetMotionType("IfElse")
        elseif s:OnMiddleWord()
            call s:SetMotionType("LongName")
        else
            call s:SetMotionType("Operand")
        endif
    endif
endfunction

" set motion type if not set already
function! s:SetMotionType(type) "{{{1
    if s:nMotionType == s:EMotion.Unknown
        let s:nMotionType = s:EMotion[a:type]
        if s:DEBUG > 0
            echo "set motion type: " . a:type
        endif
    endif
endfunction

" cursor is not on any indentifier
function! s:NotOnWord() "{{{1
    let l:char = strpart(s:strLine, s:nStartCol-1, 1)
    if s:IsIndentChar(l:char)
        return 0
    else
        return 1
    endif
endfunction

" check if cursor on any keyword
" >words is a list of ward
function! s:OnKeyword(words) "{{{1
    for l:word in a:words
        let l:index = match(s:strLine, '\<' . l:word . '\>')
        if l:index == -1
            continue
        endif

        let l:index += 1
        if s:nStartCol >= l:index && s:nStartCol <= l:index + strlen(l:word)
            return 1
        endif
    endfor
    return 0
endfunction

function! s:OnMiddleWord() "{{{1
    let l:char = strpart(s:strLine, s:nStartCol-1, 1)
    if s:IsIndentChar(l:char) == 0
        return 0
    endif
    let l:prevchar = strpart(s:strLine, s:nStartCol-2, 1)
    if s:IsIndentChar(l:prevchar) == 0
        return 0
    endif
    let l:postchar = strpart(s:strLine, s:nStartCol, 1)
    if s:IsIndentChar(l:postchar) == 0
        return 0
    endif
    return 1
endfunction

function! s:IsIndentChar(char) "{{{1
    if match(a:char, '[a-zA-Z0-9_]') == -1
        return 0
    else
        return 1
    end
endfunction

" cursor is comment area
function! s:IsInComment() "{{{1
    " commemt after //
    let l:index = match(s:strLine, '//')
    if  l:index != -1 && l:index <= s:nStartCol -1
        return 1
    endif

    " inline /* */
    let l:index = match(s:strLine, '/\*')
    if l:index != -1 && l:index <= s:nStartCol -1
        let l:cend = matchend(s:strLine, '\*/')
        if l:cend == -1 || l:cend >= s:nStartCol
            return 1
        endif
    endif

    " /* block, between line leading *
    let l:index = match(s:strLine, '^\s\?\*')
    if l:index != -1
        return 1
    endif

    return 0
endfunction

" check if the char under cursor in any of interest symbol char
function! s:IsCatchedDelemter() "{{{1
    for l:char in split(s:CatchDelimeter, '\zs')
        if l:char == s:char
            return 1
        endif
    endfor
    return 0
endfunction

" move cusor according motion type
function! s:DoMoveNext() "{{{1
    if s:nMotionType == s:EMotion.Blank
        call search('^\s*$')

    elseif s:nMotionType == s:EMotion.Comment
        call search('/[/*]', 'e')

    elseif s:nMotionType == s:EMotion.Function
        call search('^[a-zA-Z_].*\w\+\s*(.*)')

    elseif s:nMotionType == s:EMotion.LongName
        call s:MoveInLongName()

    elseif s:nMotionType == s:EMotion.Operand
        normal! e
        call search('\w')

    elseif s:nMotionType == s:EMotion.Operator
        call search('\w')
        call search('[^a-zA-Z_ ]')

    elseif s:nMotionType == s:EMotion.FlowJump
        call search('\<break\>\|\<return\>\|\<continue\>')

    elseif s:nMotionType == s:EMotion.Case
        call search('\<case\>\|\<default\>')

    elseif s:nMotionType == s:EMotion.IfElse
        call search('\<if\>\|\<else\>')

    elseif s:nMotionType == s:EMotion.Delimeter
        call search(s:char)

    endif
endfunction

" long C Indentifier name such as:
" aaaa_bbbb_cccc AAA_BBB_CCC  or
" AaaaBbbbCcc
function! s:MoveInLongName() "{{{1
    let [l:line, l:col] = searchpos('_', 'nc', s:nStartLine)
    if l:col != 0 && l:line == s:nStartLine
        call cursor(l:line, l:col+1)
    elseif search('[A-Z]', '', s:nStartLine)
    else
        normal! e
    endif
endfunction

" select operator range according motion type
function! s:DoSelectOpend() "{{{1
    if s:TrySelectPair() == 1
        return 1

    elseif s:TryPartialSetence() == 1
        return 1

    elseif s:nMotionType == s:EMotion.Blank
        call search('^\s*$')

    elseif s:nMotionType == s:EMotion.Comment
        call s:SelectComment()

    elseif s:nMotionType == s:EMotion.Function
        " select the function name
        normal! f(hviw

    elseif s:nMotionType == s:EMotion.LongName
        call s:SelectPartialName()

    elseif s:nMotionType == s:EMotion.Operand
        " simple select a word
        normal! viw

    elseif s:nMotionType == s:EMotion.Operator
        " donot want do anything
        return 0

    elseif s:nMotionType == s:EMotion.FlowJump
        " simple select a word
        normal! viw

    elseif s:nMotionType == s:EMotion.Case
        " select the label word after :
        call search(':')
        normal! hviw

    elseif s:nMotionType == s:EMotion.IfElse
        " select the if condition in ()
        if match(s:strLine, '\<if\>') != -1
            normal! f(vi(
        endif

    elseif s:nMotionType == s:EMotion.Delimeter
        " donot want do anything
        return 0

    endif
endfunction

" when curson is just on the pair character such as(), select with 'a'
" when is just one character shift inner, select with 'i' block
" that is 'va(' or 'vi(' ect
" see predefined variable s:PariBlocks
function! s:TrySelectPair() "{{{1
    for l:pair in s:PairBlocks
        let l:left = strpart(l:pair, 0, 1)
        let l:right = strpart(l:pair, 1, 1)
        if s:char == l:left || s:char == l:right
            execut 'normal! va' . s:char
            return 1
        elseif s:GetCharFromCursor(-1) == l:left
            execut 'normal! vi' . l:left
            return 1
        elseif s:GetCharFromCursor(1) == l:right
            execut 'normal! vi' . l:right
            return 1
        endif
    endfor
    return 0
endfunction

" operate on part of long name, separated by _ or capital character
function! s:SelectPartialName() "{{{1
    let [l:num, l:wordLeft] = searchpos('\w\+', 'nb', s:nStartLine)
    let [l:num, l:wordRight] = searchpos('\w\+', 'ne', s:nStartLine)
    let l:word = expand('<cword>')

    if match(l:word, '_') != -1
        let [l:num, l:partLeft] = searchpos('_', 'nb', s:nStartLine)
        let [l:num, l:partRight] = searchpos('_', 'nc', s:nStartLine)
        if l:partLeft == 0 || l:partLeft < l:wordLeft
            let l:partLeft = l:wordLeft
        else
            let l:partLeft += 1
        endif
        if l:partRight == 0 || l:partRight > l:wordRight
            let l:partRight = l:wordRight
        else
            let l:partRight -= 1
        endif
        call cursor([l:num, l:partLeft])
        let l:len = l:partRight - l:partLeft
        execute 'normal! v' . l:len . 'l'

    else
        let [l:num, l:partLeft] = searchpos('[A-Z]', 'ncb', s:nStartLine)
        let [l:num, l:partRight] = searchpos('[A-Z]', 'n', s:nStartLine)
        if l:partLeft == 0 || l:partLeft < l:wordLeft
            let l:partLeft = l:wordLeft
        endif
        if l:partRight == 0 || l:partRight > l:wordRight
            let l:partRight = l:wordRight
        else
            let l:partRight -= 1
        endif
        call cursor([l:num, l:partLeft])
        let l:len = l:partRight - l:partLeft
        execute 'normal! v' . l:len . 'l'
    endif
endfunction

" when on comma ',' select the previous item
" when next on ',' select the next item, such as function parameter
" do nearly the same thing with semicolon ';'
function! s:TryPartialSetence() "{{{1
    if s:char == ',' || s:char == ';'
        " search backward
        let [l:num, l:partLeft] = searchpos('[(,;]', 'nb', s:nStartLine)
        if l:partLeft
            " goto last ( or , character
            call cursor(l:num, l:partLeft)
            "skill space
            call search('\S')
            execute 'normal! vt' . s:char
        else
            execute 'normal! ^vt' . s:char
        endif
        return 1

    else
        let l:left = s:GetCharFromCursor(-1)
        if l:left == ',' || l:left == ';'
            " skip space and search forward , or )
            call search('\S', 'c')
            let [l:num, l:partRight] = searchpos('[),;]', 'n', s:nStartLine)
            if l:partRight
                let l:len = l:partRight - col('.') -1
                execute 'normal! v' . l:len .'l'
            else
                normal! v$h
            endif
            return 1
        endif
    endif

    return 0
endfunction

" operate on comment block
function! s:SelectComment() "{{{1
    if match(s:strLine, '//') != -1
        call search('//', 'b')
        if s:char != '/'
            " only select tailing text without //
            normal! wv$h
        else
            " also select //
            normal! v$h
        endif
    else
        " comment block /**/
        call search('/\*', 'cb')
        if s:char != '/' && s:char != '*'
            " A bug: when */ is at beginning of line,
            " h cannot move left any more
            normal! wv/\*\/h
        else
            normal! v/\*\/l
        endif
    endif
endfunction

" return a character relative the cursor shift position
" or empty string when beyond the ends
function! s:GetCharFromCursor(pos) "{{{1
    let l:index = s:nStartCol -1 + a:pos
    return strpart(s:strLine, index, 1)
endfunction

echo "qcmotion plug loaded"
