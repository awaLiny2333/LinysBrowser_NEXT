# Liny 的浏览器！

[中文](README.md) | [English](README_EN.md)

## 快速上手

在 [build_auto](build_auto) 目录下有最新测试版本的 build 产品，
这些产品可能存在某些未发现的不稳定因素，不建议长期使用
——用了的话，记得常来检查更新！

在界面下方的输入框里输入 URL 或关键词，并且回车或点击小放大镜以提交。

点击四个小圆点（2x2）组成的按钮以查看页面详情和更多功能，再点一次以关闭面板。

## 启发

Liny 的浏览器为 HarmonyOS NEXT 而构建，旨在为各种性能水平的设备提供一个浏览器的轻量之选。

这个项目受 tuyafeng 大佬传奇之作 [Via](https://viayoo.com/)、
来自 Mozilla 的最可爱赛博小狐狸 [Firefox](https://firefox.com/) 之启发，
以及来自开源鸿蒙的 [浏览器](https://gitee.com/openharmony/applications_app_samples/tree/master/code/BasicFeature/Web/Browser)
及其定制增强版分支 [🌐 浏览器CE（社区版）](https://gitee.com/westinyang/browser-ce)
开放代码的帮助（解惑），最终得以呈现。感谢你们！！(*￣3￣)╭

## 预览

大屏（浅色）：

![Tablet_light](Examples/gallery_4.png)

折叠屏（深色）：

![Foldable_Dark](Examples/gallery_1.png)

手机（浅色）：

|                    浏览页面                    |                    标签页面                     |
|:------------------------------------------:|:-------------------------------------------:|
| ![Phone_light_web](Examples/gallery_2.png) | ![Phone_light_tabs](Examples/gallery_3.png) |

## 相关权限

[ohos.permission.INTERNET](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/security/permission-list.md#ohospermissioninternet)

## 计划和开发

可能需要很多时间，也可能有些东西会永远被搁置。(ง •_•)ง

### 功能

- [x] Cookies 管理与清理
- [x] 缓存管理与清理
- [x] 广告过滤
- [ ] 隐私模式
- [x] 页面内搜索
- [x] 禁用 JavaScript
- [ ] 网页链接右键／长按菜单（预览、操作）
- [x] 无图模式
- [ ] 阅读模式
- [ ] 搜索建议
- [ ] 插件／脚本
- [ ] DRM 内容支持
- [x] 响应网页的新标签页打开要求
- [x] 网页内下载功能
- [x] UA 切换与自定义（UA 相关设置）
- [x] 启动时恢复上次浏览的进度
- [x] 多任务平行浏览

### 体验

- [x] 自定义主题（配色）
- [x] 标题栏自定义上下
- [x] 标签页栏自定义横竖
- [x] 接入系统返回
- [x] 客制化动画曲线

## 约束和限制

道阻且长。

1. 由于 Liny 不成体系的编程思想和低陋的代码水平，这个应用可能存在一些性能问题。 
   如果出现错误，还请各路前辈高手斧正，感激不尽！
2. 神秘问题导致应用启动后第一次打开设置页面会发现某些分段按钮不显示已选择的项。
3. 由于神秘的问题和暂时却不得不的妥协，
   有时候启动应用后广告屏蔽白名单可能生效不及时，导致网页上的广告还是被屏蔽了。
   （正在想办法解决）
4. 由于神秘的问题和暂时却不得不的妥协，
   有时候启动应用后广告屏蔽启用可能生效不及时，导致网页上的广告没有被屏蔽。
   （正在想办法解决）
5. 在某些情况下打开上次关闭时的标签页功能会失败，于是什么标签页都没有显示出来。（正在调查）
6. 也许是因为 Windows x86-64 模拟器的性能问题，快速打开大量新标签页会导致错误 17100001
   (Init error. The WebviewController must be associated with a Web component)
   并且使应用崩溃。
   （似乎解决了，但是仍有待观察）
7. 快速关闭很多标签页似乎会导致所有的标签页按钮消失。
   这是因为在某些未知的特定条件下，标签页按钮会尝试关闭 最后+1 个标签页面。
   一个判断语句已经被添加，用于检测请求关掉的页面是否合法。
   （似乎解决了，但是仍有待观察）
8. HarmonyOS UA 不被很多网站所理解，并且常常会导致不正确的网站呈现（但是可以自定义 UA 了）。
9. 当垂直标签页高度超过屏幕高度，并且启用滚动（Scroll）时，关闭、新建标签页动画效果可能会很奇怪。
10. 这个项目要求 HarmonyOS NEXT API12 以运行。

## 提交信息的说明
这个项目诞生以来的提交信息过于混乱，于是 Liny 决定作出一些自我约束……

1. fix：修复更新，用于标注对一个问题的修复；
2. feat：功能更新，一般用于标注推出了什么新功能；
3. improve：改进更新，一般用于标注已有的某些东西的变化，如逻辑、界面、文案等；
4. code：代码更新，用于标注代码优化，如代码整理、逻辑整理等；
5. version：版本号变更，用于标注版本号的变化；
6. api：API 级别变更，用于标注需要的 API 级别的变化；
7. other: 未归类的其它提交。