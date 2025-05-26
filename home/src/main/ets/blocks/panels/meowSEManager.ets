import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysSymbol from '../../components/texts/linysSymbol';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import {
  animation_default,
  capsule_bar_height,
  default_search_engine,
  fontSize_Large,
  fontSize_Normal
} from '../../hosts/bunch_of_defaults';
import { bunch_of_search_engines, search_engine } from '../../hosts/bunch_of_search_engines';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';

@Component
struct meowSEManager {
  @StorageLink('bunch_of_search_engines') bunch_of_search_engines: bunch_of_search_engines =
    new bunch_of_search_engines();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @StorageLink('search_engine') search_engine: string = "";
  @StorageLink('search_engine_selected') @Watch('on_select') selected_index: number = -2; // -1 for system default
  @State default_pressing: boolean = false;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 2.5 }) {
      Row() {
        Row() {
          Text($r('app.string.Settings_general_custom_ua_default'))// Title
            .fontColor(!this.default_pressing ? this.color_current_font : this.color_current_secondary)
            .fontWeight(!this.default_pressing ? FontWeight.Regular : FontWeight.Bold)
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
      .border({
        radius: 10,
        width: 2,
        color: -1 == this.selected_index ? this.color_current_font : "transparent",
        // color: "red"
      })
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
      .onClick(() => {
        this.selected_index = -1;
        // Set UA
      })
      .height(46)
      .animation(animation_default())

      ForEach(
        this.bunch_of_search_engines.list_of_search_engines, (_user_agent: search_engine, key: number) => {
        meowSEButton({
          selected_index: this.selected_index,
          my_index: key,
        })
      })

      Row() {
        Blank()
        linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })
          .onClick(() => {
            this.add_new_custom_search_engine();
          })
      } // Add Button
      .width("100%")
      .padding(5)
    }
    .padding(5)
    .borderRadius(13.5)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .width("100%")
    .animation(animation_default())
    .onAppear(() => {
      this.on_appear();
    })
  }

  async on_appear() {
    let custom_search_engine = await this.bunch_of_settings.get('custom_search_engines') as string;
    this.bunch_of_search_engines.import_string(custom_search_engine);
    this.selected_index =
      await this.bunch_of_settings.get('custom_search_engines_selected_index') as number;
    // console.log("[Meow][meowSEManager] Search engine Manager READY");
  }

  // on_SE_change() {
  //   console.log('[Meow][meowSEManager] Search Engine list change! Syncing data to Settings...')
  // }

  on_select() {
    this.select_search_engine(this.selected_index);
  }

  select_search_engine(index: number) {
    if (index <= -1) {
      // If set back to default
      this.search_engine = default_search_engine();
    } else {
      this.search_engine = this.bunch_of_search_engines.list_of_search_engines[index].url;
    }
    this.save_search_engines_to_settings();
  }

  add_new_custom_search_engine() {
    this.bunch_of_search_engines.add_search_engine(new search_engine(new Date().toLocaleString(),
      "https://bing.com/search?q=%s"));
    this.save_search_engines_to_settings();
  }

  // Data utils

  save_search_engines_to_settings() {
    this.bunch_of_settings.set('custom_search_engines', this.bunch_of_search_engines.export_string());
    this.bunch_of_settings.set('custom_search_engines_selected_index', this.selected_index);
  }
}

export default meowSEManager;

@Component
struct meowSEButton {
  @Link selected_index: number;
  @Prop my_index: number;
  @StorageLink('bunch_of_search_engines') bunch_of_search_engines: bunch_of_search_engines =
    new bunch_of_search_engines();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @State my_se: search_engine = this.bunch_of_search_engines.list_of_search_engines[this.my_index];
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
            .fontWeight(!this.pressing ? FontWeight.Regular : FontWeight.Bold)
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
          .scrollBar(BarState.Off)
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
            this.editing = !this.editing;
            return;
          } // Toggle Edit Panel
          this.set_global_SE_to_mine();
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
              TextArea({ text: this.edit_content })
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
              linysTimeoutButton({
                text: "  󰀁  ",
                onExecution: () => {
                  this.delete_myself();
                }
              })
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
      .border({
        radius: 10,
        width: 2,
        color: this.my_index == this.selected_index ? this.color_current_font : "transparent"
      })
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
      }, 10)
    })
  }

  set_global_SE_to_mine() {
    // Rough but works!
    // Forgive Liny about this OwO
    this.selected_index = -1;
    this.selected_index = this.my_index;
  }

  save_changes() {
    this.edit_content = this.edit_content.replaceAll("\n", "");

    this.my_label = this.edit_label;
    this.my_content = this.edit_content;
    this.my_se.label = this.edit_label;
    this.my_se.url = this.edit_content;
    this.save_search_engine_to_kv_store();

    if (this.selected_index == this.my_index) {
      this.set_global_SE_to_mine();
    }
  }

  delete_myself() {

    // Confirm delete
    this.editing = false;
    this.bunch_of_search_engines.del_search_engine(this.my_index);

    if (this.selected_index == this.my_index) {
      this.selected_index = this.my_index - 1;
    } else {
      // Refresh
      let prev_selected = this.selected_index;
      this.selected_index = -2;
      this.selected_index = Math.min(this.bunch_of_search_engines.list_of_search_engines.length - 1, prev_selected);
    }
    this.save_search_engine_to_kv_store();

  }

  save_search_engine_to_kv_store() {
    console.log("[Meow][meowUAManager] Started to save custom user-agents to KVStore!")
    this.bunch_of_settings.set('custom_search_engines', this.bunch_of_search_engines.export_string());
  }
}
