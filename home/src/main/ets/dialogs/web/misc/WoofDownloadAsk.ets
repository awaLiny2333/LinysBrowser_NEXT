import { webview } from "@kit.ArkWeb";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { symbolForFileType } from "../../../catstypicalframework/utils/resource";
import { addUnitsToSize } from "../../../catstypicalframework/utils/storage";
import { MooTextInputV2 } from "../../../components/common/MooTextInputV2";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { standardSpacing } from "../../../components/constants";
import { getMyDawn } from "../../../hosts/app/downloads/scripts/helper";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofDownloadAskPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;
  // Info
  @Local webDlItem: webview.WebDownloadItem | undefined;
  @Local filename: string = '';
  // UI
  inputId: string = `WoofDownloadAsk_filename_${Date.now().toString(16)}`;

  aboutToAppear(): void {
    const req = this.myDialog.lastRequest;
    if (req) {
      this.webDlItem = req.param as webview.WebDownloadItem;
      this.filename = this.webDlItem?.getSuggestedFileName() || 'file';
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.Downloads_title'), myLayout: this.myLayout, myDialog: this.myDialog, showConfirmButton: true, showCancelButton: true, shiftBackgroundColor: true,
      onConfirm: () => {
        this.submit();
      },
      onCancel: () => {
        this.controller.close();
      }
    }) {
      // Info of download
      Column({ space: standardSpacing }) {
        Column({ space: standardSpacing }) {
          Text(this.webDlItem?.getUrl()).attributeModifier(new MooTextModifier()).opacity(0.75);
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
    this.controller.close();
  }
}

@CustomDialog
export struct WoofDownloadAskDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofDownloadAskPanel({ controller: this.controller, myLayout: this.myLayout, myDialog: this.myDialog });
  }
}
