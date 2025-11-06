import linysSymbol from '../../components/texts/linysSymbol';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import linysShowButton from '../../components/buttons/linysShowButton';
import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import woofControlFrame from '../woofControlFrame';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import linysSwitchWithText from '../../components/toggles/linysSwitchWithText';
import ManageListElement from './ManageListElement';
import { animation_default, capsule_bar_height } from '../../hosts/bunch_of_defaults';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import { match_domain } from '../../utils/url_tools';
import { all_false } from '../../utils/data_operation_tools';

@CustomDialog
struct woofGeneralManage {
  controller: CustomDialogController;
  // Environment and Hosts
  @LocalStorageLink('current_url') current_url: string = "=￣ω￣=";
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @State add_site_edit: string = "";
  @State showing_add_panel: boolean = false;
  // Generals
  @Link general_switch: boolean;
  @Link all_sites_switch: boolean;
  @Link sites_list: string[];
  @State descriptions: ResourceStr[] = [];
  @State tips: ResourceStr = '';
  @State title: ResourceStr = '';
  @State switch_desc: ResourceStr = '';
  @State subtitle_sites_list: ResourceStr = '';
  @State subtitle_all_sites: ResourceStr = ''; // If this is left blank, then this toggle is not displayed
  @State switch_id: string = '';
  @State sites_list_id: string = '';
  @State switch_all_sites_id: string = '';
  // UI
  @State full_view: boolean = false;
  // Pass in content components
  @BuilderParam extra_manage: () => void;
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Manage
  @State @Watch('on_select_change') selected: boolean[] = all_false(this.sites_list.length);
  @State selecting: boolean = false;
  @State selected_number: number = 0;
  @State delete_confirm: number = 0;
  // alignRules
  alignRules_head_non_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    left: { anchor: "__container__", align: HorizontalAlign.Start }
  };
  alignRules_head_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    bottom: { anchor: "controls", align: VerticalAlign.Top },
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
    top: { anchor: "title", align: VerticalAlign.Bottom },
    bottom: { anchor: "controls", align: VerticalAlign.Top },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Gateways
  @LocalStorageLink('universal_fail_prompt_desc_gateway') uni_fail_prompt_gateway: ResourceStr = "";
  // Actions
  onDelete?: (deleted: string[], remaining: string[]) => void;
  onAdd?: (added: string) => void;
  // Count
  @LocalStorageLink('opened_dialog_controllers') opened_dialog_controllers: CustomDialogController[] = [];

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
      title: this.title,
      controller: this.controller,
    }) {
      RelativeContainer() {
        Column() {
          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.descriptions, (desc: ResourceStr, _index: number) => {
                linysText({
                  text: desc,
                  max_lines: 10
                })
                  .width("100%")
              })
              linysText({
                text: $r('app.string.General_select_guide'),
                max_lines: 10,
                is_description: true,
                is_expanded: true
              })
                .width("100%")
              if (this.tips) {
                linysText({
                  text: this.tips,
                  max_lines: 3,
                  is_description: true,
                  is_expanded: true
                })
                  .width("100%")
                  .visibility(this.match_this_domain(this.current_url) ? Visibility.None : Visibility.Visible)
                  .animation(animation_default())
              } // Tips on status of current site.
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
        } // TODO: Such nesting is bad O.o
        .padding({ right: this.tablet_mode ? 10 : 0 })
        .width(this.tablet_mode ? (this.full_view ? "0%" : "40%") : "100%")
        .constraintSize(this.tablet_mode ? {} : { maxHeight: '35%' })
        .alignRules(this.tablet_mode ? this.alignRules_head_tablet : this.alignRules_head_non_tablet)
        .visibility(this.full_view ? Visibility.None : Visibility.Visible)
        .animation(animation_default())
        .id("title")

        Column({ space: 10 }) {
          Row({ space: 10 }) {
            linysText({
              text: this.subtitle_sites_list,
              max_lines: 3
            }) // Subtitle on list of domains
              .width("100%")
              .layoutWeight(1)
              .padding({ top: this.tablet_mode ? 0 : 10 })
              .opacity(this.all_sites_switch || !this.general_switch ? 0.5 : 1)
              .animation(animation_default())

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
              ForEach(this.sites_list, (item: string, index: number) => {
                ManageListElement({
                  text: item,
                  index: index,
                  selected: this.selected,
                  selected_number: this.selected_number,
                  selecting: this.selecting
                })
                  .width("100%")
              })
              if (this.sites_list.length == 0) {
                linysTextTitle({
                  text: "¯\\_(ツ)_/¯"
                })
                  .margin(30)
                  .opacity(0.7)
                  .animation(animation_default())
              }
            }
            .width("100%")
          } // domains display list
          .scrollable(ScrollDirection.Vertical)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.Top)
          .borderRadius(10)
          .backgroundColor(this.color_current_secondary)
          .width("100%")
          .layoutWeight(1)
          .opacity(this.all_sites_switch || !this.general_switch ? 0.5 : 1)
          .animation(animation_default())

          if (this.subtitle_all_sites) {
            linysSwitchWithText({
              text: this.subtitle_all_sites,
              toggle_state: this.all_sites_switch,
              onExecution: () => {
                bunch_of_settings.set(this.switch_all_sites_id, this.all_sites_switch);
              }
            })
              .opacity(!this.general_switch ? 0.5 : 1)
              .animation(animation_default())
          } // Toggle on all sites

          linysSwitchWithText({
            text: this.switch_desc,
            toggle_state: this.general_switch,
            onExecution: () => {
              bunch_of_settings.set(this.switch_id, this.general_switch);
            }
          }) // Feature enable

        } // Whitelist
        .width(this.tablet_mode ? (this.full_view ? "100%" : "60%") : "100%")
        .height(this.tablet_mode ? "100%" : undefined)
        .alignRules(this.tablet_mode ? this.alignRules_body_tablet : this.alignRules_body_non_tablet)
        .animation(animation_default())

        Column() {
          if (this.extra_manage) {
            this.extra_manage();
            Row().height(10)
          }

          linysShowButton({
            show: this.showing_add_panel,
            symbol_glyph_target: "sys.symbol.plus",
            text: $r("app.string.Settings_woof_add_a_domain")
          })// Add Button
            .onClick(() => {
              this.showing_add_panel = !this.showing_add_panel;
            })

          Scroll() {
            Column({ space: 8 }) {
              TextInput({ text: this.add_site_edit })// Input domain
                .onChange((value) => {
                  this.add_site_edit = value;
                })
                .fontWeight(FontWeight.Regular)
                .fontColor(this.color_current_font)
                .caretColor(this.color_current_font)
                .selectedBackgroundColor(this.color_current_font)
                .width("100%")
                .onSubmit(() => {
                  this.add_item(this.add_site_edit);
                  this.add_site_edit = "";
                  this.showing_add_panel = false;
                })
                .height(capsule_bar_height())
                .animation(animation_default())

              linysCapsuleButton({ text: "  󰀓  " })
                .animation(animation_default())
                .onClick(() => {
                  this.add_item(this.add_site_edit);
                  this.add_site_edit = "";
                  this.showing_add_panel = false;
                })
            }
            .padding({ top: 10 })
            .alignItems(this.preferred_hand_left_or_right == 'right' ? HorizontalAlign.End : HorizontalAlign.Start)
            .animation(animation_default())
            .width("100%")
          } // Add
          .scrollBar(BarState.Off)
          .width("100%")
          .height(this.showing_add_panel ? 90 : 0)
          .animation(animation_default())

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
        } // Controls
        .padding({ top: 10, right: this.tablet_mode ? 10 : 0 })
        .alignItems(this.preferred_hand_left_or_right == 'right' ? HorizontalAlign.End : HorizontalAlign.Start)
        .alignRules(this.alignRules_foot)
        .opacity(this.all_sites_switch || !this.general_switch ? 0.5 : 1)
        .visibility(this.full_view ? Visibility.None : Visibility.Visible)
        .backgroundColor(this.color_current_primary)
        .animation(animation_default())
        .width(this.tablet_mode ? "40%" : "100%")
        .id("controls")
        .onAppear(() => {
          setInterval(() => {
            if (this.delete_confirm > 0) {
              this.delete_confirm -= 1;
            }
            // Reset delete confirm
          }, 10)
        })

      }.layoutWeight(1)
    }
  }

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
   * Adds an item.
   * @param domain The item.
   * */
  add_item(domain: string) {
    if (domain == '') {
      this.uni_fail_prompt_gateway = $r('app.string.Fail_desc_no_content');
      return;
    }
    // don't add same domains
    if (this.sites_list.includes(domain)) {
      this.uni_fail_prompt_gateway = $r('app.string.Fail_desc_duplicate_domain');
      return;
    }
    if (this.onAdd) {
      this.onAdd(domain);
    }
    this.sites_list.push(domain);
    bunch_of_settings.set(this.sites_list_id, this.sites_list.join("\n"))
  }

  /**
   * Deletes the selected items.
   * */
  delete_selected() {
    let new_exceptions: string[] = [];
    let delete_exceptions: string[] = [];
    for (let index = 0; index < this.selected.length; index++) {
      if (!this.selected[index]) {
        new_exceptions.push(this.sites_list[index]);
      } else {
        delete_exceptions.push(this.sites_list[index]);
      }
    }
    if (this.onDelete) {
      this.onDelete(delete_exceptions, new_exceptions);
    }
    this.sites_list = new_exceptions;
    this.delete_confirm = 0;
    this.selecting = false;
    this.selected_number = 0;
    this.selected = all_false(this.sites_list.length);
    bunch_of_settings.set(this.sites_list_id, this.sites_list.join("\n"))
  }

  /**
   * Checks if address is included in the list of sites.
   * @param address The address.
   * @returns True if is in.
   * */
  match_this_domain(address: string) {
    if (!this.general_switch) {
      return true;
    }
    // Disable toggle ON
    if (this.all_sites_switch) {
      // Disable on all sites
      return false;
    }
    // Disable on some sites
    if (address && this.sites_list.includes(match_domain(address)[1])) {
      return false;
    }
    return true;
  }
}

export default woofGeneralManage;