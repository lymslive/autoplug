" Author: lymslive
" Create: 2016-02-29
" Last Modify: 2017-08-11
"

" Load buffer from the other window in to current window,
" make the two windows hold the same buffer.
" Or if provided a file name as argument, find that file and edit it,
" the argument canbe in the pattern "filename:lineno"
function! edvsplit#ED#EditAnother(...) " {{{1
	let WinCnt = winnr('$')
	if WinCnt == 1
		vsplit
	else
		if a:0 == 0
			let idx = edvsplit#ED#FindAnother()
			execute 'buffer ' . winbufnr(idx)
		else
			call edvsplit#ED#Findfl(a:1)
		endif
	endif
endfunction

" Much lick the previous function edvsplit#ED#EditAnother
" Load current buffer into the other window too, make the two windows hold the same buffer.
function! edvsplit#ED#EditInAnother() " {{{1
	let WinCnt = winnr('$')
	let cdx = winbufnr(0)
	if WinCnt == 1
		vsplit
	else
		let cdx = winbufnr(0)
		let idx = edvsplit#ED#FindAnother()
		execute idx . 'wincmd w'
		if a:0 == 0
			execute 'buffer ' . cdx
		else
			call edvsplit#ED#Findfl(a:1)
		endif
	endif
endfunction

" Jumpto tag, but in the other window,
function! edvsplit#ED#TagInAnother(tagname) " {{{1
	let WinCnt = winnr('$')
	if WinCnt == 1
		execute 'vertical stag ' . a:tagname
		" wincmd p
	else
		let idx = edvsplit#ED#FindAnother()
		execute idx . 'wincmd w'
		execute 'tag ' . a:tagname
		" wincmd p
	endif
endfunction

" Pop tag, but in the other window,
function! edvsplit#ED#PopInAnother() " {{{1
	let WinCnt = winnr('$')
	if WinCnt == 1
		vsplit
		pop
		" wincmd p
	else
		let idx = FindAnother()
		execute idx . 'wincmd w'
		pop
		" wincmd p
	endif
endfunction

" Find the other main edit window
" with the max area (height * width)
function! edvsplit#ED#FindAnother() " {{{1
	let area = 0
	let max = 0
	let idx = 0
	let cur = winnr()
	for i in range(1, winnr('$'))
		if i == cur
			continue
		endif
		let area = winwidth(i) * winheight(i)
		if area > max
			let max = area
			let idx = i
		endif
	endfor
	return idx
endfunction

" Execute any command in the other window
function! edvsplit#ED#CmdInAnother(...) " {{{1
	if a:0 == 0
		call edvsplit#ED#EditInAnother()
	else
		let cmd = ""
		for i in range(1, a:0)
			let cmd = cmd . a:{i} . " "
		endfor
		let idx = edvsplit#ED#FindAnother()
		execute idx . 'wincmd w'
		execute cmd
		wincmd p
	endif
endfunction

" copy the current line or visualed text to the another window buff
function! edvsplit#ED#CopyToAnother(mode) " {{{1
	if winnr('$') == 1
		echoerr "You need split another window"
		return
	endif
	if a:mode ==? 'v'
		normal! gvy
	else
		normal! yy
	endif
	let idx = edvsplit#ED#FindAnother()
	execute idx . 'wincmd w'
	normal! p
	wincmd p
endfunction

" move the current line or visualed text to the another window buff
function! edvsplit#ED#MoveToAnother(mode) " {{{1
	if winnr('$') == 1
		echoerr "You need split another window"
		return
	endif
	if a:mode ==? 'v'
		normal! gvd
	else
		normal! dd
	endif
	let idx = edvsplit#ED#FindAnother()
	execute idx . 'wincmd w'
	normal! p
	wincmd p
endfunction

" Find a file and jump to specific lineno
" the input arg string is in patter 'file:line' as from error log
function! edvsplit#ED#Findfl(arg) " {{{1
	let target = split(a:arg, ":")
	let narg = len(target)
	if narg < 1 || narg > 2
		echoerr "expect argument: file:lineno"
		return
	endif
	let file = target[0]
	if narg == 2
		let line = target[1]
		execute 'find ' . '+' . line . ' ' . file
	else
		execute 'find ' . file
	endif
endfunction

" :EA
" edit the alt-file of which in the other window
function! edvsplit#ED#EditAltOfAnother(...) " {{{1
	if a:0 > 0
		let extspec = a:1
	else
		let extspec = ""
	endif
	let WinCnt = winnr('$')
	if WinCnt == 1
		vsplit
	endif
	let idx = edvsplit#ED#FindAnother()
	let file = bufname(winbufnr(idx))
	let altfile = AB#FindAltFile(file, extspec)
	" echomsg altfile
	if strlen(altfile) > 0
		execute "edit ". altfile
	else
		echoerr "can't find alternative file"
	endif
endfunction

" :DA
" jump to the another window to edit the alt-file of current file
function! edvsplit#ED#EditAltInAnother(...) " {{{1
	if a:0 > 0
		let extspec = a:1
	else
		let extspec = ""
	endif
	let file = expand("%:p")
	let WinCnt = winnr('$')
	if WinCnt == 1
		vsplit
	endif
	let idx = edvsplit#ED#FindAnother()
	execute idx . 'wincmd w'
	let altfile = AB#FindAltFile(file, extspec)
	" echomsg altfile
	if strlen(altfile) > 0
		execute "edit ". altfile
	else
		echoerr "can't find alternative file"
	endif
endfunction

" :ED file [alt-file]
" edit two files in tow windows, if only one argument, find it's alt-file
function! edvsplit#ED#EditInDouble(file, ...) " {{{1
	if a:0 <= 0
		let altfile = AB#FindAltFile(a:file)
	else
		let altfile = a:1
	endif
	if winnr('$') == 1
		vsplit
	endif
	execute "edit ". a:file
	let idx = edvsplit#ED#FindAnother()
	execute idx . 'wincmd w'
	if strlen(altfile) > 0
		execute "edit ". altfile
	else
		echoerr "can't find alternative file"
	endif
endfunction
