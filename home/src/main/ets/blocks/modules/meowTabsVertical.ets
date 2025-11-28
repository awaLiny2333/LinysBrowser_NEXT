import { bunch_of_tabs, tab_label } from '../../hosts/bunch_of_tabs';
import { animation_default, click_effect_default, fontSize_Icon_Button, fontSize_Large, fontSize_Normal } from '../../hosts/bunch_of_defaults';
import { storage_of_id } from '../../utils/ui_tools';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import lazy { unifiedData_drag_tab_from } from '../../processes/tabs_actions';
import lazy { drop_to_scratching_board } from '../../utils/drag_drop_tools';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import linysText from '../../components/texts/linysText';
import linysShowButton from '../../components/buttons/linysShowButton';
import linysSymbol from '../../components/texts/linysSymbol';

@Component
struct meowTabsVertical {
  @StorageLink('THE_LORD_OF_THE_WINDOWS') THE_LORD_OF_THE_WINDOWS: string = '';
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  /**
   * Hosts and environments */
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  // Environments
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('screen_width') screen_width: number = 0;
  @StorageLink('tabs_style') tabs_style: string = "";
  @StorageLink('tabs_style_non_tablet_mode') tabs_style_non_tablet_mode: string = "";
  @StorageLink('tabs_vertical_auto_hide') tabs_vertical_auto_hide: boolean = false;
  @StorageLink('tabs_vertical_auto_hide_button') tabs_vertical_auto_hide_button: boolean = true;
  // Controls
  @LocalStorageLink('showing_bookmarks') showing_bookmarks: boolean = false;
  @LocalStorageLink('showing_tabs') showing_tabs: boolean = false;
  @LocalStorageLink('tab_titles') tab_titles: string[] = []
  // Other Info / Statuses
  @LocalStorageLink('choosing_paralleow') choosing_paralleow: boolean = false;
  @LocalStorageLink('unloading_tabs') unloading_tabs: boolean = false;
  // Animation info
  @LocalStorageLink('is_Hov_vertical_tabs') is_Hov_vertical_tabs: boolean = false;
  @State my_visibility: Visibility = Visibility.Hidden;
  scroll_controller: Scroller = new Scroller();
  @LocalStorageLink('meow_tabs_vertical_scroll_to_idx') @Watch('on_scroll_to_idx') scroll_to_idx: number = -1;
  @LocalStorageLink('vertical_tabs_scroll_area_height') scroll_area_height: number = 0;
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('preferred_hand_reverse_tabs_panel') preferred_hand_reverse_tabs_panel: boolean = false;
  // Colors
  @StorageLink('effects') effects: boolean = false;
  // Pan Gesture
  pan_x: number = 0;
  // Timeout
  scroll_2_bottom_timeout_handle_id: number | undefined = undefined;

