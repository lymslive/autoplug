" tabpage.vim
"   functions for using tabpages
" lymslive / 2016-03

let s:debug = 1
if !exists("s:debug") && exists("s:script_loaded")
    finish
endif

" save the tabpage number that is last visited "{{{1
let s:lasttabnr = 1
augroup TabPage
    autocmd!
    autocmd TabLeave * let s:lasttabnr = tabpagenr() 
augroup end

" jumpto the last visited tabpage "{{{1
function! usetabpg#func#jumpalt(...)
    if a:0 > 0 && a:1 > 0
	execute 'tabnext ' . a:1
    else
	execute 'tabnext ' . s:lasttabnr
    endif
endfunction

" Custom Tabline: -- overall definition
function! usetabpg#func#CustTabLine() " {{{1
    " s := &tabline string(which contain many marks) 
    " vs := the output visual string(may used to count the column space) 
    let s = ''
    for i in range(tabpagenr('$'))
        " set the tab page number (for mouse clicks)
        let s .= '%' . (i+1) . 'T'
        " select the highlighting and the label is made by TabLabel()
        if i + 1 == tabpagenr()
            let s .= s:TabLabel(i+1, 'TabLineSel')
        else
            let s .= s:TabLabel(i+1, 'TabLine')
        endif
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%T%#TabLineFill#'
    let s = s:AdjustFill(s)
    " right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let s .= '%=%#TabLine#%999XX'
    endif
    return s
endfunction

" Each Tablabel: called by CustTabLine()
" Content: tabnr, windows count, modified marker, file basename
"          shorten long filename if needed
"          mark help window buffer with .HLP
" Input: n(tabnr) c( match colorgroup)
function! s:TabLabel(n, c) " {{{1
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let buffername = bufname(buflist[winnr-1])
    let filename = fnamemodify(buffername,':t:r')
    let fextion = fnamemodify(buffername,':e')
    " cut too long filename
    let fnmaxlen = 10
    if exists(fnmaxlen) && strlen(filename) >= fnmaxlen
        let filename = filename[0:fnmaxlen-3].'..'
    endif
    " check if there is no name
    if filename == ''
        let filename = 'UnNamed'
    endif
    if getbufvar(buflist[winnr-1], "&filetype") == 'help'
        let fextion = 'HLP' 
    endif "
    if fextion != ""
        let filename .= '.' . fextion
    endif 

    " construct the label as following format:
    " [tabnr^wins] [filename] [|(separator) or +(modified?)] 
    let ret = '%#' . a:c . '#'
    let ret .= a:n 
    let winds = tabpagewinnr(a:n, '$')
    if winds > 1
        let ret .= '^' . winds
    endif "
    let ret .= ' ' . filename
    for i in buflist
        if getbufvar(i, "&modified")
	    let ret .= '%#DiffText#*'
            break
        endif "
    endfor "
    " close this tabpage while as separator
    let ret .= '%#WarningMsg#%' . a:n . 'X|'
    return ret
endfunction "TabLabel

" calculate the real length when the tabline show in the scree
" One argument: tableline code string
" return: Number length in byte
function! s:GetVisulLen(tabcode) " {{{1
    " strip Tab-Marker: %nT, %nX
    let vs = substitute(a:tabcode, '%\d*[T\|X]', '', 'g')
    " strip ColorGroup-Marker: %#...#
    let vs = substitute(vs, '%#.\{-\}#', '', 'g')
    let vs = substitute(vs, '%=', '', 'g')
    return strlen(vs)
endfunction

" Fill rest tabline space with current direcotry 
" and adjust the former Tablabel if too long
" Input the former code-string and return the modified string
function! s:AdjustFill(tabcode) " {{{1
    let colscreen = &columns
    let tc = a:tabcode
    let vlen = s:GetVisulLen(tc)

    " min cwd space: D:\...###X (len=10)
    " the last X is left for close the current tabpage
    if colscreen - vlen < 10
	let tc = s:ShortenCode(tc, colscreen-10)
    endif "

    let cdstr = getcwd()
    let lcdstr = expand('%:p:h')
    if cdstr ==# lcdstr
        let cdstr = '=' . lcdstr
    else
        let cdstr = '%#DiffChange#!' . lcdstr
    endif

    let awidth = colscreen - s:GetVisulLen(tc)
    if strlen(cdstr) <= awidth
        let tc .= cdstr
    else
        let tc .= strpart(cdstr, 0, 3) . '...' . strpart(cdstr, strlen(cdstr)-3, 3)
    endif "
    return tc
endfunction "AdjustFill

" Shorten the tabline code-string within width, return modified string
function! s:ShortenCode(tcode, width) " {{{1
    if s:GetVisulLen(a:tcode) <= a:width
        return a:tcode
    endif
    " Try remove the extention
    let tc = substitute(a:tcode, '\(%\d\+T#.\{-\}#.\{-\}\)\.[^\.%#]', '\1', 'g')
    if s:GetVisulLen(tc) <= a:width
        return tc
    endif "
    " Try limit the filename within 8 characters
    let tc = substitute(tc, '\(%\d\+T%#.\{-}#.\{-\} \)\(.\{0,6}\)[^%#]*', '\1\2..', 'g')
    if s:GetVisulLen(tc) <= a:width
        return tc
    endif "
    " Try limit the filename within 4 characters
    let tc = substitute(tc, '\(%\d\+T%#.\{-}#.\{-\} \)\(.\{0,2}\)[^%#]*', '\1\2..', 'g')
    if s:GetVisulLen(tc) <= a:width
        return tc
    endif "
    " Try no filename at all, only number left
    let tc = substitute(tc, '\(%\d\+T%#.\{-}#.\{-\}\) [^%#]*', '\1', 'g')
    if s:GetVisulLen(tc) <= a:width
        return tc
    endif "
    return tc
endfunction "ShortenCode

let s:script_loaded = 1
finish "{{{1

==============================================================================
tablinecode sample:
%1T%#TablSel#tab1.ext%#WarningMsg#%1X|%2T%#TabLine#tab2.hlp%#WarningMsg#%2X|%3T%#TabLine#tab3%#DiffText#*%#WarningMsg#%3X|%T%#TabLineFill#
\(%\d\+T%#.\{-\}#.\{-\}\)\.[^.%#]\+
\(%\d\+T%#.\{-}#.\{-\} \)\(.\{0,6}\)[^%#]*
%1T%#TablSel#1^2%#WarningMsg#%1X|%2T%#TabLine#2%#WarningMsg#%2X|%3T%#TabLine#3%#DiffText#*%#WarningMsg#%3X|%T%#TabLineFill#
