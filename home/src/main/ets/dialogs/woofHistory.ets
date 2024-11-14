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
  @State selected_history_list: history_record[] = this.bunch_of_history.get_part_slice(this.stamp_today).reverse();
  @State time_period: string = new Date(this.stamp_today).toLocaleString();
  // Manage
  @State @Watch('on_select_change') selected: boolean[] = this.all_false(this.selected_history_list.length);
  @State selecting: boolean = false;
  @State selected_number: number = 0;

  build() {
    Column() {
      Column({ space: 10 }) {
        linysTitleText({ text: $r('app.string.Settings_experience_history_view') })
          .padding({ top: 5 })
        Row() {
          linysText({
            text: this.showing_before ?
            $r('app.string.Settings_experience_history_to') : $r('app.string.Settings_experience_history_from')
          })
            .opacity(0.7)
          linysText({ text: " " + this.time_period })
            .opacity(0.7)
          linysText({ text: " (" + this.selected_history_list.length.toString() + ")" })
            .opacity(0.7)
        }

        Scroll() {
          Column() {
            ForEach(this.selected_history_list.reverse(), (item: history_record, key: number) => {
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
            if (this.selected_history_list.length == 0) {
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
              this.refresh_selected_history_list();
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
              this.refresh_selected_history_list();
            })
          linysShowButton({
            text: $r('app.string.Settings_experience_history_this_month'),
            symbol_glyph_target: 'sys.symbol.calendar_31',
            show: this.showing_this_month
          })
            .onClick(() => {
              this.showing_this_month = true;
              this.showing_today = false;
              this.showing_this_year = false;
              this.showing_before = false;
              this.refresh_selected_history_list();
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
              this.refresh_selected_history_list();
            })
        } // Tab selectors
        .width("100%")
        .justifyContent(FlexAlign.End)
      }
      .alignItems(HorizontalAlign.Start)
      .width("100%")
      .layoutWeight(1)
      .animation(animation_default())

      Scroll() {
        Column({ space: 10 }) {
          Row() {
            linysTitleText({ text: $r('app.string.Settings_experience_history_selecting') })
            linysTitleText({ text: " " + this.selected_number.toString() + " " })
            linysTitleText({ text: $r('app.string.Settings_experience_history_selecting_items') })
          }

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
          }
          .width("100%")
        }
        .alignItems(HorizontalAlign.Start)
        .width("100%")
        .animation(animation_default())
      } // Select controls
      .scrollBar(BarState.Off)
      .width("100%")
      .height(this.selecting ? 80 : 0)
      .animation(animation_default())

    }
    .padding(15)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.End)
    .width("100%")
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

  all_false(length: number) {
    let result: boolean[] = [];
    for (let index = 0; index < length; index++) {
      result.push(false);
    }
    return result;
  }

  // Select Events and operations

  on_select_change() {
    if (this.selected.includes(true)) {
      this.selecting = true;
    } else {
      this.selecting = false;
    }
    this.delete_confirm = 0;
  }

  refresh_selected_history_list() {
    if (this.showing_today) {
      this.selected_history_list = this.bunch_of_history.get_part_slice(this.stamp_today);
      this.time_period = new Date(this.stamp_today).toLocaleString();
    }
    if (this.showing_this_month) {
      this.selected_history_list = this.bunch_of_history.get_part_slice(this.stamp_this_month);
      this.time_period = new Date(this.stamp_this_month).toLocaleString();
    }
    if (this.showing_this_year) {
      this.selected_history_list = this.bunch_of_history.get_part_slice(this.stamp_this_year);
      this.time_period = new Date(this.stamp_this_year).toLocaleString();
    }
    if (this.showing_before) {
      this.selected_history_list = this.bunch_of_history.get_part_slice(0, this.stamp_this_year);
      this.time_period = new Date(this.stamp_this_year).toLocaleString();
    }
    this.selected_number = 0;
    this.selected = this.all_false(this.selected_history_list.length);
  }

  select_all() {
    if (this.selected.includes(false)) {
      for (let index = 0; index < this.selected.length; index++) {
        this.selected[index] = true;
      }
      this.selected_number = this.selected.length;
    } else {
      for (let index = 0; index < this.selected.length; index++) {
        this.selected[index] = false;
      }
      this.selected_number = 0;
    }
  }

  delete_selected() {
    let bias = 0;
    if (this.showing_before) {
      // bias = the number of items in this year
      bias = this.bunch_of_history.history_list.length -
      this.bunch_of_history.index_of_record_after_time(this.stamp_this_year);
    }
    for (let index = 0; index < this.selected_history_list.length; index++) {
      if (this.selected[index]) {
        this.bunch_of_history.remove_history(this.bunch_of_history.history_list.length - 1 - index - bias, true);
      }
    }
    this.refresh_selected_history_list();
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

  select_unselect() {
    if (this.selected[this.index]) {
      this.selected_number -= 1;
    } else {
      this.selected_number += 1;
    }
    this.selected[this.index] = !this.selected[this.index];
  }
}