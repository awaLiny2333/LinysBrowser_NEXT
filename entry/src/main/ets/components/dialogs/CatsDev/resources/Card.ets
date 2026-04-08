import { UniContentCard } from '../common/UniContentCard';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowResources } from '../../../../hosts/resources/classes/meowResources';
import { meowFlexOptions } from '../../../common/constants';

/**
 * meowResources stuffs.
 */
@ComponentV2
struct ResourcesDevCard {

  @Local myMeowResources: meowResources = AppStorageV2.connect(meowResources)!;

  build() {
    UniContentCard({ title: 'meowResources' }) {
      Text(`[backgroundImagePath] ${this.myMeowResources.backgroundImagePath}`);
      Flex(meowFlexOptions) {
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
