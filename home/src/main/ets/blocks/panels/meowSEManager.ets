import { animation_default, capsule_bar_height, fontSize_Normal } from '../../hosts/bunch_of_defaults';
import { bunch_of_search_engines, search_engine } from '../../hosts/bunch_of_search_engines';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import linysSymbol from '../../components/texts/linysSymbol';
import linysTextArea from '../../components/texts/linysTextArea';
import linysExpandableCardItem from '../../components/layouts/linysExpandableCardItem';
import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';

@Component
struct meowSEManager {
  @Prop default_new_se: search_engine = new search_engine(new Date().toLocaleString(), "https://bing.com/search?q=%s");
  // Environment
  @StorageLink('search_engine') search_engine: string = "";
  @StorageLink('search_engine_selected') selected_index: number = -2; // -1 for system default
  @State is_pressing_default_card: boolean = false;
  // Colors
  @StorageLink('effects') effects: boolean = false;
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // UI
  @StorageLink('bunch_of_search_engines_update') bunch_of_search_engines_update: number = 0;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // execution
  on_normal_execution?: (idx: number, se: search_engine) => void; // Click on other ItemCards in ForEach list
  on_default_execution?: () => void; // Click on default ItemCard

  aboutToAppear() {
    console.log('[Meow][meowSEManager] Search engine Manager READY! [' + this.search_engine + ']');
  }

  build() {
    Column({ space: 2.5 }) {
      Row() {
        Row() {
          Text($r('app.string.Settings_general_custom_ua_default')) // Title
            .fontColor(!this.is_pressing_default_card ? this.color_current_font : this.color_current_secondary)
            .fontWeight(!this.is_pressing_default_card ? FontWeight.Regular : FontWeight.Bold)
            .padding({ left: 2 })
            .fontSize(fontSize_Normal())
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .margin(10)
            .animation(animation_default())
        }
        .backgroundColor(this.is_pressing_default_card ? this.color_current_font : this.color_current_primary)
        .useEffect(this.effects, EffectType.WINDOW_EFFECT)
        .animation(animation_default())
        .width("100%")
        .height("100%")
        .borderRadius(7)

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
          this.is_pressing_default_card = false;
          // If touch ends
        } else {
          this.is_pressing_default_card = true;
          // If touching
        }
      })
      .onClick(() => {
        if (this.on_default_execution) {
          this.on_default_execution();
        } else {
          bunch_of_search_engines.set_global_SE(-1);
        }
      })
      .height(46)
      .animation(animation_default())
      .hoverEffect(HoverEffect.Highlight)

      ForEach(this.bunch_of_search_engines_update ? bunch_of_search_engines.list_of_search_engines : [], (_se: search_engine, key: number) => {
        meowSECardItem({
          my_index: key,
          onExecution: this.on_normal_execution
        })
      })

      Row() {
        linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square', can_hover: true })
          .onClick(() => {
            this.add_new_custom_search_engine(this.default_new_se);
          })
      } // Add Button
      .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
      .width("100%")
      // .padding(5)
    }
    .padding(5)
    .borderRadius(13.5)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .width("100%")
    .animation(animation_default())
  }

  add_new_custom_search_engine(se: search_engine) {
    bunch_of_search_engines.add_search_engine(se);
    bunch_of_settings.set('custom_search_engines', bunch_of_search_engines.export_string());
  }
}

export default meowSEManager;

@Component
struct meowSECardItem {
  @StorageLink('search_engine_selected') selected_index: number = -1;
  // Data
  @Prop my_index: number;
  my_se: search_engine = bunch_of_search_engines.list_of_search_engines[this.my_index];
  @State my_label: string = this.my_se.label;
  @State my_content: string = this.my_se.url;
  // UI
  @State is_editing: boolean = false;
  // Edit inputs
  @State edit_label: string = this.my_label;
  @State edit_content: string = this.my_content;
  // Colors
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // execution
  onExecution?: (idx: number, se: search_engine) => void;

  @Builder
  contents() {
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
        })
        .height(capsule_bar_height())

    } // Edit label
    .width("100%")

    Row({ space: 10 }) {
      linysSymbol({ symbol_glyph_target: "sys.symbol.paperclip" })
      linysTextArea({
        init_text: this.edit_content,
        text: this.edit_content
      })
        .layoutWeight(1)

    } // Edit content
    .width("100%")
    .animation(animation_default())

    linysConfirmDenyButtons({
      onConfirm: () => {
        this.save_changes();
      },
      onDeny: () => {
        this.delete_myself();
      },
      confirm_text: '  󰀻  ',
      deny_text: '  󰀁  ',
      deny_double_confirm: true
    })
  }

  build() {
    linysExpandableCardItem({
      my_label: this.my_label,
      show_border: this.my_index == this.selected_index,
      is_editing: this.is_editing,
      allow_effects: true,
      onExecution: () => {
        if (this.onExecution) {
          this.onExecution(this.my_index, this.my_se);
        } else {
          // Select me!
          bunch_of_search_engines.set_global_SE(this.my_index);
        }
      },
      content_edit: (): void => {
        this.contents();
      }
    })
  }

  save_changes() {
    this.edit_content = this.edit_content.replaceAll("\n", "");

    this.my_label = this.edit_label;
    this.my_content = this.edit_content;
    bunch_of_search_engines.list_of_search_engines[this.my_index].label = this.edit_label;
    bunch_of_search_engines.list_of_search_engines[this.my_index].url = this.edit_content;
    this.save_search_engine_to_settings();

    // This would refresh UI in other places
    this.is_editing = false;
  }

  delete_myself() {
    this.is_editing = false;
    bunch_of_search_engines.del_search_engine(this.my_index);

    if (this.selected_index == this.my_index) {
      this.selected_index = this.my_index - 1;
    } else if (this.selected_index > this.my_index) {
      this.selected_index -= 1;
    }
    this.save_search_engine_to_settings();
  }

  save_search_engine_to_settings() {
    console.log("[Meow][meowUAManager] Started to save custom search engines to Settings!")
    bunch_of_settings.set('custom_search_engines', bunch_of_search_engines.export_string());
  }
}
