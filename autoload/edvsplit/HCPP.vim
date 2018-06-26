" File: HCPP.vim
" Author: lymslive
" Description: concurrently edit .h and .cpp in tow windows
" Last Modified: 2017-08-11

let s:FileType_Header = 1
let s:FileType_Source = 2
let s:CurrentFileType = 0
let s:FileName = ''
let s:ClassName = ''

" regexp to match a function line
" let s:FunctionPattern = '\(\w\+\)\s\+\([A-Za-z_0-9:]\+\)\s*(\(.*\))'
let s:FunctionPattern = '\(\w\+\)[ *]\+\([A-Za-z_0-9:]\+\)\s*(\(.*\))'
let s:dFunction = {'Return':1, 'LongName':2, 'Parameter':3}

let s:MemberPattern = '\(\w\+\)\s\+\(\w\+\)'
let s:MemberName = ''

function! edvsplit#HCPP#SwitchFunctionDef() "{{{1
    let s:CurrentFileType = s:DetectFileType()
	" parse function infor
	let l:ret = s:FindFunctionName()
	if l:ret == 0
		echo 'not function line'
		return 0
		" call s:DefaultEnter()
	endif

    if s:CurrentFileType == s:FileType_Header
        call s:GotoDefinitionFromHPP()
    elseif s:CurrentFileType == s:FileType_Source
        call s:GotoDeclarationFormCPP()
    else
        echoerr 'not c lang file type'
		return 0
    endif
	return 1
endfunction

function! s:DetectFileType() "{{{1
    let l:filename = bufname('%')
    let s:FileName = fnamemodify(l:filename, ':t:r')
    let l:extension = fnamemodify(l:filename, ':e')
    let l:extension = tolower(l:extension)
    if match(l:extension, 'h\|hpp') != -1
        return s:FileType_Header
    elseif match(l:extension, 'c\|cpp') != -1
        return s:FileType_Source
    else
        return 0
    endif
endfunction

" Triggled when cursor in .h header file
function! s:GotoDefinitionFromHPP() "{{{1
    " search override function in current file
	normal! $
    let l:nextoverride = search('\<' . s:dFunction.LongName . '\>', 'W')

    " add ClassName:: the search in the other cpp file
    if l:nextoverride == 0
        let s:ClassName = s:FindClassName()
        if len(s:ClassName) > 0
            let l:fullname = s:ClassName . '::' . s:dFunction.LongName
        else
            let l:fullname = s:dFunction.LongName
        endif
        call s:JumpToAnotherFile(s:FileType_Source)
        call search('\<' . l:fullname . '\>', 'w')
    endif
endfunction

" Triggled when cursor in .cpp source file
function! s:GotoDeclarationFormCPP() "{{{1
    " search override function in current file
	normal! $
    let l:nextoverride = search('\<' . s:dFunction.LongName . '\>', 'W')

    " remove ClassName:: the search in the other cpp file
    if l:nextoverride == 0
        let l:partname = s:SplitFunctionName(s:dFunction.LongName)
        let l:shortname = l:partname[1]
        call s:JumpToAnotherFile(s:FileType_Header)
        call search('\<' . l:shortname . '\>', 'w')
    endif
endfunction

" parser the current line to get function information
" return true when cursor is really on function line
function! s:FindFunctionName() "{{{1
    let l:linestr = getline('.')
    let l:list = matchlist(l:linestr, s:FunctionPattern)
    if len(l:list) > 0
        let s:dFunction.Return = l:list[1]
        let s:dFunction.LongName = l:list[2]
        let s:dFunction.Parameter = l:list[3]
        return 1
    else
        return 0
    endif
endfunction

" spit a long function to tow part ClassName::MethodName
" return two-element list, the first ClassName may empty
function! s:SplitFunctionName(longname) "{{{1
    if match(a:longname, '::')
        let l:partname = split(a:longname, '::')
        let l:name = remove(l:partname, -1)
        let l:scope = join(l:partname, '::')
        return [l:scope, l:name]
    else
        return ['', a:longname]
    endif
endfunction

" search back to find the class name
function! s:FindClassName() "{{{1
    let l:classline = search('^\s*class', 'nb')
    if l:classline == 0
        return ''
    endif

    let l:linestr = getline(l:classline)
    let l:list = matchlist(l:linestr, '^\s*class\s\+\(\w\+\)')
    if len(l:list)
        return l:list[1]
    else
        return ''
    endif
endfunction

" jump to another window, asume it is editing alt file
function! s:JumpToAnotherFile(target_ft) " {{{1
	let l:wincnt = winnr('$')
	if l:wincnt == 2
		wincmd w
		" if the other window is not editing alt file
		" jump back the origin window and edit alt file in palce
		let l:anothername = expand('%:t:r')
		if l:anothername !=# s:FileName
			wincmd p
			call edvsplit#AB#EditAltFile(expand("%:p"))
		endif
	else
        call edvsplit#ED#EditAltInAnother()
	endif
endfunction

function! s:DefaultEnter() " {{{1
	 " . expand('<cword>')
	execute 'normal! :'
endfunction
