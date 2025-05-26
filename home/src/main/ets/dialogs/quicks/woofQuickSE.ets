import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysShowButton from '../../components/buttons/linysShowButton';
import linysSymbol from '../../components/texts/linysSymbol';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  default_search_engine,
  fontSize_Large,
  fontSize_Normal
} from '../../hosts/bunch_of_defaults';
import { bunch_of_search_engines, search_engine } from '../../hosts/bunch_of_search_engines';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import woofControlFrame from '../woofControlFrame';

@CustomDialog
struct woofAddSE {
  controller: CustomDialogController;
  @Prop link: string = '';
  @Prop label: string = '';
  @Prop keyword: string = ''
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Host
  @StorageLink('bunch_of_search_engines') bunch_of_search_engines: bunch_of_search_engines = new bunch_of_search_engines();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Animation UI Statuses
  @State adding_SE: boolean = false;
  @State height_of_add_panel: number = 0;
  button_height_default: number = 42;
  // Data
  @State @Watch('on_click_selected') clicked_index: number = -1;
  // Gateways
  @StorageLink('universal_load_url_gateway') load_url_gateway: string = "";

  build() {
    woofControlFrame({
      title: $r('app.string.AddSE_search_again_on'),
      controller: this.controller
    }) {
      Scroll() {
        Column({ space: 15 }) {

          Column({ space: 6.5 }) {
            Row() {
              Text($r('app.string.Settings_general_custom_ua_default'))// Title
                .fontColor(this.color_current_font)
                .animation(animation_default())
                .fontSize(fontSize_Normal())
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }
            .padding(10)
            .borderRadius(7)
            .backgroundColor(this.color_current_primary)
            .animation(animation_default())
            .height(this.button_height_default)
            .width("100%")
            .animation(animation_default())
            .clickEffect(click_effect_default())
            .onClick(() => {
              this.load_url_gateway = default_search_engine().replaceAll('%s', this.keyword);
              if (this.controller) {
                this.controller.close();
              }
            })

            ForEach(
              this.bunch_of_search_engines.list_of_search_engines, (_user_agent: search_engine, key: number) => {
              meowSEButton({
                my_index: key,
                meow: this.clicked_index
              })
            })
          } // List of SEs
          .padding(6.5)
          .borderRadius(13.5)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .width("100%")
          .animation(animation_default())

          Column() {
            Row() {
              linysShowButton({
                symbol_glyph_target: 'sys.symbol.plus_square',
                text: $r('app.string.AddSE_add_to_search_engines'),
                show: this.adding_SE
              })
                .onClick(() => {
                  this.adding_SE = !this.adding_SE;
                })
            } // Plus button
            .width("100%")
            .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)

            Scroll() {
              Column({ space: 10 }) {
                Row({ space: 10 }) {
                  linysSymbol({ symbol_glyph_target: "sys.symbol.rename" })
                  TextInput({ text: this.label })
                    .onChange((value) => {
                      this.label = value;
                    })
                    .fontWeight(FontWeight.Regular)
                    .fontColor(this.color_current_font)
                    .caretColor(this.color_current_font)
                    .selectedBackgroundColor(this.color_current_font)
                    .layoutWeight(1)
                    .height(capsule_bar_height())

                } // Edit label
                .width("100%")

                Row({ space: 10 }) {
                  linysSymbol({ symbol_glyph_target: "sys.symbol.paperclip" })
                  TextArea({ text: this.link })
                    .onChange((value) => {
                      this.link = value;
                    })
                    .fontWeight(FontWeight.Regular)
                    .fontColor(this.color_current_font)
                    .caretColor(this.color_current_font)
                    .selectedBackgroundColor(this.color_current_font)
                    .layoutWeight(1)

                } // Edit content
                .width("100%")
                .animation(animation_default())

                Row() {
                  Blank()
                  linysCapsuleButton({ text: '  󰀓  ' })
                    .onClick(() => {
                      this.bunch_of_search_engines.add_search_engine(new search_engine(this.label, this.link));
                      this.bunch_of_settings.set('custom_search_engines', this.bunch_of_search_engines.export_string());
                    })
                } // Confirm Button
                .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
                .width("100%")
              }
              .onAreaChange((_o, n) => {
                this.height_of_add_panel = n.height as number;
              })
            }
            .margin({ top: this.adding_SE ? 15 : 0 })
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.PARENT_FIRST
            })
            .edgeEffect(EdgeEffect.Spring)
            .height(this.adding_SE ? this.height_of_add_panel : 0)
            .animation(animation_default())
            .scrollBar(BarState.Off)
          } // Add
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width("100%")
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({
        maxHeight: 48.5 * this.bunch_of_search_engines.list_of_search_engines.length + (this.adding_SE ? 260 : 110)
      })
      .animation(animation_default())
      .onAppear(() => {
        // Preserve the main title only
        this.label = this.label.replace(this.keyword, '');
        this.label = this.label.replace(/ ?[_-] ?/g, '');
      })
    }
  }

  on_click_selected() {
    // Choose to search on another engine
    this.load_url_gateway =
      this.bunch_of_search_engines.list_of_search_engines[this.clicked_index].url.replaceAll('%s', this.keyword);
    if (this.controller) {
      this.controller.close();
    }
  }
}

export default woofAddSE;

@Component
struct meowSEButton {
  @Link meow: number;
  @StorageLink('search_engine_selected') selected_index: number = -2; // -1 for system default
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
          this.meow = this.my_index;
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

      // .border({
      //   radius: 10,
      //   width: 2,
      //   color: "transparent"
      // })
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