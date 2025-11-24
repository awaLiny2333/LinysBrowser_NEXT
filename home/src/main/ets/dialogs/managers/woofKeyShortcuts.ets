import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysShowButton from '../../components/buttons/linysShowButton';
import linysText from '../../components/texts/linysText';
import { animation_default, click_effect_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import lazy woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofKeyShortcuts {
  controller: CustomDialogController;
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts();
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
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
      title: $r('app.string.Key_shortcuts_manage'),
      controller: this.controller,
      space_column: 10
    }) {
      Scroll() {
        Column({ space: 10 }) {
          ForEach(this.bunch_of_key_shortcuts.key_shortcut_labels, (label: string, _index: number) => {
            KeyDisplayCard({ key_settings_id: label })
          })
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width("100%")
      }
      .borderRadius(10)
      .constraintSize({ maxHeight: 588 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
    }
  }
}

export default woofKeyShortcuts;

@Component
struct KeyDisplayCard {
  @StorageLink('bunch_of_key_shortcuts') @Watch('on_refresh') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(false);
  @Prop key_settings_id: string;
  @State showing_keyboard: boolean = false;
  @State keys_edit: string[] = [];
  @State key_binds: string = '';
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');

  aboutToAppear(): void {
    this.on_refresh();
  }

  on_refresh() {
    // Set display text
    let got_shortcut = this.bunch_of_key_shortcuts.get_shortcut_string(this.key_settings_id);
    if (this.bunch_of_key_shortcuts.get_shortcut(this.key_settings_id)?.main_key) {
      this.key_binds = got_shortcut.reverse().join(' + ').toUpperCase();
    }
  }

  build() {
    Column() {
      linysText({ text: $r('app.string.Key_shortcuts_'.concat(this.key_settings_id)) })// Key name
        .width('100%')

      Row({ space: 10 }) {
        linysText({
          text: this.key_binds
        })
          .opacity(0.8)
          .layoutWeight(1)
        // linysText({ text: $r('app.string.Key_shortcuts_modify') })
        linysShowButton({
          symbol_glyph_target: 'sys.symbol.square_and_pencil',
          text: $r('app.string.Key_shortcuts_modify'),
          show_margin: { left: 0, right: 0 },
          show: this.showing_keyboard
        })
          .onClick(() => {
            if (this.keys_edit.length < 1) {
              // Init
              this.keys_edit = this.bunch_of_key_shortcuts.get_shortcut_string(this.key_settings_id);
            }
            this.showing_keyboard = !this.showing_keyboard;
          })
      } // Key info and change button
      .alignItems(VerticalAlign.Bottom)
      .width("100%")

      Column() {
        if (this.showing_keyboard) {
          KeyBoard({
            keys_edit: this.keys_edit,
            key_settings_id: this.key_settings_id,
            showing_keyboard: this.showing_keyboard
          })
            .width('100%')
            .padding({ top: 10 })
          // .visibility(this.showing_keyboard ? Visibility.Visible : Visibility.None)
        }
      }
      .clip(true)
      .height(this.showing_keyboard ? undefined : 0)
      .animation(animation_default())
    }
    .padding(10)
    .borderRadius(10)
    .backgroundColor(this.color_current_secondary)
  }
}

@Component
struct KeyBoard {
  @State key_settings_id: string = '';
  @Link keys_edit: string[];
  @Link showing_keyboard: boolean;
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts();
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Data
  first_line = ['esc', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12']
  second_line = ['tab', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']
  third_line = ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l']
  fourth_line = ['shift', 'z', 'x', 'c', 'v', 'b', 'n', 'm']
  fifth_line = ['ctrl', 'alt', 'dpad_left', 'dpad_up', 'dpad_down', 'dpad_right']
  // UI
  @State my_height: number | undefined = 0;

  aboutToAppear(): void {
    setTimeout(() => {
      this.my_height = undefined;
    }, 10)
  }

  build() {
    Column({ space: 5 }) {
      Scroll() {
        Column({ space: 5 }) {
          Row({ space: 5 }) {
            ForEach(this.first_line, (key_id: string, _index: number) => {
              KeyButton({ key_id: key_id, keys_selected: this.keys_edit })
            })
          }

          Row({ space: 5 }) {
            ForEach(this.second_line, (key_id: string, _index: number) => {
              KeyButton({ key_id: key_id, keys_selected: this.keys_edit })
            })
          }

          Row({ space: 5 }) {
            ForEach(this.third_line, (key_id: string, _index: number) => {
              KeyButton({ key_id: key_id, keys_selected: this.keys_edit })
            })
          }

          Row({ space: 5 }) {
            ForEach(this.fourth_line, (key_id: string, _index: number) => {
              KeyButton({ key_id: key_id, keys_selected: this.keys_edit })
            })
          }

          Row({ space: 5 }) {
            ForEach(this.fifth_line, (key_id: string, _index: number) => {
              KeyButton({ key_id: key_id, keys_selected: this.keys_edit })
            })
          }
        }
      }
      .width("100%")
      .alignSelf(ItemAlign.Center)
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
      .edgeEffect(EdgeEffect.Spring)

      Row() {
        Blank()
        linysCapsuleButton({ text: '  󰀓  ' })
          .onClick(() => {
            this.bunch_of_key_shortcuts.set_shortcut(this.key_settings_id, this.keys_edit);
            this.showing_keyboard = false;
          })
      } // Confirm
      .width("100%")
      .margin({ top: 5 })
    }
    .height(this.my_height)
    .animation(animation_default())
    .clip(true)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
  }
}

@Component
struct KeyButton {
  @Link keys_selected: string[];
  @State key_id: string = '';
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @StorageLink('effects') effects: boolean = false;
  // UI
  @State isHov: boolean = false;

  build() {
    Text(this.id_to_display())
      .fontWeight(this.keys_selected.includes(this.key_id) ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(this.keys_selected.includes(this.key_id) && !this.effects ? this.color_current_primary : this.color_current_font)
      .backgroundColor(this.keys_selected.includes(this.key_id) && !this.effects ? this.color_current_font : this.color_current_primary)
      .brightness(this.keys_selected.includes(this.key_id) && this.effects ? 1.2 : this.isHov ? 1.1 : 1)
      .animation(animation_default())
      .clickEffect(click_effect_default())
      .padding(10)
      .borderRadius(7)
      .constraintSize({ minWidth: 40 })
      .textAlign(TextAlign.Center)
      .onClick(() => {
        if (this.keys_selected.includes(this.key_id)) {
          // remove
          if (this.is_modifier(this.key_id)) {
            // Ensure there is a modifier key, unless a function key is selected
            if (this.keys_selected.length == 2) {
              let to_examine = this.keys_selected[0];
              if (to_examine == this.key_id) {
                to_examine = this.keys_selected[1];
              }
              if (!this.is_function_key(to_examine)) {
                return;
              }
            }
            let index_delete = this.keys_selected.indexOf(this.key_id);
            this.keys_selected.splice(index_delete, 1);
          }
        } else {
          // add
          if (!this.is_modifier(this.key_id)) {
            // Add main key
            // Remove original main key
            for (let index = 0; index < this.keys_selected.length; index++) {
              if (!this.is_modifier(this.keys_selected[index])) {
                this.keys_selected.splice(index, 1);
                break;
              }
            }
          }
          this.keys_selected.push(this.key_id);
          if (this.keys_selected.length == 1 && !this.is_function_key(this.keys_selected[0])) {
            this.keys_selected.push('ctrl');
          }
        }
      })
      .onHover((isHv) => {
        this.isHov = isHv;
      })
  }

  id_to_display() {
    let result = '';
    let ids = ['dpad_up', 'dpad_down', 'dpad_left', 'dpad_right'];
    let displays = ['󰃘', '󰃛', '󰃚', '󰃙'];
    if (ids.includes(this.key_id)) {
      result = displays[ids.indexOf(this.key_id)];
    } else {
      result = this.key_id;
    }
    return result.toUpperCase();
  }

  is_modifier(key_id: string) {
    return ['ctrl', 'alt', 'shift'].includes(key_id);
  }

  is_function_key(key_id: string) {
    return ['f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12'].includes(key_id);
  }
}