# EmEditorUpdater

由于EmEditor 便携版不支持自动更新，手动更新较为繁琐，需要打开EmEditor官网找到便携版的下载地址 --> 下载 --> 解压 --> 覆盖 --> 激活(如果需要的话），这些步骤几乎全为纯手工操作，极为繁琐，本工具的诞生就是为了解决EmEditor便携版检查更新升级不方便的问题。

使用方法：

1. 将Release目录下的文件拷贝到EmEditor目录下的 ExTool\EmEditorUpdater 目录下（如果没有的话，就手工新建一个）。

2. 在EmEditor的外部工具设置里新增一个 Update 和 Updateconfig 的工具，设置如下：

![外部工具栏](https://raw.githubusercontent.com/DavidWang88/EmEditorUpdater/master/ScreenCapture/extoolbar.png "外部工具栏")
![update](https://raw.githubusercontent.com/DavidWang88/EmEditorUpdater/master/ScreenCapture/update.png "Update")
![updateconfig](https://raw.githubusercontent.com/DavidWang88/EmEditorUpdater/master/ScreenCapture/updateconfig.png "Updateconfig")

3. 点击工具栏上的 Updateconfig 即可打开更新配置对话框，点击工具栏上的 Update 即可执行静默更新。