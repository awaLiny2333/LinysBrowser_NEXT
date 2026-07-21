import { meow } from "../../../catstypicalframework/utils/catsLogger";
import { unlinkFile } from "../../../catstypicalframework/utils/storage";
import { MooCapsuleButton } from "../../../components/common/MooCapsuleButton";
import { MooSlider } from "../../../components/common/MooSlider";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { standardSpacing } from "../../../components/constants";
import { defaultAnimation, getMySettings, shortcutsHeight, shortcutsPath } from "../../../components/settings";
import { openDialogRequestType } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { requestDialog } from "../../../hosts/system/dialogs/scripts/dialog";
import { getMyResource } from "../../../hosts/system/resources/scripts/helpers";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { meowAppMessageType } from "../../../hosts/system/windows/scripts/messaging";
import { WoofUniFrame } from "../../WoofUniFrame";

@ComponentV2
struct WoofHomepage {
  @Param @Require myUi: meowUiHost;

  build() {
    Scroll() {
      Column({ space: standardSpacing }) {
        // Backdrop
        UniContentCard({ title: $r('app.string.Homepage_backdrop'), icon: $r('sys.symbol.tropicaltrees_and_sand'), expanded: true }) {
          MooCapsuleButton({
            text: $r('app.string.Homepage_backdrop_selectFromFiles'),
            clickAction: () => {
              getMyResource().pickBackgroundImageFromDocuments();
            }
          });
          MooCapsuleButton({
            text: $r('app.string.Homepage_backdrop_selectFromGallery'),
            clickAction: () => {
              getMyResource().pickBackgroundImageFromGallery();
            }
          });
          MooCapsuleButton({
            text: $r('app.string.General_delete'),
            needDoubleConfirm: true,
            isEnabled: getMyResource().backgroundImage != undefined,
            clickAction: () => {
              unlinkFile(getMyResource().backgroundImagePath);
              animateToImmediately(defaultAnimation(), () => {
                getMyResource().backgroundImage = undefined;
              });
            }
          });
        };

        // Shortcuts
        UniContentCard({ title: $r('app.string.Homepage_shortcuts'), icon: $r('sys.symbol.quick_help'), expanded: true }) {
          Text(shortcutsPath()).attributeModifier(new MooTextModifier());
          MooCapsuleButton({
            text: $r('app.string.General_select'),
            clickAction: () => {
              requestDialog(this.myUi.myDialog, openDialogRequestType.BOOKMARKS_PICKER, undefined, true);
            }
          });
          MooCapsuleButton({
            text: $r('app.string.General_unselect'),
            needDoubleConfirm: true,
            clickAction: () => {
              getMySettings().setByIndex(45, '');
            }
          });

          Text($r('app.string.Homepage_shortcuts_initialHeight')).attributeModifier(new MooTextModifier());
          MooSlider({
            min: 0,
            max: 100,
            value: shortcutsHeight(),
            step: 1,
            onChange: (r: number) => {
              getMySettings().setByIndex(46, r);
            }
          });
        };
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding(standardSpacing);
    }
    .edgeEffect(EdgeEffect.Spring)
    .scrollable(ScrollDirection.Vertical);
  }

  @Monitor('myUi.localMessageTunnel')
  receiveMessage() {
    if (this.myUi.localMessageTunnel?.type == meowAppMessageType.BOOKMARKS_PICKED) {
      const path = this.myUi.localMessageTunnel.payload as string;
      meow(`Received folder! ${path}`, 'WoofHomepage][receiveMessage');
      getMySettings().setByIndex(45, path);
    }
  }
}

@CustomDialog
struct WoofHomepageDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Homepage'), myUi: this.myUi }) {
      WoofHomepage({ myUi: this.myUi });
    };
  }
}

export { WoofHomepageDialog };
