import { animation_default, click_effect_default, fontSize_Large, minimum_card_width } from '../../hosts/bunch_of_defaults';
import lazy woofControlFrame from '../woofControlFrame';
import linysTextTitle from '../../components/texts/linysTextTitle';
import linysTimeoutButtonWithText from '../../components/buttons/linysTimeoutButtonWithText';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import linysText from '../../components/texts/linysText';
import linysCapsuleButtonWithText from '../../components/buttons/linysCapsuleButtonWithText';
import linysSwitchWithText from '../../components/toggles/linysSwitchWithText';
import { bunch_of_extensions, extension } from '../../hosts/bunch_of_extensions';
import linysImageButton from '../../components/buttons/linysImageButton';
import { select_install_extension, uninstall_extension } from '../../processes/extension_actions';
import { storage_of_id } from '../../utils/ui_tools';

@CustomDialog
struct woofExtensions {
  controller: CustomDialogController;
  // Env
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  // Hosts
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @StorageLink('bunch_of_extensions') bunch_of_extensions: bunch_of_extensions = new bunch_of_extensions();
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
            button_text: ' 󰀵 ',
            onExecution: () => {
              select_install_extension(this.storage);
            }
          })
          // .opacity(0.5)
          // .enabled(false) // TODO: Finish add extensions feature
        }
        .onAreaChange((o, n) => {
          this.notice_height = n.height as number;
        })
        .width('100%')

        linysTextTitle({
          text: $r('app.string.extensions_installed')
        })

        WaterFlow() {
          ForEach(this.bunch_of_extensions.extensions, (item: extension, idx: number) => {
            subCard({
              my_extension: item,
              my_index: idx,
              controller: this.controller,
              storage: this.storage
            })
          }, (ext: extension) => {
            return ext.id;
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
  storage: LocalStorage | undefined;
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.start_window_background');
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
  my_extension: extension | undefined;
  @Prop my_index: number;
  @State my_enabled: boolean = false;
  // Popup
  controller: CustomDialogController | undefined = undefined;

  aboutToAppear(): void {
    if (this.my_extension?.manifest_version == 3) {
      this.my_enabled = true;
    }
  }

  build() {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        if (this.my_extension?.icon_path) {
          linysImageButton({
            path: this.my_extension?.path_full + '/' + (this.my_extension?.icon_path)
          })
        } else {
          Text('󰠶')
            .fontColor(this.color_current_font)
            .fontSize(fontSize_Large() + 4)
            .fontWeight(FontWeight.Medium)
        }
        Text(this.my_extension?.name)
          .fontColor(this.color_current_font)
          .fontSize(fontSize_Large())
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
      } // title
      .opacity(0.8)

      linysSwitchWithText({
        text: this.basic_info().join(' '),
        toggle_state: this.my_enabled,
        onExecution: () => {
          if (this.my_enabled) {
          } else {
          }
        }
      })
        .opacity(0.8)
        .enabled(false) // TODO: Finish disabling extensions

      // linysText({ text: this.basic_info().join(' '), max_lines: 999 })
      //   .opacity(0.8)

      linysText({ text: this.more_info().join('\n'), max_lines: 999, is_description: true })

      if (this.my_extension?.homepage_url) {
        linysText({ text: this.my_extension.homepage_url, can_hover: true })
          .opacity(0.8)
          .onClick(() => {
            this.storage?.set('showing_more_options', false);
            this.storage?.set('universal_new_tab_gateway', [this.my_extension!.homepage_url, false]);
            this.controller?.close();
          })
      }

      linysTimeoutButtonWithText({
        desc_text: '',
        button_text: "  󰀁  ",
        onExecution: () => {
          if (this.my_extension?.id) {
            uninstall_extension(this.my_extension.id);
          }
        }
      })

    }
    .backgroundColor(this.color_current_secondary)
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
    info.push(this.my_extension?.version || 'version');
    info.push(this.my_extension?.description || 'description');
    return info;
  }

  more_info() {
    let info: string[] = [];
    info.push('id: ' + this.my_extension?.id);
    info.push('default_locale: ' + this.my_extension?.default_locale);
    info.push('manifest_version: ' + this.my_extension?.manifest_version);
    info.push('icon_path: ' + this.my_extension?.icon_path);
    info.push('best_action_default_icon: ' + this.my_extension?.action_default_icon_path);
    info.push('action_default_title: ' + this.my_extension?.action_default_title);
    info.push('action_default_popup: ' + this.my_extension?.action_default_popup);
    return info;
  }
}