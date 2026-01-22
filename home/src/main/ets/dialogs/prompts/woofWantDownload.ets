import linysShowButton from '../../components/buttons/linysShowButton';
import linysText from '../../components/texts/linysText';
import linysTextTitle from '../../components/texts/linysTextTitle';
import linysConfirmDenyButtons from '../../components/buttons/linysConfirmDenyButtons';
import { animation_default, capsule_bar_height, click_effect_default } from '../../hosts/bunch_of_defaults';
import { is_legal_filename } from '../../utils/storage_tools';
import { bunch_of_downloads } from '../../hosts/bunch_of_downloads';
import { meowContext } from '../../utils/environment_tools';
import { storage_of_id } from '../../utils/ui_tools';
import lazy { fileIo } from '@kit.CoreFileKit';
import lazy { webview } from '@kit.ArkWeb';
import linysFileNameErrorDisplay from '../../components/linysFileNameErrorDisplay';
import { copy } from '../../utils/clipboard_tools';

@CustomDialog
struct woofWantDownload {
  controller: CustomDialogController;
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  @State from: string = ''; // @Param
  @State @Watch('refresh') file_name: string = ''; // @Param
  @State url: string = ''; // @Param
  @State try_additional_info: string[] = []; // @Param
  @State item: webview.WebDownloadItem | undefined = undefined; // @Param
  @State error_code: number = 0;
  // Params
  @State file_dir: string = '';
  @State download_target_path: string = '';
  // UI
  @State showing_additional_info: boolean = false;
  // Hosts
  @StorageLink('bunch_of_downloads') bunch_of_downloads: bunch_of_downloads = new bunch_of_downloads();
  // Colors
  @StorageLink('effects') effects: boolean = false;
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';
  // Count
  @LocalStorageLink('opened_dialog_controllers') opened_dialog_controllers: CustomDialogController[] = [];
  viewable_contents: string[] = [
    'text/html',
    'application/xhtml+xml',
    'application/xml',
    'text/xml'
  ];

  aboutToAppear(): void {
    this.refresh();
    this.opened_dialog_controllers.push(this.controller);
    console.log(`[Dialog][Open] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  aboutToDisappear(): void {
    this.opened_dialog_controllers.splice(this.opened_dialog_controllers.indexOf(this.controller), 1);
    console.log(`[Dialog][Close] Now dialog count: ${this.opened_dialog_controllers.length}!`);
  }

  build() {
    Column({ space: 12 }) {
      linysTextTitle({ text: $r('app.string.Index_downloads_prompt') })// prompt
        .width("100%")

      linysText({ text: this.from, max_lines: 10, can_hover: true }) // from website // TODO: This is technically with flaw
        .width("100%")
        .opacity(0.9)
        .visibility(!this.showing_additional_info ? Visibility.Visible : Visibility.None)
        .animation(animation_default())
        .clickEffect(click_effect_default())
        .onClick(() => {
          copy(this.from);
        })
        .translate({ x: -5 })

      additionalInfoDisplay({
        my_additional_info: this.try_additional_info
      })
        .visibility(this.showing_additional_info ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      linysFileNameErrorDisplay({ file_name: this.file_name, error_code: this.error_code });

      TextInput({ text: this.file_name }) // Edit file name
        .onSubmit(() => {
          if (this.error_code == 0) {
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
        .id('woofWantDownload_TextInput_filename')
        .onAppear(() => {
          // Focus to TextInput if is free window mode
          let free_window = AppStorage.get('free_window_mode') as boolean;
          if (free_window) {
            focusControl.requestFocus('woofWantDownload_TextInput_filename');
          }
        })
        .keyboardAppearance(KeyboardAppearance.IMMERSIVE)

      Row({ space: 10 }) {
        linysShowButton({
          symbol_glyph_target: 'sys.symbol.info_circle',
          show: this.showing_additional_info,
          show_margin: { left: 0, right: 5 },
          text: $r('app.string.Index_downloads_additional_info')
        })// Info
          .onClick(() => {
            this.showing_additional_info = !this.showing_additional_info;
          })

        linysConfirmDenyButtons({
          confirm_enabled: this.error_code == 0,
          onConfirm: () => {
            if (this.error_code == 0) {
              this.submit();
            }
          },
          onDeny: () => {
            if (this.controller) {
              this.controller.close();
            }
          }
        }) // Confirm deny buttons
          .layoutWeight(1)

      } // Control
      .justifyContent(this.preferred_hand_left_or_right == 'right' ? FlexAlign.End : FlexAlign.Start)
      .animation(animation_default())
      .width('100%')

      if (this.is_viewable()) {
        Row() {
          linysText({
            text: $r('app.string.Index_downloads_prompt_direct_browse'),
            can_hover: true
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .clickEffect(click_effect_default())
        .onClick(() => {
          if (this.url) {
            this.storage.set('universal_new_tab_gateway', [this.url, false]);
          }
          this.storage.set('showing_downloads', false);
          this.storage.set('showing_scratching_board', false);
          this.storage.set('showing_settings', false);
          this.storage.set('showing_more_options', false);
          if (this.controller) {
            this.controller.close();
          }
        })
      }
    }
    .padding(20)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .useEffect(this.effects, EffectType.WINDOW_EFFECT)
    .backgroundColor(this.effects ? undefined : this.color_current_primary)
  }

  /**
   * Checks if the filename is legal.
   * And sets this.error_code.
   * Also updates additional info.
   * */
  refresh() {
    this.file_dir = meowContext().tempDir + '/downloads/' + this.file_name + '/' + Date.now().toString() + '/';
    this.download_target_path = this.file_dir + this.file_name;

    this.try_additional_info = [
      'url: ' + this.item!.getUrl(),
      'mimetype: ' + this.item!.getMimeType(),
      'totalBytes: ' + this.item!.getTotalBytes().toString(),
      'path: ' + this.download_target_path,
      'meow: meow meow meow',
    ];

    this.error_code = is_legal_filename(this.file_name);
  }

  /**
   * Starts the download task!
   * */
  submit() {
    // LINK START!
    if (this.item) {
      // Make directory
      console.log('[Meow][bunch_of_downloads] Task folder creation: ' + this.file_dir);
      try {
        fileIo.mkdirSync(this.file_dir, true);
      } catch (e) {
        console.log('[Meow][bunch_of_downloads] Task folder creation failed! ' + e);
        return;
      }

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
      // this.list_of_urls.push('link');

      try {
        this.item.start(this.download_target_path);
        this.storage.set('uni_webDownloadItem_gateway', undefined);
      } catch (e) {
        console.error('[woofWantDownload] item.start failed! ' + e);
        let task_idx = this.bunch_of_downloads.list_of_on_going_tasks.length - 1;
        this.bunch_of_downloads.delete_task(task_idx);
        return;
      }
      console.log('[bunch_of_downloads] dl_delegate.onBeforeDownload! download_target_path: [' + this.download_target_path + ']')
    }

    // Goodbye my friends
    if (this.controller) {
      this.bunch_of_downloads.update_timestamp();
      this.controller.close();
    }
  }

  /**
   * Checks if current download content can be directly viewed in the browser.
   * @returns True if viewable;
   * */
  is_viewable() {
    try {
      if (this.item) {
        console.log(`[woofWantDownload][is_viewable] Check if is viewable for ${this.url}... MimeType=${this.item.getMimeType()}!`);
        if (this.viewable_contents.includes(this.item.getMimeType())) {
          return true;
        }
      }
    } catch (e) {
      console.error(`[woofWantDownload][is_viewable] Returning a false due to Error: ` + e);
    }

    return false;
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