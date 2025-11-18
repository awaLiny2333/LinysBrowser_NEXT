import { animation_default, click_effect_default, fontSize_Icon_Button, fontSize_Large, fontSize_Normal } from '../../hosts/bunch_of_defaults';
import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import { LengthMetrics } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import lazy { drop_to_scratching_board } from '../../utils/drag_drop_tools';
import linysShowButton from '../../components/buttons/linysShowButton';
import linysSymbol from '../../components/texts/linysSymbol';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import { storage_of_id } from '../../utils/ui_tools';
import { unifiedData_drag_tab_from } from '../../processes/tabs_actions';

@Component
struct meowTabsHorizontal {
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  // HOST
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  // Environments
  @LocalStorageLink('showing_tabs') showing_tabs: boolean = false;
  @LocalStorageLink('showing_more_options') showing_more_options: boolean = false;
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('title_bar_position') title_bar_position: string = "";
  // Controls and environments
  @LocalStorageLink('tab_titles') tab_titles: string[] = []
  @LocalStorageLink('current_title') current_title: string = "=￣ω￣=";
  @LocalStorageLink('tab_urls') tab_urls: string[] = []
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  @LocalStorageLink('tab_match_domains') tab_match_domains: string[][] = [];
  // @LocalStorageLink('current_match_domain') current_match_domain: string[] = ['scheme', 'domain'];
  @LocalStorageLink('tab_loading_progresses') tab_loading_progresses: number[] = [0]
  @LocalStorageLink('current_loading_progress') current_loading_progress: number = 0
  @LocalStorageLink('tab_is_loading') tab_is_loading: boolean[] = [true]
  @LocalStorageLink('current_is_loading') current_is_loading: boolean = true
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Gateways
  @LocalStorageLink('universal_new_tab_gateway') new_tab_gateway: (string | boolean)[] = ['', false];
  @LocalStorageLink('choosing_paralleow') choosing_paralleow: boolean = false;
  @LocalStorageLink('universal_close_all_tabs_gateway') close_all_tabs_gateway: number = -1;
  // UI statuses
  @State length_width_of_tabs: number = 0;
  @State full_area_width: number = 10;
  @State my_height: number | undefined = 0;
  // Drop
  @LocalStorageLink('showing_scratching_board') showing_scratching_board: boolean = false;

