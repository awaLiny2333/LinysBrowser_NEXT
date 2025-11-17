import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import woofControlFrame from '../woofControlFrame';
import linysSymbol from '../../components/texts/linysSymbol';
import linysCapsuleButtonWithText from '../../components/buttons/linysCapsuleButtonWithText';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import ManageListElement from './ManageListElement';
import { animation_default } from '../../hosts/bunch_of_defaults';
import { copy_from_uri_to_sandbox, document_pick_to_uri, sandbox_unlink_sync } from '../../utils/storage_tools';
import { all_false } from '../../utils/data_operation_tools';
import { apply_EasyList, get_EasyLists } from '../../processes/web_actions';

@CustomDialog
struct woofEasyList {
  controller: CustomDialogController;
  // Environment
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @LocalStorageProp('current_url') current_url: string = "=￣ω￣=";
  @LocalStorageLink('universal_fail_prompt_desc_gateway') uni_fail_prompt_gateway: ResourceStr = "";
  // UI
  @State full_view: boolean = false;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Interfaces
  @State lists: string[][] = get_EasyLists();
  // alignRules
  alignRules_head_non_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    left: { anchor: "__container__", align: HorizontalAlign.Start },
  };
  alignRules_head_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    bottom: { anchor: "controls_rules", align: VerticalAlign.Top },
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
    top: { anchor: "title_rules_manager", align: VerticalAlign.Bottom },
    bottom: { anchor: "controls_rules", align: VerticalAlign.Top },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Count
  @LocalStorageLink('opened_dialog_controllers') opened_dialog_controllers: CustomDialogController[] = [];
  // Manage
  @State @Watch('on_select_change') selected: boolean[] = all_false(this.lists.length);
  @State selecting: boolean = false;
  @State selected_number: number = 0;
  @State delete_confirm: number = 0;

  aboutToAppear(): void {
    this.opened_dialog_controllers.push(this.controller);
    console.log(`[Dialog][Open] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  aboutToDisappear(): void {
    this.opened_dialog_controllers.splice(this.opened_dialog_controllers.indexOf(this.controller), 1);
    console.log(`[Dialog][Close] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  build() {
    woofControlFrame({
      title: $r('app.string.Settings_experience_manage_adblock_rules'),
      controller: this.controller,
    }) {
      RelativeContainer() {
        Column() {
          Scroll() {
            Column({ space: 10 }) {
              linysText({
                text: $r('app.string.Settings_experience_manage_adblock_rules_desc_1'),
                max_lines: 10
              })
                .width("100%")
              linysText({
                text: $r('app.string.Settings_experience_manage_adblock_rules_desc_2'),
                max_lines: 10
              })
                .width("100%")
              linysText({
                text: $r('app.string.Settings_experience_manage_adblock_rules_desc_3'),
                max_lines: 10,
                is_description: true,
                is_expanded: true
              })
                .width("100%")
              linysText({
                text: $r('app.string.Have_a_Nice_Surf'),
                max_lines: 2
              })
                .width("100%")
                .opacity(0.9)
            }
            .width("100%")
          } // Descriptions
          .scrollBar(BarState.Off)
          .align(Alignment.TopStart)
          .edgeEffect(EdgeEffect.Spring)
          .padding({ bottom: 10, top: 5 })
          .borderRadius(10)
        }
        .padding({ right: this.tablet_mode ? 10 : 0 })
        .width(this.tablet_mode ? (this.full_view ? "0%" : "40%") : "100%")
        .alignRules(this.tablet_mode ? this.alignRules_head_tablet : this.alignRules_head_non_tablet)
        .visibility(this.full_view ? Visibility.None : Visibility.Visible)
        .animation(animation_default())
        .constraintSize(this.tablet_mode ? {} : { maxHeight: '35%' })
        .id("title_rules_manager")

        Column({ space: 10 }) {
          Row({ space: 10 }) {
            linysText({ text: $r('app.string.Settings_experience_manage_adblock_rules_active'), max_lines: 3 }) // Rules active
              .width("100%")
              .layoutWeight(1)
              .padding({ top: this.tablet_mode ? 0 : 10 })

            linysSymbol({
              symbol_glyph_target: this.full_view ?
                'sys.symbol.arrow_down_right_and_arrow_up_left' :
                'sys.symbol.arrow_up_left_and_arrow_down_right'
            })
              .padding({ top: 5 })
              .onClick(() => {
                this.full_view = !this.full_view
              })
          }
          .alignItems(VerticalAlign.Center)
          .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
          .width('100%')

          Scroll() {
            Column() {
              ForEach(this.lists, (item: string[], index: number) => {
                ManageListElement({
                  text: item[0] + ' (' + item[1] + ')',
                  index: index,
                  selected: this.selected,
                  selecting: this.selecting,
                  selected_number: this.selected_number
                })
                  // .width("100%")
              })
              if (this.lists.length == 0) {
                linysTextTitle({
                  text: "¯\\_(ツ)_/¯"
                })
                  .margin(30)
                  .opacity(0.7)
                  .animation(animation_default())
              }
            }
            .width("100%")
          } // Rules display list
          .scrollable(ScrollDirection.Vertical)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.Top)
          .borderRadius(10)
          .backgroundColor(this.color_current_secondary)
          .width("100%")
          .layoutWeight(1)
        } // Rules
        .clip(true)
        // .backgroundColor(this.color_current_primary)
        .width(this.tablet_mode ? (this.full_view ? "100%" : "60%") : "100%")
        .height(this.tablet_mode ? "100%" : undefined)
        .alignRules(this.tablet_mode ? this.alignRules_body_tablet : this.alignRules_body_non_tablet)
        .animation(animation_default())

        Column({ space: 10 }) {

          Scroll() {
            Column({ space: 10 }) {
              Row() {
                linysTextTitle({ text: $r("app.string.Settings_edit_selecting") })
                linysTextTitle({ text: " " + this.selected_number.toString() + " " })
                linysTextTitle({ text: $r("app.string.Settings_edit_selecting_items") })
              }

              Row() {
                linysSymbol({ symbol_glyph_target: 'sys.symbol.list_checkmask' })
                  .onClick(() => {
                    this.select_unselect_all();
                  })
                Blank()
                linysTimeoutButton({
                  text: "  󰀁  ",
                  onExecution: () => {
                    this.delete_selected();
                  }
                }) // Delete
              }
              .width("100%")
            }
            .padding({ top: 10 })
            .alignItems(HorizontalAlign.Start)
            .width("100%")
          } // Select controls
          .scrollBar(BarState.Off)
          .width("100%")
          .height(this.selecting ? 80 : 0)
          .animation(animation_default())

          linysCapsuleButtonWithText({
            button_text: '  󰃟  ',
            desc_text: $r('app.string.Settings_experience_manage_adblock_rules_add'),
            onExecution: () => {
              document_pick_to_uri(['txt']).then(result => {
                if (!result) {
                  this.uni_fail_prompt_gateway = $r('app.string.Fail_select_bad_file');
                  return;
                }
                console.log(`[Copy_EasyList] ${result}`);
                try {
                  copy_from_uri_to_sandbox(result, 'easylist');
                } catch (e) {
                  this.uni_fail_prompt_gateway = e.toString();
                }
                this.lists = get_EasyLists();
                apply_EasyList();
              });
            }
          }) // Add
        } // Controls
        .margin({ top: 15 })
        .padding(this.tablet_mode ? { right: 10 } : undefined)
        .alignItems(HorizontalAlign.End)
        .alignRules(this.alignRules_foot)
        .visibility(this.full_view ? Visibility.None : Visibility.Visible)
        // .backgroundColor(this.color_current_primary)
        .animation(animation_default())
        .width(this.tablet_mode ? "40%" : "100%")
        .id("controls_rules")
      }.layoutWeight(1)
    }
  }

  // Manage

  /**
   * Called when some item is selected.
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
   * Selects or unselects all items.
   * */
  select_unselect_all() {
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
   * Deletes the selected items.
   * */
  delete_selected() {
    for (let index = 0; index < this.selected.length; index++) {
      if (this.selected[index]) {
        sandbox_unlink_sync('easylist/' + this.lists[index][0]);
      }
    }
    this.lists = get_EasyLists();
    apply_EasyList();
    this.delete_confirm = 0;
    this.selecting = false;
    this.selected_number = 0;
    this.selected = all_false(this.lists.length);
  }
}

export default woofEasyList;
