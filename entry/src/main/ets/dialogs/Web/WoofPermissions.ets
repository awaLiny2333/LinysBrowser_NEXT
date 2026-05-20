import { common } from "@kit.AbilityKit";
import { meowLayout } from "../../catstypicalframework/hosts/meowLayout";
import { meow, meowLevel } from "../../catstypicalframework/utils/catsLogger";
import { requestUserPermission } from "../../catstypicalframework/utils/permission";
import { MooCapsuleButton } from "../../components/common/MooCapsuleButton";
import { MooTextModifier } from "../../components/common/MooTextModifier";
import { UniContentCard } from "../../components/common/UniContentCard";
import { UniRowOfCapsuleButtons } from "../../components/common/UniRowOfCapsuleButtons";
import { standardSpacing } from "../../components/constants";
import { defaultAnimation } from "../../components/settings";
import { meowTabInfo } from "../../hosts/app/tabs/classes/meowTabInfo";
import { meowDialogManager } from "../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../WoofUniFrame";

@ComponentV2
struct WoofPermissionsPanel {
  @Param @Require controller: CustomDialogController;
  @Param @Require myLayout: meowLayout;
  @Param @Require myDialog: meowDialogManager;
  // Info
  data: OnPermissionRequestEvent | undefined;
  tabInfo: meowTabInfo | undefined;
  @Local desc: string[] = [];
  @Local allowed: string[] = [];
  @Local denied: string[] = [];

  aboutToAppear(): void {
    const req = this.myDialog.lastRequest;
    if (req) {
      this.data = (req.param as [OnPermissionRequestEvent, meowTabInfo])[0];
      this.tabInfo = (req.param as [OnPermissionRequestEvent, meowTabInfo])[1];
      if (this.data) {
        this.desc = this.parsePermissionReq(this.data);
      }
    }
  }

  build() {
    WoofUniFrame({
      controller: this.controller, title: $r('app.string.WebPermissions_title'), myLayout: this.myLayout, myDialog: this.myDialog,
      aboutToClose: () => {
        if (this.desc.length > 0) {
          // Throw all remainings into denied
          this.denied.push(...this.desc);
          this.desc = [];
          this.checkSubmit();
        }
      }
    }) {
      Column({ space: standardSpacing * 0.75 }) {
        Text(this.data?.request.getOrigin()).attributeModifier(new MooTextModifier()).width('100%').padding(standardSpacing * 0.5).opacity(0.75);
        Repeat(this.desc)
          .each((item: RepeatItem<string>) => {
            UniContentCard({ space: standardSpacing }) {
              Text($r('app.string.WebPermissions_desc_'.concat(item.item))).attributeModifier(new MooTextModifier()).width('100%').padding(standardSpacing * 0.25);
              // Allow deny buttons
              UniRowOfCapsuleButtons() {
                MooCapsuleButton({
                  text: $r('app.string.General_cancel'),
                  needDoubleConfirm: true,
                  clickAction: () => {
                    this.denied.push(item.item);
                    animateToImmediately(defaultAnimation(), () => {
                      this.desc.splice(item.index, 1);
                    });
                    this.checkSubmit();
                  }
                });
                MooCapsuleButton({
                  text: $r('app.string.General_confirm'),
                  needDoubleConfirm: true,
                  clickAction: () => {
                    this.allowed.push(item.item);
                    animateToImmediately(defaultAnimation(), () => {
                      this.desc.splice(item.index, 1);
                    });
                    this.checkSubmit();
                  }
                });
              };
            };
          });
      }.padding(standardSpacing);
    };
  }

  checkSubmit() {
    if (this.desc.length > 0) {
      // Not yet.
      return;
    }
    // Remember
    for (const per of this.allowed) {
      if (!(this.tabInfo!.allowedPermissions.includes(per))) {
        this.tabInfo!.allowedPermissions.push(per);
      }
    }
    // Request permissions from system
    requestUserPermission(this.getUIContext().getHostContext() as common.UIAbilityContext, this.allowed);
    // Submit
    this.data?.request.grant(this.allowed);
    meow(`Granted: [${this.allowed}], denied: [${this.denied}]`, 'WoofPermissions][checkSubmit', meowLevel.WARN);
    this.controller.close();
  }

  parsePermissionReq(event: OnPermissionRequestEvent) {
    const p: string[] = [];
    for (const permission of event.request.getAccessibleResource()) {
      if (this.tabInfo!.allowedPermissions.includes(permission)) {
        this.allowed.push(permission);
      } else {
        p.push(permission); // Push to ask if not remembered to allow
      }
    }
    return p;
  }
}

@CustomDialog
export struct WoofPermissionsDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofPermissionsPanel({ controller: this.controller, myLayout: this.myLayout, myDialog: this.myDialog });
  }
}
