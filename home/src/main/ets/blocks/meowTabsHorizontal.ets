import linysShowButton from '../components/linysShowButton';
import linysSymbol from '../components/linysSymbol';
import linysText from '../components/linysText';
import { animation_default, fontSize_Large, fontSize_Normal } from '../hosts/bunch_of_defaults';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';

@Component
struct meowTabsHorizontal {
  // HOST
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs();
  // Environments
  @Link showing_tabs: boolean;
  @Link webViews_ready: boolean;
  @StorageLink('current_main_tab_index') current_main_tab_index: number = 0;
  @StorageLink('current_sub_tab_index') current_sub_tab_index: number = -1;
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageProp('pathDir') pathDir: string = "";
  // Controls and environments
  @StorageLink('tab_titles') tab_titles: string[] = []
  @StorageLink('current_title') current_title: string = "=￣ω￣=";
  @StorageLink('tab_urls') tab_urls: string[] = []
  @StorageLink('current_url') current_url: string = "=￣ω￣=";
  @StorageLink('tab_loading_progresses') tab_loading_progresses: number[] = [0]
  @StorageLink('current_loading_progress') current_loading_progress: number = 0
  @StorageLink('tab_is_loading') tab_is_loading: boolean[] = [true]
  @StorageLink('current_is_loading') current_is_loading: boolean = true
  // Gateways
  @StorageLink('universal_new_tab_gateway') new_tab_gateway: string = "";
  @StorageLink('choosing_paralleow') choosing_paralleow: boolean = false;
  // UI statuses
  @State length_width_of_tabs: number = 0;
  @State full_area_width: number = 10;

  build() {
    Row({ space: 5 }) {
      Scroll() {
        Row({ space: 5 }) {
          ForEach(this.tab_titles, (title: string, index: number) => {
            HorizontalTabButton({
              current_main_tab_index: this.current_main_tab_index,
              current_sub_tab_index: this.current_sub_tab_index,
              index: index,
              title: title,
              webViews_ready: this.webViews_ready,
              full_area_width: this.full_area_width,
              tab_titles: this.tab_titles
            })
          })
        }
        .onAreaChange((_old, n) => {
          this.length_width_of_tabs = n.width as number;
        })
        .margin({ bottom: this.length_width_of_tabs > this.full_area_width ? 15 : 0 })
        .animation(animation_default())
      } // Scroll of tab buttons
      .scrollBarWidth(5)
      .scrollBar(this.tab_width() == 60 ? BarState.On : BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Start)
      .layoutWeight(1)
      .height(this.length_width_of_tabs > this.full_area_width ? 55 : 40)
      .animation(animation_default())
      .onAreaChange((_old, n) => {
        this.full_area_width = n.width as number;
      })

      linysShowButton({
        symbol_glyph_target: 'sys.symbol.map',
        show: this.choosing_paralleow || this.current_sub_tab_index >= 0,
        text: this.choosing_paralleow ? $r('app.string.Paralleow_choose_a_tab') : $r('app.string.Paralleow')
      })// Paralleow entrance
        .onClick(() => {
          this.webViews_ready = true;
          this.choose_paralleow();
        })
        .visibility(this.tab_titles.length > 1 ? Visibility.Visible : Visibility.Hidden)
        .margin({ left: 4, bottom: this.length_width_of_tabs > this.full_area_width ? 15 : 0 })
        .animation(animation_default())

      linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })// New tab
        .onClick(() => {
          this.webViews_ready = true;
          this.new_tab_gateway = "new_tab";
        })
        .margin({ bottom: this.length_width_of_tabs > this.full_area_width ? 15 : 0 })
        .animation(animation_default())

    } // Base container
    .padding({ left: 8, right: 15 })
    .animation(animation_default())

  }

  choose_paralleow() {
    if (this.choosing_paralleow) {
      // if is choosing, cancel choosing, back to no paralleow
      this.choosing_paralleow = false;
    } else {
      if (this.current_sub_tab_index < 0) {
        // if haven't chosen one, then start to choose
        this.choosing_paralleow = true;
      } else {
        // Quit Paralleow
        this.choosing_paralleow = false;
        this.current_sub_tab_index = -1;
      }
    }
  }

  tab_width() {
    let result = this.full_area_width / (this.tab_titles.length) - 5;
    if (result > 200) {
      return 200;
    }
    if (result < 60) {
      return 60;
    }
    return result;
  }
}

export default meowTabsHorizontal;

@Component
struct HorizontalTabButton {
  @Link current_main_tab_index: number;
  @Link current_sub_tab_index: number;
  @Prop index: number;
  @Prop title: string;
  @Link webViews_ready: boolean;
  @Link full_area_width: number;
  @Link tab_titles: string[];
  // Gateways
  @StorageLink('universal_close_tab_gateway') close_tab_gateway: number = -1;
  @StorageLink('universal_tab_button_clicked_gateway') uni_tab_button_clicked: number = -1;
  @State offset_y: number = 100;

  build() {
    Row({ space: 8 }) {
      Text("󰇀")// Paralleow icon
        .fontSize(fontSize_Large())
        .fontColor($r('app.color.font_color_title'))
        .fontWeight((this.current_main_tab_index == this.index || this.current_sub_tab_index == this.index) ?
        FontWeight.Medium : undefined)
        .visibility(this.current_sub_tab_index == this.index ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      linysText({ text: this.title == "" ? "Meow" : this.title })// Web title text
        .layoutWeight(1)

      SymbolGlyph($r('sys.symbol.xmark'))// Close icon
        .fontSize(fontSize_Normal())
        .fontColor([$r('app.color.font_color_title')])
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.webViews_ready = true;
          this.close_tab_gateway = this.index;
          // Close tab
        })
        .visibility(this.tab_width() < 80 ? this.visibility_visible_on_chosen(this.index) : Visibility.Visible)
        .animation(animation_default())
    }
    .offset({ y: this.offset_y })
    .width(this.tab_width())
    .onClick(() => {
      this.uni_tab_button_clicked = this.index;
    })
    .padding(10)
    .height("100%")
    .border({
      radius: 10,
      width: 2,
      color: (this.current_main_tab_index == this.index || this.current_sub_tab_index == this.index)
        ? $r('app.color.font_color_title') : "transparent"
    })
    .backgroundColor($r('app.color.start_window_background'))
    .animation(animation_default())
    .onAppear(() => {
      setTimeout(() => {
        this.offset_y = 0;
      }, 50)
    })
  }

  tab_width() {
    let result = this.full_area_width / (this.tab_titles.length) - 5;
    if (result > 200) {
      return 200;
    }
    if (result < 60) {
      return 60;
    }
    return result;
  }

  visibility_visible_on_chosen(index: number) {
    if (this.current_main_tab_index == index || this.current_sub_tab_index == index) {
      return Visibility.Visible;
    }
    return Visibility.None;
  }
}
