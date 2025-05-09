import linysLockSlider from '../components/linysLockSlider';
import linysText from '../components/linysText';
import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large
} from '../hosts/bunch_of_defaults';
import { bunch_of_settings } from '../hosts/bunch_of_settings';

@Component
struct meowAnimationManager {
  // Environment
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings(true);
  // Colors
  @StorageProp('color_current_primary') color_current_primary: ResourceColor =
    $r('app.color.start_window_background');
  @StorageProp('color_current_secondary') color_current_secondary: ResourceColor =
    $r('app.color.block_color');
  @StorageProp('color_current_font') color_current_font: ResourceColor =
    $r('app.color.font_color_title');
  // editing
  @State delete_confirm: number = 0;
  @StorageLink('animation_response') animation_response: number = 0;
  @StorageLink('animation_damping_coefficient') animation_damping_coefficient: number = 0;
  @State lock_response: boolean = true;
  @State lock_damping_coefficient: boolean = true;

  build() {
    Column({ space: 10 }) {

      linysText({
        text: $r('app.string.Settings_appearance_animation_response')
      }) // Slider and display of animation_response

      linysLockSlider({
        slider_min: 1,
        slider_max: 100,
        display: (0.01 * this.animation_response).toFixed(2),
        slider_value: this.animation_response,
        onTouchUp: () => {
          this.bunch_of_settings.set('animation_response', this.animation_response);
        }
      })

      linysText({
        text: $r('app.string.Settings_appearance_animation_damping_coefficient')
      }) // Slider and display of animation damping coefficient

      linysLockSlider({
        slider_min: 0,
        slider_max: 75,
        slider_value: this.animation_damping_coefficient,
        display: (0.01 * this.animation_damping_coefficient).toFixed(2),
        onTouchUp: () => {
          this.bunch_of_settings.set('animation_damping_coefficient',
            this.animation_damping_coefficient);
        }
      })

      Row() {
        linysText({
          text: $r("app.string.Settings_appearance_animation_reset")
        })
        Blank()
        Button('  󰃈  ')// Reset
          .type(ButtonType.Capsule)
          .backgroundColor(this.delete_confirm > 0 ? this.color_current_primary :
          this.color_current_font)
          .fontColor(this.delete_confirm > 0 ? this.color_current_font :
          this.color_current_primary)
          .border({
            width: 2,
            color: this.delete_confirm > 0 ? this.color_current_font : "transparent"
          })
          .fontSize(fontSize_Large())
          .fontWeight(FontWeight.Medium)
          .height(capsule_bar_height())
          .onClick(async () => {
            this.delete_confirm += 300;
            if (this.delete_confirm >= 301) {
              this.delete_confirm = 0;
              // Reset
              this.bunch_of_settings.reset('animation_response');
              this.bunch_of_settings.reset('animation_damping_coefficient');
              // Sync
              this.animation_response = await this.bunch_of_settings.get('animation_response') as number;
              console.log(this.animation_response.toString())
              this.animation_damping_coefficient =
                await this.bunch_of_settings.get('animation_damping_coefficient') as number;
            }
          })
          .clickEffect(click_effect_default())
          .animation(animation_default())
          .onAppear(() => {
            setInterval(() => {
              if (this.delete_confirm > 0) {
                this.delete_confirm -= 1;
              }
              // Reset confirm timeout
            }, 10)
          })
      }
      .width("100%")
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}

export default meowAnimationManager;