import { AppStorageV2 } from '@kit.ArkUI';
import { meowManagedSettings } from '../../../../hosts/settings/classes/meowManagedSettings';
import { defaultSearchEngine, urlDefaultBlank } from '../../../../hosts/settings/scripts/defaultSettingsValues';
import { applyUserAgentFromSettings } from '../../../../hosts/tabs/scripts/userAgents';
import { mooTextType, standardSpacing } from '../../../settings';
import { MooCapsuleButton } from '../../../common/MooCapsuleButton';
import { MooStringPairArrayList } from '../../../common/MooStringPairArrayList';
import { MooTextInputV2 } from '../../../common/MooTextInputV2';
import { MooTextModifier } from '../../../common/MooTextModifier';
import { UniContentCard } from '../../../common/UniContentCard';

@ComponentV2
struct SettingsGeneral {
  @Local mySettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
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
          onEdit: () => {
            this.mySettings.requestSaveToDisk();
          },
          onSelect: (n) => {
            this.selectedIndexUA = n;
            this.mySettings.setByIndex(42, n);
            applyUserAgentFromSettings();
          }
        });

        Text($r('app.string.Settings_category_general_surf_searchEngine')).attributeModifier(new MooTextModifier());
        MooStringPairArrayList({
          defaultItem: ['Bing', defaultSearchEngine()],
          selectedIndex: this.selectedIndexSE,
          array: this.mySettings.settingsData[43].value as string[][],
          allowSelect: true,
          onEdit: () => {
            this.mySettings.requestSaveToDisk();
          },
          onSelect: (n) => {
            this.selectedIndexSE = n;
            this.mySettings.setByIndex(44, n);
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
          }
        });
      };
    };
  }
}

export { SettingsGeneral };
