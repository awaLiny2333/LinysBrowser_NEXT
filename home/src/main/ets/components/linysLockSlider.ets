import { animation_default } from '../hosts/bunch_of_defaults';
import linysLockToggle from './toggles/linysLockToggle';
import linysText from './texts/linysText';

// @Reusable
@Component
struct linysLockSlider {
  @State is_locked: boolean = true;
  @Prop slider_min: number = 0;
  @Prop slider_max: number = 100;
  @Prop display: string | undefined = undefined;
  @Link slider_value: number;
  // Colors
  @StorageLink('color_current_primary') color_current_primary: ResourceColor = $r('app.color.start_window_background');
  @StorageLink('color_current_secondary') color_current_secondary: ResourceColor = $r('app.color.block_color');
  @StorageLink('color_current_font') color_current_font: ResourceColor = $r('app.color.font_color_title');
  // Operations
  onTouchUp?: () => void;

  build() {
    Row({ space: 5 }) {
      linysLockToggle({ locked: this.is_locked })

      Slider({
        min: this.slider_min,
        max: this.slider_max,
        value: this.slider_value,
        style: SliderStyle.InSet,
      })
        .enabled(!this.is_locked)
        .opacity(!this.is_locked ? 1 : 0.5)
        .animation(animation_default())
        .layoutWeight(1)
        .blockColor(this.color_current_primary)
        .selectedColor(this.color_current_font)
        .onChange((value) => {
          this.slider_value = value;
        })
        .onTouch(e => {
          if (e.type == TouchType.Up) {
            // this.bunch_of_settings.set('animation_damping_coefficient',
            //   this.slider_value);
            if (this.onTouchUp) {
              this.onTouchUp();
            }
          }
        })
      linysText({ text: this.display ? this.display : this.slider_value.toString() })
        .margin({ right: 5 })
    }
  }
}

export default linysLockSlider;