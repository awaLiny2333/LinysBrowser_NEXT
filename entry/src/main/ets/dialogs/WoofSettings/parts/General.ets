import { AppStorageV2 } from '@kit.ArkUI';
import { MooCapsuleButton } from '../../../components/common/MooCapsuleButton';
import { MooStringPairArrayList } from '../../../components/common/MooStringPairArrayList';
import { MooTextInputV2 } from '../../../components/common/MooTextInputV2';
import { MooTextModifier } from '../../../components/common/MooTextModifier';
import { UniContentCard } from '../../../components/common/UniContentCard';
import { mooTextType, standardSpacing } from '../../../components/settings';
import { applyUserAgentFromSettings } from '../../../hosts/app/tabs/scripts/userAgents';
import { meowManagedSettings } from '../../../hosts/userdata/settings/classes/meowManagedSettings';
import { defaultSearchEngine, urlDefaultBlank } from '../../../hosts/userdata/settings/scripts/defaultSettingsValues';
import { meowDialogManager, openDialogRequestType } from '../../../hosts/system/dialogs/classes/meowDialogManager';
import { requestDialog } from '../../../hosts/system/dialogs/scripts/dialog';

@ComponentV2
struct SettingsGeneral {
  // Hosts
  @Param @Require myDialog: meowDialogManager;
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  // Local
  @Local selectedIndexUA: number = this.mySettings.settingsData[42].value as number;
  @Local selectedIndexSE: number = this.mySettings.settingsData[44].value as number;

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
          array: this.mySettings.settingsData[41].value as string[][],
          allowSelect: true,
          onEdited: () => {
            this.mySettings.requestSaveToDisk();
          },
          onSelect: (n) => {
            this.selectedIndexUA = n;
            this.mySettings.setByIndex(42, n);
            applyUserAgentFromSettings();
          },
          requestResetSelected: () => {
            this.selectedIndexUA = -1;
            this.mySettings.setByIndex(42, -1);
            applyUserAgentFromSettings();
          }
        });

        Text($r('app.string.Settings_category_general_surf_searchEngine')).attributeModifier(new MooTextModifier());
        MooStringPairArrayList({
          defaultItem: ['Bing', defaultSearchEngine()],
          selectedIndex: this.selectedIndexSE,
          array: this.mySettings.settingsData[43].value as string[][],
          allowSelect: true,
          onEdited: () => {
            this.mySettings.requestSaveToDisk();
          },
          onSelect: (n) => {
            this.selectedIndexSE = n;
            this.mySettings.setByIndex(44, n);
          },
          requestResetSelected: () => {
            this.selectedIndexSE = -1;
            this.mySettings.setByIndex(44, -1);
          }
        });

        Text($r('app.string.Settings_category_general_surf_newTabUrl')).attributeModifier(new MooTextModifier());
        MooTextInputV2({
          text: this.mySettings.settingsData[31].value as string,
          placeholder: urlDefaultBlank(),
          onChange: (c) => {
            this.mySettings.setByIndex(31, c);
          }
        });

        Text($r('app.string.Settings_category_general_surf_homeUrl')).attributeModifier(new MooTextModifier());
        MooTextInputV2({
          text: this.mySettings.settingsData[30].value as string,
          placeholder: urlDefaultBlank(),
          onChange: (c) => {
            this.mySettings.setByIndex(30, c);
          }
        });
      };
      UniContentCard({ title: $r('app.string.Settings_category_general_homepage'), icon: $r('sys.symbol.house') }) {
        MooCapsuleButton({
          text: $r('app.string.Settings_category_general_homepage_customize'),
          clickAction: () => {
            // TODO: Homepage customization entrance.
            requestDialog(this.myDialog, openDialogRequestType.HOMEPAGE, undefined, true);
          }
        });
      };
    };
  }
}

export { SettingsGeneral };
