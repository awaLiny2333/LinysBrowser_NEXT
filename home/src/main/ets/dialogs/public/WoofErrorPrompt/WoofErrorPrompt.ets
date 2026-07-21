import { LengthMetrics } from "@kit.ArkUI";
import { MeowLinks } from "../../../catstypicalframework/utils/meow";
import { isBlank } from "../../../catstypicalframework/utils/strings";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { MooCapsuleButton } from "../../../components/common/MooCapsuleButton";
import { MooTextModifier } from "../../../components/common/MooTextModifier";
import { UniContentCard } from "../../../components/common/UniContentCard";
import { standardSpacing } from "../../../components/constants";
import { meowUiHost } from "../../../hosts/system/windows/classes/meowUiHost";
import { WoofUniFrame } from "../../WoofUniFrame";
import { ErrorPromptDetails } from "./errorPromptScripts";

@ComponentV2
struct WoofPrompt {
  @Param @Require controller: CustomDialogController;
  @Param @Require myUi: meowUiHost;
  // Configs
  @Local isError: boolean = false;
  @Local title: ResourceStr | undefined = undefined;
  @Local contents: ResourceStr | undefined = undefined;
  @Local changes: ResourceStr[] | undefined = undefined;
  // UI
  myDefaultRadius: number = defaultInnerRadius + 2;

  aboutToAppear(): void {
    const req = this.myUi.myDialog.lastRequest;
    if (req) {
      const details = req.param as ErrorPromptDetails;
      this.isError = details.isError;
      this.title = details.title;
      this.contents = details.contents;
      this.changes = details.additions?.filter(item => item.toString() != '');
    }
  }

  build() {
    WoofUniFrame({ controller: this.controller, title: this.title, myUi: this.myUi }) {
      // Texts
      Scroll() {
        Column({ space: standardSpacing * 1 }) {
          // Info
          UniContentCard({ roundedRadius: this.myDefaultRadius }) {
            // Text
            if (this.contents) {
              Text(this.contents).attributeModifier(new MooTextModifier()).width('100%');
            }
          };

          // Changes
          if (this.changes && !isBlank(this.changes.join(''))) {
            List({ space: standardSpacing }) {
              Repeat(this.changes)
                .each((item) => {
                  UniContentCard({ roundedRadius: this.myDefaultRadius }) {
                    Text(item.item).attributeModifier(new MooTextModifier()).lineSpacing(LengthMetrics.vp(standardSpacing * 0.5)).opacity(0.75).width('100%');
                  };
                })
                .virtualScroll();
            }
            .borderRadius(this.myDefaultRadius)
            .width('100%')
            .height('auto')
            .constraintSize({ maxHeight: this.myUi.myLayout.height * 0.5 });
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
              Text($r('app.string.ErrorPrompt_contact')).attributeModifier(new MooTextModifier()).padding({ bottom: standardSpacing * 0.5 }).width('100%');
              MooCapsuleButton({
                text: $r('app.string.Settings_category_about_site_bilibili'),
                clickAction: () => {
                  this.myUi.openUrlAuto(MeowLinks.BILI);
                  this.myUi.myDialog.closeAll();
                }
              });
              MooCapsuleButton({
                text: $r('app.string.Settings_category_about_site_github'),
                clickAction: () => {
                  this.myUi.openUrlAuto(MeowLinks.GITHUB);
                  this.myUi.myDialog.closeAll();
                }
              });
              MooCapsuleButton({
                text: $r('app.string.Settings_category_about_site_gitee'),
                clickAction: () => {
                  this.myUi.openUrlAuto(MeowLinks.GITEE);
                  this.myUi.myDialog.closeAll();
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
export struct WoofErrorPromptDialog {
  controller: CustomDialogController;
  @Require myUi: meowUiHost;

  build() {
    WoofPrompt({ controller: this.controller, myUi: this.myUi });
  }
}
