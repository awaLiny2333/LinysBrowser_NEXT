import { common } from "@kit.AbilityKit";
import { pinShortcut } from "../../../catstypicalframework/utils/shortcuts";
import { path_2_uri, unlinkFile } from "../../../catstypicalframework/utils/storage";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { MooTextInputV2 } from "../../../components/common/MooTextInputV2";
import { meowThemeColorType, standardSpacing } from "../../../components/constants";
import { getColor, useEffects } from "../../../components/settings";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofPinShortcutPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myUi: meowUiHost;
  // Info
  @Local url: string = '';
  @Local title: string = '';
  @Local iconPath: string = '';

  aboutToAppear(): void {
    const req = this.myUi.myDialog.lastRequest;
    if (req) {
      const configs = req.param as [string, string, string]; // [url, title, iconPath]
      this.url = configs[0];
      this.title = configs[1];
      this.iconPath = configs[2];
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.PinShortcut_title'), myUi: this.myUi, shiftBackgroundColor: true,
      showConfirmButton: true, showCancelButton: true,
      onConfirm: () => {
        this.confirm();
      },
      onCancel: () => {
        this.deny();
      }
    }) {
      Column({ space: standardSpacing }) {
        if (!this.myUi.myLayout.shortMode) {
          Image(path_2_uri(this.iconPath))
            .width(64).height(64).padding(standardSpacing)
            .borderRadius(defaultInnerRadius)
            .border(useEffects() ? { width: 1, color: $r('sys.color.icon_fourth'), radius: defaultInnerRadius } : { width: 0, radius: defaultInnerRadius })
            .backgroundColor(useEffects() ? $r('app.color.blur_background_contrast') : getColor(meowThemeColorType.PRIMARY))
            .hoverEffect(HoverEffect.Highlight);
        }
        MooTextInputV2({
          text: this.url,
          icon: $r('sys.symbol.link'),
          placeholder: $r('app.string.General_url'),
          onChange: (value) => {
            this.url = value;
          },
        });
        MooTextInputV2({
          text: this.title,
          icon: $r('sys.symbol.label'),
          placeholder: $r('app.string.General_label'),
          onChange: (value) => {
            this.title = value;
          },
        });
      }
      .alignItems(HorizontalAlign.End)
      .padding(standardSpacing);
    };
  }

  async confirm() {
    this.controller.close();
    // Add and clean.
    await pinShortcut(this.getUIContext().getHostContext() as common.UIAbilityContext, this.url, `${this.title || 'meow'}`, this.iconPath);
    await unlinkFile(this.iconPath);
  }

  async deny() {
    this.controller.close();
    await unlinkFile(this.iconPath);
  }
}

@CustomDialog
export struct WoofPinShortcutDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofPinShortcutPanel({
      controller: this.controller,
      myUi: this.myUi
    });
  }
}
