import { meowLayout } from "../../catstypicalframework/hosts/meowLayout";
import { hex2hsv, hsv2hex } from "../../catstypicalframework/utils/colors";
import { standardSpacing } from "../../components/settings";
import { meowDialogManager } from "../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../WoofUniFrame";
import { DemoPanel } from "./parts/DemoPanel";
import { EditPanel } from "./parts/EditPane";

@ComponentV2
struct WoofColorPicker {
  @Param @Require controller: CustomDialogController;
  // Host
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;
  // Data
  // @Local settingsId: number = -1;
  @Local hex: string = this.myDialog.lastRequest?.param as string;
  @Local h: number = -1;
  @Local s: number = -1;
  @Local v: number = -1;
  // Event
  @Event onConfirm: (hex: string) => void;

  aboutToAppear() {
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
              this.onConfirm(this.hex);
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
              this.onConfirm(this.hex);
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
  onConfirm: (hex: string) => void = () => {
    // Do nothing by default;
  };

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Settings_category_appearance_colors'), myLayout: this.myLayout, myDialog: this.myDialog }) {
      WoofColorPicker({
        controller: this.controller, myLayout: this.myLayout, myDialog: this.myDialog, onConfirm: (hex: string) => {
          this.onConfirm(hex);
        }
      });
    };
  }
}

export { WoofColorPickerDialog };
