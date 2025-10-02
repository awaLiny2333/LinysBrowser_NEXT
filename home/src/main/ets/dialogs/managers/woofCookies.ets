import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { animation_default, click_effect_default } from '../../hosts/bunch_of_defaults';
import { webview } from '@kit.ArkWeb';
import { match_domain } from '../../utils/url_tools';
import woofControlFrame from '../woofControlFrame';
import linysTimeoutButtonWithText from '../../components/buttons/linysTimeoutButtonWithText';
import linysSymbol from '../../components/texts/linysSymbol';

@CustomDialog
struct woofCookies {
  controller: CustomDialogController;
  // Environment
  @StorageProp('tablet_mode') tablet_mode: boolean = false;
  @StorageProp('current_url') current_url: string = "=￣ω￣=";
  @State domain_url: string = this.get_domain_url(this.current_url);
  // UI
  @State full_view: boolean = false;
  // Interfaces
  @State cookies_site: string[] = this.get_cookies_site();
  // alignRules
  alignRules_head_non_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    left: { anchor: "__container__", align: HorizontalAlign.Start },
  };
  alignRules_head_tablet: AlignRuleOption = {
    top: { anchor: "__container__", align: VerticalAlign.Top },
    bottom: { anchor: "controls_cookies", align: VerticalAlign.Top },
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
    top: { anchor: "title_cookies_manager", align: VerticalAlign.Bottom },
    bottom: { anchor: "controls_cookies", align: VerticalAlign.Top },
    right: { anchor: "__container__", align: HorizontalAlign.End }
  };
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    woofControlFrame({
      title: $r('app.string.Settings_manage_cookies'),
      controller: this.controller
    }) {
      RelativeContainer() {
        Scroll() {
          Column({ space: 10 }) {
            linysText({
              text: $r('app.string.Settings_manage_cookies_desc_1'),
              max_lines: 10
            })
              .width("100%")
            linysText({
              text: $r('app.string.Settings_manage_cookies_desc_2'),
              max_lines: 10
            })
              .width("100%")
            linysText({
              text: $r('app.string.Settings_manage_cookies_desc_3'),
              max_lines: 10
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
        } // Title
        .align(Alignment.TopStart)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ bottom: 10, right: 10 })
        .width(this.tablet_mode ? (this.full_view ? "0%" : "40%") : "100%")
        .alignRules(this.tablet_mode ? this.alignRules_head_tablet : this.alignRules_head_non_tablet)
        .clip(true)
        .enabled(!this.full_view)
        .opacity(this.full_view ? 0 : 1)
        .height(this.full_view && !this.tablet_mode ? 0 : undefined)
        .animation(animation_default())
        .constraintSize(this.tablet_mode ? {} : { maxHeight: '35%' })
        .id("title_cookies_manager")

        Column() {
          Row({ space: 10 }) {
            linysText({ text: $r('app.string.Settings_manage_cookies_this_site'), max_lines: 3 })// Cookies on
              .width("100%")
              .padding({ top: this.tablet_mode ? 0 : 10, bottom: 5 })
              .layoutWeight(1)

            linysSymbol({
              symbol_glyph_target: this.full_view ?
                'sys.symbol.arrow_down_right_and_arrow_up_left' :
                'sys.symbol.arrow_up_left_and_arrow_down_right'
            })
              .onClick(() => {
                this.full_view = !this.full_view
              })
          }.width('100%')

          linysText({ text: this.domain_url })// domain
            .width("100%")
            .padding({ bottom: 10 })

          Scroll() {
            Column() {
              ForEach(this.cookies_site, (item: string, index: number) => {
                Cookie({
                  text: item,
                  index: index,
                })
                  .width("100%")
              })
              if (this.cookies_site.length == 0) {
                linysTextTitle({
                  text: "¯\\_(ツ)_/¯"
                })
                  .margin(30)
                  .opacity(0.7)
                  .animation(animation_default())
              }
            }
            .width("100%")
          } // cookies display list
          .scrollable(ScrollDirection.Vertical)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.Top)
          .borderRadius(10)
          .backgroundColor(this.color_current_secondary)
          .width("100%")
          .layoutWeight(1)
        } // Cookies
        .width(this.tablet_mode ? (this.full_view ? "100%" : "60%") : "100%")
        .height(this.tablet_mode ? "100%" : undefined)
        .alignRules(this.tablet_mode ? this.alignRules_body_tablet : this.alignRules_body_non_tablet)
        .animation(animation_default())

        Column({ space: 10 }) {
          linysText({ text: $r('app.string.Settings_manage_cookies_clear_all'), max_lines: 5 })
            .width('100%')

          linysTimeoutButtonWithText({
            desc_text: '＞︿＜',
            button_text: '  󰀁  ',
            onExecution: () => {
              this.clear_all_cookies();
            }
          }) // Delete

        } // Controls
        .margin({ top: 15 })
        .padding(this.tablet_mode ? { right: 10 } : undefined)
        .alignItems(HorizontalAlign.End)
        .alignRules(this.alignRules_foot)
        .visibility(this.full_view ? Visibility.None : Visibility.Visible)
        .animation(animation_default())
        .width(this.tablet_mode ? "40%" : "100%")
        .id("controls_cookies")
      }.layoutWeight(1)
    }
  }

  clear_all_cookies() {
    webview.WebCookieManager.clearAllCookiesSync();
    webview.WebCookieManager.saveCookieAsync();
    this.refresh_site_cookies_list();
  }

  refresh_site_cookies_list() {
    this.cookies_site = this.get_cookies_site();
  }

  get_cookies_site() {
    let list = webview.WebCookieManager.fetchCookieSync(this.domain_url).split('; ');
    if (list[list.length-1] == '') {
      list = list.slice(0, list.length - 1);
    }
    return list;
  }

  get_domain_url(url: string) {
    let match_domain_result = match_domain(url);
    return match_domain_result[0] + '://' + match_domain_result[1];
  }
}

export default woofCookies;

@Component
struct Cookie {
  @State text: string = "qwq";
  @Prop index: number;
  // Color
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column() {
      linysText({
        text: this.text,
        max_lines: 25
      })
    }
    .padding({
      left: 10,
      right: 10,
      top: 5,
      bottom: 5
    })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.color_current_secondary)
    .animation(animation_default())
    .clickEffect(click_effect_default())
    .width("100%")
  }
}