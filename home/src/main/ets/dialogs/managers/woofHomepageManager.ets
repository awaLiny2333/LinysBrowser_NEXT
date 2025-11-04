import meowHomepageManager from '../../blocks/panels/meowHomepageManager';
import linysCapsuleButtonWithText from '../../components/buttons/linysCapsuleButtonWithText';
import linysTimeoutButtonWithText from '../../components/buttons/linysTimeoutButtonWithText';
import linysLockSlider from '../../components/linysLockSlider';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { animation_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import woofSelectBookmarksPath from '../prompts/woofSelectBookmarksPath';
import woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofHomepageManager {
  @Prop link: string = '';
  @Prop title: string = '';
  @StorageLink('homepage_shortcuts_init_height') homepage_shortcuts_init_height: number = 50;
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Environment
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageProp('screen_height') screen_height: number = 0;
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
    cornerRadius: 26,
    alignment: DialogAlignment.Center,
    // // showInSubWindow: true,
    width: "90%",
  })
  controller: CustomDialogController;
  // Status
  @State content_height: number = 233;
  // Count
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
      title: $r('app.string.Settings_homepage_customization'),
      controller: this.controller
    }) {
      Scroll() {
        Column({ space: 10 }) {
          linysText({
            text: $r('app.string.Settings_homepage_shortcuts_manage_desc'),
            max_lines: 3,
            is_description: true,
            is_expanded: true
          }) // Desc

          linysTextTitle({ text: $r('app.string.Homepage_background') })// Title
            .width('100%')
          linysText({
            text: $r('app.string.Homepage_background_desc'),
            max_lines: 5,
            is_description: true,
            is_expanded: true
          }) // Desc

          meowHomepageManager() // Homepage Background Manager

          linysTextTitle({
            text: $r('app.string.Settings_homepage_shortcuts')
          }) // Title

          linysText({
            text: $r('app.string.Homepage_shortcuts_desc'),
            max_lines: 5,
            is_description: true,
            is_expanded: true
          }) // Desc

          linysCapsuleButtonWithText({
            desc_text: $r('app.string.Settings_homepage_shortcuts_select_dir'),
            button_text: "  󰂺  ",
            onExecution: () => {
              if (this.woofBookmarksPathSelector_control != null) {
                this.woofBookmarksPathSelector_control.open();
              }
            }
          }) // Select shortcuts directory

          linysTimeoutButtonWithText({
            desc_text: $r('app.string.Settings_homepage_shortcuts_reset_dir'),
            button_text: "  󰃑  ",
            onExecution: () => {
              this.select_path_result = '/';
            }
          }) // Cancel current selection

          linysTextTitle({
            text: $r('app.string.Settings_homepage_shortcuts_init_height'),
            max_lines: 5
          }) // Display height of shortcuts

          linysText({
            text: $r('app.string.Settings_homepage_shortcuts_init_height_desc'),
            max_lines: 5,
            is_description: true,
            is_expanded: true
          }) // Desc

          linysLockSlider({
            slider_value: this.homepage_shortcuts_init_height,
            onTouchUp: () => {
              bunch_of_settings.set('homepage_shortcuts_init_height', this.homepage_shortcuts_init_height);
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
      .borderRadius(13.5)
      .animation(animation_default())
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