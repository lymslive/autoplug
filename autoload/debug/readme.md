# VimL 脚本调试辅助工具

这里是一套辅助开发 VimL 脚本，从各方面方便调试 VimL 的工具方法。
最初混杂在 [vimloo](https://github.com/lymslive/vimloo) 仓库中。
后来独立取出并继续优化，让 vimloo 仓库主题明确，纯粹的基础脚本
代码库。

## 日志宏命令 LOG 系列： debug#log 模块

提供一系列日志命令，可用在脚本中：

* `:0LOG {msg}` 打印日志，可在 `LOG` 前或后附加数据表示日志级别。
* `:ELOG {msg}` 打印错误日志 error，日志级别 0
* `:DLOG {msg}` 打印调试日志 debug，日志级别 1
* `:WLOG {msg}` 打印警告日志 warn，日志级别 2
* `:0SLOG {arg}` 打印字面字串至日志，不同以上 `{msg}` 应是变量表达式。
* `:LOGUP {level}` 设定放行打印日志的级别，初始默认 0 ，只打印错误。
* `:LOGON [file]` 日志默认用 `echomsg` 打印到消息区，但可指定文件。
    特殊文件名 `%` 表示附加到当前 buffer，`%3` 表示附加到 buffer 3；
    若省略 `[file]` 参数，将新建一个专门的日志 buffer 接收后续日志。
* `:LOGOFF` 关闭打印至文件或 buffer ，恢复默认 echomsg 。
* `:DEBUG [level]` 设定全局变量 `g:DEBUG` 的值，同时也将日志级别
   设为这个值，默认是 1 。脚本代码中可自行依据 `g:DEBUG` 处理分别。

与 `SLOG` 参数区别示例如下：

```vim
: LOG 'a string variable' . v:errmsg
:SLOG a literature string without quote
```

在未加载本内置模块之前，为防其他使用了日志宏的脚本加载错误，可先
预定义几个空命令，如 `vimloo` 仓库内的 `plugin.vim` ：
```vim
if !exists(':DLOG')
    command! -nargs=* DLOG " pass
    command! -nargs=* ELOG " pass
    command! -nargs=* WLOG " pass
endif
```

日志系列命令 `:LOG {msg}` 会在消息字符串前添加一些前面，格式如：

```
[YYYYMMDD HH:MM:SS][LABEL](function <sifle>-format) msg
```

其中 `[LABEL]` 是对应日志级别的一个描述标签，如 ERR DBG 等。
`(function ..)` 段是函数栈，形如展开 `<sfile>` 的格式，能溯每层
调用的函数名及相对行数（在该函数内的行数）。如果不同在函数内调用，
该段字符串用 `(script)` 代替。

注意这可能是个相当冗长的字符串，
且主要只在当前 vim 会话中用途更大，因为在调用 `s:` 脚本私有函数及
匿名函数时，打印的函数栈描述会包含一些临时编号。

如果日志目的主要设计为打印至外部文件，供日后分析或长期存档，不打印
函数栈可能会更精简，则可用 `!` 命令变种。如 `:ELOG!` 或 `:DLOG!` 。

## 错误消息分析： debug#message 模块

`debug#message` 模块用于将 vim 内部的消息内容载入到一个辅助 buffer
中查看，并利用 `debug#frame` 模块分析错误消息中包含的函数栈信息。
上述的日志如果打印到 buffer 中，也可利用该功能。

之前曾尝试定义过两个命令 `:MessageQ` 与 `:MessageL` 分别将消息区内容
放到 quickfix 或 location list 窗口中。但似乎没什么卵用，消息比较随意，
不太适于 quickfix 模式。因而重新定义一个命令：

* `:10MessageView` 将消息的最后 10 行加载到一个辅助窗口中，
   指定数字可在命令之前，或之后。默认是 10 行。
* `g/` 快捷键，相当于 `:10MessageView`

在消息查看窗口中有几个快捷键可用：

* `q` 退出消息查看窗口。
* `k` 光标上移一行，如果到顶后，尝试额外再加载 10 行。
* `<CR>` 回车，如果当前行识别为错误函数栈，将函数栈字符串拆分为列表，
  附加到当前行之下。如果光标就在展开的表示函数栈的行，就尝试跳转到
  定义该函数的地方。目前只能支持 `#` 函数与 `s:` 函数定义跳转。

## 设定调用断点命令： debug#break 模块

主要提供一个 `:B` 命令，没错，就是单字母命令，甚至不想多定义为类似
`:Break` 的命令；就是想在编辑脚本时能使用快捷键为当前行打断点，
该命令相当于三键：冒号，字母 B ，回车。

`B` 断点命令可识别如下几类断点，给当前脚本打断点：

* 脚本级，在函数外断点，相当于 `breakadd file [line] {file}`
  在加载脚本时或重新 `source` 时，运行到相当断点行会中断。
* 在函数内断点，相当于 `breakadd func [line] {function-name}`
  可识别全局函数名（包括 `#` 全局函数）与脚本私有函数 `s:`，
  以及一种特殊的匿名函数，就是按 `vimloo` 规范的类模块，
  形如 `s:class.method()` 定义的类方法。

## 函数定义查找： debug#lookup 模块

提供一个函数 `debug#lookup#GotoDefineFunc()` 用于查找 VimL 函数定义，
不依赖 tag 文件，但如果查找失败，最后也会尝试 `:tag` 命令，故适合于
定义为 `<C-]` 的快捷键映射。目前可查找如下几类函数：

* `#` 自动加载函数
* `s:` 脚本私有函数
* `self.method()` 限于 `vimloo` 规范的类文件，查找当前文件的类方法。

此外，这个函数也用于支持在另一处定义的命令 `:EV {#function#name}` 。

* `:ClassView [filename]` 该命令用于查看类定义，向消息区打印信息，
   列出该类定义的数据与方法。其实不仅是类模块，只要是能用 `package`
   导出字典的文件，都能用该命令查看。参数可指定模块名，默认当前文件。

## 自动加载脚本重命名： debug#rename 模块

由于 `autoload/` 目录下的脚本内定义的 `#` 函数必须匹配文件路径，
但移动了脚本时略麻烦，故提供了一个命令专为此目的改名。

`:VimRename` 无参数时，只检查修复当前文件定义的 `#` 函数是否匹配。
`:VimRename newname` 一个参数时，将当前文件改名，并修复 `#` 函数名。
`:VimRename oldfile newfile` 两个参数时，给指定文件重命名。

## 快速测试： debug#test 模块

如果当前脚本定义了 `#test()` 方法，则可用一个命令快速调用该函数。
不限定该方法如何编写，可以是调用专业的真测试，也可以是简单的尝试
taste ，只为在编写脚本中，使该脚本可独立执行，顺便观察结果，
用于后续调用。

* `:Test [argument list]` 调用当前文件的 `#test()` 函数，
   并将额外的命令行参数传给该 `#test()` 方法让其自行处理参数。
* `:Test -f filename [argument list]`
   可用 `-f` 选项指定其他脚本，然后接入额外参数。
* `:Test!` 仍按 `:Test` 命令执行之后，再执行 `:MessageView` ，
   适用于 `#test()` 函数直接向 message 简单输出的情况。
