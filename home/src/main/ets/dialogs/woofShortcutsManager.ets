import meowHomepageBackgroundManager from '../blocks/meowHomepageBackgroundManager';
import meowShortcutsManager from '../blocks/meowShortcutsManager';
import linysText from '../components/linysText';
import linysTitleText from '../components/linysTitleText';
import { animation_default } from '../hosts/bunch_of_defaults';

@CustomDialog
struct woofHomepageShortcutsManager {
  controller: CustomDialogController;
  @Prop link: string = '';
  @Prop title: string = '';
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Environment
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @StorageProp('screen_height') screen_height: number = 0;
  // alignRules
  alignRules_head_non_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    left: { anchor: "__container__", align: HorizontalAlign.Start }
  };
  alignRules_head_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    right: { anchor: "downer", align: HorizontalAlign.Start },
    left: { anchor: "__container__", align: HorizontalAlign.Start },
  };
  alignRules_body_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };
  alignRules_body_non_tablet: AlignRuleOption = {
    top: { anchor: "upper", align: VerticalAlign.Bottom },
    bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };

  build() {
    RelativeContainer() {
      Scroll() {
        Column({ space: 10 }) {
          linysTitleText({ text: $r('app.string.Homepage_background') })// Title
            .width('100%')
          linysText({
            text: $r('app.string.Homepage_background_desc'),
            max_lines: 5
          })// Desc
            .margin({ bottom: 5 })
          // Blank()
          meowHomepageBackgroundManager() // Homepage Background Manager
        }
        .padding({
          top: this.tablet_mode ? 20 : 15,
          bottom: 15,
          left: 15,
          right: this.tablet_mode ? 0 : 15
        })
        .backgroundColor(this.color_current_primary)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        // .height(this.tablet_mode ? this.screen_height * 0.9 : undefined)
        .animation(animation_default())
      }
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .width(this.tablet_mode ? "40%" : "100%")
      .height(this.tablet_mode ? "100%" : undefined)
      .alignRules(this.tablet_mode ? this.alignRules_head_tablet : this.alignRules_head_non_tablet)
      .animation(animation_default())
      .id('upper')

      Column({ space: 10 }) {
        linysTitleText({
          text: $r('app.string.Settings_homepage_shortcuts_manage')
        }) // Title
        linysText({
          text: $r('app.string.Settings_homepage_shortcuts_manage_desc'),
          max_lines: 3
        })// Desc
          .margin({ bottom: 5 })
        meowShortcutsManager()// Shortcuts Manager
          .width("100%")
          .layoutWeight(1)
          .borderRadius(13.5)
      }
      .padding({
        top: this.tablet_mode ? 20 : 10,
        left: 15,
        right: 15,
        bottom: 15
      })
      .backgroundColor(this.color_current_primary)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .alignRules(this.tablet_mode ? this.alignRules_body_tablet : this.alignRules_body_non_tablet)
      .width(this.tablet_mode ? "60%" : "100%")
      .constraintSize(this.tablet_mode ? {} : { maxHeight: '70%' })
      .animation(animation_default())
      .id('downer')
    }
    .backgroundColor(this.color_current_primary)
  }
}

export default woofHomepageShortcutsManager;