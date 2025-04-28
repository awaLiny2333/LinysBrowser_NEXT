import linysCapsuleButton from '../components/linysCapsuleButton';
import linysSymbol from '../components/linysSymbol';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large,
  fontSize_Normal
} from '../hosts/bunch_of_defaults';
import { bunch_of_homepage_shortcuts, homepage_shortcut } from '../hosts/bunch_of_homepage_shortcuts';
import { bunch_of_settings } from '../hosts/bunch_of_settings';

@Component
struct meowShortcutsManager {
  @StorageLink('bunch_of_homepage_shortcuts') bunch_of_homepage_shortcuts: bunch_of_homepage_shortcuts =
    new bunch_of_homepage_shortcuts();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @StorageLink('homepage_shortcut') homepage_shortcut: string = "";
  @State list_of_homepage_shortcuts: homepage_shortcut[] = this.bunch_of_homepage_shortcuts.list_of_homepage_shortcuts;
  @State default_pressing: boolean = false;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 2.5 }) {
      Scroll() {
        Column({ space: 6 }){
          Row() {
            Row() {
              Text($r('app.string.Settings_homepage_shortcuts_add_here'))// Title
                .fontColor(!this.default_pressing ? this.color_current_font : this.color_current_secondary)
                .fontWeight(!this.default_pressing ? FontWeight.Normal : FontWeight.Medium)
                .padding({ left: 2 })
                .fontSize(fontSize_Normal())
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
                .margin(10)
                .animation(animation_default())

            }
            .width("100%")
            .height("100%")
            .borderRadius(7)
            .backgroundColor(this.default_pressing ? this.color_current_font :
            this.color_current_primary)
            .animation(animation_default())

          } // Default
          .width("100%")
          .alignRules({
            middle: { anchor: "__container__", align: HorizontalAlign.Center },
            top: { anchor: "__container__", align: VerticalAlign.Top }
          })
          .onTouch((event) => {
            if (event.type == TouchType.Up) {
              this.default_pressing = false;
              // If touch ends
            } else {
              this.default_pressing = true;
              // If touching
            }
          })
          .height(46)
          .animation(animation_default())

          ForEach(this.bunch_of_homepage_shortcuts.list_of_homepage_shortcuts,
            (_user_agent: homepage_shortcut, key: number) => {
              meowSCButton({
                my_index: key,
              })
            })

          linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })
            .onClick(() => {
              this.add_new_custom_homepage_shortcut();
            })
            .padding(5)
        }
        .alignItems(HorizontalAlign.End)
      }
      .padding(2)
      .width("100%")
      .animation(animation_default())
      .edgeEffect(EdgeEffect.Spring)
      .borderRadius(13.5)
    }
    .padding(5)
    .borderRadius(13.5)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .height('100%')
    .width('100%')
  }

  add_new_custom_homepage_shortcut() {
    this.bunch_of_homepage_shortcuts.add_homepage_shortcut(new homepage_shortcut(new Date().toLocaleString(),
      "https://you.rwebs.ite"));
    this.save_homepage_shortcuts_to_kv_store();
  }

  // Data utils

  save_homepage_shortcuts_to_kv_store() {
    this.bunch_of_settings.set('homepage_shortcuts', this.bunch_of_homepage_shortcuts.export_string());
  }
}

export default meowShortcutsManager;

