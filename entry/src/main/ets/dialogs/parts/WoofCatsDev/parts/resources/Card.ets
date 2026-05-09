import { UniContentCard } from '../../../../../components/common/UniContentCard';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowFlexOptions } from '../../../../../components/constants';
import { meowResources } from '../../../../../hosts/system/storage/classes/meowResources';

/**
 * meowResources stuffs.
 */
@ComponentV2
struct ResourcesDevCard {

  @Local myResources: meowResources = AppStorageV2.connect(meowResources)!;

  build() {
    UniContentCard({ title: 'meowResources' }) {
      Text(`[backgroundImagePath] ${this.myResources.backgroundImagePath}`);
      Flex(meowFlexOptions) {
        Button('Pick Backdrop from Files')
          .onClick(() => {
            this.myResources.pickBackgroundImageFromDocuments();
          });
        Button('Pick Backdrop from Gallery')
          .onClick(() => {
            this.myResources.pickBackgroundImageFromGallery();
          });
      };
    };
  }
}

export { ResourcesDevCard };
