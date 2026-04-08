import { getColor, meowThemeColorType, mooTextType, standardSpacing, useEffects } from '../../common/constants';
import { MooTextModifier } from '../../common/MooTextModifier';
import { UniContentCard } from '../../common/UniContentCard';
import { AppStorageV2, SegmentButtonV2Items, TabSegmentButtonV2 } from '@kit.ArkUI';
import { meowManagedSettings } from '../../../hosts/settings/classes/meowManagedSettings';
import { resourceColor2Metrics } from '../../../catstypicalframework/utils/ui';

@ComponentV2
struct SettingsOnStartUp {
  @Local myMeowManagedSettings: meowManagedSettings = AppStorageV2.connect(meowManagedSettings)!;
  @Local selectedForStartUp: number = this.selectedOptionFromSettings();

  build() {
    Column({ space: standardSpacing }) {
      Text($r('app.string.Settings_category_onStartUp'))
        .attributeModifier(new MooTextModifier(mooTextType.TITLE))
        .opacity(0.8)
        .padding({ left: standardSpacing / 2 });
      UniContentCard() {
        Text($r('app.string.Settings_category_onStartUp_page')).attributeModifier(new MooTextModifier());
        TabSegmentButtonV2({
          items: new SegmentButtonV2Items([
            { text: $r('app.string.Settings_category_onStartUp_page_newTab') },
            { text: $r('app.string.Settings_category_onStartUp_page_home') },
            { text: $r('app.string.Settings_category_onStartUp_page_continue') }
          ]),
          selectedIndex: this.selectedForStartUp!!,
          itemFontColor: resourceColor2Metrics(getColor(meowThemeColorType.FONT)),
          itemSelectedBackgroundColor: resourceColor2Metrics(getColor(useEffects() ? meowThemeColorType.PRIMARY : meowThemeColorType.FONT)),
          itemSelectedFontColor: useEffects() ? undefined : resourceColor2Metrics(getColor(meowThemeColorType.PRIMARY)),
          onItemClicked: (index) => {
            // 'new tab' | 'home' | 'continue'
            switch (index) {
              case 0:
                this.myMeowManagedSettings.setByIndex(32, 'new tab');
                break;
              case 1:
                this.myMeowManagedSettings.setByIndex(32, 'home');
                break;
              case 2:
                this.myMeowManagedSettings.setByIndex(32, 'continue');
                break;
              default:
                break;
            }
          }
        });
      };
    }
    .alignItems(HorizontalAlign.Start);
  }

  selectedOptionFromSettings() {
    const value = this.myMeowManagedSettings.settingsData[32].value as string;
    const seq = ['new tab', 'home', 'continue'];
    return seq.indexOf(value);
  }
}

export { SettingsOnStartUp };