  build() {
    Column({ space: 10 }) {
      Row() {
        linysSymbol({
          can_hover: true,
          symbol_glyph_target: this.is_Hov_vertical_tabs ? 'sys.symbol.arrow_down_right_and_arrow_up_left' : 'sys.symbol.arrow_up_left_and_arrow_down_right'
        })
          .onClick(() => {
            this.is_Hov_vertical_tabs = !this.is_Hov_vertical_tabs;
          })
      }
      .visibility(this.tabs_vertical_auto_hide && this.tabs_vertical_auto_hide_button ? Visibility.Visible : Visibility.None)
      .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.Start : FlexAlign.End)
      .animation(animation_default())
      .width('100%')

      Scroll(this.scroll_controller) {
        Column({ space: 5 }) {
          ForEach(this.bunch_of_tabs.Labels, (Label: tab_label) => {
            TabButton({
              Label: Label,
            })
          }, (Label: tab_label) => Label.timestamp.toString())
        }
        .width("100%")
      } // Tab Buttons List
      .direction(Direction.Rtl)
      .align(Alignment.Bottom)
      .edgeEffect(EdgeEffect.Spring)
      .width("100%")
      .borderRadius(10)
      .layoutWeight(1)
      .animation(animation_default())
      .onAreaChange((_o, n) => {
        this.scroll_area_height = n.height as number;
      })

      Column({ space: 10 }) {
        Row() {
          linysTimeoutButton({
            text: '  󰀁  ',
            onExecution: () => {
              this.storage.set('universal_close_all_tabs_gateway', Date.now());
            }
          })
            .visibility(this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0 || this.unloading_tabs ? Visibility.None : Visibility.Visible)
            .animation(animation_default())

          Blank()
            .onClick(() => {
              this.try_scroll_to(this.bunch_of_tabs.main_tab_idx);
            })

          linysShowButton({
            symbol_glyph_target: 'sys.symbol.moon_z',
            show: this.unloading_tabs,
            text: $r('app.string.Tabs_unload')
          }) // Sleep
            .onClick(() => {
              this.choosing_paralleow = false;
              this.unloading_tabs = !this.unloading_tabs;
            })
            .visibility(this.tab_titles.length > 1 ? Visibility.Visible : Visibility.Hidden)
            .animation(animation_default())

          linysShowButton({
            symbol_glyph_target: 'sys.symbol.map',
            show: this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0,
            text: this.choosing_paralleow ? $r('app.string.Paralleow_choose_a_tab') : $r('app.string.Paralleow')
          }) // Paralleow
            .onClick(() => {
              this.unloading_tabs = false;
              this.storage.set('choose_paralleow_timestamp', Date.now());
            })
            .visibility(this.tab_titles.length > 1 ? Visibility.Visible : Visibility.Hidden)
            .animation(animation_default())

          linysSymbol({ symbol_glyph_target: 'sys.symbol.plus_square', can_hover: true }) // New Tab
            .onClick(() => {
              // this.new_tab("", true, false);
              this.storage.set('universal_new_tab_gateway', ["new_tab", false])
            })
            .keyboardShortcut(this.bunch_of_key_shortcuts.new_tab.main_key, this.bunch_of_key_shortcuts.new_tab.modifier)
        } // New Tab and Paralleow Button
        .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
        .width("100%")

        linysText({ text: $r('app.string.Paralleow_description'), max_lines: 4 })
          .visibility(this.choosing_paralleow || this.bunch_of_tabs.sub_tab_idx >= 0 ? Visibility.Visible : Visibility.None)
          .animation(animation_default())
          .width('100%')

        linysText({ text: $r('app.string.Tabs_unload_description'), max_lines: 4 })
          .visibility(this.unloading_tabs ? Visibility.Visible : Visibility.None)
          .animation(animation_default())
          .width('100%')
      }

      // .visibility(this.is_Hov_vertical_tabs || !this.tablet_mode || !this.tabs_vertical_auto_hide ? Visibility.Visible : Visibility.Hidden)
      // .animation(animation_default())

    } // Tabs Panel
    .width(this.tablet_mode ? 230 : '90%')
    .padding({
      left: 5,
      right: 5,
      top: this.effects ? 0 : 10,
    })
    .animation(animation_default())
    .height("100%")
    .justifyContent(FlexAlign.End)
    .clip(true)
    .onDrop((e) => {
      try {
        let drop_ok = drop_to_scratching_board(e, this.storage, true);
        if (!drop_ok) {
          this.storage.set('showing_scratching_board', false);
        }
      } catch (e) {
        console.error('[onDrop] Failed: ' + e);
      }
    })
    .onDragEnter(() => {
      this.storage.set('showing_scratching_board', false);
      this.storage.set('showing_more_options', false);
    })
    .onDragLeave(() => {
      this.storage.set('showing_scratching_board', false);
    })
    .gesture(
      PanGesture({ direction: PanDirection.Left | PanDirection.Right })
        .onActionStart(() => {
          this.pan_x = 0;
        })
        .onActionUpdate((e) => {
          this.pan_x += e.offsetX;
        })
        .onActionEnd(() => {
          if (this.is_right_align()) {
            if (this.pan_x < 0) {
              // ← Switch to Bookmarks
              this.storage.set('showing_bookmarks', true);
              // this.showing_tabs = false;
            } else {
              // → Right Align Close panel
              this.storage.set('showing_tabs', false);
            }
          } else {
            if (this.pan_x < 0) {
              // ← Close panel
              this.storage.set('showing_tabs', false);
            } else {
              // → Open bookmarks
              this.storage.set('showing_bookmarks', true);
            }
          }
        })
    )
  }

  // Tab controls

  /**
   * Tries to scroll to a tab of specific index.
   * @param idx The index of the target tab.
   * */
  try_scroll_to(idx: number) {
    let tab_height_default: number = 42;
    clearTimeout(this.scroll_2_bottom_timeout_handle_id); // Cancel existing timeout;
    this.scroll_2_bottom_timeout_handle_id = setTimeout(() => {
      let tar = (idx + 1) * tab_height_default + (idx) * 5;

      // Determine scroll distance
      const max_y = (this.bunch_of_tabs.Tabs.length) * tab_height_default + (this.bunch_of_tabs.Tabs.length - 1) * 5;
      let scroll_y = tar - 0.5 * this.scroll_area_height - (tab_height_default + 5) * 0.5;
      // Limit range
      if (scroll_y > max_y - this.scroll_area_height) {
        scroll_y = max_y - this.scroll_area_height;
      }
      if (scroll_y < 0) {
        scroll_y = 0;
      }

      // Scroll
      console.log(`[try_scroll_to] idx=${idx}, tar=${tar}, scroll_y=${scroll_y}`);
      this.scroll_controller.scrollTo({
        xOffset: 0,
        yOffset: scroll_y,
        animation: true,
      });
    }, 50);
  }

  // Data

  is_right_align() {
    return (this.preferred_hand_left_or_right == 'right' && !this.preferred_hand_reverse_tabs_panel) ||
      (!(this.preferred_hand_left_or_right == 'right') && this.preferred_hand_reverse_tabs_panel);
  }

  // Events

  on_scroll_to_idx() {
    if (this.scroll_to_idx < 0) {
      return;
    }
    this.try_scroll_to(this.scroll_to_idx)
    this.scroll_to_idx = -1;
  }
}

