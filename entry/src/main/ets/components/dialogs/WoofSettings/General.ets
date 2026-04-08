import { meowManagedSettings } from '../../../hosts/settings/classes/meowManagedSettings';
import { AppStorageV2 } from '@kit.ArkUI';
import { standardSpacing, mooTextType } from '../../common/constants';
import { MooTextModifier } from '../../common/MooTextModifier';
import { UniContentCard } from '../../common/UniContentCard';

@ComponentV2
struct SettingsGeneral {
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_general'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .width('100%')
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });
      UniContentCard({ title: $r('app.string.Settings_category_general_surf'), icon: $r('sys.symbol.figure_paddle_surfing') }) {

      };
      UniContentCard({ title: $r('app.string.Settings_category_general_homepage'), icon: $r('sys.symbol.house') }) {

      };
    };
  }
}

export { SettingsGeneral };