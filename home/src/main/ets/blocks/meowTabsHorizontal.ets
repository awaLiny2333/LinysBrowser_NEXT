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
  @StorageLink('universal_close_tab_gateway') close_tab_gateway: number = -1;
  @StorageLink('choosing_paralleow') choosing_paralleow: boolean = false;
  @StorageLink('universal_tab_button_clicked_gateway') uni_tab_button_clicked: number = -1;
  // UI statuses
  @State length_width_of_tabs: number = 0;
  @State full_area_width: number = 10;

  build() {
    Row({ space: 5 }) {
      Scroll() {
        Row({ space: 5 }) {
          ForEach(this.tab_titles, (title: string, index: number) => {
            Row({ space: 8 }) {
              Text("󰇀")
                .fontSize(fontSize_Large())
                .fontColor($r('app.color.font_color_title'))
                .fontWeight((this.current_main_tab_index == index || this.current_sub_tab_index == index) ?
                FontWeight.Medium : undefined)
                .visibility(this.current_sub_tab_index == index ? Visibility.Visible : Visibility.None)
                .animation(animation_default())

              linysText({ text: title == "" ? "Meow" : title })
                .constraintSize({ maxWidth: 150 })

              SymbolGlyph($r('sys.symbol.xmark'))
                .fontSize(fontSize_Normal())
                .fontColor([$r('app.color.font_color_title')])
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                  this.webViews_ready = true;
                  this.close_tab_gateway = index;
                  // Close tab
                })
            }
            .constraintSize({ maxWidth: 200 })
            .onClick(() => {
              this.uni_tab_button_clicked = index;
            })
            .padding(10)
            .height("100%")
            .border({
              radius: 10,
              width: 2,
              color: (this.current_main_tab_index == index || this.current_sub_tab_index == index)
                ? $r('app.color.font_color_title') : "transparent"
            })
            .backgroundColor($r('app.color.start_window_background'))
            .animation(animation_default())
          })
        }
        .onAreaChange((_old, n) => {
          this.length_width_of_tabs = n.width as number;
        })
        .margin({ bottom: this.length_width_of_tabs > this.full_area_width ? 15 : 0 })
        .animation(animation_default())
      } // Scroll of tab buttons
      .scrollBarWidth(5)
      .scrollBar(BarState.On)
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
      })
        .onClick(() => {
          this.webViews_ready = true;
          this.choose_paralleow();
        })
        .visibility(this.tab_titles.length > 1 ? Visibility.Visible : Visibility.Hidden)
        .margin({ left: 4, bottom: this.length_width_of_tabs > this.full_area_width ? 15 : 0 })
        .animation(animation_default())

      linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })
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
}

export default meowTabsHorizontal;
