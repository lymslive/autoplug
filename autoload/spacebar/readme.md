# 空格快捷键

空格是最方便的按键，但在 vim 内置基本没利用这个键。
所以写了该插件，试图最大化利用该方便的快捷键。
提供了多套空格快捷键，其中最有用的可能是混合模式与CPP模式。

## 主要功能

可以用 Space 自定义命令选择不同的空格映射模式，
并且映射了 `\<Space>` 自动循环不同模式。
不同文件可以用不同的空格映射套餐。

### Mix 混合模式

* 普通模式下，切换折叠，或寻找下一空行（即}）
* 选择模式下，限字符选择，搜索选定的文本，拷入 / 之后
* 操作后缀模式下，按 } 至下一空行
* 插入模式，当然不改变空格意义

```
nnoremap <buffer> <Space>   @=(foldlevel(line('.'))>0) ? "za" : "}"<CR>
nnoremap <buffer> <S-Space> @=(foldlevel(line('.'))>0) ? (foldclosed(line('.'))>0? "zr":"zm") : "{"<CR>
vnoremap <buffer> <Space>   y/<C-R>=(visualmode() != 'v')? "" : getreg()<CR>
vnoremap <buffer> <S-Space> y?<C-R>=(visualmode() != 'v')? "" : getreg()<CR>
onoremap <buffer> <Space>   }
onoremap <buffer> <S-Space> {
```

### CPP 模式

适用于 C++ 源文件，在混合模式基础上，改进了普通模式下的功能行为。

* 如果光标位于已折叠区，则打开折叠
* 如果光标位于大括号{}之上，关闭折叠
* 如果在空行上，显示当前函数头定义行
* 否则在一般文本行上，空格将在行首行尾切换，集 ^$ 功能于一键，且移至行尾时能处
  理忽略最末的悬式开大括号 { 。

如果在 C++ 文件中不同在大括号处识别折叠，请设置正确折叠方式：`set foldmethod=syntax`。

### 其他模式

* View 视图模式，用空格翻页，PageDown
* Fold 折叠模式，空格全部映射为折叠相关功能
* Search 搜索模式，全部映射到 /? 相关搜索功能
* Edit 编辑模式，用于优化处理空行与空格

## 使用方法

重映射的空格键是局部于文件 buff 的，所以一开始并未改变全局的空格映射。可自行在
vimrc 中复制定义一个自己满意的全局空格映射。

在本插件的 plugin/Spacebar 中提供以下命令与快捷键：

```
command! -narg=?  Space call Spacebar#SpaceModeSelect(<f-args>)
noremap \<Space> :Space<CR>
```

用于为当前文件按需选择不同的空格映射套餐。

Space 命令可接受参数为以上介绍的模式：Mix, Cpp, View, Fold, Search, Edit，可简
写首字母。不带参数时自动轮循切换下一个。

若要为 C++ 文件中自动使用 Cpp 空格键映射，可用自己的 ftplugin/cpp.vim 文件中加
入如下一行：

```
silent! call Spacebar#SpaceModeSelect('Cpp')
```

不带 silent 时会额外在状态栏下面回显成功切换空格按键模式的一行消息。
