import { meowLayout } from '../../catstypicalframework/hosts/meowLayout';
import { meowDialogManager } from '../../hosts/system/dialogs/classes/meowDialogManager';
import { meowUiStatuses } from '../../hosts/system/windows/classes/meowUiStatuses';
import { meowManagedSettings } from '../../hosts/userdata/settings/classes/meowManagedSettings';
import { WoofUniFrame } from '../WoofUniFrame';
import { AppStorageV2 } from '@kit.ArkUI';
import { MooStringArrayList } from '../../components/common/MooStringArrayList';
import { standardSpacing } from '../../components/settings';
import { fileDocumentPick2Path, fileCopy, listFilesUnderDir, unlinkFile, fileNameOfPath } from '../../catstypicalframework/utils/storage';
import { meow, meowLevel } from '../../catstypicalframework/utils/catsLogger';
import { globalMessage, meowAppMessageType } from '../../hosts/system/windows/scripts/messaging';
import { meowAppStatuses } from '../../hosts/system/windows/classes/meowAppStatuses';

@ComponentV2
struct AdBlockerRulesPanel {
  @Local myApp: meowAppStatuses = AppStorageV2.connect(meowAppStatuses)!;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  // Data
  easylistDirPath: string = this.getUIContext().getHostContext()!.filesDir + '/easylist';
  @Local myRules: string[] = [];

  aboutToAppear(): void {
    this.refreshFiles();
  }

  build() {
    MooStringArrayList({
      list: this.myRules,
      enableLabelField: false,
      onDelete: async (index: number) => {
        // Delete that one from files.
        await unlinkFile(this.easylistDirPath + '/' + this.myRules[index]);
        this.refreshFiles().then(() => {
          this.applyFiles();
        });
      },
      onNew: async () => {
        // Pick new from files.
        const result = await fileDocumentPick2Path(['.txt'], 233);
        if (!result.succeed) {
          meow(`Failed to pick easylist from documents.`, 'WoofAdBlockerRules', meowLevel.WARN);
          return;
        }

        // Add them one by one.
        for (let i = 0; i < result.sourcePaths!.length; i++) {
          const path = result.sourcePaths![i];
          await fileCopy(path, this.easylistDirPath + '/' + fileNameOfPath(path), true);
        }
        meow(`Easylist loaded from [${result.sourcePaths!.join(', ')}].`, 'WoofAdBlockerRules', meowLevel.INFO);

        // Refresh
        this.refreshFiles().then(() => {
          this.applyFiles();
        });
      }
    })
      .padding(standardSpacing);
  }

  /**
   * Refreshes the easylist folder files.
   */
  async refreshFiles() {
    const results = await listFilesUnderDir(this.easylistDirPath);
    if (results) {
      this.myRules = results;
    }
    globalMessage(meowAppMessageType.SETTINGS_EASYLIST_REFRESH, results);
  }

  /**
   * Apply the changes.
   */
  applyFiles() {
    // TODO: apply easylist rules.
  }

  /**
   * Refresh message receiver!
   */
  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    const msg = this.myApp.crossAppMessageTunnel!;
    const payload = msg.payload as string[];
    if (msg.type == meowAppMessageType.SETTINGS_EASYLIST_REFRESH) {
      if (this.myRules != payload) {
        this.myRules = payload;
      }
    }
  }
}

@CustomDialog
struct WoofAdBlockerRulesDialog {
  controller: CustomDialogController;
  @Require myDialog: meowDialogManager;
  @Require myLayout: meowLayout;
  @Require myUi: meowUiStatuses;

  build() {
    WoofUniFrame({
      controller: this.controller, myDialog: this.myDialog, myLayout: this.myLayout, shiftBackgroundColor: true,
      title: $r('app.string.AdBlocker_rules'),
      tutorial: $r('app.string.AdBlocker_rules_tutorial'),
    }) {
      AdBlockerRulesPanel();
    };
  }
}

export { WoofAdBlockerRulesDialog };
