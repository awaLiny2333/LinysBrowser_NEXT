import { AppStorageV2 } from "@kit.ArkUI";
import { meowLayout } from "../../catstypicalframework/hosts/meowLayout";
import { meow } from "../../catstypicalframework/utils/catsLogger";
import { unlinkFile } from "../../catstypicalframework/utils/storage";
import { MooCapsuleButton } from "../../components/common/MooCapsuleButton";
import { MooSlider } from "../../components/common/MooSlider";
import { MooTextModifier } from "../../components/common/MooTextModifier";
import { UniContentCard } from "../../components/common/UniContentCard";
import { defaultAnimation, standardSpacing } from "../../components/settings";
import { meowDialogManager, openDialogRequestType } from "../../hosts/app/dialogs/classes/meowDialogManager";
import { meowResources } from "../../hosts/app/env/classes/meowResources";
import { requestDialog } from "../../hosts/app/dialogs/scripts/dialog";
import { meowAppMessageType } from "../../hosts/app/windows/scripts/messaging";
import { meowUiStatuses } from "../../hosts/app/windows/classes/meowUiStatuses";
import { meowManagedSettings } from "../../hosts/data/settings/classes/meowManagedSettings";
import { WoofUniFrame } from "../WoofUniFrame";

@ComponentV2
struct WoofHomepage {
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myUi: meowUiStatuses;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;

  build() {
    Scroll() {
      Column({ space: standardSpacing }) {
        // Backdrop
        UniContentCard({ title: $r('app.string.Homepage_backdrop'), icon: $r('sys.symbol.tropicaltrees_and_sand'), expanded: true }) {
          MooCapsuleButton({
            text: $r('app.string.Homepage_backdrop_selectFromFiles'),
            clickAction: () => {
              const myResources = AppStorageV2.connect(meowResources)!;
              myResources.pickBackgroundImageFromDocuments();
            }
          });
          MooCapsuleButton({
            text: $r('app.string.Homepage_backdrop_selectFromGallery'),
            clickAction: () => {
              const myResources = AppStorageV2.connect(meowResources)!;
              myResources.pickBackgroundImageFromGallery();
            }
          });
          MooCapsuleButton({
            text: $r('app.string.General_delete'),
            needDoubleConfirm: true,
            isEnabled: (AppStorageV2.connect(meowResources)!).backgroundImage != undefined,
            clickAction: () => {
              const myResources = AppStorageV2.connect(meowResources)!;
              unlinkFile(myResources.backgroundImagePath);
              animateToImmediately(defaultAnimation(), () => {
                myResources.backgroundImage = undefined;
              });
            }
          });
        };

        // Shortcuts
        UniContentCard({ title: $r('app.string.Homepage_shortcuts'), icon: $r('sys.symbol.quick_help'), expanded: true }) {
          Text(this.mySettings.settingsData[45].value as string).attributeModifier(new MooTextModifier());
          MooCapsuleButton({
            text: $r('app.string.General_select'),
            clickAction: () => {
              requestDialog(this.myDialog, openDialogRequestType.BOOKMARKS_PICKER, undefined, true);
            }
          });
          MooCapsuleButton({
            text: $r('app.string.General_unselect'),
            clickAction: () => {
              this.mySettings.setByIndex(45, '');
            }
          });

          Text($r('app.string.Homepage_shortcuts_initialHeight')).attributeModifier(new MooTextModifier());
          MooSlider({
            min: 0,
            max: 100,
            value: this.mySettings.settingsData[46].value as number,
            step: 1,
            onChange: (r: number) => {
              this.mySettings.setByIndex(46, r);
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
      this.mySettings.setByIndex(45, path);
    }
  }
}

@CustomDialog
struct WoofHomepageDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myUi: meowUiStatuses;

  build() {
    WoofUniFrame({ controller: this.controller, title: $r('app.string.Homepage'), myLayout: this.myLayout, myDialog: this.myDialog }) {
      WoofHomepage({ myDialog: this.myDialog, myUi: this.myUi });
    };
  }
}

export { WoofHomepageDialog };