  build() {
    // if (this.tablet_mode && this.tabs_style == 'horizontal' || !this.tablet_mode && this.tabs_style_non_tablet_mode == 'horizontal') {
    Column() {
      Row({ space: 10 }) {
        linysTimeoutButton({
          text: '  󰀁  ',
          onExecution: () => {
            this.close_all_tabs_gateway = Date.now();
          }
        })
          .visibility(!this.tablet_mode || this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0 ? Visibility.None : Visibility.Visible)
          .animation(animation_default())
          .padding(5)

        Scroll() {
          Row({ space: this.tablet_mode ? 7 : 5 }) {
            ForEach(this.tab_titles, (title: string, index: number) => {
              HorizontalTabButton({
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

        Row() {
          linysShowButton({
            symbol_glyph_target: 'sys.symbol.map',
            show: this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0,
            show_margin: 0,
            text: this.choosing_paralleow ? $r('app.string.Paralleow_choose_a_tab') : $r('app.string.Paralleow')
          })// Paralleow entrance
            .onClick(() => {
              this.choose_paralleow();
            })
            .visibility(this.tablet_mode ? (this.tab_titles.length > 1 ? Visibility.Visible : Visibility.Hidden) : Visibility.None)
            .margin({ left: 4 })
            .animation(animation_default())

          linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square', can_hover: true })// New tab
            .onClick(() => {
              this.new_tab_gateway = ["new_tab", false];
            })
            .margin({ right: 5 })
            .visibility(this.tablet_mode ? Visibility.Visible : Visibility.None)
            .animation(animation_default())
        }
      } // Base container
      .alignItems(VerticalAlign.Center)

      Row() {
        linysTimeoutButton({
          text: '  󰀁  ',
          onExecution: () => {
            this.close_all_tabs_gateway = Date.now();
          }
        })
          .visibility(this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0 ? Visibility.None : Visibility.Visible)
          .animation(animation_default())
        // .padding({ left: 5 })

        Blank()

        linysShowButton({
          symbol_glyph_target: 'sys.symbol.map',
          show: this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0,
          text: this.choosing_paralleow ? $r('app.string.Paralleow_choose_a_tab') : $r('app.string.Paralleow')
        })// Paralleow entrance
          .onClick(() => {
            this.choose_paralleow();
          })
          .visibility(this.tab_titles.length > 1 ? Visibility.Visible : Visibility.Hidden)
          .animation(animation_default())

        linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square', can_hover: true })// New tab
          .onClick(() => {
            this.storage.set('extra_background', false);
            this.new_tab_gateway = ["new_tab", false];
          })// .margin({ bottom: this.length_width_of_tabs > this.full_area_width ? 15 : 0, right: 8 })
          .animation(animation_default())
      } // Extension for compact (non-tablet mode) layout
      .alignItems(VerticalAlign.Center)
      .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
      .visibility(this.tablet_mode ? Visibility.None : Visibility.Visible)
      .padding({ left: 5, right: 5, top: this.length_width_of_tabs > this.full_area_width ? 0 : 10 })
      .animation(animation_default())
      .width('100%')
    }
    .height(this.my_height)
    .padding({ left: 10, right: 10 })
    .animation(animation_default())
    .clip(true)
    .onAppear(() => {
      this.my_height = undefined;
      console.log('[Meow][meowTabsHorizontal] Created HorizontalTabs!')
    })
    .onDrop((e) => {
      try {
        let drop_ok = drop_to_scratching_board(e, this.storage, true);
        if (!drop_ok) {
          this.showing_scratching_board = false;
        }
      } catch (e) {
        console.error('[onDrop] Failed: ' + e);
      }
    })
    .onDragEnter(() => {
      // this.showing_scratching_board = true;
      this.showing_scratching_board = false;
      this.showing_more_options = false;
    })
    .onDragLeave(() => {
      this.showing_scratching_board = false;
    })

    // }
  }

  choose_paralleow() {
    if (this.choosing_paralleow) {
      // if is choosing, cancel choosing, back to no paralleow
      this.choosing_paralleow = false;
    } else {
      if (this.bunch_of_tabs.sub_tab_idx < 0) {
        // if haven't chosen one, then start to choose
        this.choosing_paralleow = true;
      } else {
        // Quit Paralleow
        this.choosing_paralleow = false;
        this.bunch_of_tabs.sub_tab_idx = -1;
        this.bunch_of_tabs.save_tab_index_stats('[meowTabsHorizontal][choose_paralleow]');
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

  visibility_drag_2in1_top() {
    return deviceInfo.deviceType == '2in1' && this.title_bar_position == 'top' && this.tablet_mode ? Visibility.Visible : Visibility.None;
  }
}

export default meowTabsHorizontal;

@Component
struct HorizontalTabButton {
  @Prop index: number;
  @Prop title: string;
  @Link full_area_width: number;
  @Link tab_titles: string[];
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  // Host
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  // Data
  @LocalStorageLink('tab_restore_on_creations') tab_restore_on_creations: boolean[] = [false];
  // Gateways
  @LocalStorageLink('universal_close_tab_gateway') close_tab_gateway: number = -1;
  @LocalStorageLink('universal_tab_button_click_gateway') uni_tab_button_clicked: number = -1;
  @State offset_y: number = 100;
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  @State isHov: boolean = false;

  build() {
    Row({ space: 8 }) {
      if (this.preferred_hand_left_or_right == 'left') {
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.xmark',
          can_hover: true,
          font_size: fontSize_Icon_Button() * 0.85,
          radius: 6
        })
          .visibility(this.tab_width() <= 80 ? this.visibility_visible_on_chosen(this.index) : Visibility.Visible)
          .onClick(() => {
            this.close_tab_gateway = this.index;
            // Close tab
          })
          .margin({ right: 4 })
      }

      Text(this.tablet_mode ? "󰃊" : "󰃎") // Paralleow icon left
        .visibility((this.bunch_of_tabs.sub_tab_idx > -1 && this.bunch_of_tabs.main_tab_idx == this.index) ? Visibility.Visible : Visibility.None)
        .fontColor(this.color_current_font)
        .fontSize(fontSize_Large())
        .fontWeight(FontWeight.Bold)
        .animation(animation_default())

      Text(this.tablet_mode ? "󰈱" : "󰈮") // Paralleow icon right
        .visibility(this.bunch_of_tabs.sub_tab_idx == this.index ? Visibility.Visible : Visibility.None)
        .fontColor(this.color_current_font)
        .fontSize(fontSize_Large())
        .fontWeight(FontWeight.Bold)
        .animation(animation_default())

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
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.xmark',
          can_hover: true,
          font_size: fontSize_Icon_Button() * 0.85,
          radius: 6
        })
          .visibility(this.tab_width() <= 80 ? this.visibility_visible_on_chosen(this.index) : Visibility.Visible)
          .onClick(() => {
            this.close_tab_gateway = this.index;
            // Close tab
          })
          .margin({ right: 4 })
      }
    }
    .padding({ left: 10 })
    .offset({ y: this.offset_y })
    .width(this.tab_width())
    .height("100%")
    .border({
      radius: 10,
      width: 2,
      color: (this.bunch_of_tabs.main_tab_idx == this.index || this.bunch_of_tabs.sub_tab_idx == this.index)
        ? this.color_current_font : "transparent"
    })
    .backgroundColor(this.color_current_primary)
    .opacity(this.tab_restore_on_creations[this.index] ? 0.5 : 1)
    .brightness(this.isHov ? 1.1 : 1)
    .animation(animation_default())
    .onAppear(() => {
      setTimeout(() => {
        this.offset_y = 0;
      }, 50)
    })
    .clickEffect(click_effect_default())
    .draggable(true)
    .onDragStart((event) => {
      try {
        // Drag this tab
        let unifiedData = unifiedData_drag_tab_from(this.my_window_id, this.index);
        (event as DragEvent).setData(unifiedData);
      } catch (e) {
        console.error('[Meow][Tabs] Set drag data failed: ' + e);
      }
    })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.uni_tab_button_clicked = this.index;
    })
    .onHover((isHv) => {
      this.isHov = isHv;
    })
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

  /**
   * Visibility value for components like the close button for the tab.
   * @param index Index of the tab.
   * @returns Visibility.Visible if is the chosen tab, Visibility.None otherwise.
   * */
  visibility_visible_on_chosen(index: number) {
    if (this.bunch_of_tabs.main_tab_idx == index || this.bunch_of_tabs.sub_tab_idx == index) {
      return Visibility.Visible;
    }
    return Visibility.None;
  }
}
