import lazy { fastbuffer } from "@kit.ArkTS";
import { meowLayout } from "../../../catstypicalframework/hosts/meowLayout";
import lazy { meow } from "../../../catstypicalframework/utils/catsLogger";
import { fileDocumentPickSave, listFilesUnderDir, readArrayBufferConcurrent } from "../../../catstypicalframework/utils/storage";
import { defaultRoundedRadius } from "../../../catstypicalframework/utils/ui";
import lazy { MooCapsuleButton } from "../../../components/common/MooCapsuleButton";
import { MooTextButton } from "../../../components/common/MooTextButton";
import lazy { MooTextModifier } from "../../../components/common/MooTextModifier";
import lazy { UniContentCard } from "../../../components/common/UniContentCard";
import { defaultAnimation, standardSpacing } from "../../../components/settings";
import { meowDialogManager } from "../../../hosts/system/dialogs/classes/meowDialogManager";
import { WoofUniFrame } from "../../WoofUniFrame";
interface faultLogInfo {
  name: string;
  path: string;
}

@ComponentV2
struct FaultLogsPanel {
  @Local logs: faultLogInfo[] = [];

  aboutToAppear(): void {
    // Scan logs
    const dirPath = `${this.getUIContext().getHostContext()!.filesDir}/faultlogs`;
    listFilesUnderDir(dirPath).then((results) => {
      if (!results) {
        return;
      }

      // Process into faultLogInfo[]
      // By CodeGenie in DevEco Studio Preview 6.0.5.433 @ May 1 2026.
      this.logs = results.map((name) => {
        return { name: name, path: `${dirPath}/${name}` } as faultLogInfo;
      }).sort((a, b) => b.name.localeCompare(a.name));
    });
  }

  build() {
    List() {
      Repeat(this.logs)
        .each((item: RepeatItem<faultLogInfo>) => {
          ListItem() {
            UniContentCard({ title: `#${this.logs.length - item.index} ${item.item.name}`, icon: $r('sys.symbol.doc_text') }) {
              FaultLogsEntry({ name: item.item.name, path: item.item.path });
            };
          }.padding({ bottom: standardSpacing });
        })
        .virtualScroll();
      if (this.logs.length == 0) {
        ListItem() {
          MooTextButton({ text: $r('app.string.General_empty') });
        }.padding({ bottom: standardSpacing });
      }
    }
    .borderRadius(defaultRoundedRadius)
    .padding({ left: standardSpacing, right: standardSpacing, top: standardSpacing })
    .width('100%')
    .height('auto');
  }
}

@ComponentV2
struct FaultLogsEntry {
  @Param @Require name: string;
  @Param @Require path: string;
  @Local content: string = '';

  aboutToAppear(): void {
    readArrayBufferConcurrent(this.path).then((result) => {
      if (result) {
        try {
          const fileContents = fastbuffer.from(result).toString();
          animateToImmediately(defaultAnimation(), () => {
            this.content = fileContents;
          });
        } catch (e) {
          meow(`this.contents = fastbuffer.from(result).toString(); failed for path [${this.path}]: ${e}`, 'FaultLogsEntry][WoofFaultLogs');
        }
      }
    });
  }

  build() {
    Column({ space: standardSpacing }) {
      Text(this.content).attributeModifier(new MooTextModifier());
      MooCapsuleButton({
        text: $r('app.string.General_export'),
        clickAction: () => {
          fileDocumentPickSave(this.name, this.content);
        }
      });
    }.width('100%');
  }
}

@CustomDialog
struct WoofFaultLogsDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;

  build() {
    WoofUniFrame({
      controller: this.controller,
      title: $r('app.string.FaultLogs'),
      myDialog: this.myDialog, myLayout: this.myLayout,
    }) {
      FaultLogsPanel();
    };
  }
}

export { WoofFaultLogsDialog };
