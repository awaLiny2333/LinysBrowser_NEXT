import linysCapsuleButton from '../components/linysCapsuleButton';
import linysShowButton from '../components/linysShowButton';
import linysText from '../components/linysText';
import linysTitleText from '../components/linysTitleText';
import { animation_default, capsule_bar_height } from '../hosts/bunch_of_defaults';

@CustomDialog
struct woofWantDownload {
  controller: CustomDialogController;
  @State from: string = '';
  @State file_name: string = '';
  @State url: string = '';
  @State try_additional_info: string = '';
  // UI
  @State showing_additional_info: boolean = false;
  // Gateways
  @StorageLink('universal_new_download_filename_gateway') new_download_filename_gateway: string = "";
  @StorageLink('universal_new_download_additional_info') new_download_additional_info: string = "";
  @StorageLink('universal_new_download_gateway') new_download_gateway: string = "";
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');

  build() {
    Column({ space: 15 }) {
      linysTitleText({ text: $r('app.string.Index_downloads_prompt') })// prompt
        .width("100%")

      linysText({ text: this.from, max_lines: 10 })// from website
        .width("100%")
        .opacity(0.9)
        .visibility(!this.showing_additional_info ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      additionalInfoDisplay({
        my_additional_info: this.try_additional_info.split('\n')
      })
        .visibility(this.showing_additional_info ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      TextInput({ text: this.file_name })// Edit file name
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
        linysCapsuleButton({ text: "  󰁖  " })
          .onClick(() => {
            if (this.controller) {
              this.controller.close();
            }
          })
        linysCapsuleButton({ text: "  󰀓  " })
          .onClick(() => {
            this.submit();
          })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
    }
    .padding(20)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .backgroundColor(this.color_current_primary)
  }

  submit() {
    // Assigned file name overwrite
    this.new_download_filename_gateway = this.file_name;

    // Assign additional info
    this.new_download_additional_info = this.try_additional_info;

    // LINK START!
    this.new_download_gateway = this.url;

    // Goodbye
    if (this.controller) {
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