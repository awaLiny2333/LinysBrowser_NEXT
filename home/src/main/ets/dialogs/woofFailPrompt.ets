import linysText from '../components/linysText';
import linysTitleText from '../components/linysTitleText';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Normal
} from '../hosts/bunch_of_defaults';
import { LengthMetrics } from '@kit.ArkUI';

@CustomDialog
struct woofFailPrompt {
  controller: CustomDialogController;
  @Prop desc: ResourceStr = 'Desc';
  @State @Watch('on_meow_reversed') meow: boolean = false;

  build() {
    Column({ space: 10 }) {
      linysTitleText({
        text: $r('app.string.Fail'),
        max_lines: 1
      })
        .padding({ top: 5 })
        .width("100%")

      linysText({
        text: this.desc,
        max_lines: 10
      })
        .width("100%")

      linysText({
        text: $r('app.string.Fail_tips_general_call_liny'),
        max_lines: 10
      })
        .width("100%")

      linysText({
        text: 'ヽ(￣ω￣(￣ω￣〃)ゝ',
        max_lines: 1
      })
        .width("100%")

      visitLink({
        meow: this.meow,
        text: $r('app.string.About_bilibili'),
        link: "https://space.bilibili.com/678438347",
      })

      visitLink({
        meow: this.meow,
        text: $r('app.string.About_GitHub'),
        link: "https://github.com/awaLiny2333/LinysBrowser_NEXT",
      })

      visitLink({
        meow: this.meow,
        text: $r('app.string.About_Gitee'),
        link: "https://gitee.com/awa_Liny/LinysBrowser_NEXT",
      })

      Button($r('app.string.OK'))
        .type(ButtonType.Capsule)
        .backgroundColor($r("app.color.font_color_title"))
        .fontColor($r('app.color.start_window_background'))
        .fontSize(fontSize_Normal() + 2)
        .fontWeight(FontWeight.Medium)
        .height(capsule_bar_height())
        .clickEffect(click_effect_default())
        .animation(animation_default())
        .alignSelf(ItemAlign.End)
        .onClick(() => {
          if (this.controller) {
            this.controller.close();
          }
        })
    }
    .padding(15)
    .backgroundColor($r('app.color.start_window_background'))
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width("100%")
  }

  on_meow_reversed() {
    // Visit one of the support pages
    if (this.controller) {
      this.controller.close();
    }
  }
}

export default woofFailPrompt;

@Component
struct visitLink {
  // Environment
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('showing_tabs') showing_tabs: boolean = false;
  @StorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @StorageLink('showing_more_options') showing_more_options: boolean = false;
  @StorageLink('showing_app_settings') showing_app_settings: boolean = false;
  @StorageLink('showing_downloads') showing_downloads: boolean = false;
  @StorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  // Internal stuff
  @Prop text: ResourceStr = $r('app.string.HomeAbility_label');
  @Prop color: ResourceStr = $r('app.color.font_color_title');
  @Prop max_lines: number = 1;
  @Prop font_weight: FontWeight = FontWeight.Normal;
  @State link: string = "huawei.com";
  @StorageLink('universal_new_tab_gateway') universal_new_tab_gateway: string = "";
  // This is for status noticing
  @Link meow: boolean;

  build() {
    Text(this.text)
      .fontColor(this.color)
      .fontSize(fontSize_Normal())
      .fontWeight(this.font_weight)
      .textAlign(TextAlign.Start)
      .maxLines(this.max_lines)
      .lineSpacing(LengthMetrics.vp(4))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .onClick(() => {
        // Reverse meow to trigger something
        this.meow = !this.meow;
        // New tab!
        this.universal_new_tab_gateway = this.link;
        // Close all panels
        if (!this.tablet_mode) {
          // These are expected to remain open in tablet mode
          this.showing_tabs = false;
          this.showing_bookmarks = false;
        }
        this.showing_more_options = false;
        this.showing_app_settings = false;
        this.showing_downloads = false;
        this.showing_scratching_board = false;
      })
      .width("100%")
  }
}
