import linysShowButton from '../components/linysShowButton';
import linysSymbol from '../components/linysSymbol';
import linysText from '../components/linysText';
import linysTitleText from '../components/linysTitleText';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large
} from '../hosts/bunch_of_defaults';
import { bunch_of_history, history_record } from '../hosts/bunch_of_history';
import { sandbox_save } from '../utils/storage_tools';

@CustomDialog
struct woofHistory {
  controller: CustomDialogController;
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history();
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @State scroll_area_height: number = 0;
  @Link showing_settings: boolean;
  // Interactions
  @State showing_today: boolean = true;
  @State showing_this_month: boolean = false;
  @State showing_this_year: boolean = false;
  @State showing_before: boolean = false;
  @State delete_confirm: number = 0;
  // Dates
  @State stamp_today: number = new Date().setHours(0, 0, 0, 0);
  @State stamp_this_month: number = new Date(this.stamp_today).setDate(1);
  @State stamp_this_year: number = new Date(this.stamp_this_month).setMonth(0, 1);
  @State history_list: history_record[] = this.bunch_of_history.get_part_slice(this.stamp_today).reverse();
  @State time_period: string = new Date(this.stamp_today).toLocaleString();
  // Manage
  @State @Watch('on_select_change') selected: boolean[] = this.all_false(this.history_list.length);
  @State selecting: boolean = false;
  @State selected_number: number = 0;
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

