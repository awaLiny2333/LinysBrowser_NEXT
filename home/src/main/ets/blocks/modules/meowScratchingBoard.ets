import { animation_default, animation_popup_duration, click_effect_default } from '../../hosts/bunch_of_defaults';
import { extract_links_from_text, is_downloadable } from '../../utils/url_tools';
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import lazy { copy } from '../../utils/clipboard_tools';
import lazy { preview_image } from '../../utils/preview_tools';
import lazy { document_save_from_uri, image_save_from_uri } from '../../utils/storage_tools';
import { add_units_to_size, get_file_size_Sync, get_file_suffix } from '../../utils/storage_tools';
import lazy { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysSymbol from '../../components/texts/linysSymbol';
import linysText from '../../components/texts/linysText';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { storage_of_id } from '../../utils/ui_tools';

@Component
struct meowScratchingBoard {
  // Links
  @LocalStorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  @LocalStorageLink('drop_result_strings') @Watch('on_data_change') data_list: string[] = [];
  // UI
  @Prop show_feed_prompt: boolean = true;
  @State area_height: number = 200;
  @LocalStorageProp('screen_height') screen_height: number = 0;
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
      linysTextTitle({
        text: this.show_feed_prompt ? $r('app.string.Index_drop_please') : $r('app.string.Index_drop_ok')
      })
        .width(this.show_feed_prompt ? undefined : "100%")
        .animation(animation_default())

      Scroll(this.scroll_controller) {
        Column({ space: 10 }) {
          ForEach(this.extracted_data, (item: string, index: number) => {
            data_display({
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
      .borderRadius(10)
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
struct data_display {
  @Link showing_scratching_board: boolean;
  @State text: string = "meow";
  @State type: string = "text";
  @State downloadable: boolean = false;
  @State download_filename: string = '';
  @State image_size: string = "233x233";
  @State index: number = 0;
  @State offset_y: number = 50;
  @State this_visibility: Visibility = Visibility.Hidden;
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Environment
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  @LocalStorageLink('universal_new_tab_gateway') new_tab_gateway: string = "";
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageProp('screen_width') screen_width: number = 0;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Status
  @State copied: number = 0;
  @State image_height: number = 0;
  @State image_width: number = 0;

  aboutToAppear(): void {
    if (this.type == 'url') {
      this.downloadable = is_downloadable(this.text)[0] as boolean;
      this.download_filename = is_downloadable(this.text)[1] as string;
    }
  }

  // Save menu
  @Builder
  SaveMenu() {
    Menu() {
      MenuItem({
        content: $r('app.string.Save_to_files'),
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.arrow_right_folder_circle')).fontSize('24vp'),
      })
        .onClick(() => {
          document_save_from_uri(this.text);
        })
      MenuItem({
        content: $r('app.string.Save_to_gallery'),
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.picture_badge_arrow_down')).fontSize('24vp'),
      }).onClick(() => {
        image_save_from_uri(this.text, this.getUIContext().getHostContext()!);
      })
    }
    .fontColor(this.color_current_font)
    .backgroundColor(this.color_current_primary)
  }

  build() {
    Row({ space: 15 }) {
      if (this.type == 'image') {
        RelativeContainer() {
          Image(this.text)
            .width(Math.min(300, this.screen_width - 100))
            .borderRadius(10)
            .onComplete((event) => {
              let imageWidth = event?.width;
              let imageHeight = event?.height;
              this.image_size = imageWidth + 'x' + imageHeight
              // console.info('imageWidth:'+imageWidth,'imageHeight:'+imageHeight);
            })
            .id('image')
            .onAreaChange((_o, n) => {
              this.image_height = n.height as number;
              this.image_width = n.width as number;
            })

          Scroll() {
            Flex({
              direction: !this.tablet_mode ? FlexDirection.Row : FlexDirection.Column,
              space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) }
            }) {
              linysText({ text: this.image_size })// Size
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .padding(10)
                .borderRadius(10)
              linysText({ text: get_file_suffix(this.text) }) // Type
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .padding(10)
                .borderRadius(10)
              linysText({ text: add_units_to_size(get_file_size_Sync(this.text)) })
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .padding(10)
                .borderRadius(10)
            } // Info display
          }
          .borderRadius(10)
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .constraintSize(this.tablet_mode ? { maxHeight: this.image_height } : { maxWidth: this.image_width })
          .scrollable(this.tablet_mode ? ScrollDirection.Vertical : ScrollDirection.Horizontal)
          .id('info')
          .margin(this.tablet_mode ? { left: 10 } : { top: 10 })
          .alignRules(this.tablet_mode
            ? {
              top: { anchor: 'image', align: VerticalAlign.Top },
              left: { anchor: 'image', align: HorizontalAlign.End }
            }
            : {
              top: { anchor: 'image', align: VerticalAlign.Bottom },
              left: { anchor: 'image', align: HorizontalAlign.Start }
            })
        }
        .width('auto')
        .height('auto')
        .animation(animation_default())

        Column({ space: 10 }) {
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.save'
          }) // Save
            .clickEffect(click_effect_default())
            .bindMenu(this.SaveMenu)
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.magnifyingglass'
          }) // Search
            .clickEffect(click_effect_default())
            .onClick(() => {
              // Search online
            })
          linysSymbol({
            symbol_glyph_target: 'sys.symbol.arrow_up_left_and_arrow_down_right'
          })
            .clickEffect(click_effect_default())
            .onClick(() => {
              preview_image(this.text, this.storage);
            }) // Preview
        } // Buttons
      } else {
        // Type Symbol
        linysSymbol({
          symbol_glyph_target: this.type_symbol(),
          font_weight: this.type == "text" ? FontWeight.Regular : FontWeight.Medium,
        })
        // Text display
        linysText({
          text: this.text,
          max_lines: 10,
          font_weight: this.type == "text" ? FontWeight.Regular : FontWeight.Bold,
        })
          .layoutWeight(1)
        // Buttons
        Row({ space: 10 }) {
          // Text copy
          linysSymbol({
            symbol_glyph_target: this.copied ? 'sys.symbol.checkmark_clipboard_fill' : 'sys.symbol.text_clipboard'
          })
            .clickEffect(click_effect_default())
            .onClick(() => {
              this.copy_text(this.text);
            })
          // Download button
          if (this.downloadable) {
            linysSymbol({
              symbol_glyph_target: 'sys.symbol.download'
            })
              .clickEffect(click_effect_default())
              .onClick(() => {
                this.download_url(this.text);
              })
          }
          // Url visit button
          if (this.type == 'url') {
            linysSymbol({
              symbol_glyph_target: 'sys.symbol.arrow_right'
            })
              .clickEffect(click_effect_default())
              .onClick(() => {
                this.open_url(this.text);
              })
          }

        }
      } // Content display with Controls
    }
    .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
    .padding(15)
    .borderRadius(20)
    .backgroundColor(this.color_current_primary)
    .justifyContent(FlexAlign.Start)
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
    .onClick(() => {
      this.default_action();
    })
  }

  /**
   * The default symbols for different types of items.
   * @returns the symbolGlyphs id name.
   * */
  type_symbol() {
    if (this.type == 'url') {
      return 'sys.symbol.paperclip';
    }
    if (this.type == 'image') {
      return 'sys.symbol.picture';
    }
    return 'sys.symbol.text_and_t'
  }

  // Actions

  /**
   * The default actions for link, text and image when clicked.
   * */
  default_action() {
    if (this.type == 'url') {
      this.open_url(this.text);
    }
    if (this.type == 'text') {
      this.copy_text(this.text);
    }
    if (this.type == 'image') {
      preview_image(this.text, this.storage);
    }
  }

  /**
   * Copies a text into system pasteboard.
   * @param text the text
   * */
  copy_text(text: string) {
    copy(text);
    this.copied = animation_popup_duration();
  }

  /**
   * Calls the webViews to open a new tab
   * @param link the link of new tab
   * */
  open_url(url: string) {
    this.new_tab_gateway = url;
    this.showing_scratching_board = false;
  }

  /**
   * Call the webViews to download something from a link
   * @param link the link of file to be downloaded
   * */
  download_url(url: string) {
    try {
      (this.storage.get('bunch_of_tabs') as bunch_of_tabs).workingMainTab().controller.startDownload(url);
    } catch (e) {
      console.error('[meowScratchingBoard] Download Url failed! ' + e);
    }
  }
}