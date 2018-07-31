" Spacebar.vim
" First Create: 2011-10-27
" Last Modify: 2017-08
" lymslive (403708621@qq.com)

let s:debug = 1
if !exists("s:debug") && exists("s:loaded")
    finish
endif

let g:SpaceModes = ['Mix', 'View', 'Search', 'Fold', 'Edit', 'Cpp']
let g:SpaceModeDefaul = 'Mix'
let b:SpaceModeCurrent = ''
" let g:SpaceSmartEnable = 1

" Space Mode Maps: "{{{
" Maps should be local.

" Default Mix Mode:
function! s:SpaceAsMix() " {{{
    nnoremap <buffer> <Space>   @=(foldlevel(line('.'))>0) ? "za" : "}"<CR>
    nnoremap <buffer> <S-Space> @=(foldlevel(line('.'))>0) ? (foldclosed(line('.'))>0? "zr":"zm") : "{"<CR>
    vnoremap <buffer> <Space>   y/<C-R>=(visualmode() != 'v')? "" : getreg()<CR>
    vnoremap <buffer> <S-Space> y?<C-R>=(visualmode() != 'v')? "" : getreg()<CR>
    onoremap <buffer> <Space>   }
    onoremap <buffer> <S-Space> {
endfunction "SpaceAsMix }}}

" Default Mix Mode:
function! s:SpaceAsCpp() " {{{
    nnoremap <buffer> <Space>   :call <SID>BounceInline()<CR>
    nnoremap <buffer> <S-Space> :call <SID>SeeFunctionHeader()<CR>
    vnoremap <buffer> <Space>   y/<C-R>=(visualmode() != 'v')? "" : getreg()<CR>
    vnoremap <buffer> <S-Space> y?<C-R>=(visualmode() != 'v')? "" : getreg()<CR>
    onoremap <buffer> <Space>   }
    onoremap <buffer> <S-Space> {
endfunction "SpaceAsMix }}}

" View Mode:
" let <Space>/<S-Space> do <PageDown>/<PageUp>
function! s:SpaceAsView() " {{{
    nnoremap <buffer> <Space>   <PageDown>
    nnoremap <buffer> <S-Space> <PageUp>
    vnoremap <buffer> <Space>   <PageDown>
    vnoremap <buffer> <S-Space> <PageUp>
    onoremap <buffer> <Space>   }
    onoremap <buffer> <S-Space> {
endfunction "SpaceAsView }}}

" Search Mode:
" let <Space> do "/" searching and <S-Space> do "?" search.
" In char-visual mode searching the selected text.
function! s:SpaceAsSearch() " {{{
    nnoremap <buffer> <Space>   /
    nnoremap <buffer> <S-Space> ?
    vnoremap <buffer> <Space>   y/<C-R>=(visualmode() != 'v')? "" : getreg()<CR>
    vnoremap <buffer> <S-Space> ?/<C-R>=(visualmode() != 'v')? "" : getreg()<CR>
    onoremap <buffer> <Space>   /<C-R>/<CR>
    onoremap <buffer> <S-Space> ?<C-R>/<CR>
endfunction "SpaceAsSearch }}}

" Folde Mode:
" let <Space> toggles the fold; <S-Space> toggles all the fold.
" In line-visual mode will create/delete fold for the seleted lines.
function! s:SpaceAsFold() " {{{
    nnoremap <buffer> <Space>   @=(foldlevel(line('.'))>0) ? "za" : "zj"<CR>
    nnoremap <buffer> <S-Space> @=(foldlevel(line('.'))>0) ? (foldclosed(line('.'))>0? "zr":"zm") : "zk"<CR>
    vnoremap <buffer> <Space>   @=(visualmode() == 'V')? "zf" : ""<CR>
    vnoremap <buffer> <S-Space> @=(visualmode() == 'V')? "zd" : ""<CR>
    onoremap <buffer> <Space>   ]z
    onoremap <buffer> <S-Space> [z
endfunction "SpaceAsFold }}}

" Edit Mode:
" Deal with blank line when the cursor is at the start of line, or otherwise
" deal with white space within the current line. But if the selection has
" expaned across a newline, always deal with blank lines.
" Generally, <Space> adds a blank line(or space) below the cursor, <S-Space>
" work oppositely. Successive blank or space is reduced. In visual mode,
" <Space> add blank/space while <S-Space> remove them.
function! s:SpaceAsEdit() " {{{
    nnoremap <buffer> <Space>   :call <SID><C-R>=(col(".")<=1)? "EditBlank()" : "EditSpace()"<CR><CR>
    nnoremap <buffer> <S-Space> :call <SID><C-R>=(col(".")<=1)? "EditBlank('S')" : "EditSpace('S')"<CR><CR>
    vnoremap <buffer> <Space>   :call <SID><C-R>=(col(".")<=1)? "EditBlank()" : "EditSpace('', 'v')"<CR><CR>
    vnoremap <buffer> <S-Space> :call <SID><C-R>=(col(".")<=1)? "EditBlank('S')" : "EditSpace('S', 'v')"<CR><CR>
    onoremap <buffer> <Space>   }
    onoremap <buffer> <S-Space> {
endfunction "SpaceAsEdit }}}

" SpaceCmdFirst:
" Cancle search cmd when input <Space> at the very beginning cmdline.
function! s:SpaceCmdFirst() " {{{
    let type = getcmdtype()
    let map = "\<Space>"
    if type == "/" || type == "?"
        if getcmdpos() == 1
            let map = "\<C-C>"
        endif
    endif
    return map
endfunction "SpaceCmdFirst }}}
" Two accident <Space>s have no effect. However, this doesn't work!
" cnoremap <Space> <C-R>=<SID>SpaceCmdFirst()<CR>
" cnoremap <S-Space> <Space>
" End of Space Mode Maps. "}}}

