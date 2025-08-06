import linysTextTitle from '../../components/texts/linysTextTitle';
import { bunch_of_downloads } from '../../hosts/bunch_of_downloads';
import { animation_default, animation_popup_duration, click_effect_default, minimum_card_width } from '../../hosts/bunch_of_defaults';
import { request } from '@kit.BasicServicesKit';
import linysText from '../../components/texts/linysText';
import { copy } from '../../utils/clipboard_tools';
import { add_units_to_size, get_download_uri } from '../../utils/storage_tools';
import linysShowButton from '../../components/buttons/linysShowButton';
import linysTimeoutButton from '../../components/buttons/linysTimeoutButton';
import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import { open_file_uri } from '../../utils/link_tools';
import linysCapsuleButtonWithText from '../../components/buttons/linysCapsuleButtonWithText';

@Component
struct meowDownloads {
  @StorageLink('bunch_of_downloads') @Watch('on_download_state_change') bunch_of_downloads: bunch_of_downloads =
    new bunch_of_downloads(true);
  @StorageLink('universal_new_download_gateway') @Watch('on_new_download') uni_new_download_gateway: string = "";
  @StorageLink('showing_downloads') showing_downloads: boolean = false;
  // Downloads
  @StorageLink('direct_download') direct_download: boolean = false;
  @Link screen_width: number;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 10 }) {
      Column({ space: 5 }) {
        linysTextTitle({
          text: $r('app.string.Downloads_notice_title')
        })
        linysText({
          text: $r('app.string.Downloads_notice_content'),
          max_lines: 20
        })
      }
      .visibility(this.direct_download ? Visibility.None : Visibility.Visible)
      .padding(15)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width("100%")
      .borderRadius(10)
      .backgroundColor(this.color_current_primary)
      .animation(animation_default())

      Column({ space: 5 }) {
        linysTextTitle({
          text: $r('app.string.Index_downloads_direct'),
          max_lines: 20
        })
          .width('100%')

        linysText({ text: $r('app.string.Index_downloads_direct_desc'), max_lines: 20 })
          .width('100%')

        linysCapsuleButtonWithText({
          desc_text: $r('app.string.Index_downloads_direct_desc_check'),
          button_text: '  󰃋  ',
          onExecution: async () => {
            open_file_uri(await get_download_uri());
          }
        })
          .width('100%')
      }
      .visibility(!this.direct_download ? Visibility.None : Visibility.Visible)
      .padding(15)
      .width("100%")
      .borderRadius(10)
      .backgroundColor(this.color_current_primary)
      .animation(animation_default())

      WaterFlow() {
        if (this.bunch_of_downloads.list_of_on_going_tasks.length == 0) {
          FlowItem() {
            linysTextTitle({
              text: "¯\\_(ツ)_/¯"
            })
              .alignRules({
                center: { anchor: "__container__", align: VerticalAlign.Center },
                middle: { anchor: "__container__", align: HorizontalAlign.Center },
              })
          }
          .opacity(0.5)
          .width("100%")
          .height("100%")
          .animation(animation_default())
        }

        ForEach(
          this.bunch_of_downloads.list_of_on_going_tasks,
          (_request_task: request.DownloadTask, key: number) => {
            meowDownloadCard({
              bunch_of_downloads: this.bunch_of_downloads,
              my_index: key,
            })
          },
        )
      }
      .columnsTemplate(this.bunch_of_downloads.list_of_on_going_tasks.length == 0 ? "1fr" : "1fr ".repeat(Math.ceil(this.screen_width / minimum_card_width())))
      .rowsGap(10)
      .columnsGap(10)
      .width("100%")
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
      .animation(animation_default())
      .onAppear(() => {
        // console.log("[Meow][meowDownloads] Downloads READY")
        this.on_appear();
      })
    }
    .height(this.showing_downloads ? "75%" : 0)
    .margin({ left: 15, right: 15 })
    .animation(animation_default())

  }

  on_appear() {
    this.bunch_of_downloads.delete_all_downloaded_files();
  }

  on_download_state_change() {

  }

  // Gateway

  on_new_download() {
    if (this.uni_new_download_gateway != "") {
      this.bunch_of_downloads.start_download_task(this.uni_new_download_gateway);
      this.uni_new_download_gateway = "";
    }
  }
}

