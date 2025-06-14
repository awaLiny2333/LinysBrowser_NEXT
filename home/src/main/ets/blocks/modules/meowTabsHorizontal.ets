import linysShowButton from '../../components/buttons/linysShowButton';
import linysSymbol from '../../components/texts/linysSymbol';
import { animation_default, click_effect_default, fontSize_Large, fontSize_Normal } from '../../hosts/bunch_of_defaults';
import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import { LengthMetrics } from '@kit.ArkUI';
import { allow_drop_types, drop_to_scratching_board } from '../../utils/drag_drop_tools';
import linysText from '../../components/texts/linysText';
import { deviceInfo } from '@kit.BasicServicesKit';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';

@Component
struct meowTabsHorizontal {
  // HOST
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  // Environments
  @StorageLink('showing_tabs') showing_tabs: boolean = false;
  @StorageLink('showing_more_options') showing_more_options: boolean = false;
  @StorageLink('windowDecorWidth') windowDecorWidth: number = 0;
  @StorageLink('current_main_tab_index') current_main_tab_index: number = 0;
  @StorageLink('current_sub_tab_index') current_sub_tab_index: number = -1;
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageProp('pathDir') pathDir: string = "";
  @StorageProp('title_bar_position') title_bar_position: string = "";
  // Controls and environments
  @StorageLink('tab_titles') tab_titles: string[] = []
  @StorageLink('current_title') current_title: string = "=￣ω￣=";
  @StorageLink('tab_urls') tab_urls: string[] = []
  @StorageLink('current_url') current_url: string = "=￣ω￣=";
  @StorageLink('tab_loading_progresses') tab_loading_progresses: number[] = [0]
  @StorageLink('current_loading_progress') current_loading_progress: number = 0
  @StorageLink('tab_is_loading') tab_is_loading: boolean[] = [true]
  @StorageLink('current_is_loading') current_is_loading: boolean = true
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Gateways
  @StorageLink('universal_new_tab_gateway') new_tab_gateway: string = "";
  @StorageLink('choosing_paralleow') choosing_paralleow: boolean = false;
  @StorageLink('universal_close_all_tabs_gateway') close_all_tabs_gateway: number = -1;
  // UI statuses
  @State length_width_of_tabs: number = 0;
  @State full_area_width: number = 10;
  // Drop
  @StorageLink('showing_scratching_board') showing_scratching_board: boolean = false;

