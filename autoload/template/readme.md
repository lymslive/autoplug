# VimL 模块与类文件模板生成工具

## builder 生成命令

* `:ClassNew classname [-options]` 当前目录需在 `autoload` 或其子目录，生成
`classname.vim` 文件作为 `classname` 类定义文件。
* `:ClassAdd [-options]` 与 `:ClassNew` 类似，但在当前编辑的文件中添加类定义代码，类名根
据文件名决定，当前文件须在 `autoload` 或其子目录下。
* `:ClassTemp [-options]` 与 `:ClassAdd` 类似，但不要求当前文件在 `autoload` 目录下。只是
将 `tempclass` 的代码载入临时查看。

这三个命令支持许多选项参数，用于指定包含或不包含模板类定义中的某些方法组件。
用 `:ClassTemp -a` 将 [tempclass.vim](autoload/tempclass.vim) 全部内容载入。
该源文件中每段前的注释中标记了选项参数，小写字母表示默认提取，大写字母表示默认不提取。
这三个命令末尾可附加选项覆盖源文件中指定的选项（各选项字母组合一起当作一个参数传入）。

* `:ClassPart -xyz` 必须带上选项参数，只将指定参数的源文件段提取，忽略源文件中
自己标记的默认选项。主要用于已用 `:ClassNew` 或 `:ClassAdd` 添加类代码后，需
要补充少量遗漏的组件。

