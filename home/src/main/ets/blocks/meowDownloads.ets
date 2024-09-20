import linysTitleText from '../components/linysTitleText';
import { bunch_of_downloads } from '../hosts/bunch_of_downloads';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large
} from '../hosts/bunch_of_settings';
import { request } from '@kit.BasicServicesKit';
import linysText from '../components/linysText';

@Component
struct meowDownloads {
  @Link @Watch('on_download_state_change') bunch_of_downloads: bunch_of_downloads;
  @Link showing_downloads: boolean;
  @Link screen_width: number;

  build() {
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
        (item: request.DownloadTask, key: number) => {
          meowDownloadsButton({
            bunch_of_downloads: this.bunch_of_downloads,
            my_index: key,
          })
        },
      )
    }
    .columnsTemplate(this.bunch_of_downloads.list_of_on_going_tasks.length == 0 ?
      "1fr" : "1fr ".repeat(Math.ceil(this.screen_width / 430)))
    .rowsGap(10)
    .columnsGap(10)
    .height(this.showing_downloads ? "75%" : 0)
    .padding({ left: 15, right: 15 })
    .width("100%")
    .edgeEffect(EdgeEffect.Spring)
    .animation(animation_default())
    .onAppear(() => {
      console.log("[Meow][meowDownloads] Downloads READY")
      this.on_appear();
    })
  }

  on_appear() {
    this.bunch_of_downloads.delete_all_downloaded_files();
  }

  on_download_state_change() {

  }
}

export default meowDownloads

@Component
struct meowDownloadsButton {
  @Prop my_index: number;
  @Link @Watch('update_progress') bunch_of_downloads: bunch_of_downloads;
  @State my_progress: number = 0;
  @State my_file_name: string = "";
  @State my_full_download_size: number = 0;
  @State my_current_download_size: number = 0;
  @State my_paused: boolean = false;
  @State formatted_download_progress: string = "／";
  @State formatted_download_percentage: string = "%";

  build() {
    FlowItem() {
      Column({ space: 15 }) {
        linysTitleText({
          text: this.my_file_name,
        })
        Row({ space: 5 }) {
          linysText({
            text: this.formatted_download_percentage,
          })

          linysText({
            text: this.formatted_download_progress,
          })
        }

        Row({ space: 10 }) {
          Blank()
          Button(this.my_paused ? "  󰂴  " : "  󰂱  ")// Pause Continue
            .type(ButtonType.Capsule)
            .backgroundColor($r("app.color.font_color_title"))
            .fontColor($r('app.color.start_window_background'))
            .fontSize(fontSize_Large())
            .fontWeight(FontWeight.Medium)
            .height(capsule_bar_height())
            .onClick(() => {
              this.pause_or_continue();
            })
            .clickEffect(click_effect_default())
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
              this.export_file();
            })
            .clickEffect(click_effect_default())
            .visibility(this.formatted_download_percentage == "100%" ? Visibility.Visible : Visibility.None)
            .animation(animation_default())
        }
        .width("100%")
      }
      .padding(15)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width("100%")
      .borderRadius(10)
      .backgroundColor($r('app.color.start_window_background'))
    } // Start up
    .width("100%")
    .onAppear(async () => {
      // Init download information
      this.update_progress();
    })
  }

  export_file() {
    this.bunch_of_downloads.save_downloaded_item_to_local(this.my_index);
  }

  async update_progress() {
    this.my_file_name = this.bunch_of_downloads.list_of_file_names[this.my_index];
    this.my_full_download_size = this.bunch_of_downloads.list_of_full_size[this.my_index];
    this.my_current_download_size = this.bunch_of_downloads.list_of_downloaded_size[this.my_index];
    this.my_progress = Number.parseFloat((this.my_current_download_size / this.my_full_download_size * 100).toFixed(2));
    this.my_paused = this.bunch_of_downloads.list_of_paused[this.my_index];

    this.set_formatted_download_progress();
    this.set_formatted_download_percentage();
  }

  pause_or_continue() {
    if (this.my_paused) {
      this.bunch_of_downloads.continue_task(this.my_index)
    } else {
      this.bunch_of_downloads.pause_task(this.my_index)
    }
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
      this.formatted_download_progress = downloaded + "/" + total;
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