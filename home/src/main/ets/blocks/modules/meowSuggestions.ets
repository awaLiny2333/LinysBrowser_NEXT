import { animation_default, click_effect_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_bookmarks } from '../../hosts/bunch_of_bookmarks';
import { bunch_of_history } from '../../hosts/bunch_of_history';
import linysText from '../../components/texts/linysText';
import { search_label_link } from '../../utils/data_operation_tools';
import lazy woofQR from '../../dialogs/contents/woofQR';
import linysSymbol from '../../components/texts/linysSymbol';

@Component
struct meowSuggestions {
  // Environments or settings
  @Prop top_margin: number = 0;
  @Prop bottom_margin: number = 0;
  @State content_height: number = 0;
  @LocalStorageProp('is_search_input_typing') is_search_input_typing: boolean = false;
  @LocalStorageProp('search_input') @Watch('refresh_suggestions') search_input: string = "";
  @LocalStorageLink('search_extracted_keyword') search_extracted_keyword: string = '';
  @LocalStorageProp('screen_height') screen_height: number = 0;
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('leftAvoidWidth') leftAvoidWidth: number = 1;
  @LocalStorageLink('rightAvoidWidth') rightAvoidWidth: number = 1;
  @LocalStorageLink('showing_more_options') showing_more_options: boolean = false;
  @LocalStorageLink('showing_app_settings') showing_app_settings: boolean = false;
  @LocalStorageLink('showing_downloads') showing_downloads: boolean = false;
  // Hosts
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("meow");
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history(true);
  // Settings
  @StorageLink('max_bookmark_advice') max_bookmark_advice: number = 5;
  @StorageLink('max_history_advice') max_history_advice: number = 5;
  // Myself
  @State bookmark_suggestions: string[][] = [];
  @State history_suggestions: string[][] = [];
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Scroll() {
      if (this.tablet_mode) {
        Row({ space: this.bookmark_suggestions.length > 0 && this.history_suggestions.length > 0 ? 10 : 0 }) {
          suggestionList({ suggestions: this.bookmark_suggestions })
            .layoutWeight(1)
            .visibility(this.bookmark_suggestions.length > 0 ? Visibility.Visible : Visibility.None)
            .animation(animation_default())
          suggestionList({ suggestions: this.history_suggestions })
            .layoutWeight(1)
            .visibility(this.history_suggestions.length > 0 ? Visibility.Visible : Visibility.None)
            .animation(animation_default())
        }
        .alignItems(VerticalAlign.Top)
        .onAreaChange((_o, n) => {
          this.content_height = n.height as number;
        })
        .animation(animation_default())
      } else {
        Column({ space: 10 }) {
          suggestionList({ suggestions: this.bookmark_suggestions })
            .width("100%")
            .visibility(this.bookmark_suggestions.length > 0 ? Visibility.Visible : Visibility.None)
            .animation(animation_default())
          suggestionList({ suggestions: this.history_suggestions })
            .width("100%")
            .visibility(this.history_suggestions.length > 0 ? Visibility.Visible : Visibility.None)
            .animation(animation_default())
        }
        .alignItems(HorizontalAlign.Start)
        .onAreaChange((_o, n) => {
          this.content_height = n.height as number;
        })
        .animation(animation_default())
      }
    }
    .borderRadius(12)
    .scrollBar(BarState.Off)
    .margin({
      left: 15,
      right: 15,
      top: this.top_margin,
      bottom: this.bottom_margin
    })
    .height(Math.min(this.content_height, 0.4 * this.screen_height))
    .visibility(this.visibility_suggestions())
    .animation(animation_default())
    .edgeEffect(EdgeEffect.Spring)
  }

  visibility_suggestions() {
    if (this.bookmark_suggestions.length + this.history_suggestions.length == 0) {
      return Visibility.None;
    }
    if (this.showing_more_options) {
      return Visibility.None;
    }
    if (this.search_input == "") {
      return Visibility.None;
    }
    if (!this.is_search_input_typing) {
      return Visibility.None;
    }
    return Visibility.Visible
  }

  refresh_suggestions() {
    if (!this.is_search_input_typing) {
      return;
    }

    this.showing_more_options = false;
    this.showing_app_settings = false;
    this.showing_downloads = false;
    if (this.search_input === undefined || this.search_input.length == 0) {
      this.bookmark_suggestions = [];
      this.history_suggestions = [];
    } else {
      let all_plain_label_link_collection = this.bunch_of_bookmarks.get_all_plain_label_link();
      let label_link_bookmark: string[][] = [];
      for (let index = 0; index < all_plain_label_link_collection.length; index++) {
        label_link_bookmark.push(Array.from(all_plain_label_link_collection[index]));
      }
      this.bookmark_suggestions = search_label_link(label_link_bookmark, this.search_input, 0.8, this.max_bookmark_advice);
      this.history_suggestions = bunch_of_history.search_with_index(this.search_input.toUpperCase(), this.max_history_advice);
    }
  }
}

export default meowSuggestions;

// @Reusable
@Component
struct meowRelation {
  @Prop relation: string[] = [];
  @Prop index: number;
  @State offset_y: number = 50;
  @State this_visibility: Visibility = Visibility.Hidden;
  @LocalStorageLink('universal_load_url_gateway') load_url_gateway: string = "";
  // Env
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Dialogs
  @State show_title: string = '';
  @State show_url: string = '';
  woofQR_control: CustomDialogController = new CustomDialogController({
    builder: woofQR({
      title: this.show_title,
      link: this.show_url
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  });
  // UI
  @State isEntireHov: boolean = false;

  build() {
    Row({ space: 6 }) {
      Column({ space: 2 }) {
        linysText({
          text: this.relation[0].length == 0 ? "　" : this.relation[0]
        })
        linysText({
          text: this.relation[1]
        })
          .opacity(0.7)
      }
      .borderRadius(8)
      .brightness(this.isEntireHov ? 1.1 : 1)
      .animation(animation_default())
      .padding(7)
      .alignItems(HorizontalAlign.Start)
      // .width("100%")
      .layoutWeight(1)
      .clickEffect(click_effect_default())
      .onClick(() => {
        this.load_url_gateway = this.relation[1];
      })
      .onHover((isHv) => {
        this.isEntireHov = isHv;
      })

      linysSymbol({
        symbol_glyph_target: 'sys.symbol.qrcode',
        can_hover: true
      })// QRcode
        .onClick(() => {
          this.show_title = this.relation[0];
          this.show_url = this.relation[1];
          this.woofQR_control.open();
        })
        .opacity(0.7)
        .padding(10)
    }
    .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
    .visibility(this.this_visibility)
    .offset({ y: this.offset_y })
    .animation(animation_default())
    .onAppear(() => {
      setTimeout(() => {
        this.offset_y = 0;
        this.this_visibility = Visibility.Visible;
      }, (this.index) * 60)
    })
  }
}

@Component
struct suggestionList {
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @Prop suggestions: string[][] = [];

  build() {
    Column() {
      ForEach(this.suggestions, (item: string[], index: number) => {
        meowRelation({
          relation: item,
          index: index
        })
      })
    }
    .padding(6)
    .backgroundColor(this.color_current_primary)
    .borderRadius(12)
    .visibility(this.suggestions.length > 0 ? Visibility.Visible : Visibility.None)
    .animation(animation_default())
  }
}