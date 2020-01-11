" File: CBook
" Author: lymslive
" Description: class for notebook
" Create: 2019-12-10
" Modify: 2019-12-10

let s:class = {}
let s:class._ctype_ = s:class
let s:class.basedir = ''
let s:class.notes = []
let s:class.tags = {}
let s:class.mrus = []
let s:class.listfile = v:null
let s:class.mapid = v:null    " map noteid to index in self.notes
let s:class.gidcounter = v:null

let s:NOTE_DIR = 'd'
let s:NOTE_LIST = 'notelist'
let s:NOTE_EXT = '.md'

let s:SNoteRecord = {'noteid': '', 'title': '', 'tagstr': '', 'tags': v:null}
let s:SNoteID = {'date': '', 'counter': 0}

" Func: #class 
function! wenote#CBook#class() abort
    return s:class
endfunction

" Func: #new 
function! wenote#CBook#new(basedir) abort
    if empty(a:basedir)
        return v:null
    endif
    let l:object = copy(s:class)
    let l:object.basedir = expand(a:basedir)
    let l:filepath = l:object.basedir .. '/' .. s:NOTE_LIST
    let l:object.listfile = wenote#lib#CListfile#new(l:filepath)
    return l:object.init()
endfunction

" Method: init 
function! s:class.init() dict abort
    let self.notes = []
    let self.tags = {}
    let self.mrus = []
    let self.mapid = {}
    call self.readlist()
    call self.build_map()
    call self.initGID()
    let self.bModified = v:false
    let self.bTagCounted = v:false
    return self
endfunction

" Method: build_map 
function! s:class.build_map() dict abort
    for l:idx in range(len(self.notes))
        let l:note = self.notes[l:idx]
        let l:tokens = split(l:note, '\t')
        if len(l:tokens) > 0
            let l:noteid = l:tokens[0]
            let self.mapid[l:noteid] = l:idx
        endif
    endfor
    return self
endfunction

" Method: readlist 
function! s:class.readlist() dict abort
    if empty(self.listfile)
        return
    endif
    call self.listfile.read()
    let self.notes = self.listfile.get('notes')
    let self.mrus = self.listfile.get('mrus')
endfunction

" Method: writelist 
function! s:class.writelist() dict abort
    if empty(self.listfile)
        return
    endif
    let l:content = {}
    let l:content.notes = self.notes
    let l:content.mrus = self.mrus
    call self.listfile.set(l:content).write()
endfunction

" Method: getlist 
function! s:class.getlist(...) dict abort
    if empty(self.notes)
        call self.readlist()
    endif
    if empty(self.notes)
        call self.rebuild()
    endif
    if a:0 == 0 || empty(a:1)
        return self.notes
    endif
    if a:1 ==# 'tag'
        return self.listTag('with_count')
    elseif a:1 ==# 'mru'
        return self.mrus
    endif
    let l:arg = a:1
    if a:0 >= 2 && !empty(a:2)
        return self.bykey(l:arg, a:2)
    endif
    if l:arg =~# '^\d\+$'
        return self.bydate(l:arg)
    else
        return self.bytag(l:arg)
    endif
endfunction

