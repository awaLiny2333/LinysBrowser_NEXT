import linysTitleText from '../components/linysTitleText';
import { bunch_of_downloads } from '../hosts/bunch_of_downloads';
import {
  animation_default,
  animation_popup_duration,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large,
  minimum_block_width
} from '../hosts/bunch_of_defaults';
import { request } from '@kit.BasicServicesKit';
import linysText from '../components/linysText';
import { copy } from '../utils/clipboard_tools';

@Component
struct meowDownloads {
  @StorageLink('bunch_of_downloads') @Watch('on_download_state_change') bunch_of_downloads: bunch_of_downloads =
    new bunch_of_downloads();
  @StorageLink('universal_new_download_gateway') @Watch('on_new_download') uni_new_download_gateway: string = "";
  @Link showing_downloads: boolean;
  @Link screen_width: number;

  build() {
    Column({ space: 10 }) {
      Column({ space: 5 }) {
        linysTitleText({
          text: $r('app.string.Downloads_notice_title')
        })
        linysText({
          text: $r('app.string.Downloads_notice_content'),
          max_lines: 5
        })
      }
      .padding(15)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width("100%")
      .borderRadius(10)
      .backgroundColor($r('app.color.start_window_background'))
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
          // .visibility(this.bunch_of_downloads.list_of_on_going_tasks.length == 0 ? Visibility.Visible : Visibility.None)
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
        "1fr" : "1fr ".repeat(Math.ceil(this.screen_width / minimum_block_width())))
      .rowsGap(10)
      .columnsGap(10)
      .width("100%")
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
      .animation(animation_default())
      .onAppear(() => {
        console.log("[Meow][meowDownloads] Downloads READY")
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

  on_new_download() {
    if (!(this.uni_new_download_gateway == "")) {
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
  // Display info
  @State formatted_download_progress: string = "／";
  @State formatted_download_percentage: string = "%";
  // UI Effects
  @State y_off_set: number = 50;
  @State visible: Visibility = Visibility.Hidden;
  @State exporting: boolean = false;
  @State delete_confirm: number = 0;
  @State copied: number = 0;

  build() {
    FlowItem() {
      Column({ space: 15 }) {
        linysTitleText({
          text: this.my_file_name,
          max_lines: 4,
        }) // File name

        linysText({
          text: this.my_link,
          max_lines: 4,
        })// FIle link
          .clickEffect(click_effect_default())
          .onClick(() => {
            copy(this.my_link);
            this.copied = animation_popup_duration();
          })
          .opacity(0.7)

        linysText({
          text: $r('app.string.Downloads_copied'),
        })
          .offset({ y: this.copied > 0 ? -5 : -50 })
          .opacity(0.7)
          .visibility(this.copied > 0 ? Visibility.Visible : Visibility.None)
          .animation(animation_default())

        Row({ space: 5 }) {
          linysText({
            text: this.formatted_download_percentage,
          })

          linysText({
            text: this.formatted_download_progress,
          })
        } // Progress

        Row({ space: 10 }) {
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
              this.delete_task()
            })
            .enabled(!this.exporting)
            .clickEffect(click_effect_default())
            .animation(animation_default())

          Button(this.my_paused ? "  󰂴  " : "  󰂱  ")// Pause Continue
            .type(ButtonType.Capsule)
            .backgroundColor($r("app.color.font_color_title"))
            .fontColor($r('app.color.start_window_background'))
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
            .fontColor($r('app.color.start_window_background'))
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
        .width("100%")
      }
      .padding(15)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width("100%")
      .borderRadius(10)
      .backgroundColor($r('app.color.start_window_background'))
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
        if (this.delete_confirm > 0) {
          this.delete_confirm -= 1;
        }
        // Reset delete confirm
        if (this.copied > 0) {
          this.copied -= 1;
        }
        // Reset copy
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
    this.delete_confirm += 300;
    if (this.delete_confirm >= 301) {
      // Delete
      this.bunch_of_downloads.delete_task(this.my_index);
    }
  }

  export_file() {
    this.bunch_of_downloads.save_downloaded_item_to_local(this.my_index).then(() => {
      this.exporting = false;
    })
  }

  private set_formatted_download_progress() {
    let downloaded: string = "";
    let total: string = "";

    if (this.my_current_download_size > 1000 * 1000) {
      downloaded = (this.my_current_download_size / 1000 / 1000).toFixed(3) + " MB"
    } else {
      downloaded = (this.my_current_download_size / 1000).toFixed(3) + " KB"
    }

    if (this.my_full_download_size > 1000 * 1000) {
      total = (this.my_full_download_size / 1000 / 1000).toFixed(3) + " MB"
    } else {
      total = (this.my_full_download_size / 1000).toFixed(3) + " KB"
    }

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