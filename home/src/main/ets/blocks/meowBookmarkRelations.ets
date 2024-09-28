import { animation_default } from '../hosts/bunch_of_defaults';
import linysText from '../components/linysText';
import { get_relations } from '../utils/bookmark_relation_tools';
import { bunch_of_bookmarks } from '../hosts/bunch_of_bookmarks';

@Component
struct meowBookmarkRelations {
  // Environments or settings
  @Prop is_search_input_typing: boolean;
  @Prop top_margin: number = 0;
  @Prop bottom_margin: number = 0;
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("meow");
  @Prop @Watch('get_relations') search_input: string = "";
  @Prop @Watch('get_relations') settings_max_bookmark_suggestions: number = 5;
  // Myself
  @State relations: string[][] = [];

  build() {
    Column({ space: 8 }) {
      ForEach(this.relations, (item: string[], index: number) => {
        meowRelation({
          relation: item,
          index: index
        })
      })
    }
    .height(this.relations.length * 50 + 20)
    .alignItems(HorizontalAlign.Start)
    .margin({
      left: 15,
      right: 15,
      top: this.top_margin,
      bottom: this.bottom_margin
    })
    .padding(15)
    // .layoutWeight(1)
    .borderRadius(10)
    .backgroundColor($r('app.color.start_window_background'))
    .visibility(this.relations.length == 0 || this.search_input == "" ?
    Visibility.None : this.visible_when_typing())
    .animation(animation_default())

  }

  visible_when_typing() {
    return this.is_search_input_typing ? Visibility.Visible : Visibility.None
  }

  get_relations() {
    if (this.search_input === undefined) {
      this.relations = [];
    } else {
      this.relations =
        get_relations(this.bunch_of_bookmarks, this.search_input, this.settings_max_bookmark_suggestions);
    }
  }
}

export default meowBookmarkRelations;

@Component
struct meowRelation {
  @Prop relation: string[] = [];
  @Prop index: number;
  @State offset_y: number = 50;
  @State this_visibility: Visibility = Visibility.Hidden;
  @StorageLink('universal_new_tab_gateway') universal_new_tab_gateway: string = "";

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
      this.universal_new_tab_gateway = this.relation[1];
    })
    .onAppear(() => {
      setTimeout(() => {
        this.offset_y = 0;
        this.this_visibility = Visibility.Visible;
      }, (this.index) * 60)
    })
  }
}