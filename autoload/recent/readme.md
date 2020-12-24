# Recent: 全局记录最近打开的文件

* `Recent` : 等效 `Recent file`
* `Recent f[ile]` ：列出最近打开的文件
* `Recent d[ir]` ：列出最近打开的文件所在目录
* `Recent .ext` ：列出最近打开的后缀名为 `.ext` 的文件

最近文件/目录列表以 json 格式保存于 `$VIMHOME/autoload/my/recent/save.json` 。
当执行 `PI recent` 加载该插件时，自动读入保存的列表，退出 vim 时自动保存。
以此记录全局的最近访问文件/目录。

内置命令 `oldfiles` 可以列出记录在 `.viminfo` 中的最近打开文件。这个自定义命令
`Recent` 有所加强，还可以按目录或文件类型（后缀名）更快捷地筛选
