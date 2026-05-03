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
  MEOW = '󰉿 Meow'
}

/**
 * Hard-coded update history.
 */
export const updateHistories: updateHistory[] = [
  {
    version: '2.0.0',
    date: '2026 06',
    tag: [updateTag.BETA, updateTag.MEOW],
    description_zh: '我常常思考，如果冲浪喵有 2.0 会怎么样……\n——于是它诞生了！\n使用船新架构搭建的冲浪喵！这艘特修斯之船将在状态管理 V2、fastbuffer、猫咪典型 UI 框架和先进人工智能技术的加持下，继续驶向充满未知的汪洋！',
    description_en: 'I often wondered… what if Surfing Meow had a 2.0?\n— And then it happened!\nMeat BrowserCat rebuilt on a brand-spanking-new architecture! This very Ship of Theseus, powered by State Management V2, FastBuffer, the Cats\' Typical UI Framework, and cutting-edge AI, now sails boldly into the vast, uncharted ocean of possibilities!',
  },
];
