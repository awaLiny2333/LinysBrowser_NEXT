import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { animation_default, click_effect_default } from '../../hosts/bunch_of_defaults';
import woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofUpdateHistory {
  controller: CustomDialogController;
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @State texts: string[] = [
    'v1.7.10-beta 2025 10' +
      '一个面向未来的更新！正式面向 HarmonyOS 6.0 (API20) 发布！将 Passkey 支持带入冲浪喵～' +
      '注意：我们在此版本中更换了包名，因为有神秘开发者率先将冲浪喵在应用市场抢注了……不过也因祸得福彻底丢弃了大量历史遗留问题？' +
      'A future-oriented update! Now releasing towards HarmonyOS 6.0 (API20)! Bringing Passkey support into BrowserCat~' +
      'CAUTION: We changed our bundle name in this update, as a mysterious dev has already registered the bundle name of BrowserCat in the App Gallery...' +
      'But this comes out as an unexpected gift as bunch of historical left over problems are then discarded?',

    'v1.7.9-beta 2025 10',
    '一个突破性的更新！将多窗口支持、PC / 2in1 使用特化、完全性能优化、启动速度优化……以及更全面的使用体验带入冲浪喵～',
    'A breakthrough update! Bringing multi-window support, PC / 2in1 optimization, full performance optimization, ' +
      'launch speed optimization... and a more well-rounded using experience into BrowserCat~',

    'v1.7.8-beta 2025 07',
    '一个补充性的更新！将浏览器界面右键支持、权限申请、更好的页面内搜索、网页打印、Blob 下载支持、代理下载支持、跨设备接续等功能带入冲浪喵～',
    'A supplementary update! Bringing right click support for ui, Permission Request, better in-page searching, web printing, ' +
      'Blob download support, proxy enabled download support and cross-device continuation support into BrowserCat~',

    'v1.7.7-beta 2025 06',
    '一个实验性的更新！将历史记录索引、更多辅助功能带入冲浪喵～\n' +
      '实现了猫抓板图片处理、一键关闭所有标签页等功能！\n' +
      '在不科学的实验中，这个历史记录索引成功承载长达 20 年、共 1500000 条历史记录而不崩溃，因此 Liny 还有 20 年时间优化它！:P',
    'An experimental update! Bringing history indexing and more accessibility features into BrowserCat~\n' +
      'Implemented image processing for Scratching Board and one button to close all tabs!\n' +
      'In an unscientific experiment, this history indexing system succeeded to host up to 1,500,000 histories for a span of ' +
      'over 20 years without crashing. So, Liny has got another 20 years to optimize it! :P',

    'v1.7.6-beta 2025 05',
    '一个普通的更新，将故障日志查看、性能指示器和大量体验与性能优化带入冲浪喵～\n' +
      '实现了更好的显示区域避让，尝试修复了计算缓存卡顿、历史面板打开卡顿、下载文件名 uri 不解码、自动抓取搜索词加号不解码等体验问题。\n' +
      '并且升级到了 API 16！',
    'A normal update, bringing fault logs viewer, performance monitor and quite a lot of experience & performance optimizations into BrowserCat!\n' +
      'Implemented a better safe area display policy, and ' +
      'tried to fix experience issues like lags when calculating cache size, lags when opening History panel, ' +
      'download file name not decoding from uri codes, ' +
      'and plus signs in auto extracted search keywords not being replaced by spaces, etc.\n' +
      'And upgraded to API 16!',

    'v1.7.5-beta 2025 04',
    '一个神奇的更新，将自定义主页背景、快捷链接带入冲浪喵～\n' +
      '并且尝试修复神秘的崩溃等大量隐藏／关键问题，请务必安装此更新！',
    'A magical (?) update, bringing custom homepage background and shortcuts into BrowserCat!\n' +
      'AND, tried to fix plenty of hidden / critical problems like weird crashing on startup, PLEASE INSTALL THIS UPDATE!',

    'v1.7.4-beta 2025 01',
    '一个主要更新，将键盘快捷键、页面内搜索、JS 管理和无图模式带入冲浪喵～\n' +
      '并且修复了下载无法保存、下载文件名混乱等关键问题，请务必安装此更新！',
    'A major update, bringing Keyboard shortcuts, In-page searching, JavaScript management and No picture mode into BrowserCat!\n' +
      'AND, fixed download saving failure, download wrong file name problems, PLEASE INSTALL THIS UPDATE!',

    'v1.7.3-beta 2024 12',
    '一个常规更新，将沉浸式全屏、曲奇管理和更准确的缓存大小统计带入冲浪喵～\n' +
      '并且并且，现在这个 App 可以被设置为默认浏览器了！',
    'A regular update, bringing Immersive Fullscreen, Cookie management, and more accurate cache size calculation into BrowserCat!\n' +
      'What\'s more, The app can now be set as default browser of system!',

    'v1.7.2-beta 2024 12',
    '一个常规更新，将智能防追踪功能带入冲浪喵～\n' +
      '并且并且，现在这个 App 可以被设置为默认浏览器了！',
    'A regular update, bringing Intelligent Tracking Prevention feature into BrowserCat!\n' +
      'What\'s more, The app can now be set as default browser of system!',

    'v1.7.1-beta 2024 12',
    '一个关键的补充更新，提供了历史自动迁移能力，这样老版本冲浪喵上的历史记录会被继承了！',
    'A KEY PATCH. INTRODUCING HISTORY MIGRATION FROM OLD BROWSERCATS.\n' +
      'So that history records on old BrowserCats would be inherited.',

    'v1.7.0-beta 2024 12',
    '一个关键的发行版更新，将网页深色模式、更新记录、致谢和一些体验优化带入冲浪喵～\n' +
      '这个版本正在尝试优化一些组件的性能问题，但是这需要一些深层的修改。\n' +
      '所以，以前的历史浏览记录和上一次打开的标签页并没有得到继承……对不起！！！\n＞︿＜',
    'A KEY release of a KEY update, bringing better History system and a few experience optimizations into BrowserCat!\n' +
      'This version is trying to solve some performance issue of parts of this project, but this requires some deep level modification.\n' +
      'Therefore, the previous History records and last status of opened tabs are not inherited. So sorry for that...',

    'v1.6.4-beta 2024 12',
    '一个体面的发行版更新，将网页深色模式、更新记录、致谢和一些体验优化带入冲浪喵～',
    'A decent release of update, bringing Web Dark Mode, Update History, Credits and a few experience optimizations into BrowserCat!',

    'v1.6.3-beta 2024 12',
    '一个主要更新计划的早期预览，将储存管理和一些体验优化（和一些 Bug）带入冲浪喵～',
    'An early preview of a major update plan, bringing Storage Management and a few experience optimizations (and some Bugs) into BrowserCat!',

    'v1.6.2-beta 2024 12',
    '一个主要更新计划的早期预览，将自定义主题颜色（和一些 Bug）带入冲浪喵～',
    'An early preview of a major update plan, bringing Customizable Theme Colors (and some Bugs) into BrowserCat!',

    'v1.6.0-beta 2024 11',
    '一个主要更新计划的早期预览，将（操作失败时的）弹窗提醒和更新日志带入冲浪喵～',
    'An early preview of a major update plan, bringing notice prompts (when an operation fails) and update notes into BrowserCat!',

    'v1.5.3-beta 2024 11',
    '一个主要更新，将更好的设置面板布局、更好的历史面板 UI 和广告过滤带入冲浪喵～\n' +
      '将 HarmonyOS 的 compileSdkVersion 提升到了 13，修复了若干个问题、完成了一些代码清理！',
    'A major update, bringing better Settings Panel arrangement, better UI for History Panel and Ads Blocker into BrowserCat!\n' +
      'Changed compileSdkVersion for the HarmonyOS product to 13. Fixed several bugs and did bunch of code clean up!',

    'v1.5.0-beta 2024 10',
    '一个主要更新，将横排标签页面板和拖放面板（猫抓板！）带入冲浪喵～\n' +
      '增加了移动书签／文件夹的入口，并且修复了若干个问题、完成了一些代码清理！',
    'A major update, bringing Horizontal Tabs Panel and links / text dropping panel (Scratching Board!) into BrowserCat!\n' +
      'Added entry to move a bookmark or folder to another position, fixed several bugs and did bunch of code clean up!',

    'v1.4.0-beta 2024 10',
    '冲浪喵的第一个发行版本！\n' +
      '完成了垂直标签页、书签管理、历史记录、网页内下载、搜索关键词联想、自定义UA、自定义搜索引擎，和很多动效！',
    'The first release of BrowserCat!\n' +
      'Finished vertical tabs, bookmarks management, history records, in web downloads, keyword typing suggestions, custom UA, custom search engine, and some many animations!'
  ];
  @LocalStorageLink('opened_dialog_controllers') opened_dialog_controllers: CustomDialogController[] = [];

  aboutToAppear(): void {
    this.opened_dialog_controllers.push(this.controller);
    console.log(`[Dialog][Open] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  aboutToDisappear(): void {
    this.opened_dialog_controllers.splice(this.opened_dialog_controllers.indexOf(this.controller), 1);
    console.log(`[Dialog][Close] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  build() {
    woofControlFrame({
      title: $r('app.string.Update_record'),
      controller: this.controller
    }) {
      Scroll() {
        Column({ space: 10 }) {
          ForEach(this.texts, (text: string, index: number) => {
            if (index % 3 == 0) {
              release_card({
                title: text,
                text_eng: this.texts[index + 1],
                text_chi: this.texts[index + 2],
              })
            }
          })
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width("100%")
      }
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
    }
  }
}

export default woofUpdateHistory;

@Component
struct release_card {
  @State title: string = '';
  @State text_eng: string = '';
  @State text_chi: string = '';

  build() {
    Column({ space: 8 }) {
      linysTextTitle({
        text: this.title,
      })
        .width("100%")
      linysText({
        text: this.text_eng,
        max_lines: 30
      })
        .width("100%")
        .opacity(0.7)
      linysText({
        text: this.text_chi,
        max_lines: 20
      })
        .width("100%")
        .opacity(0.7)
    }
    .clickEffect(click_effect_default())
    .alignItems(HorizontalAlign.Start)
    .padding(10)
    .borderRadius(10)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .width("100%")
    .animation(animation_default())
  }
}