  build() {
    Column() {
      Row({ space: 10 }) {
        linysTimeoutButton({
          text: '  󰀁  ',
          onExecution: () => {
            this.close_all_tabs_gateway = Date.now();
          }
        })
          .visibility(!this.tablet_mode || this.choosing_paralleow || this.current_sub_tab_index >= 0 ? Visibility.None : Visibility.Visible)
          .animation(animation_default())
          .padding({ left: 5 })

        Row() {
          linysText({
            text: $r('app.string.Index_tabs_title_drag')
          })
        } // Drag area
        .visibility(this.visibility_2in1_top())
        .height(this.length_width_of_tabs > this.full_area_width ? 55 : 40)
        .animation(animation_default())
        .justifyContent(FlexAlign.Center)
        .borderRadius(12)
        .padding(10)
        .width(50 + 10)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .clickEffect(click_effect_default())

        Scroll() {
          Row({ space: this.tablet_mode ? 7 : 5 }) {
            ForEach(this.tab_titles, (title: string, index: number) => {
              HorizontalTabButton({
                current_main_tab_index: this.current_main_tab_index,
                current_sub_tab_index: this.current_sub_tab_index,
                index: index,
                title: title,
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
        .scrollBar(this.tab_width() == 80 ? BarState.On : BarState.Off)
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
            this.choose_paralleow();
          })
          .visibility(this.tablet_mode ? (this.tab_titles.length > 1 ? Visibility.Visible : Visibility.Hidden) : Visibility.None)
          .margin({ left: 4 })
          .animation(animation_default())

        linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })// New tab
          .onClick(() => {
            this.new_tab_gateway = "new_tab";
          })
          .margin({ right: 8 })
          .visibility(this.tablet_mode ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

        Row() {
          Row() {
            linysText({
              text: $r('app.string.Index_tabs_title_drag')
            })
          }
          .justifyContent(FlexAlign.Center)
          .padding(10)
          .height(this.length_width_of_tabs > this.full_area_width ? 55 : 40)
          .borderRadius(12)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .width(50 + 10)
          .clickEffect(click_effect_default())
        } // Drag area
        .justifyContent(FlexAlign.Start)
        .visibility(this.visibility_2in1_top())
        .width(this.windowDecorWidth + 50)
        .animation(animation_default())

      } // Base container
      .alignItems(VerticalAlign.Center)

      Row({ space: 5 }) {
        linysTimeoutButton({
          text: '  󰀁  ',
          onExecution: () => {
            this.close_all_tabs_gateway = Date.now();
          }
        })
          .visibility(this.choosing_paralleow || this.current_sub_tab_index >= 0 ? Visibility.None : Visibility.Visible)
          .animation(animation_default())
        // .padding({ left: 5 })

        Blank()

        linysShowButton({
          symbol_glyph_target: 'sys.symbol.map',
          show: this.choosing_paralleow || this.current_sub_tab_index >= 0,
          text: this.choosing_paralleow ? $r('app.string.Paralleow_choose_a_tab') : $r('app.string.Paralleow')
        })// Paralleow entrance
          .onClick(() => {
            this.choose_paralleow();
          })
          .visibility(this.tab_titles.length > 1 ? Visibility.Visible :
          Visibility.Hidden)// .margin({ left: 4, bottom: this.length_width_of_tabs > this.full_area_width ? 15 : 0 })
          .animation(animation_default())

        linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square' })// New tab
          .onClick(() => {
            AppStorage.set('extra_background', false);
            this.new_tab_gateway = "new_tab";
          })// .margin({ bottom: this.length_width_of_tabs > this.full_area_width ? 15 : 0, right: 8 })
          .animation(animation_default())
      } // Extension for compact (non-tablet mode) layout
      .alignItems(VerticalAlign.Center)
      .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
      .visibility(this.tablet_mode ? Visibility.None : Visibility.Visible)
      .padding({ left: 7, right: 7, top: this.length_width_of_tabs > this.full_area_width ? 0 : 10 })
      .animation(animation_default())
      .width('100%')

    }
    .padding({ left: 8, right: 8 })
    .animation(animation_default())
    .allowDrop(allow_drop_types())
    .onDrop((e) => {
      drop_to_scratching_board(e);
    })
    .onDragEnter(() => {
      this.showing_scratching_board = true;
      this.showing_more_options = false;
    })
    .onDragLeave(() => {
      this.showing_scratching_board = false;
    })
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
    let result = (this.full_area_width) / (this.tab_titles.length) - (this.tablet_mode ? 7 : 5);
    if (result > 200) {
      return 200;
    }
    if (result < 80) {
      return 80;
    }
    return result;
  }

  visibility_2in1_top() {
    return deviceInfo.deviceType == '2in1' && this.title_bar_position == 'top' && this.tablet_mode ? Visibility.Visible : Visibility.None;
  }
}

export default meowTabsHorizontal;

@Component
struct HorizontalTabButton {
  @Link current_main_tab_index: number;
  @Link current_sub_tab_index: number;
  @Prop index: number;
  @Prop title: string;
  @Link full_area_width: number;
  @Link tab_titles: string[];
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  // Gateways
  @StorageLink('universal_close_tab_gateway') close_tab_gateway: number = -1;
  @StorageLink('universal_tab_button_click_gateway') uni_tab_button_clicked: number = -1;
  @State offset_y: number = 100;
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Row({ space: 8 }) {
      if (this.preferred_hand_left_or_right == 'left') {
        SymbolGlyph($r('sys.symbol.xmark'))// Close icon
          .fontSize(fontSize_Normal())
          .fontColor([this.color_current_font])
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.close_tab_gateway = this.index;
            // Close tab
          })
          .visibility(this.tab_width() <= 80 ? this.visibility_visible_on_chosen(this.index) : Visibility.Visible)
          .animation(animation_default())
      }

      Text("󰇀")// Paralleow icon
        .fontSize(fontSize_Large())
        .fontColor(this.color_current_font)
        .fontWeight((this.current_main_tab_index == this.index || this.current_sub_tab_index == this.index) ? FontWeight.Bold : undefined)
        .visibility(this.current_sub_tab_index == this.index ? Visibility.Visible : Visibility.None)
        .animation(animation_default())
        .offset({ y: -2 })

      Text(this.title == "" ? "Meow" : this.title)
        .fontColor(this.color_current_font)
        .fontSize(fontSize_Normal())
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Start)
        .maxLines(1)
        .lineSpacing(LengthMetrics.vp(4))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      if (this.preferred_hand_left_or_right == 'right') {
        SymbolGlyph($r('sys.symbol.xmark'))// Close icon
          .fontSize(fontSize_Normal())
          .fontColor([this.color_current_font])
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.close_tab_gateway = this.index;
            // Close tab
          })
          .visibility(this.tab_width() <= 80 ? this.visibility_visible_on_chosen(this.index) : Visibility.Visible)
          .animation(animation_default())
      }
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
        ? this.color_current_font : "transparent"
    })
    .backgroundColor(this.color_current_primary)
    .animation(animation_default())
    .onAppear(() => {
      setTimeout(() => {
        this.offset_y = 0;
      }, 50)
    })
    .clickEffect(click_effect_default())
  }

  tab_width() {
    let result = (this.full_area_width) / (this.tab_titles.length) - (this.tablet_mode ? 7 : 5);
    if (result > 200) {
      return 200;
    }
    if (result < 80) {
      return 80;
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