" Space Mode Select: "{{{
command! -narg=? -bar -complete=custom,s:SpaceComplete Space call spacebar#func#SpaceModeSelect(<f-args>)
" Argument: A word indicate the space behavior mode, availabe value is list in
" g:spaceModes. If no argument supplied, cycled to next mode. Addition to
" that, "Smart" and "NoSmart" is also accept to triggle smart space maps.
" Custom complete in command is appleneted, and abbreviated is accpeted too.
function! spacebar#func#SpaceModeSelect(...) " {{{
    if a:0 < 1
        let mode = ""
    else
        let mode = a:1
    endif

    if mode == ""
        call s:SpaceModeNext()
    elseif mode ==? "Smart"
        call s:SpaceSmartMap()
    elseif mode ==? "NoSmart"
        call s:SpaceNoSmartMap()
    elseif mode =~? "V"
        let b:SpaceModeCurrent = "View"
        call s:SpaceModeUpdate()
    elseif mode =~? "S"
        let b:SpaceModeCurrent = "Search"
        call s:SpaceModeUpdate()
    elseif mode =~? "F"
        let b:SpaceModeCurrent = "Fold"
        call s:SpaceModeUpdate()
    elseif mode =~? "E"
        let b:SpaceModeCurrent = "Edit"
        call s:SpaceModeUpdate()
    elseif mode =~? "M"
        let b:SpaceModeCurrent = "Mix"
        call s:SpaceModeUpdate()
    elseif mode =~? "C"
        let b:SpaceModeCurrent = "Cpp"
        call s:SpaceModeUpdate()
    else
        echo "Can't understant the argumnet: " . mode
    endif
endfunction "SpaceModeCycle }}}
function! s:SpaceModeNext() " {{{
    if !exists("b:SpaceModeCurrent")
        let b:SpaceModeCurrent = g:SpaceModeDefaul
    endif
    let ind = index(g:SpaceModes, b:SpaceModeCurrent)
    if ind == len(g:SpaceModes) - 1
        let ind = 0
    else
        let ind += 1
    end
    let b:SpaceModeCurrent = g:SpaceModes[ind]
    call s:SpaceModeUpdate()
endfunction "SpaceModeNext }}}
function! s:SpaceModeUpdate() " {{{
    if b:SpaceModeCurrent ==? "View"
        call s:SpaceAsView()
    elseif b:SpaceModeCurrent ==? "Search"
        call s:SpaceAsSearch()
    elseif b:SpaceModeCurrent ==? "Fold"
        call s:SpaceAsFold()
    elseif b:SpaceModeCurrent ==? "Edit"
        call s:SpaceAsEdit()
    elseif b:SpaceModeCurrent ==? "Mix"
        call s:SpaceAsMix()
    elseif b:SpaceModeCurrent ==? "Cpp"
        call s:SpaceAsCpp()
    endif
    echo "Now Space Behavior Mode is:" . b:SpaceModeCurrent
endfunction "SpaceModeUpdate }}}
function! s:SpaceComplete(A, L, P) " {{{
    let clist = g:SpaceModes
    call add(clist, "Smart")
    call add(clist, "NoSmart")
    return join(clist, "\n")
endfunction "SpaceComplete }}}

" Smart Space Maps:
" Make some maps, automticlly switch space mode.
function! s:SpaceSmartMap() " {{{
    nnoremap <C-F> :Space View<CR><C-F>
    nnoremap <C-B> :Space View<CR><C-B>
    nnoremap / :Space Search<CR>/
    nnoremap ? :Space Search<CR>?
    nnoremap z<Space> :Space Fold<CR>za
    nnoremap <bar><Space> :Space Edit<CR>
endfunction "SpaceTriggerMap }}}
function! s:SpaceNoSmartMap() " {{{
    nunmap <C-F>
    nunmap <C-B>
    nunmap /
    nunmap ?
    nunmap z<Space>
    nunmap <bar><Space>
endfunction "SpaceNoSmartMap }}}

" Initial:
if exists("g:SpaceSmartEnable") && g:SpaceSmartEnable == 1
    call s:SpaceSmartMap()
endif
" }}}

" EditBlank: "{{{
" Overall function for map to deal with blank lines.
" nnoremap <Space>/<S-Space>: Test whether the current line(and the one just
" below/above it) is blank line or not. If there are tow or more successive
" blank lines, reducu to one blank line; if there is only one blank line,
" remove it; and if there is none, add a blank line below/above the current.
" vnoremap <Space>: Insert a blank line between every two nonblank lines.
" vnoremap <S-Space>: Reduce successive blank lines to only one between tow
" nonblank lines, and if this fails, try to remove the sole blank line between
" tow nonblank lines. v-maps work when in line-wise("V") visual mode. 
" Note: "blank line" contains nothing, a line only has space isn't blank.
" Optional: modified key such as "Shift".
function! s:EditBlank(...) range " {{{
    if a:firstline == a:lastline
        let mode = "n"
    else
        let mode = "V"
    endif
    if a:0 > 0 && a:1 != ""
        let mkey = a:1
    else
        let mkey = ""
    endif

    if mode == "n"
        if mkey == ""
            " nmap <Space>
            call s:BlankCut(line("."), 1, 1)
        elseif mkey =~? "^S"
            " nmap <S-Space>
            call s:BlankCut(line("."), -1, 1)
        endif " of mkey
    elseif mode == "V"
        if mkey == ""
            " vmap <Space>
            call s:BlankEach(a:firstline, a:lastline)
        elseif mkey =~? "^S"
            " vmap <S-Space>
            call s:BlankOnly(a:firstline, a:lastline, 1)
        endif
    endif " of mode
endfunction "EditBlank}}}

" BlankCut:
" Remove the successive blank line around the current line. If itself is the
" only blank line, just remove it.  If the current line is not blank, try the
" one above or below it, indicated by the optional arg.
" Argument: line. the number of "current" line
" Optional: direction (1/-1). "above" or "below";
"         : toggle (0/1). If ture, will add one blank line when the
"         : above/below line is also non-blank.
" Return: None
function! s:BlankCut(line, ...) " {{{
    let delnum = 0
    let line = a:line

    " current is not blank?
    if getline(line) != ""
        if a:0 >= 1 && (a:1 == 1 || a:1 == -1)
            let line += a:1
        else
            return delnum
        endif
        " current line is still not blank?
        if getline(line) != ""
            if a:0 >= 2 && a:2
                if a:1 == -1
                    call append(line, "")
                else
                    call append(line-1, "")
                endif
            end
            return delnum
        endif
    endif

    " current must blank line now.
    let nnb = nextnonblank(line)
    let pnb = prevnonblank(line)
    call s:BlankOnly(pnb, nnb)
    if nnb - pnb == 2
        execute line . " delete"
        let delnum += 1
        return delnum
    else
        return s:BlankOnly(pnb, nnb)
    endif
endfunction "BlankCut }}}

" BlankOnly:
" Remove successive blank lines, left only one, in the range.
" Argument: first, last. Indicate the range of lines to deal with.
" Optional: recurtion, if nonempty or nonzeor, try to delete all the only blank
" line beteew two non-blank lines, if fails to remvoe any successive blank line.
" Return: the number of deleted blank lines.
function! s:BlankOnly(first, last, ...)"{{{
    let delnum = 0
    let laststr = "Not Blank Line"
    for lnum in range(a:last, a:first, -1)
        let line = getline(lnum)
        if line == "" && laststr == ""
            execute lnum . " delete"
            let delnum += 1
        endif
        let laststr = line
    endfor

    if delnum > 0 || a:0 < 1 || ! a:1
        return delnum
    else
        return s:BlankNone(a:first, a:last)
    end
endfunction "}}}

" BlankNone:
" like BlankOnly(), but delete all blank lines in ther range.
function! s:BlankNone(first, last) "{{{
    let delnum = 0
    for lnum in range(a:last, a:first, -1)
        let line = getline(lnum)
        if line == ""
            execute lnum . " delete"
            let delnum += 1
        endif
    endfor
    return delnum
endfunction "}}}

" BlankEach: 
" Make every non-blank line separated by at least on blank line.
" Argument: first, last. Indicate line range.
" Return: the number of added blank lines.
function! s:BlankEach(first, last) "{{{
    let addnum = 0
    let laststr = "NOT-Blank-Line"
    for lnum in range(a:last, a:first, -1)
    let line = getline(lnum)
    if line != "" && laststr != ""
        call append(lnum, "")
        let addnum += 1
    endif
    let laststr = line
    endfor
endfunction "}}}
" End of EditBlank Block "}}}

" EditSpace: "{{{
" Similar to EditBlank, work within the current line for white space(\s).
" Optional: mkey("[S]fit", ect); mode("n", "v", ect).
" nnoremap <Space>: Add a space after the cursor. But if the cursor is already
" on a space char, reduce the successive space around the cursor to one space.
" nnoremap <S-Space>: Add a space before the cursor. If the cursor is on
" space, then reduce all successive space , and trim tailing space.
" vnoremap <Space>: Just insert a sapce before and after the selection.
" vnoremap <S-Space>: Remove all space in selection.
" Note: when refer to "all space", it include <tab> and started indentation.
" Script Variable: Use to restore the cursor position.
let s:ColPos = 0
function! s:EditSpace(...) range " {{{
    " Switch to EditBlank lines if multy lines seleted.
    if a:0 > 0 && a:1 != ""
        let mkey = a:1
    else
        let mkey = ""
    endif
    if a:firstline != a:lastline
        '<,'> call s:EditBlank(mkey)
        return
    endif
    " Note: buildin mode() can't test v-mode in this case?!
    if a:0 >= 2
        let mode = a:2
    else
        let mode = "n"
    endif

    let newstr = ""
    let linestr = getline(".")
    let curpos = col(".")
    let s:ColPos = curpos
    if mode == "n"
        let newstr = s:SpaceCut(linestr, curpos-1, mkey)
    elseif mode == "v"
        let cols = col("'<")
        let cole = col("'>")
        let s:ColPos = cols
        let newstr = s:SpaceRange(linestr, cols-1, cole-1, mkey)
    endif

    " set new string and reaonable cursor position.
    call setline(".", newstr)
    if s:ColPos == "$"
        let s:ColPos = col("$")
    endif
    call setpos(".", [0, line("."), s:ColPos, 0])
endfunction "EditSpace }}}

" SpaceCut:
" Opational: mkey. Such as "Shift", do work in another way.
function! s:SpaceCut(str, pos, ...) " {{{
    let curchar = strpart(a:str, a:pos, 1)
    if curchar == " " || curchar == "\t"
        let space = 1
    else
        let space = 0
    endif
    if a:0 >= 1
        let mkey = a:1
    else
        let mkey = ""
    endif

    let newstr = a:str
    if space == 0
        " cursor at non-space
        if mkey == ""
            let newstr = s:StringInsert(a:str, " ", a:pos)
        elseif mkey =~? "^S"
            let newstr = s:StringInsert(a:str, " ", a:pos-1)
            let s:ColPos += 1
        endif
    else
        " cursor at space position
        if mkey == ""
            let first = s:NextNonSpace(a:str, a:pos, -1)
            let last = s:NextNonSpace(a:str, a:pos, 1)
            let newstr = s:SpaceOnly(a:str, first, last)
            let s:ColPos = first+1
        elseif mkey =~? "^S"
            let newstr = s:SpaceOnly(a:str)
            let s:ColPos = "$"
        endif
    endif

    return newstr
endfunction "SpaceCut }}}

" StringInsert:
" Insert a sub string (a:sub) to main string (a:main) after postion (a:start).
" Return: The new string.
function! s:StringInsert(main, sub, start) " {{{
    if a:start <= 0
        let new = a:sub . a:main
    elseif a:start >= strlen(a:main)-1
        let new = a:main . a:sub
    else
        let new =  strpart(a:main, 0, a:start+1) . a:sub . strpart(a:main, a:start+1)
    endif
    return new
endfunction "StringInsert }}}

" NextNonSpace:
" Find the next non-sapce character in string.
" Argument: str, search start index, and search direction (1/-1).
" Return: the first found index, note that vim-string index start from 0.
" If not found, index 0 or last index (strlen-1) is returned.
function! s:NextNonSpace(str, start, dir) " {{{
    let ind = a:start
    let char = strpart(a:str, ind, 1)
    while char == " " || char == "\t"
        if ind <= 0 || ind >= strlen(a:str)-1
            break
        endif
        let ind += a:dir
        let char = strpart(a:str, ind, 1)
    endwhile
    return ind
endfunction "NextNonSpace }}}

" SpaceOnly:
" Remove successive space in string part.
" Option: start index and last index of string to work on, default the whole
" string. Tailing space is also remove if string part contains string end.
" Return: a new string copy with modification.
function! s:SpaceOnly(str, ...) " {{{
    let first = 0
    let last = strlen(a:str) - 1
    if a:0 >= 1
        first = a:1
    endif
    if a:0 >= 2
        last = a:2
    endif

    let midstr = strpart(a:str, first, last-first+1)
    let midstr = substitute(midstr, '\(\S\)\s\+', '\1 ', 'g')
    let newstr = strpart(a:str, 0, first) . midstr . strpart(a:str, last+1)
    if last >= strlen(a:str)-1
        let newstr = substitute(newstr, '\s*$', '', 'g')
    endif
    return newstr
endfunction "SpaceOnly }}}

" SpaceRange:
" EditSpace for vmap in char-visual mode. Add s space in two ends or remove
" all space in the seletion (Shift).
" Argument: string and it's first&last index
" Opational: mkey. Such as "Shift", do work in another way.
" Return: The modified new string.
function! s:SpaceRange(str, first, last, ...) " {{{
    let newstr = a:str
    if a:0 >= 1
        let mkey = a:1
    else
        let mkey = ""
    endif

    if mkey == ""
        let newstr = s:StringInsert(a:str, " ", a:last)
        let newstr = s:StringInsert(newstr, " ", a:first-1)
        let s:ColPos += 1
    elseif mkey =~? "^S"
        let midstr = strpart(a:str, a:first, a:last-a:first+1)
        let midstr = substitute(midstr, '\s\+', '', 'g')
        let newstr = strpart(a:str, 0, a:first) . midstr . strpart(a:str, a:last+1)
    endif
    return newstr
endfunction "SpaceRange }}}
" End of EditSpace Block. "}}}

" Cpp Mode: {{{

" Space behaves as ^$ bouncing in line, when not on {} brace
function! s:BounceInline() " {{{
	" 1. open folder
	if foldclosed(line('.'))>0
		normal! za
		return 1
	endif

	let l:linestr = getline('.')
	let l:colindex = col('.') -1

	" 1.5 cursor on blank line
	if match(l:linestr, '^\s*$') != -1
		call s:SeeFunctionHeader()
		return 1
	endif

	" 2. close folder only on {} character
	let l:char = strpart(l:linestr, l:colindex, 1)
	if l:char == '{' || l:char == '}'
		normal! za
		return 1
	endif

	" 3. ^ bounce to beginning when at end of line expcet {
	let l:linelen = len(l:linestr)
	if col('.') >= l:linelen
		normal! ^
		return 1
	else
		let l:endstr = strpart(l:linestr, l:colindex+1)
		if match(l:endstr, '^\s*{\s*$') != -1
			normal! ^
			return 1
		endif
	endif

	" 4. ^ bounce to end of line but before tailing {
	normal! $
	if match(l:linestr, '{\s*$') != -1
		call search('{', 'bc')
		normal! h
		return 1
	endif

	return 0
endfunction "BounceInline }}}

" serach backward a function head line
function! s:SeeFunctionHeader() " {{{
	let l:lastbrace = search('^{', 'bn')
	if l:lastbrace == 0
		return 0
	endif

	" no matter end), in case multiple line function header
	let l:lastline = search('^\w\+\s\+[a-zA-Z0-9_:]\+\s*(.*', 'bn')
	if l:lastline == 0
		return 0
	endif

	let l:linestr = getline(l:lastline)
	echo l:linestr
	return 1
endfunction "SeeFunctionHeader }}}
" }}}
let s:loaded = 1
finish
