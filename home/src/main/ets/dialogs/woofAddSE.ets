import linysCapsuleButton from '../components/linysCapsuleButton';
import linysShowButton from '../components/linysShowButton';
import linysSymbol from '../components/linysSymbol';
import linysTitleText from '../components/linysTitleText';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  default_search_engine,
  fontSize_Normal
} from '../hosts/bunch_of_defaults';
import { bunch_of_search_engines, search_engine } from '../hosts/bunch_of_search_engines';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import woofControlFrame from './woofControlFrame';

@CustomDialog
struct woofAddSE {
  controller: CustomDialogController;
  @Prop link: string = '';
  @Prop label: string = '';
  @Prop keyword: string = ''
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Host
  @StorageLink('bunch_of_search_engines') @Watch('on_SE_change') bunch_of_search_engines: bunch_of_search_engines =
    new bunch_of_search_engines();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  // Animation UI Statuses
  @State adding_SE: boolean = true;
  @State height_of_add_panel: number = 0;
  button_height_default: number = 42;
  // Data
  @State list_of_search_engines: search_engine[] = this.bunch_of_search_engines.list_of_search_engines;
  // Uni
  @StorageLink('universal_load_url_gateway') load_url_gateway: string = "";

  build() {
    woofControlFrame({
      title: $r('app.string.AddSE_search_again_on'),
      controller: this.controller
    }) {
      Scroll() {
        Column({space:15}) {
          Column({ space: 6.5 }) {
            Row() {
              Text($r('app.string.Settings_general_custom_ua_default'))// Title
                .fontColor(this.color_current_font)
                .animation(animation_default())
                .fontSize(fontSize_Normal())
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }
            .padding(10)
            .borderRadius(7)
            .backgroundColor(this.color_current_primary)
            .animation(animation_default())
            .height(this.button_height_default)
            .width("100%")
            .animation(animation_default())
            .clickEffect(click_effect_default())
            .onClick(() => {
              this.load_url_gateway = default_search_engine().replaceAll('%s', this.keyword);
              if (this.controller) {
                this.controller.close();
              }
            })

            ForEach(
              this.list_of_search_engines, (_user_agent: search_engine, key: number) => {
              meowSEButton({
                my_index: key,
              })
                .onClick(() => {
                  this.load_url_gateway = this.list_of_search_engines[key].url.replaceAll('%s', this.keyword);
                  if (this.controller) {
                    this.controller.close();
                  }
                })
            },
            )
          }
          .padding(6.5)
          .borderRadius(13.5)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .width("100%")
          .animation(animation_default())

          Column(){
            Row() {
              linysShowButton({
                symbol_glyph_target: 'sys.symbol.plus_square',
                text: $r('app.string.AddSE_add_to_search_engines'),
                show: this.adding_SE
              })
                .onClick(() => {
                  this.adding_SE = !this.adding_SE;
                })
            } // Plus button
            .width("100%")
            .justifyContent(FlexAlign.End)

            Scroll() {
              Column({ space: 10 }) {
                Row({ space: 10 }) {
                  linysSymbol({ symbol_glyph_target: "sys.symbol.rename" })
                  TextInput({ text: this.label })
                    .onChange((value) => {
                      this.label = value;
                    })
                    .fontWeight(FontWeight.Regular)
                    .fontColor(this.color_current_font)
                    .caretColor(this.color_current_font)
                    .selectedBackgroundColor(this.color_current_font)
                    .layoutWeight(1)
                    .height(capsule_bar_height())

                } // Edit label
                .width("100%")

                Row({ space: 10 }) {
                  linysSymbol({ symbol_glyph_target: "sys.symbol.paperclip" })
                  TextArea({ text: this.link })
                    .onChange((value) => {
                      this.link = value;
                    })
                    .fontWeight(FontWeight.Regular)
                    .fontColor(this.color_current_font)
                    .caretColor(this.color_current_font)
                    .selectedBackgroundColor(this.color_current_font)
                    .layoutWeight(1)

                } // Edit content
                .width("100%")
                .animation(animation_default())

                Row() {
                  Blank()
                  linysCapsuleButton({ text: '  󰀓  ' })
                    .onClick(() => {
                      this.bunch_of_search_engines.add_search_engine(new search_engine(this.label, this.link));
                      this.bunch_of_settings.set('custom_search_engines', this.bunch_of_search_engines.export_string());
                      // if (this.controller) {
                      //   this.controller.close();
                      // }
                    })
                } // Confirm Button
                .width("100%")
              }
              .onAreaChange((_o, n) => {
                this.height_of_add_panel = n.height as number;
              })
            }
            .margin({ top: this.adding_SE ? 15 : 0 })
            .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })
            .edgeEffect(EdgeEffect.Spring)
            .height(this.adding_SE ? this.height_of_add_panel : 0)
            .animation(animation_default())
            .scrollBar(BarState.Off)
          }
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width("100%")
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .onAppear(() => {
        // Preserve the main title only
        this.label = this.label.replace(this.keyword, '');
        this.label = this.label.replace(/ ?[_-] ?/g, '');
      })
    }
  }

  on_SE_change() {
    console.log('[Meow][woofAddSE] Search Engine list change! Syncing data to Settings...')
    this.sync_list_of_search_engines();
  }

  sync_list_of_search_engines() {
    this.list_of_search_engines = this.bunch_of_search_engines.list_of_search_engines;
  }
}

export default woofAddSE;

@Component
struct meowSEButton {
  @Prop my_index: number;
  @StorageLink('bunch_of_search_engines') bunch_of_search_engines: bunch_of_search_engines =
    new bunch_of_search_engines();
  @State my_se: search_engine = this.bunch_of_search_engines.list_of_search_engines[this.my_index];
  @State my_label: string = this.my_se.label;
  @State my_content: string = this.my_se.url;
  // statuses
  button_height_default: number = 42;
  // UI effects
  @State height_of_text_area: number = 42;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Row() {
      Text(this.my_label)// Title
        .fontColor(this.color_current_font)
        .animation(animation_default())
        .fontSize(fontSize_Normal())
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
    }
    .padding(10)
    .borderRadius(7)
    .backgroundColor(this.color_current_primary)
    .animation(animation_default())
    .height(this.button_height_default)
    .width("100%")
    .animation(animation_default())
    .clickEffect(click_effect_default())
  }
}