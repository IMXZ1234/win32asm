# 罗云彬 Windows环境下32位汇编语言程序设计 配套程序

手打的代码，与原文内容在命名和程序结构上有细微差异，功能是一致的。

# 原书下载链接

链接：https://pan.baidu.com/s/1ETo1ZEUkJkPxThtqRQtPNA 

提取码：f1ue

# 使用指南

请参阅原书 *第2章 准备编程环境* ，其中大部分内容依然适用，在此作如下补充：
1. 项目维护工具nmake在Visual Studio工具包中，请至官方网站下载Visual Studio。<br>对于Visual Studio 2019 Community版本，nmake.exe所在的目录为:<br>*C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30037\bin\Hostx64\x86*

2. 书中建议每次编译前运行Var.bat设置临时环境变量，实际操作上不如直接设置永久系统环境变量来得方便：<br>环境变量的设置在 此电脑-->计算机(在工具栏上)-->系统属性-->高级系统设置(右侧)-->环境变量<br>如图在系统变量处新建：<br>
(1) lib条目，路径为masm安装目录下的lib目录 (*C:\masm32\lib*)<br>
(2) include条目，路径为masm安装目录下的include目录 (*C:\masm32\include*)<br>
![lib_include.png](https://github.com/IMXZ1234/win32asm/blob/master/bin_include.png)<br>
如图在path条目下添加：<br>
(1) masm安装目录下的bin目录路径，其中包含rc.exe, link.exe, ml.exe (*C:\masm32\bin*)<br>
(2) nmake.exe所在目录路径 (*C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30037\bin\Hostx64\x86*)<br>
![path.png](https://github.com/IMXZ1234/win32asm/blob/master/path.png)<br>
注意在nmake.exe所在目录路径下也存在Visual Studio工具包自带的rc.exe, link.exe, ml.exe，而我们需要使用的是MASM32 SDK自带的rc.exe, link.exe, ml.exe，请务必保证 (1) masm安装目录下的bin目录路径 较 (2) nmake.exe所在目录路径 处于path条目中较为靠前的位置！<br>
完成设置后打开命令行，cd进入任意工程目录(如*./chapter_4/first_window*)，键入nmake指令即可完成编译链接生成exe文件。

3. 由于编译链接过程中经常使用cmd.exe，可以在右键菜单中添加在当前目录下运行cmd项，免得每次都需要cd到当前目录。运行 添加cmd到右键菜单.reg 即可完成添加。

持续更新中

如有疑问欢迎通过邮箱联系我：IMXZ123@sjtu.edu.cn