" Method: bykey 
function! s:class.bykey(key, flag) dict abort
    if a:flag == '#'
        return filter(copy(self.notes), {idx, val -> val =~# a:key})
    elseif a:flag == '?'
        return filter(copy(self.notes), {idx, val -> val =~? a:key})
    else
        return filter(copy(self.notes), {idx, val -> val =~ a:key})
    endif
endfunction

" Method: bydate 
function! s:class.bydate(date) dict abort
    return filter(copy(self.notes), {idx, val -> val =~# '^' .. a:date})
endfunction

" Method: bytag 
function! s:class.bytag(tag) dict abort
    return filter(copy(self.notes), {idx, val -> val =~# '|' .. a:date .. '|'})
endfunction

" Method: getpath 
" to fix: / may used in linux and windows, not mac
function! s:class.getpath(noteid) dict abort
    if empty(a:noteid)
        return self.basedir .. '/' .. s:NOTE_DIR
    endif
    let l:paths = [self.basedir, s:NOTE_DIR, a:noteid]
    let l:path = join(l:paths, '/') .. s:NOTE_EXT
    return l:path
endfunction

" Method: globpath 
function! s:class.globpath() dict abort
    let l:wild = self.getpath('*')
    let l:paths = glob(l:wild, 0, 1)
    return l:paths
endfunction

" Method: hasNote 
function! s:class.hasNote(...) dict abort
    if a:0 > 0 && !empty(a:1) && a:1 !=# '%'
        let l:noteid = a:1
    else
        let l:noteid = fnamemodify(bufname(), ':t:r') 
    endif
    return has_key(self.mapid, l:noteid)
endfunction

" Method: parseNote 
function! s:class.parseNote(bufnr) dict abort
    let l:content = getbufline(a:bufnr, 1, 2)
    let l:struct = self.parseContent(l:content)
    if empty(l:struct)
        return l:struct
    endif
    let l:notename = bufname(a:bufnr)
    let l:noteid = fnamemodify(l:notename, ':t:r')
    let l:struct.noteid = l:noteid
    return l:struct
endfunction

" Method: parseFile 
function! s:class.parseFile(path) dict abort
    let l:content = readfile(a:path, '', 2)
    let l:struct = self.parseContent(l:content)
    if empty(l:struct)
        return l:struct
    endif
    let l:noteid = fnamemodify(a:path, ':t:r')
    let l:struct.noteid = l:noteid
    return l:struct
endfunction

" Method: parseContent 
function! s:class.parseContent(content) dict abort
    let l:content = a:content
    if empty(l:content)
        return v:null
    endif

    let l:struct = copy(s:SNoteRecord)
    let l:title = l:content[0]
    let l:title = substitute(l:title, '^#\s*', '', '')
    if empty(l:title)
        return v:null
    endif
    let l:struct.title = l:title

    let l:tagstr = ''
    if len(l:content) > 1
        let l:line = l:content[1]
        let l:tagstr = substitute(l:line, '[` ]\+', '|', 'g')
    endif
    let l:struct.tagstr = l:tagstr

    let l:tags = split(l:tagstr, '|')
    let l:struct.tags = l:tags

    return l:struct
endfunction

" Method: struct2record 
function! s:class.struct2record(struct) dict abort
    let l:struct = a:struct
    if empty(l:struct) || empty(l:struct.noteid)
        return ''
    endif
    let l:record = printf("%s\t%s\t%s", l:struct.noteid, l:struct.title, l:struct.tagstr)
    return l:record
endfunction

" Method: record2struct 
function! s:class.record2struct(record) dict abort
    let l:tokens = split(a:record, '\t')
    if len(l:tokens) < 3
        return v:null
    endif
    let l:struct = copy(s:SNoteRecord)
    let l:struct.noteid = l:tokens[0]
    let l:struct.title = l:tokens[1]
    let l:struct.tagstr = l:tokens[2]
    let l:struct.tags = split(l:struct.tagstr, '|')
    return l:struct
endfunction

" Method: recordNote
function! s:class.recordNote(bufnr) dict abort
    let l:struct = self.parseNote(a:bufnr)
    let l:record = self.struct2record(l:struct)
    if empty(l:record)
        return self
    endif
    let l:noteid = l:struct.noteid
    if has_key(self.mapid, l:noteid)
        let l:idx = self.mapid[l:noteid]
        if self.notes[l:idx] ==# l:record
            return self
        endif
        let self.notes[l:idx] = l:record
    else
        call add(self.notes, l:record)
        let self.mapid[l:noteid] = len(self.notes) - 1
    endif
    let self.bModified = v:true
    let self.bTagCounted = v:false
    return self
endfunction

" Method: saveNotes 
function! s:class.saveNotes() dict abort
    if self.bModified
        call self.writelist()
    endif
    let self.bModified = v:false
endfunction

" Method: newNote 
" passin: title and optional tag list
" return: {notepath:'', content: []} to let caller actually edit new note
function! s:class.newNote(title, tags) dict abort
    let l:noteid =  self.incGID()
    while has_key(self.mapid, l:noteid) || filereadable(self.getpath(l:noteid))
        let l:noteid =  self.incGID()
    endwhile
    let l:notepath = self.getpath(l:noteid)
    let l:content = []
    call add(l:content, '# ' .. a:title)
    let l:tags = []
    for l:tag in a:tags
        call add(l:tags, printf('`%s`', l:tag))
    endfor
    if !empty(l:tags)
        let l:tagstr = join(l:tags, ' ')
        call add(l:content, l:tagstr)
    endif
    return {'notepath': l:notepath, 'content': l:content}
endfunction

" Method: initGID 
function! s:class.initGID() dict abort
    let l:date = strftime("%Y%m%d")
    let l:gid = copy(s:SNoteID)
    let l:gid.date = l:date
    let self.gidcounter = l:gid
    return self
endfunction

" Method: incGID 
function! s:class.incGID() dict abort
    let l:today = strftime("%Y%m%d")
    let l:date = self.gidcounter.date
    if l:date !=# l:today
        let self.gidcounter.date = l:today
        let self.gidcounter.counter = 0
    endif
    let self.gidcounter.counter += 1
    return self.curGID()
endfunction

" Method: curGID 
function! s:class.curGID() dict abort
    return self.gidcounter.date .. '_' .. self.gidcounter.counter
endfunction

" Method: countTag 
function! s:class.countTag() dict abort
    if self.bTagCounted && !empty(self.tags)
        return self.tags
    endif
    let self.tags = {}
    for l:idx in range(len(self.notes))
        let l:record = self.notes[l:idx]
        let l:struct = self.record2struct(l:record)
        for l:tag in l:struct.tags
            if has_key(self.tags, l:tag)
                let self.tags[l:tag] += 1
            else
                let self.tags[l:tag] = 0
            endif
        endfor
    endfor
    let self.bTagCounted = v:true
    return self.tags
endfunction

" Method: listTag 
" a:1, with count postfix
function! s:class.listTag(...) dict abort
    let l:dTags = self.countTag()
    let l:tags = keys(l:dTags)
    call sort(l:tags)
    let l:list = []
    for l:tag in l:tags
        let l:count = l:dTags[l:tag]
        if a:0 > 0 && !empty(a:1)
            let l:item = l:tag .. ':' l:count
        else
            let l:item = l:tag
        endif
        call add(l:list, l:item)
    endfor
    return l:list
endfunction

" Method: hasTag 
function! s:class.hasTag(tag) dict abort
    let l:dTags = self.countTag()
    return has_key(l:dTags, a:tag)
endfunction

" Method: rebuild 
function! s:class.rebuild() dict abort
    let l:paths = self.globpath()
    if empty(l:paths)
        return self
    endif
    call sort(l:paths)

    echomsg printf('find %s note files, will build notelist ...', len(l:paths))

    let l:notes = []
    let l:mapid = {}
    for l:path in l:paths
        let l:struct = self.parseFile(l:path)
        if empty(l:struct)
            continue
        endif
        let l:record = self.struct2record(l:struct)
        if empty(l:record)
            continue
        endif
        call add(l:notes, l:record)
        let l:mapid[l:struct.noteid] = len(l:notes) - 1
    endfor

    let self.notes = l:notes
    let self.mapid = l:mapid
    let self.bModified = v:true
    let self.bTagCounted = v:false
    return self
endfunction

" -------------------------------------------------------------------------------- "
"  any helper local function:

