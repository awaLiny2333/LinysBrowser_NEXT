export enum CTag {
  DEBUG = '󰃶 Bug',
  FEAT = '󰟢 Feat',
  MEOW = '󰉿 Meow'
}

export interface Contribution {
  id: number;
  tags: CTag[];
  desc: string;
}

export interface CreditDetails {
  name: string;
  contributions: Contribution[];
}

const c2: Contribution = { id: 2, tags: [CTag.FEAT], desc: 'Horizontal Tabs & Custom UA' };
const c3: Contribution = { id: 3, tags: [CTag.DEBUG], desc: 'Unintentional color' };
const c6: Contribution = { id: 6, tags: [CTag.FEAT], desc: 'Moving / rearranging bookmarks' };
const c8: Contribution = { id: 8, tags: [CTag.FEAT], desc: 'Respond to system back' };
const c11: Contribution = { id: 11, tags: [CTag.MEOW, CTag.FEAT], desc: 'More preset search engines' };
const c12: Contribution = { id: 12, tags: [CTag.FEAT], desc: 'Auto collapse tabs after clicking on a tab entry' };
const c22: Contribution = { id: 22, tags: [CTag.FEAT], desc: 'Web (force) dark mode' };
const c27: Contribution = { id: 27, tags: [CTag.FEAT], desc: 'Download directly to system Download directory' };
const c28: Contribution = { id: 28, tags: [CTag.MEOW, CTag.FEAT], desc: 'Introduce keyboard shortcuts to BrowserCat!' };
const c29: Contribution = { id: 29, tags: [CTag.DEBUG], desc: 'Failure in saving downloaded files (become files of 0B, or filename not supported)' };
const c33: Contribution = { id: 33, tags: [CTag.DEBUG, CTag.FEAT], desc: 'Failure in recognizing IPv4 addresses with ports & button to switch between http & https' };
const c38: Contribution = { id: 38, tags: [CTag.DEBUG], desc: 'Stand-alone History panel' };
const c39: Contribution = { id: 39, tags: [CTag.MEOW, CTag.FEAT], desc: 'Custom homepage backdrop & Shortcuts' };
const c40: Contribution = { id: 40, tags: [CTag.FEAT], desc: 'Quick switch in UA & Easylist & App profile backup' };
const c41: Contribution = { id: 41, tags: [CTag.DEBUG], desc: 'Failure in downloading / saving image' };
const c42: Contribution = { id: 42, tags: [CTag.DEBUG], desc: 'Downloads not handled by proxy' };
const c46: Contribution = { id: 46, tags: [CTag.FEAT], desc: 'Close all tabs' };
const c47: Contribution = { id: 47, tags: [CTag.FEAT], desc: 'Customizable homepage shortcuts height' };
const c48: Contribution = { id: 48, tags: [CTag.DEBUG, CTag.FEAT], desc: 'Fault logs storing and missing (?)' };
const c50: Contribution = { id: 50, tags: [CTag.FEAT], desc: 'Single hand optimization for Settings panel menu' };
const c52: Contribution = { id: 52, tags: [CTag.MEOW, CTag.FEAT], desc: 'Multi-window system' };
const c53: Contribution = { id: 53, tags: [CTag.FEAT], desc: 'Select homepage background from Galler & History panel shortcut & hide navigation indicator and bottom avoid' };
const c54: Contribution = { id: 54, tags: [CTag.DEBUG], desc: 'Link jump prompt too long' };
const c56: Contribution = { id: 56, tags: [CTag.FEAT, CTag.DEBUG], desc: 'Tablet floating window bug, gesture control on side bars, Basic Auth support, landscape floating window, EasyList support and many more!' };
const c57: Contribution = { id: 57, tags: [CTag.FEAT], desc: 'Web context menu' };
const c58: Contribution = { id: 58, tags: [CTag.DEBUG], desc: 'Failure in switching to default UA' };
const c62: Contribution = { id: 62, tags: [CTag.MEOW, CTag.DEBUG, CTag.FEAT], desc: 'Pin window & tablet free window mode issues' };
const c63: Contribution = { id: 63, tags: [CTag.FEAT], desc: 'Save to Gallery in Scratching Board' };
const c64: Contribution = { id: 64, tags: [CTag.FEAT], desc: 'Save web page as MHTML & open HTML files' };
const c65: Contribution = { id: 65, tags: [CTag.FEAT], desc: 'Launch speed optimization' };
const c67: Contribution = { id: 67, tags: [CTag.DEBUG], desc: 'Failure in loading the requested url from jump from another app' };
const c68: Contribution = { id: 68, tags: [CTag.DEBUG], desc: 'Another failure in download' };
const c69: Contribution = { id: 69, tags: [CTag.DEBUG], desc: 'Failure in recognizing URLs with ports (broken again)' };
const c72: Contribution = { id: 72, tags: [CTag.FEAT], desc: 'Force screen orientation' };
const c73: Contribution = { id: 73, tags: [CTag.FEAT], desc: 'Detailed build time' };
const c74: Contribution = { id: 74, tags: [CTag.DEBUG], desc: 'Lagging in scrolling in web' };
const c76: Contribution = { id: 76, tags: [CTag.MEOW, CTag.DEBUG], desc: 'Another failure in download but this time related to UI' };
const c82: Contribution = { id: 82, tags: [CTag.DEBUG], desc: 'Link jump prompt too long (broken again)' };
const c85: Contribution = { id: 85, tags: [CTag.DEBUG], desc: 'Link jump prompt too long (reported again)' };
const c86: Contribution = { id: 86, tags: [CTag.FEAT], desc: 'Pin more buttons to the Title Bar' };
const c87: Contribution = { id: 87, tags: [CTag.FEAT], desc: 'Copy download url in download dialog' };
const c94: Contribution = { id: 94, tags: [CTag.DEBUG], desc: 'Failure in restoring too long web states' };
const c98: Contribution = { id: 98, tags: [CTag.MEOW, CTag.FEAT], desc: 'Failure in restoring too long web states' };

/**
 * All user credits!
 */
export const userCredits: CreditDetails[] = [
  { name: 'sseaan', contributions: [c2] },
  { name: 'SolidFaker', contributions: [c3, c27, c29] },
  { name: 'lsxuan12138', contributions: [c6] },
  { name: 'xymeng16', contributions: [c8, c11] },
  { name: 'Luxcis', contributions: [c12] },
  { name: '000wbh000', contributions: [c22, c28, c29, c74] },
  { name: '16620106075', contributions: [c29] },
  { name: 'Liuyexin', contributions: [c29] },
  { name: 'vincenthsing', contributions: [c33] },
  { name: 'XiaoBaiXBS', contributions: [c38, c39, c40, c41, c42, c47, c48, c50, c54, c58, c62, c63, c64, c67, c68, c73, c76] },
  { name: 'WJ-T', contributions: [c46] },
  { name: 'nimmi114514', contributions: [c57] },
  { name: 'yushuo1532', contributions: [c65] },
  { name: 'msgdw', contributions: [c69, c72, c94] },
  { name: 'YukiNo420', contributions: [c53, c56] },
  { name: 'wangfh5', contributions: [c52] },
  { name: 'CoyoteRover', contributions: [c82] },
  { name: 'gfhdhytghd', contributions: [c85,c86] },
  { name: 'xccxxcys', contributions: [c87] },
  { name: 'alex3236', contributions: [c98] }
];
