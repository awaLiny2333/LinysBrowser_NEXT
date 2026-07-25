export interface updateHistory {
  version: string;
  date: string;
  tag: string[];
  description_zh: string;
  description_en: string;
}

/**
 * Update tags
 */
enum updateTag {
  BETA = '󰃯 Beta',
  MEOW = '󰉿 Meow',
  FIX = '󰃶 Fixes'
}

/**
 * Hard-coded update history.
 */
export const updateHistories: updateHistory[] = [
  {
    version: '2.1.0',
    date: '2026 07',
    tag: [updateTag.FIX, updateTag.MEOW, updateTag.BETA],
    description_zh: '优化了用户体验、补全功能，还修复了大量的、潜伏的、难以察觉的、但是很可能要命的问题！\nヽ( ´¬`)ノ\n优化用户代理快速切换逻辑、右键菜单现已兼容本地图片、全屏模式下导航指示器自动隐藏。\n利用原子写入机制一定程度上加固了书签与历史记录系统的数据安全性；强化多窗口、Web 引擎等核心模块的异常防护；修复了关闭最后一个标签页时崩溃、下载取消后实际并没有取消下载（居然从来没有人发现）、网站无 favIcon 时无法添加桌面快捷方式、非自由窗口模式下顶栏标题显示位置过低、颜色选择器中对 0 颜色值判断异常、搜索引擎拼接 URL 时 %s 未全部替换等问题；减少了更新搜索结果建议时重复的分词处理，优化了关键字词条排序实现，为动画参数与标签页域名信息设计缓存以降低内存和计算压力。',
    description_en: 'Optimized user experience and expanded features, while fixing a large batch of lurking, hard-to-spot, but potentially fatal bugs! \nヽ( ´¬`)ノ\nImproved UA quick-switching logic; the context menu now supports local images; the navigation indicator now auto-hides in fullscreen. \nStrengthened data safety for bookmarks and history via atomic writes; hardened exception handling in core modules including multiwindow and the Web engine; fixed a crash when closing the last tab, downloads silently refusing to cancel (shockingly, nobody ever noticed), failure to add desktop shortcuts when a site lacks a favIcon, the top-bar title sitting too low in non-free-window mode, incorrect handling of the color value 0 in the color picker, and incomplete `%s` replacement when constructing search engine URLs. Reduced redundant tokenization during search suggestion updates, improved keyword entry sorting, and introduced caching for animation parameters and tab domain info to ease memory and computation overhead.',
  },
  {
    version: '2.0.0',
    date: '2026 06',
    tag: [updateTag.MEOW, updateTag.BETA],
    description_zh: '我常常思考，如果这只冲浪的小猫咪有了 2.0 会怎么样……\n——于是它诞生了！\n使用船新架构搭建的冲浪喵！这艘特修斯之船将在状态管理 V2、fastbuffer、猫咪典型 UI 框架和先进人工智能技术的加持下，继续驶向充满未知的汪洋！',
    description_en: 'I often wondered… what if this surfing little kitty had a 2.0?\n— And then it happened!\nMeat BrowserCat rebuilt on a brand-spanking-new architecture! This very Ship of Theseus, powered by State Management V2, FastBuffer, the Cats\' Typical UI Framework, and cutting-edge AI, now sails boldly into the vast, uncharted ocean of possibilities!',
  },
];
