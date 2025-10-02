import lazy {
  arrayBuffer_2_pixelMap,
  image_document_pick_to_ArrayBuffer,
  image_gallery_pick_to_ArrayBuffer,
  sandbox_save,
  sandbox_unlink
} from '../../utils/storage_tools';
import linysCapsuleButtonWithText from '../../components/buttons/linysCapsuleButtonWithText';
import linysTimeoutButtonWithText from '../../components/buttons/linysTimeoutButtonWithText';

@Component
struct meowHomepageManager {
  // States
  @State homepage_background_delete_confirm: number = 0;
  // Gateways
  @StorageLink('universal_fail_prompt_desc_gateway') uni_fail_prompt_gateway: ResourceStr = "";
  // Environments
  @StorageLink('homepage_background') homepage_background: PixelMap | undefined = undefined;
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Settings / Accessibility
  @StorageLink('preferred_hand_left_or_right') preferred_hand_left_or_right: string = 'right';

  build() {
    Column({ space: 10 }) {
      linysCapsuleButtonWithText({
        desc_text: $r('app.string.Homepage_background_select_storage'),
        button_text: "  󰃟  ",
        onExecution: () => {
          this.select_set_background_image_storage();
        }
      }) // Homepage background select from files

      linysCapsuleButtonWithText({
        desc_text: $r('app.string.Homepage_background_select_gallery'),
        button_text: "  󰓥  ",
        onExecution: () => {
          this.select_set_background_image_gallery();
        }
      }) // Homepage background select from files

      linysTimeoutButtonWithText({
        desc_text: $r('app.string.Homepage_background_delete'),
        button_text: "  󰀁  ",
        onExecution: () => {
          this.delete_homepage_background();
        }
      }) // Homepage background delete
    }
    .alignItems(this.preferred_hand_left_or_right == 'right' ? HorizontalAlign.End : HorizontalAlign.Start)
    .onAppear(() => {
      setInterval(() => {
        if (this.homepage_background_delete_confirm > 0) {
          this.homepage_background_delete_confirm -= 1;
        }
        // Reset homepage_background_delete_confirm
      }, 10)
    })
  }

  /**
   * Selects an image from storage.
   * */
  select_set_background_image_storage() {
    image_document_pick_to_ArrayBuffer().then(result => {
      if (result !== undefined) {
        let buf = result as ArrayBuffer;
        // Set image for homepage
        this.homepage_background = arrayBuffer_2_pixelMap(buf);
        // Save this to sandbox
        sandbox_save('homepage_background_arrayBuffer', buf);
      } else {
        console.log('[meowAppSettings] Select homepage background failed. Received undefined?')
        this.uni_fail_prompt_gateway = $r('app.string.Fail_select_bad_image');
      }
    });
  }

  /**
   * Selects an image from gallery.
   * */
  select_set_background_image_gallery() {
    image_gallery_pick_to_ArrayBuffer().then(result => {
      if (result !== undefined) {
        let buf = result as ArrayBuffer;
        // Set image for homepage
        this.homepage_background = arrayBuffer_2_pixelMap(buf);
        // Save this to sandbox
        sandbox_save('homepage_background_arrayBuffer', buf);
      } else {
        console.log('[meowAppSettings] Select homepage background failed. Received undefined?')
        this.uni_fail_prompt_gateway = $r('app.string.Fail_select_bad_image');
      }
    });
  }

  delete_homepage_background() {
    // Delete homepage background image
    this.homepage_background = undefined;
    sandbox_unlink('homepage_background_arrayBuffer');
    console.log("[meowAppSettings] Deleted homepage background!")
  }
}

export default meowHomepageManager;