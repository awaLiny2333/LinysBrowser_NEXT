import linysTitleText from '../../components/linysTitleText';
import { bunch_of_downloads } from '../../hosts/bunch_of_downloads';
import {
  animation_default,
  animation_popup_duration,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large,
  minimum_card_width
} from '../../hosts/bunch_of_defaults';
import { request } from '@kit.BasicServicesKit';
import linysText from '../../components/linysText';
import { copy } from '../../utils/clipboard_tools';
import { add_units_to_size } from '../../utils/storage_tools';
import linysShowButton from '../../components/linysShowButton';
import linysTimeoutButton from '../../components/linysTimeoutButton';

@Component
struct meowDownloads {
  @StorageLink('bunch_of_downloads') @Watch('on_download_state_change') bunch_of_downloads: bunch_of_downloads =
    new bunch_of_downloads(true);
  @StorageLink('universal_new_download_gateway') @Watch('on_new_download') uni_new_download_gateway: string = "";
  @StorageLink('showing_downloads') showing_downloads: boolean = false;
  @Link screen_width: number;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 10 }) {
      Column({ space: 5 }) {
        linysTitleText({
          text: $r('app.string.Downloads_notice_title')
        })
        linysText({
          text: $r('app.string.Downloads_notice_content'),
          max_lines: 20
        })
      }
      .padding(15)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width("100%")
      .borderRadius(10)
      .backgroundColor(this.color_current_primary)
      .animation(animation_default())

      WaterFlow() {
        if (this.bunch_of_downloads.list_of_on_going_tasks.length == 0) {
          FlowItem() {
            linysTitleText({
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
            meowDownloadsButton({
              bunch_of_downloads: this.bunch_of_downloads,
              my_index: key,
            })
          },
        )
      }
      .columnsTemplate(this.bunch_of_downloads.list_of_on_going_tasks.length == 0 ?
        "1fr" : "1fr ".repeat(Math.ceil(this.screen_width / minimum_card_width())))
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
struct meowDownloadsButton {
  @Prop my_index: number;
  @Link @Watch('update_progress') bunch_of_downloads: bunch_of_downloads;
  // Statuses
  @State my_progress: number = 0;
  @State my_file_name: string = "";
  @State my_full_download_size: number = 0;
  @State my_current_download_size: number = 0;
  @State my_paused: boolean = false;
  @State my_link: string = "";
  @State my_additional_info: string[] = [];
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
        linysTitleText({
          text: this.my_file_name,
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

          linysTitleText({
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

        Row({ space: 5 }) {
          linysText({
            text: this.formatted_download_percentage,
          }) // Percentage
          linysText({
            text: this.formatted_download_progress,
          }) // Progress
        } // Progress

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

          Button(this.my_paused ? "  󰂴  " : "  󰂱  ")// Pause Continue
            .type(ButtonType.Capsule)
            .backgroundColor($r("app.color.font_color_title"))
            .fontColor(this.color_current_primary)
            .fontSize(fontSize_Large())
            .fontWeight(FontWeight.Medium)
            .height(capsule_bar_height())
            .onClick(() => {
              this.pause_or_continue_task();
            })
            .clickEffect(click_effect_default())
            .enabled(!this.exporting)
            .visibility(this.formatted_download_percentage == "100%" ? Visibility.None : Visibility.Visible)
            .animation(animation_default())

          Button("  󰀻  ")// Save
            .type(ButtonType.Capsule)
            .backgroundColor($r("app.color.font_color_title"))
            .fontColor(this.color_current_primary)
            .fontSize(fontSize_Large())
            .fontWeight(FontWeight.Medium)
            .height(capsule_bar_height())
            .onClick(() => {
              this.exporting = true;
              this.export_file();
            })
            .enabled(!this.exporting)
            .clickEffect(click_effect_default())
            .visibility(this.formatted_download_percentage == "100%" ? Visibility.Visible : Visibility.None)
            .animation(animation_default())
        } // Control Buttons
        .justifyContent(FlexAlign.End)
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
    this.my_file_name = this.bunch_of_downloads.list_of_file_names[this.my_index];
    this.my_full_download_size = this.bunch_of_downloads.list_of_full_size[this.my_index];
    this.my_current_download_size = this.bunch_of_downloads.list_of_downloaded_size[this.my_index];
    this.my_progress = Number.parseFloat((this.my_current_download_size / this.my_full_download_size * 100).toFixed(2));
    this.my_paused = this.bunch_of_downloads.list_of_paused[this.my_index];
    this.my_link = this.bunch_of_downloads.list_of_urls[this.my_index];
    this.my_additional_info = this.bunch_of_downloads.list_of_additional_info[this.my_index];

    this.set_formatted_download_progress();
    this.set_formatted_download_percentage();
  }

  pause_or_continue_task() {
    if (this.my_paused) {
      this.bunch_of_downloads.continue_task(this.my_index)
    } else {
      this.bunch_of_downloads.pause_task(this.my_index)
    }
  }

  delete_task() {
    // Delete
    this.bunch_of_downloads.delete_task(this.my_index);
  }

  export_file() {
    this.bunch_of_downloads.save_downloaded_item_to_local(this.my_index).then(() => {
      this.exporting = false;
    })
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