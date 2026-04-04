import { UniContentCard } from '../common/UniContentCard';
import { AppStorageV2 } from '@kit.ArkUI';
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
      Button('Pick Backdrop from Files')
        .onClick(() => {
          this.myMeowResources.pickBackgroundImageFromDocuments();
        });
    };
  }
}

export { ResourcesDevCard };
