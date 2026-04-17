import { UniContentCard } from '../../../../components/common/UniContentCard';
import { AppStorageV2 } from '@kit.ArkUI';
import { meowResources } from '../../../../hosts/env/classes/meowResources';
import { meowFlexOptions } from '../../../../components/settings';

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
