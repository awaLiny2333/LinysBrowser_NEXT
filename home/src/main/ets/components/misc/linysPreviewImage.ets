import lazy { click_effect_default } from '../../hosts/bunch_of_defaults';
import { image } from '@kit.ImageKit';
import { download_image_as_array_buffer, is_legal_ipv4, is_legal_url } from '../../utils/url_tools';
import { arrayBuffer_2_pixelMap, base64_2_arrayBuffer, is_base64_image, sandbox_save_from_pixel_map, scan_QR_from_path } from '../../utils/storage_tools';
import linysTextTitle from '../texts/linysTextTitle';
import { fileIo } from '@kit.CoreFileKit';
import { scanBarcode } from '@kit.ScanKit';

@Component
struct linysPreviewImage {
  // Env
  storage: LocalStorage = new LocalStorage();
  // Public data
  @StorageLink('web_context_image_width') web_context_image_width: number = 300;
  @StorageLink('free_window_mode') free_window_mode: boolean = false;
  @LocalStorageLink('screen_height') screen_height: number = 0;
  @LocalStorageLink('screen_width') screen_width: number = 0;
  // Menu
  @LocalStorageLink('web_context_menu_show') web_context_menu_show: boolean = false;
  // Params
  url: string = '';
  // Runtime data
  @State image_width: number = 0;
  @State image_height: number = 0;
  @LocalStorageLink('web_context_image_size') web_context_image_size: string = 'OvO';
  @State web_context_image_pixel_map: image.PixelMap | undefined = undefined;
  @LocalStorageLink('web_context_image_path') web_context_image_path: string | undefined = undefined;
  @LocalStorageLink('web_context_image_qr_scanned_result') web_context_image_qr_scanned_results: Array<scanBarcode.ScanResult> = [];

  aboutToAppear(): void {
    this.web_context_image_pixel_map?.release();
    this.web_context_image_pixel_map = undefined;
    this.web_context_image_size = 'OvO';
    console.log(`[linysPreviewImage] Released PixelMap object!`);
    this.web_context_image_qr_scanned_results = [];

    if (is_legal_url(this.url, true) || is_legal_ipv4(this.url)) {
      console.log(`[linysPreviewImage] URL Image! Trying to download...`);
      download_image_as_array_buffer(this.url)
        .then((imageData) => {
          console.log(`[linysPreviewImage] Download OK.`);
          arrayBuffer_2_pixelMap(imageData)
            .then((pixelMap) => {
              if (pixelMap) {
                this.web_context_image_pixel_map = pixelMap;
                console.log(`[linysPreviewImage] Trying to save to sandbox.`);
                sandbox_save_from_pixel_map(pixelMap, this.getUIContext().getHostContext()!).then((path) => {
                  this.web_context_image_path = path;
                  console.log(`[linysPreviewImage] Saved to sandbox: ${path}`);
                  this.on_path_update();
                });
              }
            })
            .catch((e: BusinessError) => {
              console.error(`[linysPreviewImage] arrayBuffer_2_pixelMap failed: ${e}`);
            })
        })
        .catch((e: BusinessError) => {
          console.error(`[linysPreviewImage] URL image download failed: ${e}`);
        })
    } else if (is_base64_image(this.url)) {
      console.log(`[linysPreviewImage] BASE64 Image! Trying to decode...`);
      let uwu = this.url.split(',');
      base64_2_arrayBuffer(uwu[1])
        .then((r) => {
          arrayBuffer_2_pixelMap(r)
            .then((pixelMap) => {
              if (pixelMap) {
                this.web_context_image_pixel_map = pixelMap;
                console.log(`[linysPreviewImage] Trying to save to sandbox.`);
                sandbox_save_from_pixel_map(pixelMap, this.getUIContext().getHostContext()!).then((path) => {
                  this.web_context_image_path = path;
                  console.log(`[linysPreviewImage] Saved to sandbox: ${path}`);
                  this.on_path_update();
                });
              }
            })
        })
        .catch((e: BusinessError) => {
          console.log(`[linysPreviewImage] base64_2_arrayBuffer Failed: ${e}`);
        })
    } else {
      console.error(`[linysPreviewImage] Cannot read image!!`);
    }
  }

  build() {
    if (this.web_context_image_pixel_map) {
      Row() {
        Scroll() {
          Image(this.web_context_image_pixel_map)
            .width(this.web_context_image_width)
            .onComplete((event) => {
              this.image_width = event?.width || 0;
              this.image_height = event?.height || 0;
              this.web_context_image_size = this.image_width + 'x' + this.image_height;
              // console.info('imageWidth:'+imageWidth,'imageHeight:'+imageHeight);
            })
        }
        .borderRadius(6)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .onClick(() => {
          // preview_image(url, this.storage);
          this.storage.set('universal_new_tab_gateway', [this.url, false]);
          this.web_context_menu_show = false;
        })
        .clickEffect(click_effect_default())
        .constraintSize({ maxHeight: this.web_context_image_width })
      }
      .borderRadius(10)
      .hoverEffect(HoverEffect.Highlight)
      .padding(5)
    } else {
      // Loading or failed?
      linysTextTitle({ text: '(～o￣3￣)～', can_hover: true })
        .opacity(0.7)
    }
  }

  on_path_update() {
    if (canIUse("SystemCapability.Multimedia.Scan.ScanBarcode")) {
      fileIo.access(this.web_context_image_path)
        .catch((e: BusinessError) => {
          console.error(`[linysPreviewImage][on_path_update] Failed: ${e}`);
        })
        .then((r) => {
          if (r) {
            console.log(`[linysPreviewImage][on_path_update] ${this.web_context_image_path} Scan QR...`);
            scan_QR_from_path(this.web_context_image_path!)?.then((results) => {
              if (results) {
                console.log(`[linysPreviewImage][on_path_update] Received results. Length = ${results.length}`);
                this.web_context_image_qr_scanned_results = results;
                for (let index = 0; index < results.length; index++) {
                  console.log(`[linysPreviewImage][on_path_update][${index}] QR result: ${results[index].originalValue}`);
                }
              } else {
                console.log(`[linysPreviewImage][on_path_update] Received empty / void result. `);
              }
            })
          }
        })
    }
  }
}

export default linysPreviewImage;