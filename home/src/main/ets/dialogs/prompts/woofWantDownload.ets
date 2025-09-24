import linysCapsuleButton from '../../components/buttons/linysCapsuleButton';
import linysShowButton from '../../components/buttons/linysShowButton';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import { animation_default, capsule_bar_height } from '../../hosts/bunch_of_defaults';
import { is_legal_filename } from '../../utils/storage_tools';
import { webview } from '@kit.ArkWeb';
import { bunch_of_downloads } from '../../hosts/bunch_of_downloads';
import { meowContext } from '../../utils/environment_tools';
import { fileIo } from '@kit.CoreFileKit';

@CustomDialog
struct woofWantDownload {
  controller: CustomDialogController;
  @State from: string = '';
  @State file_name: string = '';
  @State url: string = '';
  @State try_additional_info: string[] = [];
  @State item: webview.WebDownloadItem | undefined = undefined;
  // Params
  @State file_dir: string = '';
  @State download_target_path: string = '';
  // UI
  @State showing_additional_info: boolean = false;
  @State showing_illegal_chars: boolean = false;
  // Hosts
  @StorageLink('bunch_of_downloads') bunch_of_downloads: bunch_of_downloads = new bunch_of_downloads(true);
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';

  build() {
    Column({ space: 15 }) {
      linysTextTitle({ text: $r('app.string.Index_downloads_prompt') })// prompt
        .width("100%")

      linysText({ text: this.from, max_lines: 10 })// from website
        .width("100%")
        .opacity(0.9)
        .visibility(!this.showing_additional_info ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      additionalInfoDisplay({
        my_additional_info: this.try_additional_info
      })
        .visibility(this.showing_additional_info ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      linysText({ text: $r('app.string.Index_downloads_illegal_chars_in_filename'), max_lines: 3 }) // File name error prompt
        .visibility(!is_legal_filename(this.file_name) ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      TextInput({ text: this.file_name })// Edit file name
        .onSubmit(() => {
          if (is_legal_filename(this.file_name)) {
            this.submit();
          }
        })
        .onChange((value) => {
          this.file_name = value;
        })
        .fontWeight(FontWeight.Regular)
        .fontColor(this.color_current_font)
        .caretColor(this.color_current_font)
        .selectedBackgroundColor(this.color_current_font)
        .height(capsule_bar_height())

      Row({ space: 10 }) {
        linysShowButton({
          symbol_glyph_target: 'sys.symbol.info_circle',
          show: this.showing_additional_info,
          text: $r('app.string.Index_downloads_additional_info')
        })
          .onClick(() => {
            this.showing_additional_info = !this.showing_additional_info;
          })
        linysCapsuleButton({ text: "  󰁖  " })// Cancel
          .onClick(() => {
            if (this.controller) {
              this.controller.close();
            }
          })
        linysCapsuleButton({ text: "  󰀓  " })// Submit
          .onClick(() => {
            if (is_legal_filename(this.file_name)) {
              this.submit();
            }
          })
          .opacity(is_legal_filename(this.file_name) ? 1 : 0.7)
      } // Edit
      .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
      .animation(animation_default())
      .width('100%')
    }
    .padding(20)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .backgroundColor(this.color_current_primary)
  }

  submit() {
    // LINK START!
    if (this.item) {
      // Register on download start
      this.bunch_of_downloads.list_of_on_going_tasks.push(this.item);
      this.bunch_of_downloads.list_of_downloaded_size.push(0);
      this.bunch_of_downloads.list_of_download_speed.push(0);
      this.bunch_of_downloads.list_of_full_size.push(-1);
      this.bunch_of_downloads.list_of_paused.push(false);
      this.bunch_of_downloads.list_of_completed.push(false);
      this.bunch_of_downloads.list_of_additional_info.push(this.try_additional_info);
      this.bunch_of_downloads.list_of_target_folders.push(this.file_dir);
      this.bunch_of_downloads.list_of_file_names.push(this.file_name);
      this.bunch_of_downloads.list_of_urls.push(this.item.getUrl());
      this.bunch_of_downloads.list_of_failed.push(false);
      // this.list_of_urls.push('url');

      try {
        this.item.start(this.download_target_path);
        AppStorage.set('uni_webDownloadItem_gateway', undefined);
      } catch (e) {
        console.error(e);
        return;
      }
      console.log('[bunch_of_downloads] dl_delegate.onBeforeDownload! download_target_path: [' + this.download_target_path + ']')
    }

    // Goodbye
    if (this.controller) {
      this.bunch_of_downloads.update_timestamp();
      this.controller.close();
    }
  }
}

export default woofWantDownload;

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