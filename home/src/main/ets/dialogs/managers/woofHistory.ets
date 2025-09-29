import linysSymbol from '../../components/texts/linysSymbol';
import linysText from '../../components/texts/linysText';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { animation_default, capsule_bar_height, click_effect_default } from '../../hosts/bunch_of_defaults';
import { bunch_of_history, history_record } from '../../hosts/bunch_of_history';
import woofControlFrame from '../woofControlFrame';
import HistoryDataSource from '../../objects/HistoryDataSource';
import { all_false } from '../../utils/data_operation_tools';
import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';

@CustomDialog
struct woofHistory {
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history(true);
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @State scroll_area_height: number = 0;
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Interactions
  @State viewing_year: number = this.bunch_of_history.get_current_year();
  @State viewing_month: number = this.bunch_of_history.get_current_month();
  // Dates
  @State available_months: number[][] = bunch_of_history.get_history_months();
  @State opened_month_history_list: history_record[] = this.bunch_of_history.get_history_this_month();
  // Manage
  @State @Watch('on_select_change') selected: boolean[] = all_false(this.opened_month_history_list.length);
  @State selecting: boolean = false;
  @State selected_items_quantity: number = 0;
  // alignRules
  alignRules_head_non_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    left: { anchor: "__container__", align: HorizontalAlign.Start },
  };
  alignRules_head_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    bottom: { anchor: "controls_history", align: VerticalAlign.Top },
    left: { anchor: "__container__", align: HorizontalAlign.Start },
  };
  alignRules_foot: AlignRuleOption = {
    bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
    left: { anchor: "__container__", align: HorizontalAlign.Start }
  };
  alignRules_body_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };
  alignRules_body_non_tablet: AlignRuleOption = {
    top: { anchor: "title_history", align: VerticalAlign.Bottom },
    bottom: { anchor: "controls_history", align: VerticalAlign.Top },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Stuffs
  scroller: Scroller = new Scroller();
  controller: CustomDialogController;
  @StorageProp('woofHistory_search_input') woofHistory_search_input: string = '';
  // Data
  @StorageLink('woofHistory_data') data: HistoryDataSource = new HistoryDataSource(this.bunch_of_history.get_history_this_month_with_index());

  build() {
    woofControlFrame({
      title: $r('app.string.Settings_experience_history_view'),
      controller: this.controller
    }) {
      RelativeContainer() {
        Scroll() {
          Column({ space: 15 }) {
            linysText({
              text: $r('app.string.History_desc_1'),
              max_lines: 6
            })
              .width("100%")
              .opacity(0.9)
            linysText({
              text: $r('app.string.History_desc_2'),
              max_lines: 6,
              is_description: true,
              is_expanded: true
            })
              .width("100%")
              .opacity(0.9)
            linysText({
              text: $r('app.string.Have_a_Nice_Surf'),
              max_lines: 2
            })
              .width("100%")
              .opacity(0.9)
          } // Title
          .width("100%")
        } // Title and descriptions
        .scrollBar(BarState.Off)
        .align(Alignment.TopStart)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ bottom: 10, right: this.tablet_mode ? 10 : 0 })
        .width(this.tablet_mode ? "35%" : "100%")
        .alignRules(this.tablet_mode ? this.alignRules_head_tablet : this.alignRules_head_non_tablet)
        .animation(animation_default())
        .id("title_history")

        Column({ space: 10 }) {

          // Sub title
          Row() {
            linysText({
              text: $r('app.string.Settings_experience_history_date_format'),
              font_weight: FontWeight.Bold
            })
              .opacity(0.7)
            linysText({ text: " (" + this.opened_month_history_list.length.toString() + ")" })
              .opacity(0.7)
          } // Time elapse description
          .width("100%")

          Scroll() {
            List({ scroller: this.scroller }) {
              LazyForEach(this.data, (_record_item: Array<history_record | number>, _key: number) => {
                ListItem() {
                  // linysText({ text: key.toString() })
                  if (this.opened_month_history_list[_record_item[1] as number]) {
                    meowRelation({
                      index: (_record_item[1] as number),
                      selected: this.selected,
                      selected_item_quantity: this.selected_items_quantity,
                      selecting: this.selecting,
                      // record: this.opened_month_history_list[(_record_item[1] as number)],
                      record: _record_item[0] as history_record,
                      controller: this.controller,
                    })
                      .width("100%")
                  }
                }
                .animation(animation_default())
              }, (item: Array<history_record | number>) => (item[0] as history_record).accessed_time.toString() +
              this.opened_month_history_list.length.toString()) // Items

              linysTextTitle({
                text: "¯\\_(ツ)_/¯"
              })
                .margin(30)
                .opacity(0.7)
                .visibility((this.opened_month_history_list.length == 0 || this.data.totalCount() == 0)
                  ? Visibility.Visible
                  : Visibility.None)
                .animation(animation_default())
            }
            .width("100%")
            .height("100%")
          } // Main history list
          .padding({ bottom: 5 })
          .scrollable(ScrollDirection.Vertical)
          .edgeEffect(EdgeEffect.Spring)
          .onAreaChange((_o, n) => {
            this.scroll_area_height = n.height as number;
          })
          .align(Alignment.Top)
          .layoutWeight(1)
          .width("100%")
          .borderRadius(13.5)
          .backgroundColor(this.color_current_secondary)

          Scroll() {
            Row({ space: 5 }) {
              ForEach(this.available_months, (item: number[], _key: number) => {
                month_button({
                  year: item[0],
                  month: item[1],
                  viewing_year: this.viewing_year,
                  viewing_month: this.viewing_month,
                })
                  .onClick(() => {
                    // MEOW
                    this.bunch_of_history.open_month_from_disk_sync(item[0], item[1]);
                    this.refresh_current_history_list();
                    this.viewing_year = item[0];
                    this.viewing_month = item[1];
                    this.scroller.scrollToIndex(0, false);
                    this.data.setData(this.bunch_of_history.get_history_this_month_with_index(this.woofHistory_search_input));
                  })
              }) // Month Buttons
            }
          } // Available months
          .scrollable(ScrollDirection.Horizontal)
          .edgeEffect(EdgeEffect.Spring)
          .onAreaChange((_o, n) => {
            this.scroll_area_height = n.height as number;
          })
          .padding(5)
          .align(Alignment.Start)
          .width("100%")
          .borderRadius(13.5)
          .backgroundColor(this.color_current_secondary)

        } // List
        .width(this.tablet_mode ? "65%" : "100%")
        .alignRules(this.tablet_mode ? this.alignRules_body_tablet : this.alignRules_body_non_tablet)
        .animation(animation_default())

        Column() {
          Scroll() {
            Column({ space: 10 }) {
              Row() {
                linysTextTitle({ text: $r("app.string.Settings_edit_selecting") })
                linysTextTitle({ text: " " + this.selected_items_quantity.toString() + " " })
                linysTextTitle({ text: $r("app.string.Settings_edit_selecting_items") })
              } // Selecting ... item(s)
              Row() {
                linysSymbol({ symbol_glyph_target: 'sys.symbol.list_checkmask' })
                  .onClick(() => {
                    this.select_all();
                  })
                Blank()
                linysTimeoutButton({
                  text: "  󰀁  ",
                  onExecution: () => {
                    this.delete_selected();
                  }
                }) // Delete
              } // Buttons
              .width("100%")
            }
            .padding({ top: 10, right: this.tablet_mode ? 10 : 0, bottom: 5 })
            .alignItems(HorizontalAlign.Start)
            .width("100%")
            .animation(animation_default())
          } // Select controls
          .scrollBar(BarState.Off)
          .width("100%")
          .height(this.selecting ? 80 : 0)
          .animation(animation_default())
        } // Controls
        .alignItems(HorizontalAlign.End)
        .id("controls_history")
        .alignRules(this.alignRules_foot)
        .animation(animation_default())
        .width(this.tablet_mode ? "35%" : "100%")
      }
      .layoutWeight(1)

      Row({ space: 10 }) {
        // linysTextTitle({ text: '󰀞' }) // This is stupid O.o
        SearchInput({ onSubmitAction: this.submit_search })
          .layoutWeight(1)
        linysCapsuleButton({
          text: "  󰀩  "
        })
          .onClick(() => {
            this.submit_search();
          })
      } // Search
      .width('100%')
      .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
      .animation(animation_default())
    }
  }

  // Search

  submit_search() {
    // Timer
    let s = Date.now();
    // Prep
    let search = AppStorage.get('woofHistory_search_input') as string;
    let source = AppStorage.get('woofHistory_data') as HistoryDataSource;
    let history = AppStorage.get('bunch_of_history') as bunch_of_history;
    source.setData(history.get_history_this_month_with_index(search));
    console.log('[Meow][woofHistory] submit_search [' + search + '] (' + (Date.now() - s).toString() + ' ms)');
  }

  // Select Events and operations

  /**
   * Triggered when selecting or unselecting a history.
   *
   * Sets this.selecting to true, if is selecting something.
   *
   * Otherwise set it to false.
   *
   * @abstract Also resets this.delete_confirm.
   * */
  on_select_change() {
    if (this.selected.includes(true)) {
      this.selecting = true;
    } else {
      this.selecting = false;
    }
  }

  /**
   * Refreshes this.opened_month_history_list according to the time range selected.
   * */
  refresh_current_history_list() {
    this.opened_month_history_list = this.bunch_of_history.get_history_this_month();
    this.selected_items_quantity = 0;
    this.selected = all_false(this.opened_month_history_list.length);
  }

  /**
   * One click to select or unselect all history records.
   *
   * @abstract If there is still items unselected, then selects all.
   * If all items are already selected, then unselect all.
   * */
  select_all() {
    let new_selected: boolean[] = [];
    if (this.selected.includes(false)) {
      for (let index = 0; index < this.selected.length; index++) {
        new_selected.push(true);
      }
      this.selected_items_quantity = this.selected.length;
    } else {
      for (let index = 0; index < this.selected.length; index++) {
        new_selected.push(false);
      }
      this.selected_items_quantity = 0;
    }
    this.selected = new_selected;
  }

  /**
   * Deletes all items selected, and refreshes the current history list according to time range specified.
   *
   * @abstract Also reconstructs the plain history cache and saves the operated history to sandbox storage.
   * */
  delete_selected() {
    let indices: number[] = [];
    for (let index = 0; index < this.selected.length; index++) {
      if (this.selected[index]) {
        indices.push(index);
        // Notify LazyForEach
        // this.data.notifyDataDelete(indices[index]);
      }
    }
    this.bunch_of_history.remove_histories_at_indices(this.viewing_year, this.viewing_month, indices, true);
    // TODO: use better strategy to notify LazyForEach about a deletion.
    this.data.setData(this.bunch_of_history.get_history_this_month_with_index(this.woofHistory_search_input));
    this.refresh_current_history_list();
  }
}