export default meowTabsVertical;

// @Reusable // Is this safe? No, this loses the height animation
@Component
struct TabButton {
  // Sync
  @Prop Label: tab_label;
  // Public
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  @LocalStorageLink('vertical_tabs_scroll_area_height') scroll_area_height: number = 0;
  // Data
  @LocalStorageLink('tab_titles') tab_titles: string[] = [];
  @LocalStorageLink('tab_restore_on_creations') tab_restore_on_creations: boolean[] = [false];
  // Settings
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Gateways
  @LocalStorageLink('universal_tab_button_click_gateway') uni_tab_button_clicked: number = -1;
  @LocalStorageLink('universal_close_tab_gateway') close_tab_gateway: number = -1;
  // Colors
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // UI
  tab_height_default: number = 42;
  @State tab_height: number = (this.bunch_of_tabs.Tabs.length * (this.tab_height_default + 5) - 5 < this.scroll_area_height) ? 0 : this.tab_height_default;
  @State my_vis: Visibility = Visibility.Hidden;
  @State isHov: boolean = false;

  build() {
    Row({ space: 5 }) {
      if (this.preferred_hand_left_or_right == 'left') {
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.xmark',
          can_hover: true,
          font_size: fontSize_Icon_Button() * 0.85,
          radius: 6
        })
          .onClick(() => {
            this.close_tab_gateway = this.Label.index_key;
            // Close tab
          })
          .margin({ left: 4 })
      }

      if (this.bunch_of_tabs.sub_tab_idx > -1 && this.bunch_of_tabs.main_tab_idx == this.Label.index_key) {
        Text(this.tablet_mode ? "󰃊" : "󰃎") // Paralleow icon left
          .fontColor(this.color_current_font)
          .animation(animation_default())
          .fontSize(fontSize_Large())
          .fontWeight(FontWeight.Bold)
      }

      if (this.bunch_of_tabs.sub_tab_idx == this.Label.index_key) {
        Text(this.tablet_mode ? "󰈱" : "󰈮") // Paralleow icon right
          .fontColor(this.color_current_font)
          .animation(animation_default())
          .fontSize(fontSize_Large())
          .fontWeight(FontWeight.Bold)
      }

      Text(this.tab_titles[this.Label.index_key] == "" ? "Meow" : this.tab_titles[this.Label.index_key])
        .textAlign(this.preferred_hand_left_or_right == 'right' ? TextAlign.Start : TextAlign.End)
        .fontSize(fontSize_Normal())
        .fontColor(this.color_current_font)
        .fontWeight((this.bunch_of_tabs.main_tab_idx == this.Label.index_key ||
          this.bunch_of_tabs.sub_tab_idx == this.Label.index_key)
          ? FontWeight.Bold : undefined)
        .maxLines(1)
        .layoutWeight(1)

      if (this.preferred_hand_left_or_right == 'right') {
        linysSymbol({
          symbol_glyph_target: 'sys.symbol.xmark',
          can_hover: true,
          font_size: fontSize_Icon_Button() * 0.85,
          radius: 6
        })
          .onClick(() => {
            this.close_tab_gateway = this.Label.index_key;
            // Close tab
          })
          .margin({ right: 4 })
      }

    } // Title and xmark
    .border({
      radius: 10,
      width: 2,
      color: (this.bunch_of_tabs.main_tab_idx == this.Label.index_key || this.bunch_of_tabs.sub_tab_idx == this.Label.index_key)
        ? this.color_current_font : "transparent"
    })
    .backgroundColor(this.color_current_secondary)
    .visibility(this.my_vis)
    .opacity(this.tab_restore_on_creations[this.Label.index_key] ? 0.5 : 1)
    .height(this.tab_height)
    .padding(this.preferred_hand_left_or_right == 'right' ? { left: 10 } : { right: 10 })
    .brightness(this.isHov ? 1.1 : 1)
    .animation(animation_default())
    .alignItems(VerticalAlign.Center)
    .clickEffect(click_effect_default())
    .width("100%")
    .onClick(() => {
      this.uni_tab_button_clicked = this.Label.index_key;
    })
    .draggable(true)
    .onDragStart((event) => {
      try {
        // Drag this tab
        let unifiedData = unifiedData_drag_tab_from(this.my_window_id, this.Label.index_key);
        (event as DragEvent).setData(unifiedData);
      } catch (e) {
        console.error('[Meow][Tabs] Set drag data failed: ' + e);
      }
    })
    .onAppear(() => {
      this.my_vis = Visibility.Visible;
      this.tab_height = this.tab_height_default;
      this.tab_restore_on_creations[this.Label.index_key] = this.bunch_of_tabs.Tabs[this.Label.index_key].pre_restoration_stage;
    })
    .onHover((isHv) => {
      this.isHov = isHv;
    })

    // .onMouse((e) => {
    //   if (e.button == MouseButton.Right && e.action == MouseAction.Press) {
    //     // Right click
    //     this.unload_me();
    //   }
    // })
  }
}