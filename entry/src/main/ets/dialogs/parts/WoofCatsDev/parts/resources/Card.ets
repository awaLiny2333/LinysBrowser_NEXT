import { UniContentCard } from '../../../../../components/common/UniContentCard';
import { meowFlexOptions } from '../../../../../components/constants';
import { getMyResource } from '../../../../../hosts/system/storage/scripts/helpers';

/**
 * meowResources stuffs.
 */
@ComponentV2
struct ResourcesDevCard {
  build() {
    UniContentCard({ title: 'meowResources' }) {
      Text(`[backgroundImagePath] ${getMyResource().backgroundImagePath}`);
      Flex(meowFlexOptions) {
        Button('Pick Backdrop from Files')
          .onClick(() => {
            getMyResource().pickBackgroundImageFromDocuments();
          });
        Button('Pick Backdrop from Gallery')
          .onClick(() => {
            getMyResource().pickBackgroundImageFromGallery();
          });
      };
    };
  }
}

export { ResourcesDevCard };