export default meowDownloads

@Component
struct meowDownloadCard {
  @Prop my_index: number;
  @Link @Watch('update_progress') bunch_of_downloads: bunch_of_downloads;
  @StorageLink('showing_downloads') showing_downloads: boolean = false;
  // Statuses
  @State my_progress: number = 0;
  @State my_file_name: string = "";
  @State my_full_download_size: number = 0;
  @State my_current_download_size: number = 0;
  @State my_current_download_speed: number = 0;
  @State my_paused: boolean = false;
  @State my_link: string = "";
  @State my_additional_info: string[] = [];
  // Settings - Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Display info
  @State formatted_download_progress: string = "／";
  @State formatted_download_percentage: string = "%";
  // UI Effects
  @State y_off_set: number = 50;
  @State visible: Visibility = Visibility.Hidden;
  @State exporting: boolean = false;
  @State copied: number = 0;
  @State showing_additional_info: boolean = false;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    FlowItem() {
      Column({ space: 15 }) {
        linysTextTitle({
          text: '[' + this.formatted_download_percentage + '] ' + this.my_file_name,
          max_lines: 4,
        }) // File name

        Row({ space: 10 }) {
          linysText({
            text: this.my_link,
            max_lines: 4,
          })// File link
            .clickEffect(click_effect_default())
            .onClick(() => {
              copy(this.my_link);
              this.copied = animation_popup_duration();
            })
            .opacity(0.85)
            .layoutWeight(1)

          linysTextTitle({
            text: $r('app.string.Downloads_copied'),
          })// Copied!
            .offset({ x: this.copied > 0 ? 0 : 50 })
            .opacity(0.85)
            .visibility(this.copied > 0 ? Visibility.Visible : Visibility.Hidden)
            .animation(animation_default())
        }
        .visibility(!this.showing_additional_info ? Visibility.Visible : Visibility.None)
        // .alignItems(HorizontalAlign.Start)
        .animation(animation_default())

        additionalInfoDisplay({
          my_additional_info: this.my_additional_info
        })
          .visibility(this.showing_additional_info ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

        Scroll() {
          Row({ space: 8 }) {
            linysText({
              text: add_units_to_size(this.my_current_download_speed) + '/s',
            })// Speed
              .borderRadius(10)
              .padding(10)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .clickEffect(click_effect_default())
            // linysText({
            //   text: this.formatted_download_percentage,
            // }) // Percentage
            //   .borderRadius(10)
            //   .padding(10)
            //   .backgroundColor($r('sys.color.comp_background_tertiary'))
            //   .clickEffect(click_effect_default())
            linysText({
              text: this.formatted_download_progress,
            })// Progress
              .borderRadius(10)
              .padding(10)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .clickEffect(click_effect_default())
          } // Status
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .scrollable(ScrollDirection.Horizontal)

        Row({ space: 10 }) {
          linysShowButton({
            symbol_glyph_target: 'sys.symbol.info_circle',
            show: this.showing_additional_info,
            text: $r('app.string.Index_downloads_additional_info')
          })
            .onClick(() => {
              this.showing_additional_info = !this.showing_additional_info;
            })

          linysTimeoutButton({
            text: "  󰀁  ",
            onExecution: () => {
              this.delete_task();
            }
          })
            .enabled(!this.exporting)

          linysCapsuleButton({
            text: this.my_paused ? "  󰂴  " : "  󰂱  ",
          })// Pause continue
            .onClick(() => {
              this.pause_or_continue_task();
            })
            .enabled(!this.exporting)
            .visibility(this.formatted_download_percentage == "100%" ? Visibility.None : Visibility.Visible)
            .animation(animation_default())

          linysCapsuleButton({
            text: "  󰀻  "
          })// Save
            .onClick(() => {
              this.exporting = true;
              this.export_file();
            })
            .enabled(!this.exporting)
            .visibility(this.formatted_download_percentage == "100%" ? Visibility.Visible : Visibility.None)
            .animation(animation_default())

        } // Control Buttons
        .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
        .animation(animation_default())
        .width("100%")
      }
      .padding(15)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width("100%")
      .borderRadius(10)
      .backgroundColor(this.color_current_primary)
      .visibility(this.visible)
      .offset({ y: this.y_off_set })
      .animation(animation_default())
      .clip(true)
    } // Start up
    .width("100%")
    .onAppear(async () => {
      // Init download information
      this.update_progress();
      setTimeout(() => {
        this.y_off_set = 0;
        this.visible = Visibility.Visible;
        // Animation
      }, 10)

      setInterval(() => {
        // Reset copy
        if (this.copied > 0) {
          this.copied -= 10;
        }
      }, 10)
    })
  }

  async update_progress() {
    // console.log('[meowDownloads] update_progress');

    this.my_file_name = this.bunch_of_downloads.list_of_file_names[this.my_index];
    this.my_full_download_size = this.bunch_of_downloads.list_of_full_size[this.my_index];
    this.my_current_download_size = this.bunch_of_downloads.list_of_downloaded_size[this.my_index];
    this.my_current_download_speed = this.bunch_of_downloads.list_of_download_speed[this.my_index];
    this.my_progress = Number.parseFloat((this.my_current_download_size / this.my_full_download_size * 100).toFixed(2));
    this.my_paused = this.bunch_of_downloads.list_of_paused[this.my_index];
    this.my_link = this.bunch_of_downloads.list_of_urls[this.my_index];
    this.my_additional_info = this.bunch_of_downloads.list_of_additional_info[this.my_index];

    this.set_formatted_download_progress();
    this.set_formatted_download_percentage();
  }

  pause_or_continue_task() {
    if (this.my_paused) {
      this.bunch_of_downloads.continue_task(this.my_index);
    } else {
      this.bunch_of_downloads.pause_task(this.my_index);
    }
  }

  delete_task() {
    // Delete
    this.bunch_of_downloads.delete_task(this.my_index);
    if (this.bunch_of_downloads.list_of_on_going_tasks.length == 0) {
      this.showing_downloads = false;
    }
  }

  export_file() {
    this.bunch_of_downloads.save_downloaded_item_to_local(this.my_index).then(() => {
      this.exporting = false;
    })
    // this.bunch_of_downloads.save_downloaded_item_to_download(this.my_index).then((uri_back) => {
    //   this.exporting = false;
    //   if (uri_back) {
    //     open_file_uri(uri_back);
    //   }
    // })
  }

  private set_formatted_download_progress() {
    let downloaded: string = add_units_to_size(this.my_current_download_size);
    let total: string = add_units_to_size(this.my_full_download_size);

    if (this.my_full_download_size == -1) {
      // Undefined end
      this.formatted_download_progress = downloaded;
    } else {
      // Defined end
      this.formatted_download_progress = downloaded + " / " + total;
    }
  }

  private set_formatted_download_percentage() {
    if (this.my_full_download_size == -1) {
      this.formatted_download_percentage = "¯\\_(ツ)_/¯";
    } else {
      this.formatted_download_percentage = this.my_progress.toString() + "%";
    }
  }
}

@Component
struct additionalInfoDisplay {
  @Prop my_additional_info: string[];

  build() {
    Scroll() {
      Column({ space: 4 }) {
        ForEach(this.my_additional_info, (info: string, _index: number) => {
          linysText({ text: info })
            .opacity(0.7)
        }) // additional info
      }
      .margin({ bottom: 15 })
      .alignItems(HorizontalAlign.Start)
    }
    .scrollBar(BarState.On)
    .scrollable(ScrollDirection.Horizontal)
    .edgeEffect(EdgeEffect.Spring)
  }
}