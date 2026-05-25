import { MooCapsuleButton } from '../../../../components/common/MooCapsuleButton';
import { MooStringPairArrayList } from '../../../../components/common/MooStringPairArrayList';
import { MooTextInputV2 } from '../../../../components/common/MooTextInputV2';
import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../../components/common/UniContentCard';
import { mooTextType, standardSpacing } from '../../../../components/constants';
import { getMySettings } from '../../../../components/settings';
import { applyUserAgentFromSettings } from '../../../../hosts/app/tabs/scripts/userAgents';
import { searchEngineList, searchEngineSelected, userAgentList, userAgentSelected, userHomeUrl, userNewTabUrl } from '../../../../hosts/app/tabs/settings';
import { meowDialogManager, openDialogRequestType } from '../../../../hosts/system/dialogs/classes/meowDialogManager';
import { requestDialog } from '../../../../hosts/system/dialogs/scripts/dialog';
import { meowAppHost } from '../../../../hosts/system/windows/classes/meowAppHost';
import { getMyApp } from '../../../../hosts/system/windows/scripts/helpers';
import { globalMessage, meowAppMessageType } from '../../../../hosts/system/windows/scripts/messaging';
import { meowManagedSettings } from '../../../../hosts/userdata/settings/classes/meowManagedSettings';
import { defaultSearchEngine } from '../../../../hosts/userdata/settings/scripts/defaultSettingsValues';

@ComponentV2
struct SettingsGeneral {
  // Hosts
  @Param @Require myDialog: meowDialogManager;
  @Local mySettings: meowManagedSettings = getMySettings();
  @Local myApp: meowAppHost = getMyApp();
  // Local
  @Local selectedIndexUA: number = userAgentSelected();
  @Local selectedIndexSE: number = searchEngineSelected();
  // UI
  @Local refreshFlagUA: boolean = false;
  @Local refreshFlagSE: boolean = false;

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_general'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });

      UniContentCard({ title: $r('app.string.Settings_category_general_surf'), icon: $r('sys.symbol.figure_paddle_surfing') }) {
        Text($r('app.string.Settings_category_general_surf_userAgent')).attributeModifier(new MooTextModifier());
        MooStringPairArrayList({
          defaultItem: ['HarmonyOS', ''],
          selectedIndex: this.selectedIndexUA,
          array: this.getUAs(),
          allowSelect: true,
          onEdited: (index, newVal) => {
            userAgentList()[index] = newVal;
            this.mySettings.requestSaveToDisk();
            globalMessage(meowAppMessageType.SETTINGS_UA_REFRESH, this.selectedIndexUA);
          },
          onNew: () => {
            userAgentList().push(['HarmonyOS', '']);
            this.mySettings.requestSaveToDisk();
            globalMessage(meowAppMessageType.SETTINGS_UA_REFRESH, this.selectedIndexUA);
          },
          onDelete: (n) => {
            userAgentList().splice(n, 1);
            this.mySettings.requestSaveToDisk();
            globalMessage(meowAppMessageType.SETTINGS_UA_REFRESH, this.selectedIndexUA);
          },
          onSelect: (n) => {
            this.selectedIndexUA = n;
            this.mySettings.setByIndex(42, n);
            applyUserAgentFromSettings();
            globalMessage(meowAppMessageType.SETTINGS_UA_REFRESH, this.selectedIndexUA);
          },
          requestResetSelected: () => {
            this.selectedIndexUA = -1;
            this.mySettings.setByIndex(42, -1);
            applyUserAgentFromSettings();
            globalMessage(meowAppMessageType.SETTINGS_UA_REFRESH, this.selectedIndexUA);
          }
        });

        Text($r('app.string.Settings_category_general_surf_searchEngine')).attributeModifier(new MooTextModifier());
        MooStringPairArrayList({
          defaultItem: ['Bing', defaultSearchEngine()],
          selectedIndex: this.selectedIndexSE,
          array: this.getSEs(),
          allowSelect: true,
          onEdited: (index, newVal) => {
            searchEngineList()[index] = newVal;
            this.mySettings.requestSaveToDisk();
            globalMessage(meowAppMessageType.SETTINGS_SE_REFRESH, this.selectedIndexSE);
          },
          onNew: () => {
            searchEngineList().push(['Bing', defaultSearchEngine()]);
            this.mySettings.requestSaveToDisk();
            globalMessage(meowAppMessageType.SETTINGS_SE_REFRESH, this.selectedIndexSE);
          },
          onDelete: (n) => {
            searchEngineList().splice(n, 1);
            this.mySettings.requestSaveToDisk();
            globalMessage(meowAppMessageType.SETTINGS_SE_REFRESH, this.selectedIndexUA);
          },
          onSelect: (n) => {
            this.selectedIndexSE = n;
            this.mySettings.setByIndex(44, n);
            globalMessage(meowAppMessageType.SETTINGS_SE_REFRESH, this.selectedIndexSE);
          },
          requestResetSelected: () => {
            this.selectedIndexSE = -1;
            this.mySettings.setByIndex(44, -1);
            globalMessage(meowAppMessageType.SETTINGS_SE_REFRESH, this.selectedIndexSE);
          }
        });

        Text($r('app.string.Settings_category_general_surf_newTabUrl')).attributeModifier(new MooTextModifier());
        MooTextInputV2({
          text: userNewTabUrl(),
          onChange: (c) => {
            this.mySettings.setByIndex(31, c);
          }
        });

        Text($r('app.string.Settings_category_general_surf_homeUrl')).attributeModifier(new MooTextModifier());
        MooTextInputV2({
          text: userHomeUrl(),
          onChange: (c) => {
            this.mySettings.setByIndex(30, c);
          }
        });
      };
      UniContentCard({ title: $r('app.string.Settings_category_general_homepage'), icon: $r('sys.symbol.house') }) {
        MooCapsuleButton({
          text: $r('app.string.Settings_category_general_homepage_customize'),
          clickAction: () => {
            requestDialog(this.myDialog, openDialogRequestType.HOMEPAGE, undefined, true);
          }
        });
      };
    };
  }

  getUAs() {
    this.refreshFlagUA;
    // meow(`getUAs!`, 'General', meowLevel.WARN);
    return Array.from(userAgentList());
  }

  getSEs() {
    this.refreshFlagSE;
    // meow(`getSEs!`, 'General', meowLevel.WARN);
    return Array.from(searchEngineList());
  }

  /**
   * Syncing the panels across windows.
   */
  @Monitor('myApp.crossAppMessageTunnel')
  receiveMessage() {
    if (this.myApp.crossAppMessageTunnel?.type == meowAppMessageType.SETTINGS_UA_REFRESH) {
      const newIdx = this.myApp.crossAppMessageTunnel?.payload as number;
      if (newIdx != this.selectedIndexUA) {
        this.refreshFlagUA = !this.refreshFlagUA;
        this.selectedIndexUA = newIdx;
      }
    }
    if (this.myApp.crossAppMessageTunnel?.type == meowAppMessageType.SETTINGS_SE_REFRESH) {
      const newIdx = this.myApp.crossAppMessageTunnel?.payload as number;
      if (newIdx != this.selectedIndexSE) {
        this.refreshFlagSE = !this.refreshFlagSE;
        this.selectedIndexSE = newIdx;
      }
    }
  }
}

export { SettingsGeneral };
