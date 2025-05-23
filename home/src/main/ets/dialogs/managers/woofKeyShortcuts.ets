import linysCapsuleButton from '../../components/linysCapsuleButton';
import linysShowButton from '../../components/linysShowButton';
import linysText from '../../components/linysText';
import { animation_default, click_effect_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofKeyShortcuts {
  controller: CustomDialogController;
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts();
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    woofControlFrame({
      title: $r('app.string.Key_shortcuts_manage'),
      controller: this.controller
    }) {
      Scroll() {
        Column({ space: 10 }) {
          ForEach(this.bunch_of_key_shortcuts.key_shortcut_labels, (label: string, _index: number) => {
            keyDisplay({ key_settings_id: label })
          })
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width("100%")
      }
      .constraintSize({ maxHeight: 588 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
    }
  }
}

export default woofKeyShortcuts;

@Component
struct keyDisplay {
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(false);
  @Prop key_settings_id: string;
  @State showing_keyboard: boolean = false;
  @State keys_edit: string[] = [];
  @State display_text: string = '';
  // Colors
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');

  aboutToAppear(): void {
    // Set display text
    this.display_text = this.bunch_of_key_shortcuts.get_shortcut(this.key_settings_id)
      .reverse()
      .join(' + ')
      .toUpperCase();
  }

  build() {
    Column() {
      linysText({ text: $r('app.string.Key_shortcuts_'.concat(this.key_settings_id)) })// Key name
        .width('100%')

      Row({ space: 10 }) {
        linysText({
          text: this.display_text
        })
          .layoutWeight(1)
        // linysText({ text: $r('app.string.Key_shortcuts_modify') })
        linysShowButton({
          symbol_glyph_target: 'sys.symbol.square_and_pencil',
          text: $r('app.string.Key_shortcuts_modify'),
          show: this.showing_keyboard
        })
          .onClick(() => {
            if (this.keys_edit.length < 1) {
              // Init
              this.keys_edit = this.bunch_of_key_shortcuts.get_shortcut(this.key_settings_id);
            }
            this.showing_keyboard = !this.showing_keyboard;
          })
      } // Key info and change button
      .alignItems(VerticalAlign.Bottom)
      .width("100%")

      KeyBoard({
        keys_edit: this.keys_edit,
        key_settings_id: this.key_settings_id,
        display_text: this.display_text,
        showing_keyboard: this.showing_keyboard
      })
        .width('100%')
        .padding({ top: 10 })
        .visibility(this.showing_keyboard ? Visibility.Visible : Visibility.None)
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
  @Link display_text: string;
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts();
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  first_line = ['esc', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12']
  second_line = ['tab', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']
  third_line = ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l']
  fourth_line = ['shift', 'z', 'x', 'c', 'v', 'b', 'n', 'm']
  fifth_line = ['ctrl', 'alt', 'dpad_left', 'dpad_up', 'dpad_down', 'dpad_right']

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
            this.display_text = this.bunch_of_key_shortcuts.get_shortcut(this.key_settings_id)
              .reverse()
              .join(' + ')
              .toUpperCase();
            this.showing_keyboard = false;
          })
      } // Confirm
      .width("100%")
      .margin({ top: 5 })
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
  }
}

@Component
struct KeyButton {
  @Link keys_selected: string[];
  @State key_id: string = '';
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Text(this.id_to_display())
      .padding(10)
      .borderRadius(7)
      .fontWeight(this.keys_selected.includes(this.key_id) ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.keys_selected.includes(this.key_id) ? this.color_current_primary : this.color_current_font)
      .backgroundColor(this.keys_selected.includes(this.key_id) ? this.color_current_font : this.color_current_primary)
      .clickEffect(click_effect_default())
      .animation(animation_default())
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