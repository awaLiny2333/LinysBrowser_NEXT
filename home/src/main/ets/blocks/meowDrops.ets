import linysCapsuleButton from '../components/linysCapsuleButton';
import linysSymbol from '../components/linysSymbol';
import linysText from '../components/linysText';
import linysTitleText from '../components/linysTitleText';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large
} from '../hosts/bunch_of_defaults';

@Component
struct meowDrops {
  // Links
  @StorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  @Link @Watch('on_data_change') data_list: string[];
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
              .visibility(this.only_links && this.extracted_type[index] == 'text' ?
              Visibility.None : Visibility.Visible)
              .animation(animation_default())
          })
        }
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
        Button("  󰀁  ")// Delete
          .type(ButtonType.Capsule)
          .backgroundColor(this.delete_confirm > 0 ? this.color_current_primary :
          $r("app.color.font_color_title"))
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
            this.clear_data();
          })
          .clickEffect(click_effect_default())
          .animation(animation_default())
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

  on_data_change() {
    // Called when new data comes
    // If data is cleared then show feed prompt next time
    if (this.data_list.length > 0) {
      this.show_feed_prompt = false;
    } else {
      this.show_feed_prompt = true;
    }
    // Analyzes the data and extract web links
    this.extracted_data = [];
    this.extracted_type = [];
    for (let index = 0; index < this.data_list.length; index++) {
      let text = this.data_list[index];
      let match = text.match(/(https?|meow):\/\/[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]/g);
      console.log(match?.join("\n"));
      if (match) {
        for (let inner = 0; inner < match.length; inner++) {
          let position = text.indexOf(match[inner]);
          if (text.substring(0, position).replace(/\s*/, "").length > 0) {
            this.extracted_data.push(text.substring(0, position).replaceAll(/(^\s*)|(\s*$)/g, ""));
            this.extracted_type.push("text");
          }
          this.extracted_data.push(match[inner]);
          this.extracted_type.push("url");
          text = text.substring(position + match[inner].length);
        }
      }
      if (text.replace(/\s*/, "").length > 0) {
        this.extracted_data.push(text.replaceAll(/(^\s*)|(\s*$)/g, ""));
        this.extracted_type.push("text");
      }
    }
    // console.log(this.extracted_data.join("\n"))
    this.scroll_controller.scrollEdge(Edge.Top);
  }

  clear_data() {
    // Clear all scratching board data
    this.delete_confirm += 300;
    if (this.delete_confirm >= 301) {
      this.data_list = [];
      this.showing_scratching_board = false;
      this.delete_confirm = 0;
    }
  }
}

export default meowDrops;

@Component
struct raw_data_display {
  @Link showing_scratching_board: boolean;
  @State text: string = "meow";
  @State type: string = "text";
  @State index: number = 0;
  @State offset_y: number = 50;
  @State this_visibility: Visibility = Visibility.Hidden;
  @StorageLink('universal_new_tab_gateway') new_tab_gateway: string = "";
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');


  build() {
    Row({ space: 10 }) {
      linysSymbol({
        symbol_glyph_target: this.type == "url" ? 'sys.symbol.link' : 'sys.symbol.text_and_t',
        font_weight: this.type == "url" ? FontWeight.Medium : FontWeight.Normal,
      })
      // linysTitleText({ text: this.type })
      linysText({
        text: this.text,
        max_lines: 10,
        font_weight: this.type == "url" ? FontWeight.Medium : FontWeight.Normal,
      })
        .layoutWeight(1)
    }
    .padding(15)
    .borderRadius(10)
    .backgroundColor(this.color_current_primary)
    .justifyContent(FlexAlign.Start)
    .width("100%")
    .visibility(this.this_visibility)
    .offset({ y: this.offset_y })
    .animation(animation_default())
    .onAppear(() => {
      setTimeout(() => {
        this.offset_y = 0;
        this.this_visibility = Visibility.Visible;
      }, Math.min((this.index) * 60, 600))
    })
    .onClick(() => {
      if (this.type == "url") {
        this.new_tab_gateway = this.text;
        this.showing_scratching_board = false;
      }
    })
    .clickEffect(click_effect_default())
  }
}