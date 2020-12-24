" manage a group of recent list

let s:class = {}
let s:class.mrfile = v:null " recent files
let s:class.mrdir = v:null  " recent directory
let s:class.mrext = {}  " recent fiels for each extention
let s:class.datafile = '' " load/save data from dist file
let s:class.default_size = 10

function! recent#group#new(datafile) abort
    let l:obj = deepcopy(s:class)
    let l:obj.datafile = a:datafile
    return l:obj.init()
endfunction

" Method: init 
function! s:class.init() dict abort
    let self.mrfile = vimloo#mrlist#new(self.default_size)
    let self.mrdir = vimloo#mrlist#new(self.default_size)
    call self.load_json()
    return self
endfunction

" Method: record_file 
function! s:class.record_file(file) dict abort
    let l:file = a:file
    let l:dir = fnamemodify(l:file, ':p:h')
    let l:ext = fnamemodify(l:file, ':e')
    call self.mrfile.Add(l:file)
    call self.mrdir.Add(l:dir)
    if !has_key(self.mrext, l:ext)
        let self.mrext[l:ext] = vimloo#mrlist#new(self.default_size)
    endif
    call self.mrext[l:ext].Add(l:file)
endfunction

function! s:class.load_json() dict abort
    if !filereadable(self.datafile)
        return
    endif

    let l:lines = readfile(self.datafile)
    let l:string = join(l:lines, '')
    let l:json = json_decode(l:string)
    if type(l:json) != v:t_dict
        return
    endif

    if has_key(l:json, 'file') && type(l:json.file) == v:t_list
        call self.mrfile.Reserve(len(l:json.file))
        call self.mrfile.Fill(l:json.file)
    endif
    if has_key(l:json, 'dir') && type(l:json.dir) == v:t_list
        call self.mrdir.Reserve(len(l:json.dir))
        call self.mrdir.Fill(l:json.dir)
    endif

    if has_key(l:json, 'ext') && type(l:json.ext) == v:t_dict
        for [l:key, l:val] in items(l:json.ext)
            if type(l:val) == v:t_list
                let self.mrext[l:key] = vimloo#mrlist#new(self.default_size)
                call self.mrext[l:key].Reserve(len(l:val))
                call self.mrext[l:key].Fill(l:val)
            endif
        endfor
    endif
endfunction

function! s:class.save_json() dict abort
    let l:json = {}
    let l:json.file = self.mrfile.list()
    let l:json.dir = self.mrdir.list()
    if !empty(self.mrext)
        let l:json.ext = {}
        for [l:key, l:val] in items(self.mrext)
            let l:json.ext[l:key] = l:val.list()
        endfor
    endif

    let l:string = json_encode(l:json)
    return writefile([l:string], self.datafile)
endfunction
