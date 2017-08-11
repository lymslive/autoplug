# Edit in Double vertically splited windows

## Summary

One vim plugin is actually related to one working style, and it may be less
useful if not like the style. This plugin try to be helpful with editing in
large vim screen, when split into at least two windows.

With this plugin, it will be more convinient to jump between two windows,
copy/move content to the destination window, jump tags in the other window,
mirror the two window edit the same buffer (with different part), and ect.

If you prefer only using one main editing window, and/or stick other plugin
functional mini-buffer window, such as tagbar or NEDTRee, then this plugin
play bad. However, it will still work if you has addition tow editing windows,
if you computer screen is large enough.

Some tricks is inspired by a.vim (alternate buffer), such as :E and :D simple
ex commands' definition.

Documentation laguage: English in comment and doc, Chinese in the left README.

## 背景介绍

现在的计算机显示器屏幕普遍很大了。我用 vim 时一般将是最大化窗口，然后分隔为左
右两个编辑主窗口。在这两个窗口是载入相关的文件，譬如 C 语言的头文件与源文件，
或任意两个调用关系紧密的源文件，或任何需要对照着看（但又不是同一件的版本对比，
此时应该用 vimdiff 模式）的文件，或在两个窗口显示同一个大文件的不同部分。

总之我的实践经验认为，两个窗口，尤其是纵向分隔的两个窗口，是一种很舒适的符合人
体心理工学的操作方式。

另外一些 vim 用户，可能喜欢加载许多辅助插件。比如：左边是文件浏览器（NEDTRee）
，右边是标签列表（Tagbar/Taglist），下边是 quickfix ，上边是 minibuffer，诺大
的屏幕就剩中间一块区域用来编辑了。如此细致地将 vim 模拟打造与一个 IDE，我觉得
是与 vim 的设计哲学是相违和的。

事实上，我也装了这许多插件，但我最后都将其窗口设为自动隐藏了。没必要让它们始终
占用屏幕空间，只在需要时用快捷键调出，完成其使命后就让它退居后台服务。最大化编
辑窗口！于是在大部分工作时间，我的 vim 就是两个朴素的分隔窗口，它们都是编辑主
窗口。然后我就归纳了些常用操作，写成这个插件脚本，使之更方便地在这样的环境下工
作。

## 主要功能

下面以默认的自定义命令介绍主要功能，自定义命令 (command) 与键映射 (map) 其实都
是很个性化的习惯，理应支持用户配置调整。

* :E 在当前窗口打开另外一个窗口中的文件；
* :D 在另外一个窗口中打开当前窗口中的文件，这两个命令在无参数时都将使两个窗口
  编辑同一个文件；
* :ED 同时在两个窗口打开两个文件，如果未明确提供第二个文件参数，则尽量搜索一个
  相关的文件打开在另一个窗口；
* :EA 在当前窗口打开另个窗口的相关文件；
* :DA 在另一个窗口打开当前窗口的相关文件；

相关文件的概念请参考 a.vim 插件，它主要提供了 :A 命令。另一个窗口也可称之为“目
标窗口”。

* :Dtag 执行 :tag 命令，但在目标窗口中显示跳转位置；
* :Dpop 在目标窗口中执行 :pop 命令，跳回标签栈；
* :Dcopy 将当前行或选定行拷贝到目标窗口的当前光标下；
* :Dmove 与 Dcopy 类似，不过复制模式改为剪切模式；

这几个命令正常完成后，光标都将回到原来窗口。

* :DD 接收任意参数，在另一个窗口执行参数所示的命令，然后回到当前窗口。

## 注意事项

* 如果原来只有一个窗口，大多数命令会自动纵向分隔为左右两个窗口。
* 如果有三个以上窗口，会自动将其他所有窗口中区域面积（宽乘高）的窗口认为是另一
  个目标窗口。

所以，如果真的很在意一些插件的辅助窗口，依然可以在分隔两个编辑主窗口的同时长驻
打开其他一个或若干个辅助插件窗口，只要你的屏幕够大，且辅助窗口不会喧宾夺主的话
，这个插件应该依然可正常工作。

## 插件定制

插件的所有函数采用 vimScript 的自动加载机制，放在 autoload/ 目录下，而 plugin/
目录下的脚本，仅仅是些参数选项的设置 let 与自定义的 map 与 command。允许且鼓励
用户根据自己喜好修改设置与解决 map 的按键冲突。

脚本自带注释说明，应该足够简明。如果连简单的 remap 与 command 都不明白的话，你
应该加强 vim 的基本功训练，而不是去找花俏的插件。

如果担心修改“别人”的插件会导致以后更新冲突，你可以将该插件 ED.vim 改名或另存为
setlocal.vim。这样，只会执行你本地的设置脚本。

仍然是那句话，vim 插件只是分享一种工作方式。
