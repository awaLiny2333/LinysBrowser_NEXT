# Liny 的浏览器！

## 启发

Liny 的浏览器兼容 HarmonyOS NEXT API12，旨在为各种性能水平的设备提供一个轻量的浏览器的选择。

这个项目受 tuyafeng 大佬传奇之作 [Via](https://viayoo.com/)、
来自 Mozilla 的最可爱赛博小狐狸 [Firefox](https://firefox.com/) 之启发，
以及来自开源鸿蒙的 [浏览器](https://gitee.com/openharmony/applications_app_samples/tree/master/code/BasicFeature/Web/Browser)
及其定制增强版分支 [🌐 浏览器CE（社区版）](https://gitee.com/westinyang/browser-ce) 开放代码的帮助（解惑），最终得以呈现。感谢你们！！

## 预览

大屏（浅色）：

![Tablet_light](Examples/Tablet_light.png)

折叠屏（深色）：

![Foldable_Dark](Examples/Foldable_dark.png)

手机（浅色）：

|                       浏览页面                       |                        标签页面                        |
|:------------------------------------------------:|:--------------------------------------------------:|
| ![Phone_light_web](Examples/Phone_light_web.png) | ![Phone_light_tabs](Examples/Phone_light_tabs.png) |

## 快速上手

在界面下方的输入框里输入 URL 或关键词，并且回车或点击小放大镜以提交。

点击四个小圆角矩形（2x2）组成的按钮以查看标签页，再点一次以关闭面板。

点击四个小圆点（2x2）组成的按钮以查看页面详情和更多功能，再点一次以关闭面板。

## 相关权限

[ohos.permission.INTERNET](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/security/permission-list.md#ohospermissioninternet)

## 约束和限制

这个项目至离稳定和完成道阻且长。

1. 也许是因为 Windows x86-64 模拟器的性能问题，快速打开大量新标签页会导致错误 17100001
   (Init error. The WebviewController must be associated with a Web component)
   并且使应用崩溃。
   （似乎解决了，但是仍有待观察）
2. 快速关闭很多标签页似乎会导致所有的标签页按钮消失。
   这是因为在某些未知的特定条件下，标签页按钮会尝试关闭 最后+1 个标签页面。
   一个判断语句已经被添加，用于检测请求关掉的页面是否合法。
   （似乎解决了，但是仍有待观察）
3. HarmonyOS UA 不被很多网站所理解，并且常常会导致不正确的网站呈现。
4. 当垂直标签页高度超过屏幕高度，并且启用滚动（Scroll）时，关闭、新建标签页动画效果可能会很奇怪。
5. 这个项目要求 HarmonyOS NEXT API12 以运行。