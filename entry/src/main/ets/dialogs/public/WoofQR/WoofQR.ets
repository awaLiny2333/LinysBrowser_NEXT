import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { getColor, meowThemeColorType, mooTextType, standardSpacing } from "../../../components/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofQR {
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myLayout: meowLayout;
  // Local
  @Local title: string = 'Title';
  @Local url: string = 'Link';

  aboutToAppear(): void {
    const req = this.myDialog.lastRequest;
    if (req) {
      this.title = (req.param as string[])[0];
      this.url = (req.param as string[])[1];
    }
  }

  build() {
    Column({ space: this.myLayout.wideMode ? standardSpacing : standardSpacing * 0.25 }) {
      // QR
      QRCode(this.url).color(getColor(meowThemeColorType.PRIMARY)).backgroundColor('transparent').width('100%');
      
      // Texts
      if (!this.myLayout.shortMode) {
        Blank().height(standardSpacing); // Visual balance
        Column() {
          Text(this.title).attributeModifier(new MooTextModifier(mooTextType.TITLE)).maxLines(3).wordBreak(WordBreak.BREAK_ALL);
          Text(this.url).attributeModifier(new MooTextModifier()).opacity(0.75).maxLines(3).wordBreak(WordBreak.BREAK_ALL);
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start);
      }
    }
    .width('100%')
    .padding(this.myLayout.shortMode ? standardSpacing * 2 : standardSpacing * 3);
  }
}

@CustomDialog
struct WoofQRDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.QR'), myLayout: this.myLayout, myDialog: this.myDialog }) {
      WoofQR({ myDialog: this.myDialog, myLayout: this.myLayout });
    };
  }
}

export { WoofQRDialog };
