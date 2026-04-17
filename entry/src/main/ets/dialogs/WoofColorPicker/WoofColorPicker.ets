import { AppStorageV2 } from "@kit.ArkUI";
import { meowLayout } from "../../catstypicalframework/hosts/meowLayout";
import { hex2hsv, hsv2hex, isLegalHexColor } from "../../catstypicalframework/utils/colors";
import { defaultInnerRadius, defaultMenuItemRadius, defaultRoundedRadius } from "../../catstypicalframework/utils/ui";
import { meowDialogManager } from "../../hosts/env/classes/meowDialogManager";
import { meowManagedSettings } from "../../hosts/settings/classes/meowManagedSettings";
import { getColor, meowThemeColorType, standardSpacing } from "../../components/settings";
import { MooCapsuleButton } from "../../components/common/MooCapsuleButton";
import { MooSlider } from "../../components/common/MooSlider";
import { MooTextInputV2 } from "../../components/common/MooTextInputV2";
import { MooTextModifier } from "../../components/common/MooTextModifier";
import { UniRowOfCapsuleButtons } from "../../components/common/UniRowOfCapsuleButtons";
import { WoofUniFrame } from "../WoofUniFrame";

@ComponentV2
struct WoofColorPicker {
  @Param @Require controller: CustomDialogController;
  // Host
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;
  // Data
  @Local settingsId: number = -1;
  @Local hex: string = '#000000';
  @Local h: number = -1;
  @Local s: number = -1;
  @Local v: number = -1;
  // Event
  @Event onConfirm: (settingsId: number, hex: string) => void;

  aboutToAppear() {
    const mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

    this.settingsId = this.myDialog.lastRequest?.param as number; // Read from dialog manager
    this.hex = mySettings.settingsData[this.settingsId].value as string;

    const hsvArr = hex2hsv(this.hex);
    this.h = hsvArr[0];
    this.s = hsvArr[1];
    this.v = hsvArr[2];
  }

  build() {
    Column() {
      if (this.myLayout.wideMode) {
        Row({ space: standardSpacing }) {
          DemoPanel({ hex: this.hex });
          EditPanel({
            h: this.h,
            s: this.s,
            v: this.v,
            hex: this.hex,
            onHsvChange: (h: number | undefined, s: number | undefined, v: number | undefined) => {
              if (h) {
                this.h = h;
              }
              if (s) {
                this.s = s;
              }
              if (v) {
                this.v = v;
              }
              this.hex = hsv2hex([this.h, this.s, this.v]);
            },
            onHexConfirm: () => {
              this.onConfirm(this.settingsId, this.hex);
              this.controller.close();
            },
            onCancel: () => {
              this.controller.close();
            }
          });
        }
        .width('100%')
        .alignItems(VerticalAlign.Top);
      } else {
        // Vertical
        Column({ space: standardSpacing }) {
          if (!this.myLayout.shortMode) {
            DemoPanel({ hex: this.hex });
          }
          EditPanel({
            myLayoutWeight: undefined,
            h: this.h,
            s: this.s,
            v: this.v,
            hex: this.hex,
            onHsvChange: (h: number | undefined, s: number | undefined, v: number | undefined) => {
              if (h) {
                this.h = h;
              }
              if (s) {
                this.s = s;
              }
              if (v) {
                this.v = v;
              }
              this.hex = hsv2hex([this.h, this.s, this.v]);
            },
            onHexConfirm: () => {
              this.onConfirm(this.settingsId, this.hex);
              this.controller.close();
            },
            onCancel: () => {
              this.controller.close();
            }
          });
        }
        .width('100%')
        .justifyContent(FlexAlign.End);
      }
    }
    .padding(standardSpacing);
  }
}

@CustomDialog
struct WoofColorPickerDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  onConfirm: (settingsId: number, hex: string) => void = () => {
    // Do nothing.
  };

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Settings_category_appearance_colors'), myLayout: this.myLayout, myDialog: this.myDialog }) {
      WoofColorPicker({
        controller: this.controller, myLayout: this.myLayout, myDialog: this.myDialog, onConfirm: (settingsId: number, hex: string) => {
          this.onConfirm(settingsId, hex);
        }
      });
    };
  }
}

export { WoofColorPickerDialog };

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
    .borderRadius(defaultInnerRadius)
    .padding(standardSpacing)
    .layoutWeight(this.myLayoutWeight);
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

        MooCapsuleButton({
          text: '／(=∵=)＼'
        });
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