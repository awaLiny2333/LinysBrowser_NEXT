import { del_offline_zone, zone_opened } from '../../processes/zone_actions';
import { common } from '@kit.AbilityKit';
import { new_window } from '../../utils/ui_tools';
import { animation_default, minimum_card_width } from '../../hosts/bunch_of_defaults';
import lazy { fileIo } from '@kit.CoreFileKit';
import lazy { meowContext } from '../../utils/environment_tools';
import lazy woofControlFrame from '../woofControlFrame';
import linysTextSubtitleDivision from '../../components/texts/linysTextSubtitleDivision';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { sandbox_read_text_sync } from '../../utils/storage_tools';
import linysTimeoutButtonWithText from '../../components/buttons/linysTimeoutButtonWithText';

@CustomDialog
struct woofZones {
  controller: CustomDialogController;
  @StorageLink('zones') zones: string[] = [];
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Status
  @LocalStorageLink('full_screen_height') full_screen_height: number = 0;
  @LocalStorageProp('screen_width') screen_width: number = 0;
  @LocalStorageLink('compact_mode') compact_mode: boolean = false;
  // UI
  @State notice_height: number = 35;
  // Dialog
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
      title: $r('app.string.zones'),
      controller: this.controller,
      space_column: 10
    }) {
      Column({ space: 15 }) {
        Column({ space: 10 }) {
          linysText({ text: $r('app.string.zones_desc'), is_description: true, is_expanded: true }).width('100%')
            .visibility(this.compact_mode ? Visibility.None : Visibility.Visible)
            .animation(animation_default())
          linysText({ text: $r('app.string.zones_delete'), max_lines: 3, is_expanded: true }).width('100%')
        }
        .onAreaChange((o, n) => {
          this.notice_height = n.height as number;
        })
        .width('100%')

        // Row() {
        //   linysSymbol({ symbol_glyph_target: 'sys.symbol.plus', can_hover: true })
        //     .onClick(()=>{
        //       // new zone
        //     })
        // }.justifyContent(FlexAlign.End).width('100%')

        linysTextTitle({
          text: $r('app.string.zones_existing')
        })

        WaterFlow() {
          ForEach(this.zones, (item: string, idx: number) => {
            subCard({ zone_alias: item, my_index: idx, controller: this.controller })
          })
        }
        .columnsTemplate("1fr ".repeat(Math.ceil(this.screen_width * 0.9 / minimum_card_width())))
        .animation(animation_default())
        .rowsGap(10)
        .columnsGap(10)
        .borderRadius(10)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Auto)
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .constraintSize({ maxHeight: Math.max(0, this.full_screen_height * 0.9 - 35 - 45 - 50 - this.notice_height) })
      }
      .alignItems(HorizontalAlign.Start)
    }
  }
}

export default woofZones;


@Component
struct subCard {
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Contents
  @BuilderParam contents: () => void;
  // Environments
  @LocalStorageLink('is_zone') is_zone: boolean = false;
  @LocalStorageLink('my_window_alias') my_window_alias: string = '';
  @StorageLink('effects') effects: boolean = false;
  // Title
  icon: ResourceStr = '󰙟'; // TODO: Need to be customizable?
  // Stats
  @State isHov: boolean = false;
  // Data
  @Prop my_index: number;
  @Prop zone_alias: string = 'zzz';
  controller: CustomDialogController | undefined = undefined;
  @StorageLink('zones_opened') zones_opened: boolean[] = [];
  @State tabs_count: number = 0;

  aboutToAppear(): void {
    try {
      this.tabs_count = Math.floor((fileIo.listFileSync(meowContext().filesDir + '/zones/' + this.zone_alias, { recursion: false }).length) / 2);
    } catch (error) {
      this.tabs_count = 0;
      console.error('[woofZone][subCard] Scan tabs failed: ' + error);
    }
  }

  build() {
    Column({ space: 5 }) {
      linysTextSubtitleDivision({ icon: this.icon, text: this.zone_alias + ` (${this.tabs_count})`, opa: 0.8 }) // Title
        .width('100%')
        .padding({ bottom: 5 })

      if (this.tabs_count > 0) {
        if (this.tabs_count >= 1) {
          linysText({ text: sandbox_read_text_sync('/zones/' + this.zone_alias + '/continue_tabs_web_state_array_0_label') })
        }
        if (this.tabs_count >= 2) {
          linysText({ text: sandbox_read_text_sync('/zones/' + this.zone_alias + '/continue_tabs_web_state_array_1_label') })
        }
        if (this.tabs_count >= 3) {
          linysText({ text: sandbox_read_text_sync('/zones/' + this.zone_alias + '/continue_tabs_web_state_array_2_label') })
        }
        if (this.tabs_count >= 4) {
          linysText({ text: '...' })
        }
      }
      linysTimeoutButtonWithText({
        desc_text: '',
        button_text: "  󰀁  ",
        onExecution: () => {
          del_offline_zone(this.zone_alias);
        }
      }).width('100%')
    }
    .opacity(this.zones_opened[this.my_index] ? 0.5 : 1)
    .borderColor(this.border_color())
    .backgroundColor(this.color_current_primary)
    .brightness(this.isHov ? 1.04 : 1)
    .animation(animation_default())
    .padding(12)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width("100%")
    .borderRadius(10)
    .borderWidth(2)
    .onHover((isHv) => {
      this.isHov = isHv;
    })
    .onClick(() => {
      this.open();
    })
  }

  border_color() {
    let highlight = (this.zone_alias == this.my_window_alias) && this.is_zone;
    if (highlight) {
      return this.color_current_font;
    } else if (this.effects) {
      return 'transparent';
    } else {
      return this.color_current_primary;
    }
  }

  open() {
    // Prevent opening 2 same zones.
    let is_opened = zone_opened(this.zone_alias);
    // Open zone
    if (is_opened) {
      console.warn(`[zoneButton] INTERCEPTED Load zone! Zone already opened. ${this.zone_alias}`);
      return;
    }
    this.zones_opened[this.my_index] = true;
    console.log(`[zoneButton] Load zone! ${this.zone_alias}`);
    new_window(this.getUIContext().getHostContext() as common.UIAbilityContext, Date.now().toString(), this.zone_alias, true);
    if (this.controller) {
      this.controller.close();
    }
  }
}