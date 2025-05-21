import linysCapsuleButton from '../../components/linysCapsuleButton';
import linysSymbol from '../../components/linysSymbol';
import linysText from '../../components/linysText';
import linysTimeoutButton from '../../components/linysTimeoutButton';
import linysTitleText from '../../components/linysTitleText';
import { animation_default, animation_popup_duration, click_effect_default } from '../../hosts/bunch_of_defaults';
import { copy } from '../../utils/clipboard_tools';
import { preview_image } from '../../utils/preview_tools';
import { document_save_from_uri as document_save_from_uri } from '../../utils/storage_tools';
import { extract_links_from_text } from '../../utils/url_tools';

@Component
struct meowScratchingBoard {
  // Links
  @StorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  @StorageLink('drop_result_strings') @Watch('on_data_change') data_list: string[] = [];
  // UI
  @Prop show_feed_prompt: boolean = true;
  @State area_height: number = 200;
  @StorageProp('screen_height') screen_height: number = 0;
  @State delete_confirm: number = 0;
  @State only_links: boolean = false;
  // Processed data
  @State extracted_data: string[] = [];
  @State extracted_type: string[] = [];
  // Else
  scroll_controller: Scroller = new Scroller();
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 10 }) {
      linysTitleText({
        text: this.show_feed_prompt ? $r('app.string.Index_drop_please') : $r('app.string.Index_drop_ok')
      })
        .width(this.show_feed_prompt ? undefined : "100%")
        .animation(animation_default())

      Scroll(this.scroll_controller) {
        Column({ space: 10 }) {
          ForEach(this.extracted_data, (item: string, index: number) => {
            raw_data_display({
              text: item,
              type: this.extracted_type[index],
              index: index,
              showing_scratching_board: this.showing_scratching_board,
            })// Filter only links
              .visibility(this.only_links && this.extracted_type[index] != 'url' ? Visibility.None : Visibility.Visible)
              .animation(animation_default())
          })
        }
        .alignItems(HorizontalAlign.Start)
        .onAreaChange((_old, n) => {
          this.area_height = n.height as number;
        })
        .width("100%")
        .animation(animation_default())
      } // Text and links data display
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
      .layoutWeight(1)
      .visibility(this.show_feed_prompt ? Visibility.None : Visibility.Visible)
      .width("100%")
      .animation(animation_default())

      Row({ space: 10 }) {
        linysTimeoutButton({
          text: "  󰀁  ",
          onExecution: () => {
            this.clear_data();
          }
        })

        linysCapsuleButton({
          text: this.only_links ? "  󰄏  " : "  󰃁  "
        })
          .animation(animation_default())
          .onClick(() => {
            this.only_links = !this.only_links;
          })
      }
      .justifyContent(FlexAlign.End)
      .width("100%")
      .visibility(this.data_list.length > 0 ? Visibility.Visible : Visibility.None)
      .animation(animation_default())

    }
    .justifyContent(FlexAlign.Center)
    .padding({ left: 15, right: 15 })
    .width("100%")
    .height((this.show_feed_prompt ? 0.3 * this.screen_height :
    Math.min(this.area_height + 43, 0.6 * this.screen_height)) + 40)
    .animation(animation_default())
    .onAppear(() => {
      setInterval(() => {
        if (this.delete_confirm > 0) {
          this.delete_confirm -= 1;
        }
        // Reset delete confirm
      }, 10)
    })
  }

  /**
   * Called when new data comes
   *
   * If data is cleared then show feed prompt next time
   * */
  on_data_change() {
    if (this.data_list.length > 0) {
      this.show_feed_prompt = false;
    } else {
      this.show_feed_prompt = true;
    }

    // Analyzes the data and extract web links
    let extracted_result = extract_links_from_text(this.data_list);
    this.extracted_data = extracted_result[0];
    this.extracted_type = extracted_result[1];

    // console.log(this.extracted_data.join("\n"))
    this.scroll_controller.scrollEdge(Edge.Top);
  }

  clear_data() {
    // Clear all scratching board data
    this.data_list = [];
    this.showing_scratching_board = false;
  }
}

export default meowScratchingBoard;

@Component
struct raw_data_display {
  @Link showing_scratching_board: boolean;
  @State text: string = "meow";
  @State type: string = "text";
  @State index: number = 0;
  @State offset_y: number = 50;
  @State this_visibility: Visibility = Visibility.Hidden;
  @StorageLink('universal_new_tab_gateway') new_tab_gateway: string = "";
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Status
  @State copied: number = 0;

  build() {
    Row({ space: 10 }) {
      if (this.type == 'image') {
        Image(this.text)
          .width(this.tablet_mode ? '50%' : undefined)
          .borderRadius(10)
          .layoutWeight(this.tablet_mode ? undefined : 1)
        Column({ space: 10 }) {
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.save'
          })
            .clickEffect(click_effect_default())
            .onClick(() => {
              document_save_from_uri(this.text);
            })
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.magnifyingglass'
          })
            .clickEffect(click_effect_default())
            .onClick(() => {
              // Search online
            })
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.arrow_up_left_and_arrow_down_right'
          })
            .clickEffect(click_effect_default())
            .onClick(() => {
              // Check details
              preview_image(this.text);
            })
        }
      } else {
        linysSymbol({
          symbol_glyph_target: this.type_symbol(),
          font_weight: this.type == "text" ? FontWeight.Normal : FontWeight.Medium,
        }) // Type Symbol

        linysText({
          text: this.text,
          max_lines: 10,
          font_weight: this.type == "text" ? FontWeight.Normal : FontWeight.Medium,
        })// Text display
          .layoutWeight(1)

        linysSymbol({
          symbol_glyph_target: this.copied ? 'sys.symbol.checkmark_clipboard_fill' : 'sys.symbol.text_clipboard'
        })// Text copy
          .clickEffect(click_effect_default())
          .onClick(() => {
            copy(this.text);
            this.copied = animation_popup_duration();
          })

        if (this.type == 'url') {
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.arrow_right'
          })
            .clickEffect(click_effect_default())
            .onClick(() => {
              this.new_tab_gateway = this.text;
              this.showing_scratching_board = false;
            })
        } // Url visit button
      } // Content display with Controls
    }
    .padding(15)
    .borderRadius(20)
    .backgroundColor(this.color_current_primary)
    .justifyContent(FlexAlign.Start)
    // .alignItems(VerticalAlign.Top)
    .width(this.type == 'image' ? undefined : "100%")
    .visibility(this.this_visibility)
    .offset({ y: this.offset_y })
    .animation(animation_default())
    .onAppear(() => {
      setTimeout(() => {
        this.offset_y = 0;
        this.this_visibility = Visibility.Visible;
      }, Math.min((this.index) * 60, 600))

      setInterval(() => {
        if (this.copied > 0) {
          this.copied -= 10;
        }
        // Reset copy
      }, 10)
    })
    .clickEffect(click_effect_default())

  }

  type_symbol() {
    if (this.type == 'url') {
      return 'sys.symbol.paperclip';
    }
    if (this.type == 'image') {
      return 'sys.symbol.picture';
    }
    return 'sys.symbol.text_and_t'
  }
}