  build() {
    RelativeContainer() {
      Scroll() {
        Column({ space: 15 }) {
          linysTitleText({ text: $r('app.string.Settings_experience_history_view') })
            .padding({ top: 5 })
            .width("100%")
          linysText({
            text: $r('app.string.History_desc_1'),
            max_lines: 6
          })
            .width("100%")
            .opacity(0.9)
          linysText({
            text: $r('app.string.History_desc_2'),
            max_lines: 6
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
      .padding({ top: 5, bottom: 10, right: this.tablet_mode ? 10 : 0 })
      .width(this.tablet_mode ? "35%" : "100%")
      .alignRules(this.tablet_mode ? this.alignRules_head_tablet : this.alignRules_head_non_tablet)
      .animation(animation_default())
      .id("title_history")

      Column({ space: 10 }) {

        Row() {
          linysText({
            text: this.showing_before ?
            $r('app.string.Settings_experience_history_to') : $r('app.string.Settings_experience_history_from')
          })
            .opacity(0.7)
          linysText({ text: " " + this.time_period })
            .opacity(0.7)
          linysText({ text: " (" + this.history_list.length.toString() + ")" })
            .opacity(0.7)
        } // Time elapse description
        .width("100%")

        Scroll() {
          Column() {
            ForEach(this.history_list.reverse(), (item: history_record, key: number) => {
              meowRelation({
                index: key,
                show: this.showing_settings,
                selected: this.selected,
                selected_number: this.selected_number,
                selecting: this.selecting,
                label_link: item,
                controller: this.controller,
              })
                .width("100%")
            }) // Items
            if (this.history_list.length == 0) {
              linysTitleText({
                text: "¯\\_(ツ)_/¯"
              })
                .margin(30)
                .opacity(0.7)
                .animation(animation_default())
            }
          }
          .width("100%")
        }
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .onAreaChange((_o, n) => {
          this.scroll_area_height = n.height as number;
        })
        .align(Alignment.Top)
        .layoutWeight(1)
        .margin({ top: 3, bottom: 3 })
        .width("100%")
        .borderRadius(10)
        .backgroundColor($r('app.color.block_color'))
      } // List
      .width(this.tablet_mode ? "65%" : "100%")
      .alignRules(this.tablet_mode ? this.alignRules_body_tablet : this.alignRules_body_non_tablet)
      .animation(animation_default())

      Column() {
        Row({ space: 10 }) {
          linysShowButton({
            text: $r('app.string.Settings_experience_history_before'),
            symbol_glyph_target: 'sys.symbol.worldclock',
            show: this.showing_before
          })
            .onClick(() => {
              this.showing_before = true;
              this.showing_this_month = false;
              this.showing_this_year = false;
              this.showing_today = false;
              this.refresh_current_history_list();
            })
          linysShowButton({
            text: $r('app.string.Settings_experience_history_this_year'),
            symbol_glyph_target: 'sys.symbol.calendar_badge_clock',
            show: this.showing_this_year
          })
            .onClick(() => {
              this.showing_this_year = true;
              this.showing_this_month = false;
              this.showing_today = false;
              this.showing_before = false;
              this.refresh_current_history_list();
            })
          linysShowButton({
            text: $r('app.string.Settings_experience_history_this_month'),
            symbol_glyph_target: this.get_this_month_calendar_symbol(),
            show: this.showing_this_month
          })
            .onClick(() => {
              this.showing_this_month = true;
              this.showing_today = false;
              this.showing_this_year = false;
              this.showing_before = false;
              this.refresh_current_history_list();
            })
          linysShowButton({
            text: $r('app.string.Settings_experience_history_today'),
            symbol_glyph_target: 'sys.symbol.calendar_01',
            show: this.showing_today
          })
            .onClick(() => {
              this.showing_today = true;
              this.showing_this_month = false;
              this.showing_this_year = false;
              this.showing_before = false;
              this.refresh_current_history_list();
            })
        } // Time selectors
        .width("100%")
        .justifyContent(FlexAlign.End)

        Scroll() {
          Column({ space: 10 }) {
            Row() {
              linysTitleText({ text: $r('app.string.Settings_experience_history_selecting') })
              linysTitleText({ text: " " + this.selected_number.toString() + " " })
              linysTitleText({ text: $r('app.string.Settings_experience_history_selecting_items') })
            } // Selecting ... item(s)
            Row() {
              linysSymbol({ symbol_glyph_target: 'sys.symbol.list_checkmask' })
                .onClick(() => {
                  this.select_all();
                })
              Blank()
              Button("  󰀁  ")// Delete
                .type(ButtonType.Capsule)
                .backgroundColor(this.delete_confirm > 0 ? $r('app.color.start_window_background') :
                $r("app.color.font_color_title"))
                .fontColor(this.delete_confirm > 0 ? $r('app.color.font_color_title') :
                $r('app.color.start_window_background'))
                .border({
                  width: 2,
                  color: this.delete_confirm > 0 ? $r('app.color.font_color_title') : "transparent"
                })
                .fontSize(fontSize_Large())
                .fontWeight(FontWeight.Medium)
                .height(capsule_bar_height())
                .onClick(() => {
                  this.delete_confirm += 300;
                  if (this.delete_confirm >= 301) {
                    // Delete
                    this.delete_selected();
                  }
                })
                .clickEffect(click_effect_default())
                .animation(animation_default())
            } // Buttons
            .width("100%")
          }
          .padding({ top: 10 })
          .alignItems(HorizontalAlign.Start)
          .width("100%")
          .animation(animation_default())
        } // Select controls
        .scrollBar(BarState.Off)
        .width("100%")
        .height(this.selecting ? 80 : 0)
        .animation(animation_default())
      } // Controls
      .padding({ top: 10, right: this.tablet_mode ? 10 : 0 })
      .alignItems(HorizontalAlign.End)
      .id("controls_history")
      .alignRules(this.alignRules_foot)
      .animation(animation_default())
      .width(this.tablet_mode ? "35%" : "100%")

    }
    .padding(15)
    .width("100%")
    .height("100%")
    .backgroundColor($r('app.color.start_window_background'))
    .onAppear(() => {
      setInterval(() => {
        if (this.delete_confirm > 0) {
          this.delete_confirm -= 1;
        }
        // Reset delete confirm
      }, 10)
    })
  }

  // Utils

  /**
   * Constructs and returns a boolean list of specified length consists of false.
   * @param length A number, the length of the list.
   * @returns A boolean[] array, all elements are false.
   * */
  all_false(length: number) {
    let result: boolean[] = [];
    for (let index = 0; index < length; index++) {
      result.push(false);
    }
    return result;
  }

  /**
   * Gets the calendar symbol with a correct number of days in this month.
   * @returns A string, a resource address.
   * @example 'sys.symbol.calendar_29'
   * */
  get_this_month_calendar_symbol() {
    let month = new Date().getMonth();
    let year: number = new Date().getFullYear();
    let is_leap_year = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    let look_up = ['31', is_leap_year ? '29' : '28', '31', '30', '31', '30', '31', '31', '30', '31', '30', '31'];
    let symbol = 'sys.symbol.calendar_' + look_up[month];
    return symbol;
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
    this.delete_confirm = 0;
  }

  /**
   * Refreshes this.history_list according to the time range selected.
   * */
  refresh_current_history_list() {
    if (this.showing_today) {
      this.history_list = this.bunch_of_history.get_part_slice(this.stamp_today);
      this.time_period = new Date(this.stamp_today).toLocaleString();
    }
    if (this.showing_this_month) {
      this.history_list = this.bunch_of_history.get_part_slice(this.stamp_this_month);
      this.time_period = new Date(this.stamp_this_month).toLocaleString();
    }
    if (this.showing_this_year) {
      this.history_list = this.bunch_of_history.get_part_slice(this.stamp_this_year);
      this.time_period = new Date(this.stamp_this_year).toLocaleString();
    }
    if (this.showing_before) {
      this.history_list = this.bunch_of_history.get_part_slice(0, this.stamp_this_year);
      this.time_period = new Date(this.stamp_this_year).toLocaleString();
    }
    this.selected_number = 0;
    this.selected = this.all_false(this.history_list.length);
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
      this.selected_number = this.selected.length;
    } else {
      for (let index = 0; index < this.selected.length; index++) {
        new_selected.push(false);
      }
      this.selected_number = 0;
    }
    this.selected = new_selected;
  }

  /**
   * Deletes all items selected, and refreshes the current history list according to time range specified.
   *
   * @abstract Also reconstructs the plain history cache and saves the operated history to sandbox storage.
   * */
  delete_selected() {
    let bias = 0;
    if (this.showing_before) {
      // bias = the number of items in this year
      bias = this.bunch_of_history.history_list.length -
      this.bunch_of_history.index_of_record_after_time(this.stamp_this_year);
    }
    for (let index = this.history_list.length - 1; index >= 0; index--) {
      if (this.selected[index]) {
        this.bunch_of_history.remove_history(this.bunch_of_history.history_list.length - 1 - index - bias, true);
      }
    }
    this.refresh_current_history_list();
    this.bunch_of_history.reconstruct_plain_history();
    sandbox_save("history.txt", this.bunch_of_history.export_string());
    this.delete_confirm = 0;
  }
}

export default woofHistory;

@Component
struct meowRelation {
  // Base
  controller: CustomDialogController | undefined;
  @Prop label_link: history_record;
  @Prop index: number;
  @Link show: boolean;
  @Link selected: boolean[];
  @Link selected_number: number;
  @Prop selecting: boolean;
  // UI Effects
  @Prop scroll_area_height: number;
  @Prop human_time: string = new Date(this.label_link.accessed_time).toLocaleString();
  // Gateways
  @StorageLink('universal_new_tab_gateway') universal_new_tab_gateway: string = "";

  build() {
    Column({ space: 2 }) {
      linysText({
        color: this.selected[this.index] ? $r('app.color.block_color') : $r('app.color.font_color_title'),
        text: this.label_link.label.length == 0 ? "　" : this.label_link.label,
        font_weight: this.selected[this.index] ? FontWeight.Medium : FontWeight.Regular
      })
      linysText({
        color: this.selected[this.index] ? $r('app.color.block_color') : $r('app.color.font_color_title'),
        text: this.label_link.link
      })
      linysText({
        color: this.selected[this.index] ? $r('app.color.block_color') : $r('app.color.font_color_title'),
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
    .backgroundColor(this.selected[this.index] ? $r('app.color.font_color_title') : $r('app.color.block_color'))
    .animation(animation_default())
    .onClick(() => {
      if (this.selecting) {
        // Select
        this.select_unselect();
        return;
      }
      this.universal_new_tab_gateway = this.label_link.link;
      if (this.controller) {
        this.show = false;
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
  }

  /**
   * Selects or unselects myself, usually called when onClick.
   * */
  select_unselect() {
    if (this.selected[this.index]) {
      this.selected_number -= 1;
    } else {
      this.selected_number += 1;
    }
    this.selected[this.index] = !this.selected[this.index];
  }
}