import { animation_default, click_effect_default, minimum_card_width } from '../../hosts/bunch_of_defaults';
import lazy woofControlFrame from '../woofControlFrame';
import linysTextSubtitleDivision from '../../components/texts/linysTextSubtitleDivision';
import linysTextTitle from '../../components/texts/linysTextTitle';
import linysTimeoutButtonWithText from '../../components/buttons/linysTimeoutButtonWithText';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import linysText from '../../components/texts/linysText';
import linysCapsuleButtonWithText from '../../components/buttons/linysCapsuleButtonWithText';
import { manifest_of_extension } from '../../processes/extension_actions';
import linysSwitchWithText from '../../components/toggles/linysSwitchWithText';

@CustomDialog
struct woofExtensions {
  controller: CustomDialogController;
  @StorageLink('extensions') extensions: string[] = [];
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Status
  @LocalStorageLink('full_screen_height') full_screen_height: number = 0;
  @LocalStorageProp('screen_width') screen_width: number = 0;
  @LocalStorageLink('compact_mode') compact_mode: boolean = false;
  @State notice_height: number = 35;
  // Dialog
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
      title: $r('app.string.extensions'),
      controller: this.controller,
      space_column: this.compact_mode ? 0 : 10
    }) {
      Column({ space: this.compact_mode ? 8 : 15 }) {
        Column({ space: 10 }) {
          linysText({ text: $r('app.string.extensions_desc'), is_description: true, is_expanded: true }).width('100%')
            .visibility(this.compact_mode ? Visibility.None : Visibility.Visible)
            .animation(animation_default())
          linysCapsuleButtonWithText({
            desc_text: $r('app.string.extensions_install'),
            button_text: ' 󰀵 '
          })
            .opacity(0.5)
            .enabled(false) // TODO: Finish add extensions feature
        }
        .onAreaChange((o, n) => {
          this.notice_height = n.height as number;
        })
        .width('100%')

        linysTextTitle({
          text: $r('app.string.extensions_installed')
        })

        WaterFlow() {
          ForEach(this.extensions, (item: string, idx: number) => {
            subCard({ my_id: item, my_index: idx, controller: this.controller })
          })
        }
        .columnsTemplate("1fr ".repeat(Math.ceil(this.screen_width * 0.9 / minimum_card_width())))
        .animation(animation_default())
        .rowsGap(10)
        .columnsGap(10)
        .borderRadius(10)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Auto)
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .constraintSize({ maxHeight: Math.max(0, this.full_screen_height * 0.9 - 35 - 45 - 40 - this.notice_height) })
      }
      .animation(animation_default())
      .alignItems(HorizontalAlign.Start)
    }
  }
}

export default woofExtensions;

@Component
struct subCard {
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Contents
  @BuilderParam contents: () => void;
  // Environments
  @StorageLink('effects') effects: boolean = false;
  // Title
  icon: ResourceStr = '󰠶'; // TODO: Need to be customizable?
  // Stats
  @State isHov: boolean = false;
  // Data
  @Prop my_index: number;
  @Prop my_id: string = 'Ext>!';
  @State my_enabled: boolean = true;
  my_manifest: object | undefined = undefined;
  // Popup
  controller: CustomDialogController | undefined = undefined;

  aboutToAppear(): void {
    this.my_manifest = manifest_of_extension(this.my_id);
  }

  build() {
    Column({ space: 10 }) {
      linysTextSubtitleDivision({ icon: this.icon, text: this.my_manifest?.['name'], opa: 0.8 }) // Title
        .width('100%')

      linysText({ text: this.basic_info().join(' '), max_lines: 999 })
        .opacity(0.8)

      linysText({ text: this.more_info().join('\n'), max_lines: 999, is_description: true })

      linysSwitchWithText({
        text: $r('app.string.extensions_enable'),
        toggle_state: this.my_enabled,
        onExecution: () => {
          if (this.my_enabled) {
          } else {
          }
        }
      })
        .opacity(0.5)
        .enabled(false) // TODO: Finish disabling extensions

      linysTimeoutButtonWithText({
        desc_text: '',
        button_text: "  󰀁  ",
        onExecution: () => {
          // Delete
        }
      })
        .opacity(0.5)
        .enabled(false) // TODO: Finish deleting extensions
    }
    .backgroundColor(this.color_current_primary)
    .brightness(this.isHov ? 1.04 : 1)
    .animation(animation_default())
    .padding(12)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width("100%")
    .borderRadius(10)
    .clickEffect(click_effect_default())
    .onHover((isHv) => {
      this.isHov = isHv;
    })
    .onClick(() => {
      this.open();
    })
  }

  open() {

  }

  // Data

  basic_info() {
    let info: string[] = [];
    info.push(this.my_manifest?.['version']);
    info.push(this.my_manifest?.['description']);
    return info;
  }

  more_info() {
    let info: string[] = [];
    info.push('id: ' + this.my_id);
    info.push('manifest_version: ' + this.my_manifest?.['manifest_version']);
    info.push('minimum_chrome_version: ' + this.my_manifest?.['minimum_chrome_version']);
    // info.push('permissions: ' + this.my_manifest?.['permissions']);
    return info;
  }
}