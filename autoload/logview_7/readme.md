# vim 查看日志扩展插件

## 背景

日志目录有大量日志文件，一般以 `.log` 后缀名。
常有同名的系列日志，名字前缀加日期后缀，再加 `.log` 。

典型的日志文件名如：log-name-yyyymmdd-hhmmss.log 。
可以按时间排序，最常见的需求是打开最后一个日志文件。

## 命令与用法

* :Elog [log-name] 打开以 `log-name` 为前缀的最后一个日志文件。
* :ElogNext 打开后一个日志，取当前打开的日志文件前缀，按时间序。
* :ElogPrev 打开前一个日志。
* :ElogList [-n] {log-name} 列出最后几个日志文件名，可以指定后缀

ElogList 按时间倒序列出日志文件，形成编号菜单，然后执行 Elog -n 打开指定编号的
日志文件。列出菜单后自动提示，也可再次手动执行 Elog -n 。这里 n 为编号。

* :Glog word 对当前日志文件 grep 筛选，在新 tabpage 打开临时 buffer
