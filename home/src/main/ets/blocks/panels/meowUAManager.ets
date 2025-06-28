import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysSymbol from '../../components/texts/linysSymbol';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import { animation_default, capsule_bar_height, fontSize_Large, fontSize_Normal } from '../../hosts/bunch_of_defaults';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import { bunch_of_user_agents, user_agent } from '../../hosts/bunch_of_user_agents';

@Component
struct meowUAManager {
  @StorageLink('bunch_of_user_agents') bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @StorageLink('universal_global_custom_ua_gateway') now_global_custom_UA: string = "";
  @StorageLink('user_agent_selected') @Watch('on_select') selected_index: number = -1; // -1 for system default
  @State default_pressing: boolean = false;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';

  build() {
    Column({ space: 2.5 }) {
      // linysText({
      //   text: this.selected_index.toString() + ': ' + this.now_global_custom_UA
      // })

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

      ForEach(this.bunch_of_user_agents.list_of_user_agents, (_user_agent: user_agent, key: number) => {
        meowUAButton({
          selected_index: this.selected_index,
          my_index: key,
        })
      })

      Row() {
        linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })
          .onClick(() => {
            this.add_new_custom_ua();
          })
      } // Add Button
      .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
      .width("100%")
      .padding(5)
    }
    .padding(5)
    .borderRadius(13.5)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .width("100%")
    .animation(animation_default())
  }

  async aboutToAppear() {
    let custom_user_agents = await this.bunch_of_settings.get('custom_user_agents') as string;
    this.bunch_of_user_agents.import_string(custom_user_agents);
    this.selected_index = await this.bunch_of_settings.get('custom_user_agents_selected_index') as number;

    // Get UA

    console.log("[Meow][meowUAManager] UA Manager READY");
  }

  on_select() {
    // console.log('meow ' + this.selected_index.toString())
    if (this.selected_index <= -1) {
      // If set back to default
      this.now_global_custom_UA = "";
    } else {
      this.now_global_custom_UA = this.bunch_of_user_agents.list_of_user_agents[this.selected_index].user_agent_content;
    }
  }

  add_new_custom_ua() {
    this.bunch_of_user_agents.add_user_agent(new user_agent(new Date().toLocaleString(),
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0"));
    this.bunch_of_settings.set('custom_user_agents', this.bunch_of_user_agents.export_string());
  }
}

export default meowUAManager;

@Component
struct meowUAButton {
  @Link selected_index: number;
  @Prop my_index: number;
  @StorageLink('bunch_of_user_agents') bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  @State my_ua: user_agent = this.bunch_of_user_agents.list_of_user_agents[this.my_index];
  @State my_label: string = this.my_ua.label;
  @State my_content: string = this.my_ua.user_agent_content;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // statuses
  @State pressing: boolean = false;
  @State editing: boolean = false;
  @State press_timing_ok: boolean = false;
  press_timing: number = 0;
  button_height_default: number = 42;
  // Edit inputs
  @State edit_label: string = this.my_label;
  @State edit_content: string = this.my_content;
  // UI effects
  @State height_of_text_area: number = 42;
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
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width(this.press_timing_ok ? 22 : 0)
          .margin({ left: this.press_timing_ok ? 10 : 0 })
          .animation(animation_default())

        } // UA button
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
          this.set_global_UA_to_mine();
          // Set UA
        })
        .height(this.button_height_default)
        .onMouse((e) => {
          if (e.button == MouseButton.Right && e.action == MouseAction.Press) {
            // Right click
            this.editing = !this.editing;
          }
        })

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
            .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
            .animation(animation_default())
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
    .animation(animation_default())
    .onAppear(() => {
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

  set_global_UA_to_mine() {
    this.selected_index = -99;
    this.selected_index = this.my_index;
    this.bunch_of_settings.set('custom_user_agents_selected_index', this.my_index);
  }

  save_changes() {
    this.edit_content = this.edit_content.replaceAll("\n", "");

    this.my_label = this.edit_label;
    this.my_content = this.edit_content;
    this.bunch_of_user_agents.list_of_user_agents[this.my_index].label = this.edit_label;
    this.bunch_of_user_agents.list_of_user_agents[this.my_index].user_agent_content = this.edit_content;
    this.save_user_agents_to_settings();

    if (this.selected_index == this.my_index) {
      this.set_global_UA_to_mine();
    }

    // This would refresh UI in other places
    this.bunch_of_user_agents.update_last_accessed();
  }

  delete_myself() {
    this.editing = false;
    this.bunch_of_user_agents.del_user_agent(this.my_index);

    if (this.selected_index == this.my_index) {
      this.selected_index = this.my_index - 1;
    } else {
      let previous_selected = this.selected_index;
      this.selected_index = -2;
      this.selected_index = Math.min(this.bunch_of_user_agents.list_of_user_agents.length - 1, previous_selected);
      // Refresh
    }
    this.save_user_agents_to_settings();
  }

  save_user_agents_to_settings() {
    console.log("[Meow][meowUAManager] Started to save custom user-agents to KVStore!")
    this.bunch_of_settings.set('custom_user_agents', this.bunch_of_user_agents.export_string());
  }
}
