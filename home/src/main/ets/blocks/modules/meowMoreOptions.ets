import { animation_default, capsule_bar_height, click_effect_default, default_new_window_name } from '../../hosts/bunch_of_defaults';
import { bunch_of_key_shortcuts } from '../../hosts/bunch_of_key_shortcuts';
import { change_window_alias, new_window, storage_of_id } from '../../utils/ui_tools';
import { cancel_in_page_search } from '../../processes/tabs_actions';
import { bunch_of_tabs } from '../../hosts/bunch_of_tabs';
import lazy { common } from '@kit.AbilityKit';
import linysText from '../../components/texts/linysText';
import linysSymbol from '../../components/texts/linysSymbol';
import lazy linysProgressInfo from '../../components/linysProgressInfo';
import lazy meowDebug from '../panels/meowDebug';
import lazy woofPrompt from '../../dialogs/web/woofPrompt';
import linysSwitchWithText from '../../components/toggles/linysSwitchWithText';
import { modify_zone_name } from '../../processes/zone_actions';
import { is_legal_filename } from '../../utils/storage_tools';
import linysFileNameErrorDisplay from '../../components/linysFileNameErrorDisplay';
import lazy woofZones from '../../dialogs/contents/woofZones';
import meowTitleFunctionButton from './meowTitleFunctionButtons';

@Component
struct meowMoreOptions {
  @StorageLink('windowIds') windowIds: string[] = [];
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  @LocalStorageLink('is_zone') is_zone: boolean = false;
  @StorageLink('zones') zones: string[] = [];
  @LocalStorageLink('my_window_alias') my_window_alias: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  // Hosts
  @StorageLink('bunch_of_key_shortcuts') bunch_of_key_shortcuts: bunch_of_key_shortcuts = new bunch_of_key_shortcuts(true);
  @LocalStorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs(true);
  // UI Statuses
  @LocalStorageLink('showing_more_options') showing_more_options: boolean = false;
  @LocalStorageLink('showing_scratching_board') showing_scratching_board: boolean = false;
  // Logics Statuses
  @LocalStorageLink('search_input') search_input: string = "ଘ*(੭*ˊᵕˋ)੭*";
  @LocalStorageLink('is_search_input_typing') is_search_input_typing: boolean = false;
  // History
  @StorageLink('reindexing_history_progress') reindexing_history_progress: string = "";
  @StorageLink('history_index_loading_progress') history_index_loading_progress: string = "";
  @StorageLink('history_index_saving_progress') history_index_saving_progress: string = "";
  // Environments
  @StorageLink('DEV_MODE') DEV_MODE: boolean = false;
  @StorageLink('free_window_mode') free_window_mode: boolean = false;
  @LocalStorageLink('fullscreen_mode') fullscreen_mode: boolean = false;
  @LocalStorageLink('fullscreen_mode_immersive') fullscreen_mode_immersive: boolean = true;
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  // Settings
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  @StorageLink('resource_monitor') resource_monitor: boolean = true;
  // In-page search
  @LocalStorageLink('current_in_page_searching_keyword') current_in_page_searching_keyword: string = "";
  @LocalStorageLink('current_in_page_searching_stats_current') current_in_page_searching_stats_current: number = 0;
  @LocalStorageLink('current_in_page_searching_stats_total') current_in_page_searching_stats_total: number = 0;
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // dialogs
  @State rename_window_prompt_result: string = '';
  @State window_alias_legal_err: number = 1;
  rename_window_woofPrompt_control: CustomDialogController = new CustomDialogController({
    builder: woofPrompt({
      title: $r('app.string.Settings_appearance_windows_rename'),
      message: 'ID: ' + this.my_window_id,
      value: this.my_window_alias,
      promptResult: this.rename_window_prompt_result,
      single_line: true,
      onConfirm: () => {
        this.window_alias_legal_err = is_legal_filename(this.rename_window_prompt_result);
        let old_name = this.my_window_alias;
        if (this.is_zone) {
          if (this.window_alias_legal_err == 0) {
            change_window_alias(this.my_window_id, this.rename_window_prompt_result);
            modify_zone_name(old_name, this.my_window_alias);
          }
        } else {
          change_window_alias(this.my_window_id, this.rename_window_prompt_result);
        }
      },
      onDeny: () => {
        // Nothing happens
      }
    }),
    alignment: DialogAlignment.Center,
    cornerRadius: 26
  })
  Zones_control: CustomDialogController = new CustomDialogController({
    builder: woofZones(),
    alignment: DialogAlignment.Center,
    cornerRadius: 26,
    width: "90%",
  });

