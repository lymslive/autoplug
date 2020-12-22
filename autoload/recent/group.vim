" manage a group of recent list

let s:class = {}
let s:class.mrfile = [] " recent files
let s:class.mrdir = []  " recent directory
let s:class.mrext = {}  " recent fiels for each extention
let s:class.datafile = '' " load/save data from dist file

function! recent#group#new(datafile) abort
    let l:obj = deepcopy(s:class)
    let l:obj.datafile = a:datafile
    let l:obj.mrfile = vimloo#mrlist#new(10)
    let l:obj.mrdir = vimloo#mrlist#new(10)
    return s:class
endfunction

function! s:class.load_json() dict
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
            if type(l:val) = v:t_list
                let self.mrext[l:key] = vimloo#mrlist#new(10)
                call self.mrexe[l:key].Reserve(len(l:val))
                call self.mrexe[l:key].Fill(l:val)
            endif
        endfor
    endif
endfunction

function! s:class.save_json() dict
    if !filewritable(self.datafile)
        echoerr 'file cannot write to: ' . self.datefile
        return
    endif

    let l:json = {}
    let l:json.file = self.mrfile.list()
    let l:json.dir = self.mrdir.list()
    if !empty(self.mrext)
        for [l:key, l:val] in items(self.mrext)
            l:json[l:key] = l:val.list()
        endfor
    endif

    let l:string = json_encode(l:json)
    return writefile(l:string, self.datafile)
endfunction
