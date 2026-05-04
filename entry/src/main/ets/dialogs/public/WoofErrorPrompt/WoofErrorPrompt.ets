import { LengthMetrics } from "@kit.ArkUI";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { isBlank } from "../../../catstypicalframework/utils/strings";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { MooCapsuleButton } from "../../../components/common/MooCapsuleButton";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { standardSpacing } from "../../../components/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";
import { ErrorPromptDetails } from "./errorPromptScripts";

@ComponentV2
struct WoofPrompt {
  @Param @Require controller: CustomDialogController;
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myLayout: meowLayout;
  // Configs
  @Local isError: boolean = false;
  @Local title: ResourceStr | undefined = undefined;
  @Local contents: ResourceStr | undefined = undefined;
  @Local changes: ResourceStr[] | undefined = undefined;
  // UI
  myDefaultRadius: number = defaultInnerRadius + 2;

  aboutToAppear(): void {
    const req = this.myDialog.lastRequest;
    if (req) {
      const details = req.param as ErrorPromptDetails;
      this.isError = details.isError;
      this.title = details.title;
      this.contents = details.contents;
      this.changes = details.changes?.filter(item => item.toString() != '');
      if (this.changes?.length == 0) {
        this.changes = [$r('app.string.General_noChange')]; // Fill it with a notice saying no change.
      }
    }
  }

  build() {
    WoofUniFrame({ controller: this.controller, title: this.title, myLayout: this.myLayout, myDialog: this.myDialog }) {
      // Texts
      Scroll() {
        Column({ space: standardSpacing * 1 }) {
          // Info
          UniContentCard({ roundedRadius: this.myDefaultRadius }) {
            // Text
            if (this.contents) {
              Text(this.contents).attributeModifier(new MooTextModifier());
            }
          };

          // Changes
          if (this.changes && !isBlank(this.changes.join(''))) {
            List({ space: standardSpacing }) {
              Repeat(this.changes)
                .each((item) => {
                  UniContentCard({ roundedRadius: this.myDefaultRadius }) {
                    Text(item.item).attributeModifier(new MooTextModifier()).lineSpacing(LengthMetrics.vp(standardSpacing * 0.5)).opacity(0.75);
                  };
                })
                .virtualScroll();
            }
            .borderRadius(this.myDefaultRadius)
            .width('100%')
            .height('auto')
            .constraintSize({ maxHeight: this.myLayout.height * 0.5 });
          }

          // Confirm
          MooCapsuleButton({
            text: $r('app.string.General_confirm'),
            clickAction: () => {
              this.controller.close();
            }
          });

          // Contacts
          if (this.isError) {
            UniContentCard({ roundedRadius: this.myDefaultRadius }) {
              Text($r('app.string.ErrorPrompt_contact')).attributeModifier(new MooTextModifier()).padding({ bottom: standardSpacing * 0.5 });
              MooCapsuleButton({
                text: $r('app.string.Settings_category_about_site_bilibili'),
                clickAction: () => {
                  // TODO: Site Bilibili entrance.
                  this.myDialog.closeAll();
                }
              });
              MooCapsuleButton({
                text: $r('app.string.Settings_category_about_site_github'),
                clickAction: () => {
                  // TODO: Site Github entrance.
                  this.myDialog.closeAll();
                }
              });
              MooCapsuleButton({
                text: $r('app.string.Settings_category_about_site_gitee'),
                clickAction: () => {
                  // TODO: Site Gitee entrance.
                  this.myDialog.closeAll();
                }
              });
            };
          }
        }
        .padding(standardSpacing)
        .width('100%')
        .alignItems(HorizontalAlign.Start);
      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollable(ScrollDirection.Vertical);
    };
  }
}

@CustomDialog
struct WoofPromptDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofPrompt({ controller: this.controller, myDialog: this.myDialog, myLayout: this.myLayout });
  }
}

export { WoofPromptDialog };