  aboutToAppear(): void {
    this.window_alias_legal_err = is_legal_filename(this.my_window_alias);
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Row() // To get more space
          .visibility(this.current_in_page_searching_stats_total > 0 ? Visibility.None : Visibility.Visible)
          .animation(animation_default())

        RelativeContainer() {
          Row() {
            linysSymbol({
              symbol_glyph_target: 'sys.symbol.doc_text_badge_magnifyingglass', can_hover: true
            }) // in-page Search

            TextInput({
              text: this.current_in_page_searching_keyword,
              placeholder: $r('app.string.More_in_page_search')
            })
              .onChange((edit) => {
                this.current_in_page_searching_keyword = edit;
                this.bunch_of_tabs.workingMainTab().searching_keyword = edit;
              })
              .visibility(this.showing_scratching_board ? Visibility.Hidden : Visibility.Visible)
              .layoutWeight(1)
              .allowDrop(null)
              .margin({ left: 5, right: 5 })
              .height(capsule_bar_height())
              .fontWeight(FontWeight.Regular)
              .fontColor(this.color_current_font)
              .caretColor(this.color_current_font)
              .selectedBackgroundColor(this.color_current_font)
              .onDragEnter(() => {
                this.showing_scratching_board = false;
              })
              .enabled(this.showing_scratching_board ? false : true)
              .opacity(this.showing_scratching_board ? 0.8 : 1)
              .onSubmit(() => {
                try {
                  this.bunch_of_tabs.workingMainTab().controller!.searchAllAsync(this.current_in_page_searching_keyword);
                } catch (e) {
                  console.error(e);
                }
                if (this.free_window_mode) {
                  focusControl.requestFocus("in_page_search_blank");
                }
              })
              .id('in_page_search_blank')
              .onFocus(() => {
                this.storage.setOrCreate('is_search_in_page_focused', true);
              })
              .onBlur(() => {
                this.storage.setOrCreate('is_search_in_page_focused', false);
              })


            linysSymbol({ symbol_glyph_target: 'sys.symbol.magnifyingglass', can_hover: true }) // Submit
              .onClick(() => {
                try {
                  this.bunch_of_tabs.workingMainTab().controller!.searchAllAsync(this.current_in_page_searching_keyword);
                } catch (e) {
                  console.error(e);
                }
              })

            linysSymbol({ symbol_glyph_target: 'sys.symbol.xmark', can_hover: true }) // Cancel
              .onClick(() => {
                cancel_in_page_search(this.storage);
              })
              .visibility(this.current_in_page_searching_keyword != "" ? Visibility.Visible : Visibility.None)
              .animation(animation_default())
          } // Search bar
          .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
          .id('in_page_search_bar')
          .alignRules(this.tablet_mode ? {
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: "in_page_search_operation_buttons", align: HorizontalAlign.Start }
          } : {
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: "__container__", align: HorizontalAlign.End },
            top: { anchor: "__container__", align: VerticalAlign.Top }
          })
          .animation(animation_default())

