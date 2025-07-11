import { animation_default, click_effect_default, default_search_engine } from '../../hosts/bunch_of_defaults';
import { bunch_of_search_engines, search_engine } from '../../hosts/bunch_of_search_engines';
import { bunch_of_settings } from '../../hosts/bunch_of_settings';
import woofControlFrame from '../woofControlFrame';
import meowSEManager from '../../blocks/panels/meowSEManager';
import linysText from '../../components/texts/linysText';

@CustomDialog
struct woofQuickSE {
  controller: CustomDialogController;
  @Prop keyword: string = ''
  @Prop default_new_se: search_engine = new search_engine(new Date().toLocaleString(), default_search_engine());
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Host
  @StorageLink('bunch_of_search_engines') bunch_of_search_engines: bunch_of_search_engines = new bunch_of_search_engines();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Animation UI Statuses
  @State adding_SE: boolean = false;
  @State height_of_add_panel: number = 0;
  button_height_default: number = 42;
  // Gateways
  @StorageLink('universal_load_url_gateway') load_url_gateway: string = "";

  build() {
    woofControlFrame({
      title: $r('app.string.AddSE_search_again_on'),
      controller: this.controller
    }) {
      Scroll() {
        Column({ space: 10 }) {
          linysText({
            text: ' 󰀩  ' + this.keyword + ' '
          })
            .padding(10)
            .borderRadius(13.5)
            .clickEffect(click_effect_default())
            .backgroundColor(this.color_current_secondary)

          meowSEManager({
            default_new_se: this.default_new_se,
            on_default_execution: () => {
              this.search_with_se(this.keyword);
            },
            on_normal_execution: (idx, _se) => {
              this.search_with_se(this.keyword, idx);
            }
          })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .borderRadius(13.5)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({
        maxHeight: 45 + 48.5 * this.bunch_of_search_engines.list_of_search_engines.length + 100 + (this.adding_SE ? 20 + this.height_of_add_panel : 0)
      })
      .animation(animation_default())
      .onAppear(() => {
        console.log('[woofQuickSE] About to search: "' + this.keyword + '" on another engine.')
      })
    }
  }

  search_with_se(key: string, clicked_index?: number) {
    // Choose to search on another engine
    if (clicked_index !== undefined) {
      this.load_url_gateway = this.bunch_of_search_engines.list_of_search_engines[clicked_index].url.replaceAll('%s', key);
    } else {
      this.load_url_gateway = default_search_engine().replaceAll('%s', key);
    }
    console.log('[woofQuickSE] Search: "' + this.keyword + '" => ' + this.load_url_gateway);
    if (this.controller) {
      this.controller.close();
    }
  }
}

export default woofQuickSE;