export default woofHistory;

@Component
struct meowRelation {
  // Base
  controller: CustomDialogController | undefined;
  @Prop index: number;
  @Prop record: history_record;
  @Link selected: boolean[];
  @Link selected_item_quantity: number;
  @Prop selecting: boolean;
  // UI Effects
  @Prop scroll_area_height: number;
  @Prop human_time: string = new Date(this.record.accessed_time).toLocaleString();
  // Gateways
  @StorageLink('universal_new_tab_gateway') universal_new_tab_gateway: string = "";
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 2 }) {
      linysText({
        color: this.selected[this.index] ? this.color_current_secondary : this.color_current_font,
        text: this.record.label.length == 0 ? "　" : this.record.label,
        font_weight: this.selected[this.index] ? FontWeight.Bold : FontWeight.Regular
      })
      linysText({
        color: this.selected[this.index] ? this.color_current_secondary : this.color_current_font,
        text: this.record.link,
        max_lines: 2
      })
        .opacity(0.88) // Happy New Year!
      linysText({
        color: this.selected[this.index] ? this.color_current_secondary : this.color_current_font,
        text: this.human_time
      })
        .opacity(0.7)
    }
    .padding({
      left: 12,
      right: 12,
      top: 9,
      bottom: 3
    })
    .alignItems(HorizontalAlign.Start)
    .width("100%")
    .backgroundColor(this.selected[this.index] ? this.color_current_font : this.color_current_secondary)
    .animation(animation_default())
    .onClick(() => {
      if (this.selecting) {
        // Select
        this.select_unselect();
        return;
      }
      this.universal_new_tab_gateway = this.record.link;
      if (this.controller) {
        AppStorage.set('showing_app_settings', false);
        this.controller.close();
      }
    })
    .clickEffect(click_effect_default())
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          this.select_unselect();
        })
    )
    .onMouse((e) => {
      if (e.button == MouseButton.Right && e.action == MouseAction.Press) {
        // Right click
        this.select_unselect();
      }
    })
  }

  /**
   * Selects or unselects myself, usually called when onClick.
   * */
  select_unselect() {
    if (this.selected[this.index]) {
      this.selected_item_quantity -= 1;
    } else {
      this.selected_item_quantity += 1;
    }
    this.selected[this.index] = !this.selected[this.index];
  }
}

