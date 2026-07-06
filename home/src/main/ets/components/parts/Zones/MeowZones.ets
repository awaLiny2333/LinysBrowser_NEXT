import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import { ErrorPromptDetails } from "../../../dialogs/public/WoofErrorPrompt/errorPromptScripts";
import lazy { deleteZone, discoverZones, glimpseOnZone, openZone } from "../../../hosts/app/tabs/scripts/zones";
import { openDialogRequestType } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { requestDialogOnMostRecent } from "../../../hosts/system/dialogs/scripts/dialog";
import { meowAppHost } from "../../../hosts/system/windows/classes/meowAppHost";
import { getCreateMyApp } from "../../../hosts/system/windows/scripts/helpers";
import lazy { meowAppMessageType } from "../../../hosts/system/windows/scripts/messaging";
import { MooCapsuleButton } from "../../common/MooCapsuleButton";
import { MooTextModifier } from "../../common/MooTextModifier";
import { UniContentCard } from "../../common/UniContentCard";
import { UniRowOfCapsuleButtons } from "../../common/UniRowOfCapsuleButtons";
import { standardSpacing } from "../../constants";
import { defaultAnimation, waterFlowColumnsTemplate } from "../../settings";

@ComponentV2
export struct MeowZones {
  @Param @Require myLayout: meowLayout;
  @Local myApp: meowAppHost = getCreateMyApp();
  // Local
  @Local zones: string[] = [];
  @Local glimpses: string[][] = [];

  aboutToAppear(): void {
    this.scan();
  }

  build() {
    Scroll() {
      WaterFlow() {
        Repeat(this.zones)
          .each((item) => {
            FlowItem() {
              UniContentCard({ title: item.item, icon: $r('sys.symbol.briefcase'), expanded: true, space: standardSpacing * 1.25 }) {
                // Glimpses
                Repeat(this.glimpses[item.index])
                  .each((gl) => {
                    Text(gl.item).attributeModifier(new MooTextModifier()).width('100%').opacity(0.75);
                  })
                  .key((line) => line);
                // Buttons
                UniRowOfCapsuleButtons() {
                  MooCapsuleButton({
                    text: $r('app.string.General_delete'),
                    needDoubleConfirm: true,
                    clickAction: () => {
                      deleteZone(item.item).then((result) => {
                        if (result) {
                          this.scan();
                        } else {
                          // Failed;
                          requestDialogOnMostRecent(openDialogRequestType.ERROR_PROMPT, {
                            isError: true,
                            title: $r('app.string.Zones_delete_failed'),
                            contents: $r('app.string.Zones_delete_failed_desc'),
                          } as ErrorPromptDetails, true);
                        }
                      });
                    }
                  });
                  MooCapsuleButton({
                    text: $r('app.string.General_view'),
                    clickAction: () => {
                      openZone(item.item);
                    }
                  });
                };
              };
            };
          })
          .key((i) => i);
      }
      .clip(false) // To eliminate the cuts on the edges
      .columnsTemplate(waterFlowColumnsTemplate(this.myLayout))
      .columnsGap(standardSpacing)
      .rowsGap(standardSpacing);
    }
    .align(Alignment.TopStart)
    .layoutWeight(1)
    .padding(standardSpacing)
    .edgeEffect(EdgeEffect.Spring);
  }

  scan() {
    // Discover zones from disk.
    discoverZones().then(async (r) => {
      if (r != undefined) {
        // Glimpse
        // this.glimpses = [];
        const gls: string[][] = [];
        for (const zoneAlias of r) {
          const glimpse = await glimpseOnZone(zoneAlias);
          if (glimpse != undefined) {
            gls.push(glimpse);
          } else {
            gls.push([]);
          }
        }
        this.glimpses = gls;

        // Use setTimeout to enable animation.
        setTimeout(() => {
          animateToImmediately(defaultAnimation(), () => {
            this.zones = r;
          });
        });
      }
    });
  }

  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    const msg = this.myApp.crossAppMessageTunnel!;
    if (msg.type == meowAppMessageType.ZONES_REFRESH) {
      this.scan();
    }
  }
}