          Row() {
            linysText({
              text: this.current_in_page_searching_stats_current.toString() + '／' + this.current_in_page_searching_stats_total.toString()
            })
              .padding({ right: 5 })
              .animation(animation_default())
            if (this.showing_more_options) {
              linysSymbol({ symbol_glyph_target: 'sys.symbol.chevron_up', can_hover: true })
                .onClick(() => {
                  try {
                    this.bunch_of_tabs.workingMainTab().controller!.searchNext(false);
                  } catch (e) {
                    console.error(e);
                  }
                })
              linysSymbol({ symbol_glyph_target: 'sys.symbol.chevron_down', can_hover: true })
                .onClick(() => {
                  try {
                    this.bunch_of_tabs.workingMainTab().controller!.searchNext(true);
                  } catch (e) {
                    console.error(e);
                  }
                })
            }
          } // Operation buttons
          .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
          .id('in_page_search_operation_buttons')
          .padding({ left: this.tablet_mode ? 10 : 0 })
          .alignRules(this.tablet_mode ? {
            right: { anchor: "__container__", align: HorizontalAlign.End },
            center: { anchor: "__container__", align: VerticalAlign.Center }
          } : {
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: "__container__", align: HorizontalAlign.End },
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
          })
          .animation(animation_default())

        } // Search in page
        .direction(this.preferred_hand_left_or_right == 'right' ? Direction.Ltr : Direction.Rtl)
        .width("100%")
        .height(20 + (this.tablet_mode ? capsule_bar_height() : 2 * capsule_bar_height()))
        .backgroundColor(this.color_current_primary)
        .borderRadius(12)
        .padding(10)
        .animation(animation_default())

        if (this.showing_more_options) {
          Row() {
            linysText({
              text: '#' + this.windowIds.indexOf(this.my_window_id) + '｜' + this.my_window_alias,
              can_hover: true,
            }) // Current my_window_alias
              .margin({ left: 3 })
              .layoutWeight(1)
              .clickEffect(click_effect_default())
              .onClick(() => {
                this.rename_window_woofPrompt_control.open();
              })

            linysSymbol({
              symbol_glyph_target: 'sys.symbol.pencil_and_card', can_hover: true
            }) // Edit window name
              .onClick(() => {
                this.rename_window_woofPrompt_control.open();
              })
            linysSymbol({
              // symbol_glyph_target: 'sys.symbol.plus_square_dashed_on_square',
              symbol_glyph_target: 'sys.symbol.plus', can_hover: true,
            }) // New window
              .onClick(() => {
                new_window(this.getUIContext().getHostContext() as common.UIAbilityContext, Date.now().toString(), default_new_window_name());
              })
          } // Window man
          .visibility(this.visible_when_not_in_page_search())
          .animation(animation_default())
          .opacity(0.8)
          .constraintSize({ maxWidth: 500 })
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .borderRadius(12)
          .padding(5)

          Column({ space: 5 }) {
            Row({ space: 5 }) {
              linysSymbol({
                symbol_glyph_target: 'sys.symbol.briefcase',
                can_hover: true
              })
                .onClick(() => {
                  // Open Zone view
                  this.Zones_control.open();
                })

              linysSwitchWithText({
                text: $r('app.string.Tabs_save_as_zone'),
                toggle_state: this.is_zone,
                onExecution: () => {
                  // Will automatically trigger actions in Index.ets

                  // if (this.is_zone) {
                  //   console.log(`[zone_actions] SET ZONE!`);
                  //   set_zone(this.my_window_id);
                  // } else {
                  //   console.log(`[zone_actions] OFF ZONE!`);
                  //   off_zone(this.my_window_id);
                  // }
                }
              })
                .layoutWeight(1)
                .enabled(this.can_save_zone() && this.window_alias_legal_err == 0)

              linysSymbol({
                symbol_glyph_target: 'sys.symbol.magnifyingglass',
                can_hover: true
              })
                .onClick(() => {
                  // Open Zone view
                  this.Zones_control.open();
                })
            }

            linysText({
              text: $r('app.string.Tabs_save_as_zone_alias_crash'), max_lines: 999
            })
              .padding({ left: 5, right: 5 })
              .visibility(this.can_save_zone() ? Visibility.None : Visibility.Visible)
              .animation(animation_default())

            Row() {
              linysFileNameErrorDisplay({
                file_name: this.my_window_alias,
                error_code: this.window_alias_legal_err
              })
                .layoutWeight(1)
            }
            .visibility(this.window_alias_legal_err == 0 ? Visibility.None : Visibility.Visible)

          } // Zone man
          .visibility(this.visible_when_not_in_page_search())
          .animation(animation_default())
          .opacity(0.8)
          .constraintSize({ maxWidth: 500, minHeight: 43 })
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .borderRadius(12)
          .padding(this.can_save_zone() && this.window_alias_legal_err == 0 ? { left: 5, right: 5 } : {
            left: 5,
            right: 5,
            top: 5,
            bottom: 15
          })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)

          meowTitleFunctionButton({ MODE_FULL: true })
            .visibility(this.visible_when_not_in_page_search())
            .animation(animation_default())

          meowDebug() // Debug
            .opacity(0.8)
            .visibility(this.resource_monitor
              ? (this.visible_when_not_in_page_search())
              : Visibility.None)
            .animation(animation_default())

          linysProgressInfo({
            notification: $r('app.string.Settings_experience_history_index_loading_index_from_disk'),
            progress: this.history_index_loading_progress,
          })
            .opacity(0.8)
            .visibility(this.history_index_loading_progress != "" ? (this.visible_when_not_in_page_search()) : Visibility.None)
            .animation(animation_default())

          linysProgressInfo({
            notification: $r('app.string.Settings_experience_history_index_reindexing'),
            progress: this.reindexing_history_progress,
          })
            .opacity(0.8)
            .visibility(this.reindexing_history_progress != "" ? (this.visible_when_not_in_page_search()) : Visibility.None)
            .animation(animation_default())

          linysProgressInfo({
            notification: $r('app.string.Settings_experience_history_index_saving_to_disk'),
            progress: this.history_index_saving_progress,
          })
            .opacity(0.8)
            .visibility(this.history_index_saving_progress != "" ? (this.visible_when_not_in_page_search()) : Visibility.None)
            .animation(animation_default())
        }
      } // Title Bar of More Options
      .alignItems(this.preferred_hand_left_or_right == 'right' ? HorizontalAlign.End : HorizontalAlign.Start)
      .animation(animation_default())
      .width("100%")
    } // More Options
    .layoutWeight(this.showing_more_options ? 1 : undefined)
    .visibility(this.showing_more_options ? Visibility.Visible : Visibility.None)
    .animation(animation_default())
    .margin(this.free_window_mode ? { left: 10, right: 10 } : { left: 15, right: 15 })
    .align(Alignment.Bottom)
    .borderRadius(10)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
  }

  // Visibility

  visible_when_search_input_is_not_blank() {
    return this.search_input == "" ? Visibility.None : Visibility.Visible
  }

  visible_when_not_in_page_search() {
    return this.current_in_page_searching_stats_total <= 0 ? Visibility.Visible : Visibility.None;
  }

  // Enabled

  can_save_zone() {
    return this.is_zone || !this.zones.includes(this.my_window_alias);
  }
}

export default meowMoreOptions;