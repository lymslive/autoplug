# Vim 动态加载插件管理与集合

## 缘起

再也不想每实现一个或小或大的功能就开一个 vim 插件了，不但是一堆小仓库不好维护
，而且每个目录都要加入 vim `&runtimepath` 也很冗长呀。

因此，我打算将我自己写的 vim 大多数插件都整合在一个插件。每个功能“插件”都独立
放在 `autoload` 目录下的相应子目录中，尽量只采用 `autoload` 动态加载函数实现功
能，不在 `plugin` 目录下加任何代码，也就默认配置下 vim 启动时不会加载这里的任
何插件。

## 缘定

实现规范也很简单：在每个 `autoload` 子目录下放一个 `plugin.vim` 脚本，加载该脚
本表示加载该目录插件的功能，其实也不外乎是定义些命令与映射，可以通过调用其内的
任何一个 `#` 函数来触发加载该脚本，就约定为 `xxx#plugin#load()` 函数吧。

这样，一个含有 `plugin.vim` 文件的 `autoload` 子目录，就可称之为子插件。

再定义一个简易的命令 `PI` 或 `PluginLoad`，使其等效：
```vim
: PI xxx
" 等效于
: call xxx#plugin#load()
```

其实 `autoload/xxx/plugin.vim` 脚本内不一定要定义 `#load()` 函数也能触发加载，
只不过会有个烦人的错误提示而已。最简单就给个空函数即可，或者只返回 1 以示成功。

如有必要，再定义一个反命令，使其等效：
```vim
: PO xxx
" 等效于
: call xxx#plugout#unload()
```
用于取消原 `xxx/plugin.vim` 脚本中定义的命令、映射等对 vim 环境的影响。但感觉
这种需求不大，可有可无。

与文件类型有关 `ftplugin` 可能实现略麻烦点。一种方案是仍在 `plugin.vim` 文件内
定义一个 `xxx#plugin#ft_{&filetype}` 函数，然后在标准的
`ftplugin/{&filetype}.vim` 函数内调用该函数。例如，某子插件增加了编辑 `*.vim`
文件的功能，则需要在个人目录 `~/.vim/ftplugin/vim.vim` 中增加如下调用：

```vim
: call xxx#plugin#ft_vim()
```

也可以在子插件目录下再增加一个 `ftplugin.vim` 文件，在其内定义类型相关的函数。
总之就是把加载每个类型文件需要执行的代码打包成函数，供外界调用。如果函数要做的
工作较复杂，为避免重复调用，可设计增加 `b:` 变量判断。

## 缘用

将本库当作普通 vim 插件安装至某 `rtp` 路径下，再执行 `autoplug#load()` 才可后
续使用 `:PI` 命令。例如：

```sh
$ cd ~/.vim/pack/lymslive/opt/
$ git clone https://github.com/lymslive/autoplug.git
```

```vim
:packadd autoplug
:call autoplug#load()
```

后面两行 `:ex` 命令可写入 `vimrc` 或需要时临时输入命令行执行亦可。

若想在 vim 启动时自动加载某些功能插件，可在这两行后加上一系列 `:PI` 命令即可：
```vim
:PI xxx
:PI yyy
:PI zzz
" 也可以写成一行
:PI xxx yyy zzz
```

目前，`:PI` 命令支持有限补全，可补全本库及 `~/.vim` 目录下 `autoload/` 的子目
录名称。但是对于已输入的 `xxx` 参数，按 vim 的自动加载机制，会在所有 `&rtp` 路
径下搜索。

故在极简模式下，只要将本库的 `autoload/autoplug.vim` 文件下载丢到
`~/.vim/autolaod/` 目录下，应该就能工作了。也可以用其他流行的 vim 插件管理工具
自动安装。

### 自定义配置

在不执行 `:PI` 命令加载子插件时，几乎不会影响当前 vim 的任何环境设置。可按需激活想
用的功能，也可酌情在 `vimrc` 等初始化脚本中用 `:PI` 命令添加最常用的子插件。

可将某个子插件目录的 `autoload/*/plugin.vim` 文件复制到 `~/.vim/autoload` 对应位
置，再直接对全局变量、映射、命名名修改，可覆盖我这里提供的默认使用方式。部分子
插件可能支持更详尽的定制，请参阅相应的文档。

也可按这里的思路，自行在 `~/.vim/autoload` 下建子目录，组织添加自己想要的功能
，哪怕只是简单归纳配置其他大型经典插件的个人选项。

## 缘满

### 本仓库包含的实用插件列表

`autoload` 每个子目录相当于一个子插件，大部分子插件目录，也有自己的说明文档。
以下子插件大致按个人实用度排序：

+ [edvsplit](autoload/edvsplit) 双窗口编辑模式
+ [usetabpg](autoload/usetabpg) 使用多标签页工作
+ [microcmd](autoload/microcmd) 简易实用的微命令集
+ [wraptext](autoload/wraptext) 修饰包含括号等小功能
+ [tailflow](autoload/tailflow) 在 vim 中查看日志流
+ [zfold](autoload/zfold) 手动折叠扩展功能
+ [useterm](autoload/useterm) 使用 vim8 内置终端的一些配置
+ [qcmotion](autoload/qcmotion) 基于上下文件的单键快速移动
+ [debug](autoload/debug) 辅助开发调试 viml 的一组模块
+ [template](autoload/template) 辅助生成 viml 类文件的模块工具
+ [golang](autoload/golang) 个人定制的一些为开发 go 的配置
+ [spacebar](autoload/spacebar) 空格键的一些映射
+ [csviewer](autoload/csviewer) cvs 数据文件查看与编辑插件
+ [gamemaze](autoload/gamemaze) 在vim下玩玩迷宫游戏(demo)

### 保持独立的插件仓库

原来写的这几个插件，功能略复杂，迁移麻烦，故按原址不动：

* [vimloo](https://github.com/lymslive/vimloo) 面向对象化的 viml 脚本实现
* [vnote](https://github.com/lymslive/vnote) 用 vim 写日记记笔记
* [StartVim](https://github.com/lymslive/StartVim) 用不同的姿式启动 vim

<!--
### 计划或正在撸的插件

- [vtmder](autoload/vtmder) 受 TC 与 MC 启发的文件管理插件
-->

## 缘灭

以后若想再撸 vim 插件，没特别原因，应该不会额外开小仓库了。清爽。唯一不爽的是
`autoload/` 目录下的 `#` 函数全名有点长。

