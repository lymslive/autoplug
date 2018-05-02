# golang 插件定制

## 援用第三方插件

推荐 [https://github.com/fatih/vim-go](https://github.com/fatih/vim-go)
就差不多了。

启用插件：
```vim
:PI golang
```

该语句加载在文件 `autoload/golang/plugin.vim` 的配置，如：

```vim
packadd vim-go
let g:go_doc_url='https://golang.google.cn'
let g:go_fmt_command = "goimports"
```

可以根据需要加载其他三方插件，及适应配置。

也可以将配置写在 `~/.vim/ftplugin/go.vim` 中，在打开 go 文件时自动加载，不过要
注意保证只加载一次。如：

```vim
if !exists('s:once')
    let s:once = 1
    packadd vim-go
    let g:go_doc_url='https://golang.google.cn'
    let g:go_fmt_command = "goimports"
endif
```

## 增补功能

### 按相对路径引入包

按 go 语言代码组织规范，包路径从 `$GOPATH/src` 目录下开始。个人项目建议放在
`github.com/myname/project` 目录下。这路径经常很长，不方便输入。因此增加了一个
相对当前编辑文件路径引入包的功能，限 `*.go` 的 `buffer` 范围的映射与命令。

+ 相对路径只识别以 `./` 或 `../` 开头的包名。
+ `:IM` 该短命令调用 `vim-go` 插件的 `:GoImport` 命令，同时处理相对路径。
+ `insert-<CR>` 在插入模式下按回车，如果正在编辑引入语句（或块），自动转换相对路径的
  引入包。如果不是相对路径，不转换，只保持原回车功能。
+ `insert-<Esc>` 同上插入模式按回车，但 `<Esc>` 回到普通模式。

### 包级块移动搜寻浏览

提供了一些在当前包文件内快速移动光标至特定包级定义块的映射。自动保存 `'` 默认
标记，故可用 `''` 命令回到原位置。

+ `gm` 跳到 import 语句
+ `[f` `]f` 向前或向后跳到 `func` 定义语句。`vim-go` 也重定义了 `[[` 与`]]` 。
+ `[c` `]c` 向前或向后寻找 `const` 常量定义语句。
+ `[v` `]v` 向前或向后寻找 `var` 包级变量定义语句。不找局部变量，那应该在一屏
  内能看到的，除非太长的函数，那也不是良好的编程风格。
+ `[s` `]s` 搜索 `struct` 结构体。
+ `[t` `]t` 搜索 `interface` 接口。注意原生的 `[i` 命令也是有用的，不覆盖了。


要求源代码风格规范，包级定义关键应该是没缩进的，否则不能正确搜寻。

另外可参考其他有关移动浏览的插件：

+ [qcmotion](../qcmotion/readme.md)

