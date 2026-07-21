import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { standardSpacing } from "../../../components/constants";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofSslErrorPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myUi: meowUiHost;
  // Info
  data: SslErrorEvent | undefined;
  @Local desc: string = '';

  aboutToAppear(): void {
    const req = this.myUi.myDialog.lastRequest;
    if (req) {
      this.data = req.param as SslErrorEvent;
      if (this.data) {
        this.desc = this.humanDescOfSslError(this.data);
      }
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.SslError_title'), myUi: this.myUi,
      showConfirmButton: true, showCancelButton: true, doubleConfirm: true,
      onConfirm: () => {
        this.data?.handler.handleConfirm();
        this.controller.close();
      },
      onCancel: () => {
        this.data?.handler.handleCancel();
        this.controller.close();
      },
      aboutToClose: () => {
        this.data?.handler.handleCancel();
      }
    }) {
      Text(this.desc).attributeModifier(new MooTextModifier()).width('100%').padding(standardSpacing * 1.5);
    };
  }

  humanDescOfSslError(e: SslErrorEvent) {
    let error_descs: string[] = ['Invalid (0)', 'HostMismatch (1)', 'DateInvalid (2)', 'Untrusted (3)'];
    return `( o=^•ェ•)o : ${error_descs[e.error as number]}
url: ${e.url}
originalUrl: ${e.originalUrl}
referrer: ${e.referrer}
isFatalError: ${e.isFatalError}
isMainFrame: ${e.isMainFrame}`;
  }
}

@CustomDialog
export struct WoofSslErrorDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofSslErrorPanel({ controller: this.controller, myUi: this.myUi });
  }
}