@Component
struct month_button {
  @Prop year: number;
  @Prop month: number;
  @Link viewing_year: number;
  @Link viewing_month: number;
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 0 }) {
      linysText({
        text: this.year.toString(),
        font_weight: this.selected() ? FontWeight.Bold : FontWeight.Regular,
      })
      linysText({
        text: this.month.toString(),
        font_weight: this.selected() ? FontWeight.Bold : FontWeight.Regular,
      })
    }
    .border({ color: this.selected() ? this.color_current_font : 'transparent', width: 2, radius: 10 })
    .alignItems(HorizontalAlign.Start)
    .clickEffect(click_effect_default())
    .padding(8)
    .backgroundColor(this.color_current_primary)
    .animation(animation_default())
  }

  selected() {
    return this.month == this.viewing_month && this.year == this.viewing_year;
  }
}

@Component
struct SearchInput {
  @StorageLink('woofHistory_search_input') input: string = '';
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Actions
  onSubmitAction?: () => void;

  build() {
    TextInput({ text: this.input })
      .height(capsule_bar_height())
      .fontWeight(FontWeight.Regular)
      .fontColor(this.color_current_font)
      .caretColor(this.color_current_font)
      .selectedBackgroundColor(this.color_current_font)
      .animation(animation_default())
      .onChange((content) => {
        this.input = content;
      })
      .selectAll(true)
      .onSubmit(() => {
        if (this.onSubmitAction) {
          this.onSubmitAction();
        }
      })
  }

  submit() {

  }
}
