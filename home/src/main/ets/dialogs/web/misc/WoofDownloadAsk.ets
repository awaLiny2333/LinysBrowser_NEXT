import { webview } from "@kit.ArkWeb";
import { symbolForFileType } from "../../../catstypicalframework/utils/resource";
import { addUnitsToSize } from "../../../catstypicalframework/utils/storage";
import { MooTextInputV2 } from "../../../components/common/MooTextInputV2";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { standardSpacing } from "../../../components/constants";
import { getMyDawn } from "../../../hosts/app/downloads/scripts/helper";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofDownloadAskPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myUi: meowUiHost;
  // Info
  @Local webDlItem: webview.WebDownloadItem | undefined;
  @Local filename: string = '';
  @Local alreadyResolved: boolean = false;
  // UI
  inputId: string = `WoofDownloadAsk_filename_${Date.now().toString(16)}`;

  aboutToAppear(): void {
    const req = this.myUi.myDialog.lastRequest;
    if (req) {
      this.webDlItem = req.param as webview.WebDownloadItem;
      this.filename = this.webDlItem?.getSuggestedFileName() || 'file';
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.Downloads_title'), myUi: this.myUi, showConfirmButton: true, showCancelButton: true, shiftBackgroundColor: true,
      onConfirm: () => {
        this.submit();
      },
      onCancel: () => {
        this.controller.close();
      },
      aboutToClose: () => {
        if (this.alreadyResolved) return;
        this.webDlItem?.cancel();
      }
    }) {
      // Info of download
      Column({ space: standardSpacing }) {
        Column({ space: standardSpacing }) {
          Text(this.webDlItem?.getUrl()).attributeModifier(new MooTextModifier()).opacity(0.75).maxLines(3);
          Text(this.webDlItem?.getMimeType()).attributeModifier(new MooTextModifier()).opacity(0.75);
          Text(addUnitsToSize(this.webDlItem?.getTotalBytes() || 0)).attributeModifier(new MooTextModifier()).fontWeight(FontWeight.Bold);
        }
        .alignItems(HorizontalAlign.Start)
        .padding(standardSpacing * 0.5);
        // Custom file name
        MooTextInputV2({
          text: this.filename,
          icon: symbolForFileType(this.webDlItem?.getMimeType() || ''),
          myId: this.inputId,
          onChange: (value) => {
            this.filename = value;
          },
          onSubmit: () => {
            this.submit();
          }
        })
          .padding(1);
        Text($r('app.string.WindowAlias_illegalChars')).attributeModifier(new MooTextModifier()).padding(standardSpacing * 0.5);
      }
      .onAppear(() => {
        focusControl.requestFocus(this.inputId);
      })
      .alignItems(HorizontalAlign.Start)
      .padding(standardSpacing);
    };
  }

  submit() {
    if (this.webDlItem) {
      getMyDawn().confirmDownload(this.webDlItem, this.filename);
    }
    this.alreadyResolved = true;
    this.controller.close();
  }
}

@CustomDialog
export struct WoofDownloadAskDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofDownloadAskPanel({ controller: this.controller, myUi: this.myUi });
  }
}
