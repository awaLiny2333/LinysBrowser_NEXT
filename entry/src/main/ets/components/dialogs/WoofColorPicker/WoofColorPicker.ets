import { AppStorageV2 } from "@kit.ArkUI";
import { meowLayoutModeStatus } from "../../../catstypicalframework/hosts/meowLayoutModeStatus";
import { hex2hsv, hsv2hex, isLegalHexColor } from "../../../catstypicalframework/utils/colors";
import { defaultInnerRadius, defaultMenuItemRadius, defaultRoundedRadius } from "../../../catstypicalframework/utils/ui";
import { meowDialogManager } from "../../../hosts/env/classes/meowDialogManager";
import { meowManagedSettings } from "../../../hosts/settings/classes/meowManagedSettings";
import { getColor, meowThemeColorType, standardSpacing, summarizedPreferRightHand } from "../../common/constants";
import { MooCapsuleButton } from "../../common/MooCapsuleButton";
import { MooSlider } from "../../common/MooSlider";
import { MooTextInputV2 } from "../../common/MooTextInputV2";
import { MooTextModifier } from "../../common/MooTextModifier";
import { WoofUniFrame } from "../WoofSettings/common/WoofUniFrame";

@ComponentV2
struct WoofColorPicker {
  @Param @Require controller: CustomDialogController;
  // Host
  @Local layout: meowLayoutModeStatus = AppStorageV2.connect(meowLayoutModeStatus)!;
  // Data
  @Local settingsId: number = -1;
  @Local hex: string = '#000000';
  @Local h: number = -1;
  @Local s: number = -1;
  @Local v: number = -1;

  aboutToAppear() {
    const myMeowDialogManager: meowDialogManager = AppStorageV2.connect(meowDialogManager)!;
    const myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

    this.settingsId = myMeowDialogManager.lastRequest?.param as number; // Read from dialog manager
    this.hex = myMeowManagedSettings.settingsData[this.settingsId].value as string;

    const hsvArr = hex2hsv(this.hex);
    this.h = hsvArr[0];
    this.s = hsvArr[1];
    this.v = hsvArr[2];
  }

  build() {
    Column() {
      if (this.layout.wideMode) {
        Row({ space: standardSpacing }) {
          DemoPanel({ hex: this.hex });
          EditPanel({
            h: this.h,
            s: this.s,
            v: this.v,
            hex: this.hex,
            controller: this.controller,
            onHexChange: (hex: string) => {
              this.hex = hex;
            },
            onHexConfirm: () => {
              const myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
              myMeowManagedSettings.setByIndex(this.settingsId, this.hex);
            }
          });
        }
        .width('100%')
        .alignItems(VerticalAlign.Top);
      } else {
        Column({ space: standardSpacing }) {
          DemoPanel({ hex: this.hex });
          EditPanel({
            h: this.h,
            s: this.s,
            v: this.v,
            hex: this.hex,
            controller: this.controller,
            onHexChange: (hex: string) => {
              this.hex = hex;
            },
            onHexConfirm: () => {
              const myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
              myMeowManagedSettings.setByIndex(this.settingsId, this.hex);
            }
          });
        }
        .width('100%')
        .justifyContent(FlexAlign.End);
      }
    }.padding({ top: 50, left: standardSpacing, right: standardSpacing, bottom: standardSpacing });
  }
}

@CustomDialog
struct WoofColorPickerDialog {
  controller: CustomDialogController;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Settings') }) {
      WoofColorPicker({ controller: this.controller });
    };
  }
}

export { WoofColorPickerDialog };

@ComponentV2
struct EditPanel {
  @Param @Require controller: CustomDialogController;
  // Data
  @Param hex: string = '';
  @Param h: number = -1;
  @Param s: number = -1;
  @Param v: number = -1;
  // Events
  @Event onHexChange: (hex: string) => void;
  @Event onHexConfirm: () => void;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_appearance_colors_picker_hue')).attributeModifier(new MooTextModifier());
      MooSlider({
        lock: false,
        min: 0,
        max: 360,
        value: this.h,
        step: 1,
        onChange: (value: number) => {
          this.onHexChange(hsv2hex([value, this.s, this.v]));
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
          this.onHexChange(hsv2hex([this.h, value, this.v]));
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
          this.onHexChange(hsv2hex([this.h, this.s, value]));
        }
      });

      Text($r('app.string.Settings_category_appearance_colors_picker_code')).attributeModifier(new MooTextModifier());
      MooTextInputV2({
        text: this.hex,
        onChange: (c) => {
          if (isLegalHexColor(c)) {
            this.onHexChange(c);
          }
        }
      });

      // Buttons
      Row({ space: standardSpacing }) {
        MooCapsuleButton({
          text: $r('app.string.General_confirm'),
          clickAction: () => {
            this.onHexConfirm();
            this.controller.close();
          }
        });
        MooCapsuleButton({
          text: $r('app.string.General_cancel'),
          clickAction: () => {
            this.controller.close();
          }
        });
      }
      .direction(summarizedPreferRightHand() ? Direction.Rtl : Direction.Ltr)
      .alignSelf(summarizedPreferRightHand() ? ItemAlign.End : ItemAlign.Start);
    }
    .backgroundColor(getColor(meowThemeColorType.PRIMARY))
    .borderRadius(defaultInnerRadius)
    .padding(standardSpacing)
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Start);
  }
}

@ComponentV2
struct DemoPanel {
  @Param @Require hex: string;

  build() {
    Scroll() {
      Column({ space: standardSpacing }) {
        Row() {
          Text('ヽ（´ー｀）┌').attributeModifier(new MooTextModifier());
        }
        .padding(2 * standardSpacing)
        .backgroundColor(getColor(meowThemeColorType.SECONDARY))
        .borderRadius(defaultMenuItemRadius);

        // Color block
        Row() {
          MooCapsuleButton({
            text: '／(=∵=)＼'
          });
        }
        .padding(standardSpacing)
        .alignItems(VerticalAlign.Bottom)
        .height(120)
        .border({
          width: 2,
          color: getColor(meowThemeColorType.FONT),
          radius: defaultRoundedRadius
        })
        .width('60%')
        .backgroundColor(this.hex);
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%');
    }
    .edgeEffect(EdgeEffect.Spring)
    .layoutWeight(1)
    .padding(standardSpacing)
    .backgroundColor(getColor(meowThemeColorType.PRIMARY))
    .borderRadius(defaultInnerRadius);
  }
}