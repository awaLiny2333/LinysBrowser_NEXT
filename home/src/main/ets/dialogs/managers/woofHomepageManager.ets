import meowHomepageBackgroundManager from '../../blocks/panels/meowHomepageBackgroundManager';
import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysLockSlider from '../../components/linysLockSlider';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { animation_default, click_effect_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import woofSelectBookmarksPath from '../prompts/woofSelectBookmarksPath';
import woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofHomepageManager {
  @Prop link: string = '';
  @Prop title: string = '';
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @StorageLink('homepage_shortcuts_init_height') homepage_shortcuts_init_height: number = 50;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Environment
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @StorageProp('screen_height') screen_height: number = 0;
  // Select bookmark
  @State @Watch('on_select_change') select_path_result: string = '';
  @StorageLink('homepage_shortcuts_bookmarks_dir') homepage_shortcuts_dir: string = '/';
  @State looking_at_path: string = this.homepage_shortcuts_dir;
  woofBookmarksPathSelector_control: CustomDialogController = new CustomDialogController({
    builder: woofSelectBookmarksPath({
      prompt_title: $r('app.string.Settings_homepage_shortcuts_select_dir'),
      select: this.select_path_result,
      looking_at_path: this.looking_at_path
    }),
    cornerRadius: 16,
    alignment: DialogAlignment.Center,
    // // showInSubWindow: true,
    width: "90%",
  })
  controller: CustomDialogController;
  // Status
  @State content_height: number = 233;

  build() {
    woofControlFrame({
      title: $r('app.string.Settings_homepage_customization'),
      controller: this.controller
    }) {
      Scroll() {
        Column({ space: 10 }) {
          linysText({
            text: $r('app.string.Settings_homepage_shortcuts_manage_desc'),
            max_lines: 3
          })// Desc
            .borderRadius(12)
            .padding(10)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .width('100%')
            .clickEffect(click_effect_default())
            .margin({ bottom: 5 })

          linysTextTitle({ text: $r('app.string.Homepage_background') })// Title
            .width('100%')
          linysText({
            text: $r('app.string.Homepage_background_desc'),
            max_lines: 5
          }) // Desc

          meowHomepageBackgroundManager() // Homepage Background Manager

          linysTextTitle({
            text: $r('app.string.Settings_homepage_shortcuts')
          }) // Title

          linysText({
            text: $r('app.string.Homepage_shortcuts_desc'),
            max_lines: 5
          }) // Desc

          Row({ space: 10 }) {
            Blank()
            linysText({ text: $r('app.string.Settings_homepage_shortcuts_select_dir') })
            linysCapsuleButton({ text: "  󰂺  " })// Move
              .onClick(() => {
                if (this.woofBookmarksPathSelector_control != null) {
                  this.woofBookmarksPathSelector_control.open();
                }
              })
          }
          .width('100%')

          linysTextTitle({
            text: $r('app.string.Settings_homepage_shortcuts_init_height')
          }) // Display height of shortcuts

          linysText({
            text: $r('app.string.Settings_homepage_shortcuts_init_height_desc'),
            max_lines: 5
          }) // Desc

          linysLockSlider({
            slider_value: this.homepage_shortcuts_init_height,
            onTouchUp: () => {
              this.bunch_of_settings.set('homepage_shortcuts_init_height', this.homepage_shortcuts_init_height);
            }
          })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .onAreaChange((_o, n) => {
          this.content_height = n.height as number;
        })
        // .height(this.tablet_mode ? this.screen_height * 0.9 : undefined)
        .animation(animation_default())
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .constraintSize({ maxHeight: this.content_height })
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }
  }

  on_select_change() {
    this.homepage_shortcuts_dir = this.select_path_result;
    // this.bunch_of_settings.set('homepage_shortcuts_bookmarks_dir', this.homepage_shortcuts_dir);
  }
}

export default woofHomepageManager;