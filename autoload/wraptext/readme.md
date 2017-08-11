# 《Wrap: 括号修饰小插件》

自己在用 vim 比较早期时写的一个实用插件，主要用于将当前行或选区添加配对括号。
虽然后来发现其他一些不错的相关功能插件，如
[surround](https://github.com/tpope/vim-surround) 采用操作符工作方式，
[pairs](https://github.com/jiangmiao/auto-pairs) 则比较专注插入模式的括号处理
。不过插件装得多了，有时不免出现冲突，所以原来按自己需求写的东西虽然简陋，却还
一直挺习惯。

故再重新整理一下，这个插件的 Wrap 还是有些不同的特色功能。

## 【主要功能】

核心就一个函数：
```
wraptext#func#wrap(prefix, postfix, mode)
```

* 前缀文本 prefix 与后缀文本 postfix 可以其一为空串，比如很多语言的注释只要求
  前缀，不要求后缀。

* `a:mode` 参数，大致对应 vim 当前的工作模式，支持 'nvV' 之一，'i' 插入模式下
  的功能似不完善。

* `n` 参数：在 vim 普通模式 (normal) 下使用，将当前行整行加上前后缀字符，变成
  "prefix + 原当前行文本 + postfix"。忽略并保持前导空白缩进。并支持切换，即若
  原来加上了前后缀文本，重要执行则取消前后缀文本。可用于映射注释当前行。

* `v` 参数：在 vim 可视模式 (visual) 下使用。vim 的可视模式本身有三种不同的选
  择方式。
  - `v` 字符选择模式，一般是在行内选定少量文本，执行 Wrap 后分别在选区首尾加上
	前后缀文本。
  - `V` 行选择模式，对选定的每一行进行 Wrap 操作，在每一行的行首与行尾加上前后
	缀文本。
  - `^V` 列块选择模式，对每一行选定的部分文本，在其首尾加上前后缀文本。

* `V` 参数：仅用于 vim 的行选择模式，将选定的行作为一个整体，在其第一行前面插入
  一行 prefix 文本，在其最后一行增加一行 postfix 文本。

注：目前，好像只有 `n` 模式支持切换功能，而在可视选择模式下实现与操作都略麻烦。

## 【键映射示例】

```
nnoremap ,( <ESC>:call wraptext#func#wrap("(", ")", "n")<CR>
vnoremap ,( <ESC>:call wraptext#func#wrap("(", ")", "v")<CR>
" 其他各种括号引号
nnoremap ,<Space> v<ESC>:call wraptext#func#wrap(" ", " ", "v")<CR>
vnoremap ,<Space> <ESC>:call wraptext#func#wrap(" ", " ", "v")<CR>
```
最后两映射的意思是在选定文本或当前字符前后各添加一个空格。

我喜欢直接在 `map` 命令中使用设定的前导字符，不使用 `<Leader>` ，因为我为每个
特殊字符如 `,;\` 等，都设定了一些功能类型相近的映射，不用单一的 `<Leader>` ，
所以习惯于在每个 `map` 中明确写出哪个 `<Leader>`。可移植性啥的，全局替换或列块
选择编辑就可解决的。

对于有编辑功能的命令，我设定的 `<Leader>` 是逗号。添加英文半角括号引号就用一个
逗号，添加中文全角括号引号，就用两个逗号。
```
nnoremap ,,< <ESC>:call wraptext#func#wrap("《", "》", "n")<CR>
nnoremap ,,[ <ESC>:call wraptext#func#wrap("【", "】", "n")<CR>
" 许多中文括号
```

在各种文件类型插件中，不同编程语言使用不同的注释符号。如在 `cpp.vim` 中使用如
下映射：
```
nnoremap <buffer> ,x <ESC>:call wraptext#func#wrap('// ', '', "n")<CR>
vnoremap <buffer> ,x <ESC>:call wraptext#func#wrap('// ', '', "v")<CR>
vnoremap <buffer> ,,x <ESC>:call wraptext#func#wrap('/*', '*/', visualmode())<CR>
vnoremap <buffer> ,X <ESC>:call wraptext#func#wrap('#if 0', '#endif', visualmode())<CR>
```

Vim 的内置 `x` 命令是删除的意思，注释算是一种特殊删除，因而用 `,x` 作为注释映射。

## 【插入模式的简单映射】

在插入模式如，要输入配对括号，若有特殊需求，一些简单的 `imap` 即可实现。
```
inoremap ` ``<Left>
inoremap ' ''<Left>
inoremap " ""<Left>
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>
inoremap } {}
inoremap ) ()
inoremap ] []
```

如果偏爱在插入模式下工作，
[pairs](https://github.com/jiangmiao/auto-pairs)
提供的功能比较丰富。

<!--
## 【安装使用】
如有需求，按常规的 vim 插件安装方式下载安装。`plugin/Warp.vim` 文件中的键映射
可自行按需调整。不同语言的文本类型插件中，也自行按上述 `cpp.vim` 示例添加映射。
-->
