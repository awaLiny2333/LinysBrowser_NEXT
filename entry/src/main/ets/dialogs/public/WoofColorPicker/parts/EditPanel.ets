import { isLegalHexColor, hsv2hex, hex2hsv } from '../../../../catstypicalframework/utils/colors';
import { defaultInnerRadius } from '../../../../catstypicalframework/utils/ui';
import { MooCapsuleButton } from '../../../../components/common/MooCapsuleButton';
import { MooSlider } from '../../../../components/common/MooSlider';
import { MooTextInputV2 } from '../../../../components/common/MooTextInputV2';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { UniRowOfCapsuleButtons } from '../../../../components/common/UniRowOfCapsuleButtons';
import { standardSpacing, getColor, meowThemeColorType, useEffects } from '../../../../components/settings';

@ComponentV2
struct EditPanel {
  // Config
  @Param myLayoutWeight: number = 1;
  // Data
  @Param @Require hex: string;
  @Param @Require h: number;
  @Param @Require s: number;
  @Param @Require v: number;
  // Events
  @Event onHsvChange: (h: number | undefined, s: number | undefined, v: number | undefined) => void;
  @Event onHexConfirm: () => void;
  @Event onCancel: () => void;

  build() {
    Scroll() {
      Column({ space: standardSpacing }) {
        Text($r('app.string.Settings_category_appearance_colors_picker_hue')).attributeModifier(new MooTextModifier());
        MooSlider({
          lock: false,
          min: 0,
          max: 360,
          value: this.h,
          step: 1,
          onChange: (value: number) => {
            this.onHsvChange(value, this.s, this.v);
          }
        });
        Text($r('app.string.Settings_category_appearance_colors_picker_saturation')).attributeModifier(new MooTextModifier());
        MooSlider({
          lock: false,
          min: 0,
          max: 100,
          value: this.s,
          step: 1,
          onChange: (value: number) => {
            this.onHsvChange(this.h, value, this.v);
          }
        });
        Text($r('app.string.Settings_category_appearance_colors_picker_value')).attributeModifier(new MooTextModifier());
        MooSlider({
          lock: false,
          min: 0,
          max: 100,
          value: this.v,
          step: 1,
          onChange: (value: number) => {
            this.onHsvChange(this.h, this.s, value);
          }
        });

        Text($r('app.string.Settings_category_appearance_colors_picker_code')).attributeModifier(new MooTextModifier());
        MooTextInputV2({
          text: this.hex,
          onChange: (c) => {
            if (isLegalHexColor(c)) {
              if (hsv2hex([this.h, this.s, this.v]) != c) {
                const hsv = hex2hsv(c);
                this.onHsvChange(hsv[0], hsv[1], hsv[2]);
              }
            }
          }
        });

        // Buttons
        UniRowOfCapsuleButtons() {
          MooCapsuleButton({
            text: $r('app.string.General_confirm'),
            clickAction: () => {
              this.onHexConfirm();
            }
          });
          MooCapsuleButton({
            text: $r('app.string.General_cancel'),
            clickAction: () => {
              this.onCancel();
            }
          });
        };
      }
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Start);
    }
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(getColor(meowThemeColorType.PRIMARY))
    .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
    .padding(standardSpacing)
    .layoutWeight(this.myLayoutWeight);
  }
}

export { EditPanel };
