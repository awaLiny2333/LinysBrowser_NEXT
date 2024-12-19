import { animation_default } from '../hosts/bunch_of_defaults';
import linysText from '../components/linysText';
import { get_relations } from '../utils/label_link_relation_tools';
import { bunch_of_bookmarks } from '../hosts/bunch_of_bookmarks';
import { bunch_of_history } from '../hosts/bunch_of_history';

@Component
struct meowSuggestions {
  // Environments or settings
  @Prop top_margin: number = 0;
  @Prop bottom_margin: number = 0;
  @State content_height: number = 0;
  @StorageProp('is_search_input_typing') is_search_input_typing: boolean = false;
  @StorageProp('search_input') @Watch('refresh_suggestions') search_input: string = "";
  @StorageProp('screen_height') screen_height: number = 0;
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  // Hosts
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("meow");
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history(true);
  // Settings
  @StorageProp('max_bookmark_advice') @Watch('refresh_suggestions') max_bookmark_advice: number = 5;
  @StorageProp('max_history_advice') @Watch('refresh_suggestions') max_history_advice: number = 5;
  // Myself
  @State bookmark_suggestions: string[][] = [];
  @State history_suggestions: string[][] = [];
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Scroll() {
      if (this.tablet_mode) {
        Row({ space: 10 }) {
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
        .onAreaChange((_o, n) => {
          this.content_height = n.height as number;
        })
        .alignItems(HorizontalAlign.Start)
        .animation(animation_default())
      }
    }
    .scrollBar(BarState.Off)
    .margin({
      left: 15,
      right: 15,
      top: this.top_margin,
      bottom: this.bottom_margin
    })
    .height(Math.min(this.content_height, 0.4 * this.screen_height))
    .visibility((this.bookmark_suggestions.length + this.history_suggestions.length == 0) || this.search_input == "" ?
    Visibility.None : this.visible_when_typing())
    .edgeEffect(EdgeEffect.Spring)
    .animation(animation_default())

  }

  visible_when_typing() {
    return this.is_search_input_typing ? Visibility.Visible : Visibility.None
  }

  refresh_suggestions() {
    if (this.search_input === undefined) {
      this.bookmark_suggestions = [];
      this.history_suggestions = [];
    } else {
      let label_link_bookmark = this.bunch_of_bookmarks.get_all_plain_label_link();
      this.bookmark_suggestions =
        get_relations(label_link_bookmark, this.search_input, this.max_bookmark_advice);

      let label_link_history = this.bunch_of_history.get_plain_history();
      this.history_suggestions =
        get_relations(label_link_history, this.search_input, this.max_history_advice);
    }
  }
}

export default meowSuggestions;

@Component
struct meowRelation {
  @Prop relation: string[] = [];
  @Prop index: number;
  @State offset_y: number = 50;
  @State this_visibility: Visibility = Visibility.Hidden;
  @StorageLink('universal_load_url_gateway') load_url_gateway: string = "";

  build() {
    Column({ space: 2 }) {
      linysText({
        text: this.relation[0].length == 0 ? "　" : this.relation[0]
      })
      linysText({
        text: this.relation[1]
      })
        .opacity(0.7)
    }
    .alignItems(HorizontalAlign.Start)
    .width("100%")
    .visibility(this.this_visibility)
    .offset({ y: this.offset_y })
    .animation(animation_default())
    .onClick(() => {
      this.load_url_gateway = this.relation[1];
    })
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
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @Prop suggestions: string[][] = [];

  build() {
    Column({ space: 8 }) {
      ForEach(this.suggestions, (item: string[], index: number) => {
        meowRelation({
          relation: item,
          index: index
        })
      })
    }
    .padding(15)
    .backgroundColor(this.color_current_primary)
    .borderRadius(10)
    .visibility(this.suggestions.length > 0 ? Visibility.Visible : Visibility.None)
    .animation(animation_default())
  }
}