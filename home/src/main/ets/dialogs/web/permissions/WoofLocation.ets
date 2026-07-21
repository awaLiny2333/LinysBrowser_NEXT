import { common } from "@kit.AbilityKit";
import { requestUserPermission } from "../../../catstypicalframework/utils/permission";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { standardSpacing } from "../../../components/constants";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofLocationPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myUi: meowUiHost;
  // Info
  @Local data: OnGeolocationShowEvent | undefined;

  aboutToAppear(): void {
    const req = this.myUi.myDialog.lastRequest;
    if (req) {
      this.data = req.param as OnGeolocationShowEvent;
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.Geolocation_title'), myUi: this.myUi,
      showConfirmButton: true, showCancelButton: true, doubleConfirm: true,
      onConfirm: async () => {
        await this.requestPermissionFromSystem();
        this.data?.geolocation.invoke(this.data.origin, true, false);
        this.controller.close();
      },
      onCancel: () => {
        this.data?.geolocation.invoke(this.data.origin, false, false);
        this.controller.close();
      },
      aboutToClose: () => {
        this.data?.geolocation.invoke(this.data.origin, false, false);
      }
    }) {
      Column() {
        UniContentCard({ roundedRadius: defaultInnerRadius }) {
          Text(`󰆳  ${this.data?.origin}`).attributeModifier(new MooTextModifier()).width('100%');
        };
      }.padding(standardSpacing);
    };
  }

  async requestPermissionFromSystem() {
    await requestUserPermission(this.getUIContext().getHostContext() as common.UIAbilityContext, ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION']);
  }
}

@CustomDialog
export struct WoofWebGeolocationDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofLocationPanel({ controller: this.controller, myUi: this.myUi });
  }
}
