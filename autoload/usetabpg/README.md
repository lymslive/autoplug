# UseTabpage

## Summary

It may be useful when use multiply tabpages in vim.
* custom tabline with much more informations
* :T command to jump to the last visited tabpage
* feel free to directly modify this plugin's map interface

## 简介

一个辅助多页签 (tabpage) 编辑的小脚本插件，主要功能有：

* 定制的页签栏 (tabline)，显示更丰富的信息。
  注意 gVim 需要设置 set go-=e 才显示此文本模式的 tabline

* :T 命令用于跳转到上次访问的页签中，在很多页签时极有用。

* 普通模式下，g-jkhl 在页签间移动，g-[0-9] 直接访问相应编号的页签

## 安装

* 推荐插件管理工作，如 [Vundle](https://github.com/VundleVim/Vundle.vim) 或
  [pathogen](https://github.com/tpope/vim-pathogen)。

* 下载复制到任一个 runtimpath 路径下，如 ~/.vim

* 下载到任意喜欢的目录，然后将该目录加入 runtimpath。如：

>> :set rtp+=/where/you/download/or/put

## 定制与配置

plugin/usetab.vim 是开放式脚本，它只罗列一些简单的 vim ex 命令，比如设置选项，
自定义命令，重映射键，并带有可观的注释。而将实际工作的函数定义放在 autoload/
目录下采取自动加载机制。

所以，如果用户（包括期月年后的自己）发现该插件的按键与其他插件有冲突或单纯地不
喜欢，可以直接修改（或仅需切换注释）本插件中相关语句。

如果在意更新冲突的问题，可以在相同目录下另存一个 setlocal.vim 文件，把自己需要
语句复制到该文件。这样在加载插件中只会加载用户本地的 setlocal.vim ，不会再加载
插件原生提供的脚本。

该做法旨在简化插件的编码与使用，不想增加一系列的全局变量让用户在 .vimrc 设值以
调整插件的某些行为，节省不必要的脚本语句运行，与不必要的全局变量。

在一般不太挑剔的情况下，接受插件提供的默认按键接口就行。真有需要时直接看注释修
改某些语句即可。一般知道寻找插件的 vimer 应该对简单的 set map 或 command 命令
无理解障碍才对。

若想要暂时禁用本插件，也只要在 usetab.vim 同目录下放一个空实现的 setlocal.vim
即可。
