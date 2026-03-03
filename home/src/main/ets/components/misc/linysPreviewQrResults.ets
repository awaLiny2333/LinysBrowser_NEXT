import lazy { copy } from '../../utils/clipboard_tools';
import lazy linysText from '../texts/linysText';
import lazy { scanBarcode } from '@kit.ScanKit';
import lazy { click_effect_default } from '../../hosts/bunch_of_defaults';
import linysPreviewTextActions from './linysPreviewTextActions';
import { storage_of_id } from '../../utils/ui_tools';

@Component
struct linysPreviewQrResults {
  // Eng
  @LocalStorageLink('my_window_id') my_window_id: string = '';
  storage: LocalStorage = storage_of_id(this.my_window_id);
  @LocalStorageLink('tablet_mode') tablet_mode: boolean = false;
  @StorageLink('free_window_mode') free_window_mode: boolean = false;
  // Colors
  @StorageLink('color_current_back') color_current_back: ResourceColor = $r('app.color.font_color_title');
  // Data
  @LocalStorageLink('web_context_image_qr_scanned_result') web_context_image_qr_scanned_results: Array<scanBarcode.ScanResult> = [];

  build() {
    if (canIUse("SystemCapability.Multimedia.Scan.ScanBarcode")) {
      Column({ space: 5 }) {
        ForEach(this.web_context_image_qr_scanned_results, ((res: scanBarcode.ScanResult) => {
          linysText({ text: '󰄨 ' + res.originalValue, can_hover: true, max_lines: this.tablet_mode || this.free_window_mode ? 8 : 4 })
            .onClick(() => {
              copy(res.originalValue);
            })
            .clickEffect(click_effect_default())

          linysPreviewTextActions({ storage: this.storage, content: res.originalValue })
        }))
      }
      .alignItems(HorizontalAlign.Start)
      .padding(5)
      .margin(5)
      // .opacity(0.75)
      .borderRadius(10)
      .backgroundColor($r('sys.color.comp_background_secondary'))

    } else {
      // Nothing
    }
  }
}

export default linysPreviewQrResults;