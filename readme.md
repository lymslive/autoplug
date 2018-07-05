# Vim 本地插件集合与管理

## 缘起

再也不想每实现一个或小或大的功能就开一个 vim 插件了，不但是一堆小仓库不好维护
，而且每个目录都要加入 vim `runtimepath` 也很冗长呀。

因此，我打算将我自己写的 vim 大多数插件都整合在一个插件。每个功能“插件”都独立
放在 `autoload` 目录下的相应子目录中，尽量只采用 `autoload` 动态加载函数实现功
能，不在 `plugin` 目录下加任何代码，也就默认配置下 vim 启动时不会加载这里的任
何插件。

## 缘定

实现规范也很简单：在每个 `autoload` 子目录下放一个 `plugin.vim` 脚本，加载该脚
本表示加载该目录插件的功能，其实也不外乎是定义些命令与映射，可以通过调用其内的
任何一个 `#` 函数来触发加载该脚本，就约定为 `xxx#plugin#load()` 函数吧。

再定义一个简易的命令 `PI` 或 `PluginLoad`，使其等效：
```vim
: PI xxx
" 等效于
: call xxx#plugin#load()
```

其实 `autoload/xxx/plugin.vim` 脚本内不一定要定义 `#load()` 函数也能触发加载，
只不过会有个烦人的错误提示而已。最简单就给个空函数即可。

如有必要，再定义一个反命令，使其等效：
```vim
: PO xxx
" 等效于
: call xxx#plugout#unload()
```
用于取消原 `xxx/plugin.vim` 脚本中定义的命令、映射等对 vim 环境的影响。但感觉
这种需求不大，可有可无。

这里 `xxx` 代表一个在本库 `autoload/xxx` 子目录下的一个“子插件”。

与文件类型有关 `ftplugin` 可能实现略麻烦点，另议。

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
录名称。但是对于已输入的 `xxx` 参数，按 vim 的自动加载机制，会在所有 `rtp` 路
径下搜索。

故在极简模式下，只要将本库的 `autoload/autoplug.vim` 文件下载丢到
`~/.vim/autolaod/` 目录下，应该就能工作了。

## 缘满

### 保持独立的插件仓库

原来写的这几个插件，功能略复杂，迁移麻烦，故按原址不动：

* [vimloo](https://github.com/lymslive/vimloo) 面向对象化的 viml 脚本实现
* [vnote](https://github.com/lymslive/vnote) 用 vim 写日记记笔记
* [StartVim](https://github.com/lymslive/StartVim) 用不同的姿式启动 vim

### 本仓库包含的功能插件列表

+ [edvsplit](autoload/edvsplit) 双窗口编辑模式
+ [usetabpg](autoload/usetabpg) 使用多标签页工作
+ [microcmd](autoload/microcmd) 简易实用的微命令集
+ [wraptext](autoload/wraptext) 修饰包含括号等小功能
+ [qcmotion](autoload/qcmotion) 基于上下文件的单键快速移动
+ [spacebar](autoload/spacebar) 空格键的一些映射
+ [gamemaze](autoload/gamemaze) 在vim下玩玩迷宫游戏(demo)


### 计划或正在撸的插件

- [csviewer](autoload/csviewer) cvs 数据文件查看与编辑插件
- [vtmder](autoload/vtmder) 受 TC 与 MC 启发的文件管理插件

## 缘灭

以后若想再撸 vim 插件，没特别原因，应该不会额外开小仓库了。清爽。唯一不爽的是
`autoload/` 目录下的 `#` 函数全名有点长。

