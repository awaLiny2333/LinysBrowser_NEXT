import { UniContentCard } from '../common/UniContentCard';
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';
import { meowResources } from '../../../hosts/resources/classes/meowResources';

/**
 * meowResources stuffs.
 */
@ComponentV2
struct ResourcesDevCard {

  @Local myMeowResources: meowResources = AppStorageV2.connect(meowResources)!;

  build() {
    UniContentCard({ title: 'CatsTypicalFramework' }) {
      Text(`[backgroundImagePath] ${this.myMeowResources.backgroundImagePath}`);
      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        Button('Pick Backdrop from Files')
          .onClick(() => {
            this.myMeowResources.pickBackgroundImageFromDocuments();
          });
        Button('Pick Backdrop from Gallery')
          .onClick(() => {
            this.myMeowResources.pickBackgroundImageFromGallery();
          });
      };
    };
  }
}

export { ResourcesDevCard };
