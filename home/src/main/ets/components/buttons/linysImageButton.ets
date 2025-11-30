import { animation_default, click_effect_default, fontSize_Icon_Button } from '../../hosts/bunch_of_defaults';
import { path_2_uri } from '../../utils/storage_tools';

@Component
struct linysImageButton {
  @Prop path: string;
  // Settings
  can_hover: boolean = false;
  radius: number = 10;
  // UI
  @State isHov: boolean = false;
  // Actions
  execution?: () => void;

  // aboutToAppear(): void {
    // console.log(`[linysImageButton] path=${this.path}`);
  // }

  build() {
    Image(this.path ? path_2_uri(this.path) : '')
      .brightness(this.isHov ? 1.1 : 1)
      .animation(animation_default())
      .height(fontSize_Icon_Button() + (this.can_hover ? 10 : 0))
      .width(fontSize_Icon_Button() + (this.can_hover ? 10 : 0))
      .padding(this.can_hover ? 5 : 0)
      .borderRadius(this.can_hover ? this.radius : 0)
      .clickEffect(click_effect_default())
      .onHover((isHv) => {
        if (this.can_hover) {
          this.isHov = isHv;
        }
      })
      .onClick(() => {
        if (this.execution) {
          this.execution();
        }
      })
  }
}

export default linysImageButton;