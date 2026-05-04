import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { MooCapsuleButton } from "../../../components/common/MooCapsuleButton";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { standardSpacing } from "../../../components/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";
import { LengthMetrics } from "@kit.ArkUI";
import { ErrorPromptDetails } from "./errorPromptScripts";
import { UniContentCard } from "../../../components/common/UniContentCard";

@ComponentV2
struct WoofPrompt {
  @Param @Require controller: CustomDialogController;
  @Param @Require myDialog: meowDialogManager;
  @Param @Require myLayout: meowLayout;
  // Local
  @Local isError: boolean = false;
  @Local title: ResourceStr | undefined = undefined;
  @Local contents: ResourceStr | undefined = undefined;
  @Local additional: ResourceStr[] | undefined = undefined;

  aboutToAppear(): void {
    const req = this.myDialog.lastRequest;
    if (req) {
      const details = req.param as ErrorPromptDetails;
      this.isError = details.isError;
      this.title = details.title;
      this.contents = details.contents;
      this.additional = details.additional;
    }
  }

  build() {
    WoofUniFrame({ controller: this.controller, title: this.title, myLayout: this.myLayout, myDialog: this.myDialog }) {
      // Texts
      Scroll() {
        Column({ space: standardSpacing * 1 }) {
          // Info
          UniContentCard() {
            // Text
            if (this.contents) {
              Text(this.contents).attributeModifier(new MooTextModifier());
            }

            // Desc additional
            if (this.additional) {
              Repeat(this.additional)
                .each((item) => {
                  if (item.item) {
                    Text(item.item).attributeModifier(new MooTextModifier()).lineSpacing(LengthMetrics.vp(standardSpacing * 0.5)).opacity(0.75);
                  }
                });
            }

            Blank();

            // Confirm
            MooCapsuleButton({
              text: $r('app.string.General_confirm'),
              clickAction: () => {
                this.controller.close();
              }
            });
          };

          // Contacts
          if (this.isError) {
            UniContentCard() {
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
