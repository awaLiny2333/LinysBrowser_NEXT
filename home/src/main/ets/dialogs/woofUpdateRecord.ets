import linysText from '../components/linysText';
import linysTitleText from '../components/linysTitleText';
import { animation_default } from '../hosts/bunch_of_defaults';

@CustomDialog
struct woofUpdateRecord {
  controller: CustomDialogController;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @State texts: string[] = [
    'v1.6.3-beta',
    'An early preview of a major update plan, bringing Storage Management and a few experience optimizations (and some Bugs) into Browser Cat!',
    '一个主要更新计划的早期预览，将储存管理和一些体验优化（和一些 Bug）带入冲浪喵～',

    'v1.6.2-beta',
    'An early preview of a major update plan, bringing Customizable Theme Colors (and some Bugs) into Browser Cat!',
    '一个主要更新计划的早期预览，将自定义主题颜色（和一些 Bug）带入冲浪喵～',

    'v1.6.0-beta',
    'An early preview of a major update plan, bringing notice prompts (when an operation fails) and update notes into Browser Cat!',
    '一个主要更新计划的早期预览，将（操作失败时的）弹窗提醒和更新日志带入冲浪喵～',

    'v1.5.3-beta',
    'A major update, bringing better Settings Panel arrangement, better UI for History Panel and Ads Blocker into Browser Cat!\n' +
      'Changed compileSdkVersion for the HarmonyOS product to 13. Fixed several bugs and did bunch of code clean up!',
    '一个主要更新，将更好的设置面板布局、更好的历史面板 UI 和广告过滤带入冲浪喵～\n' +
      '将 HarmonyOS 的 compileSdkVersion 提升到了 13，修复了若干个问题、完成了一些代码清理！',

    'v1.5.0-beta',
    'A major update, bringing Horizontal Tabs Panel and links / text dropping panel (Scratching Board!) into Browser Cat!\n' +
      'Added entry to move a bookmark or folder to another position, fixed several bugs and did bunch of code clean up!',
    '一个主要更新，将横排标签页面板和拖放面板（猫抓板！）带入冲浪喵～\n' +
      '增加了移动书签／文件夹的入口，并且修复了若干个问题、完成了一些代码清理！',

    'v1.4.0-beta',
    'The first release of Browser Cat!\n' +
      'Finished vertical tabs, bookmarks management, history records, in web downloads, keyword typing suggestions, custom UA, custom search engine, and some many animations!',
    '冲浪喵的第一个发行版本！\n' +
      '完成了垂直标签页、书签管理、历史记录、网页内下载、搜索关键词联想、自定义UA、自定义搜索引擎，和很多动效！'
  ];

  build() {
    Scroll() {
      Column({ space: 10 }) {
        linysTitleText({
          text: $r('app.string.Update_record'),
        })
          .width("100%")
          .padding({ top: 5, bottom: 5 })
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
      .padding(15)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width("100%")
    }
    .backgroundColor(this.color_current_primary)
    .edgeEffect(EdgeEffect.Spring)
  }
}

export default woofUpdateRecord;

@Component
struct release_card {
  @State title: string = '';
  @State text_eng: string = '';
  @State text_chi: string = '';

  build() {
    Column({ space: 5 }) {
      linysTitleText({
        text: this.title,
      })
        .width("100%")
      linysText({
        text: this.text_eng,
        max_lines: 5
      })
        .width("100%")
        .opacity(0.7)
      linysText({
        text: this.text_chi,
        max_lines: 5
      })
        .width("100%")
        .opacity(0.7)
    }
    .alignItems(HorizontalAlign.Start)
    .padding(10)
    .borderRadius(10)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .width("100%")
    .animation(animation_default())
  }
}