@Component
struct meowSCButton {
  @Prop my_index: number;
  @StorageLink('bunch_of_homepage_shortcuts') bunch_of_homepage_shortcuts: bunch_of_homepage_shortcuts =
    new bunch_of_homepage_shortcuts();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @State my_se: homepage_shortcut = this.bunch_of_homepage_shortcuts.list_of_homepage_shortcuts[this.my_index];
  @State my_label: string = this.my_se.label;
  @State my_content: string = this.my_se.url;
  // statuses
  @State editing: boolean = false;
  @State pressing: boolean = false;
  @State press_timing_ok: boolean = false;
  press_timing: number = 0;
  button_height_default: number = 42;
  // Edit inputs
  @State edit_label: string = this.my_label;
  @State edit_content: string = this.my_content;
  @State delete_confirm: number = 0;
  // UI effects
  @State height_of_text_area: number = 42;
  @State visible: Visibility = Visibility.Hidden;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column() {
      Column() {
        Row() {
          Text(this.my_label)// Title
            .fontColor(!this.pressing ? this.color_current_font : this.color_current_secondary)
            .fontWeight(!this.pressing ? FontWeight.Normal : FontWeight.Medium)
            .animation(animation_default())
            .padding({ left: 2 })
            .fontSize(fontSize_Normal())
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          Scroll() {
            SymbolGlyph($r('sys.symbol.square_and_pencil'))
              .fontSize(fontSize_Large())
              .fontColor([this.color_current_secondary])
          } // Edit Icon
          .scrollable(ScrollDirection.Horizontal)
          .width(this.press_timing_ok ? 22 : 0)
          .margin({ left: this.press_timing_ok ? 10 : 0 })
          .animation(animation_default())

        } // Bookmark button
        .borderRadius(this.editing ? { topLeft: 7, topRight: 7 } : 7)
        .backgroundColor(this.pressing ? this.color_current_font : this.color_current_primary)
        .animation(animation_default())
        .padding(10)
        .alignRules({
          middle: { anchor: "__container__", align: HorizontalAlign.Center },
          top: { anchor: "__container__", align: VerticalAlign.Top }
        })
        .onTouch((event) => {
          if (event.type == TouchType.Up) {
            this.pressing = false;
            // If touch ends
          } else {
            this.pressing = true;
            // If touching
          }
        })
        .onClick(() => {
          if (this.press_timing_ok) {
            this.delete_confirm = 0;
            this.editing = !this.editing;
            return;
          } // Toggle Edit Panel
        })
        .height(this.button_height_default)

        Scroll() {
          Column({ space: 10 }) {
            Row({ space: 10 }) {
              linysSymbol({ symbol_glyph_target: "sys.symbol.rename" })
              TextInput({ text: this.edit_label })
                .onChange((value) => {
                  this.edit_label = value;
                })
                .fontWeight(FontWeight.Regular)
                .fontColor(this.color_current_font)
                .caretColor(this.color_current_font)
                .selectedBackgroundColor(this.color_current_font)
                .layoutWeight(1)
                .onSubmit(() => {
                  this.save_changes();
                  this.editing = false;
                })
                .height(capsule_bar_height())

            } // Edit label
            .width("100%")

            Row({ space: 10 }) {
              linysSymbol({ symbol_glyph_target: "sys.symbol.paperclip" })
              TextInput({ text: this.edit_content })
                .onChange((value) => {
                  this.edit_content = value;
                })
                .fontWeight(FontWeight.Regular)
                .fontColor(this.color_current_font)
                .caretColor(this.color_current_font)
                .selectedBackgroundColor(this.color_current_font)
                .layoutWeight(1)
                .onSubmit(() => {
                  this.save_changes();
                  this.editing = false;
                })
                .onAreaChange((_o, n) => {
                  this.height_of_text_area = n.height as number;
                })
              // .height(capsule_bar_height())

            } // Edit content
            .width("100%")
            .animation(animation_default())

            Row({ space: 10 }) {
              Blank()
              Button("  󰀁  ")// Delete
                .type(ButtonType.Capsule)
                .backgroundColor(this.delete_confirm > 0 ? this.color_current_primary :
                this.color_current_font)
                .fontColor(this.delete_confirm > 0 ? this.color_current_font :
                this.color_current_primary)
                .border({
                  width: 2,
                  color: this.delete_confirm > 0 ? this.color_current_font : "transparent"
                })
                .fontSize(fontSize_Large())
                .fontWeight(FontWeight.Medium)
                .height(capsule_bar_height())
                .onClick(() => {
                  this.delete_myself();
                })
                .clickEffect(click_effect_default())
                .animation(animation_default())

              linysCapsuleButton({ text: "  󰀻  " })
                .onClick(() => {
                  this.save_changes();
                  this.editing = false;
                })

            } // Buttons of operations
            .width("100%")
          }
          .padding({
            top: 6,
            left: 14,
            right: 14,
            bottom: 14
          })
          .backgroundColor(this.color_current_primary)
          .border({
            radius: { bottomLeft: 10, bottomRight: 10 }
          })

        } // Edit panel
        .height(!this.editing ? 0 : 108 + this.height_of_text_area)
        .visibility(this.editing ? Visibility.Visible : Visibility.None)
        .animation(animation_default())
        .scrollBar(BarState.Off)
        .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })
      }
    }
    .width("100%")
    .visibility(this.visible)
    .animation(animation_default())
    .onAppear(() => {
      setTimeout(() => {
        this.visible = Visibility.Visible;
      }, 10)
      setInterval(() => {
        if (this.pressing) {
          this.press_timing += 1;
        } else {
          this.press_timing = 0;
        }
        this.press_timing_ok = this.press_timing > 16;
        // Count press time
        if (this.delete_confirm > 0) {
          this.delete_confirm -= 1;
        }
        // Reset delete confirm
      }, 10)
    })
  }

  save_changes() {
    this.edit_content = this.edit_content.replaceAll("\n", "");

    this.my_label = this.edit_label;
    this.my_content = this.edit_content;
    this.my_se.label = this.edit_label;
    this.my_se.url = this.edit_content;
    this.bunch_of_homepage_shortcuts.last_accessed = Date.now();
    console.log(this.my_se.label)
    this.save_homepage_shortcut_to_kv_store();
  }

  delete_myself() {
    this.delete_confirm += 300;
    if (this.delete_confirm >= 301) {
      this.editing = false;
      this.bunch_of_homepage_shortcuts.del_homepage_shortcut(this.my_index);
      this.save_homepage_shortcut_to_kv_store();
    }
  }

  save_homepage_shortcut_to_kv_store() {
    console.log("[Meow][meowShortcutsManager] Started to save custom Homepage Shortcuts " +
    this.bunch_of_homepage_shortcuts.export_string() + " to Settings!")
    this.bunch_of_settings.set('homepage_shortcuts', this.bunch_of_homepage_shortcuts.export_string());
  }
}
