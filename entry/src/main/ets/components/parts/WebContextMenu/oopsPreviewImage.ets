import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { contextMenuImageWidth } from "../../../hosts/app/tabs/settings";
import { MooTextModifier } from "../../common/MooTextModifier";
import { standardSpacing } from "../../constants";

@ComponentV2
export struct oopsPreviewImage {
  @Param @Require url: string;
  // UI
  @Local imageWidth: number = 0;
  @Local imageHeight: number = 0;
  @Local imageSize: string = '';
  // Events
  @Event requestVisit: (url: string) => void;
  @Event requestCloseMenu: () => void;

  build() {
    Column({ space: standardSpacing }) {
      Scroll() {
        Image(this.url)
          .width(contextMenuImageWidth())
          .onComplete((event) => {
            this.imageWidth = event?.width || 0;
            this.imageHeight = event?.height || 0;
            this.imageSize = this.imageWidth + 'x' + this.imageHeight;
            // console.info('imageWidth:'+imageWidth,'imageHeight:'+imageHeight);
          });
      }
      .borderRadius(6)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .onClick(() => {
        // preview_image(url, this.storage);
        this.requestVisit(this.url);
        this.requestCloseMenu();
      })
      .constraintSize({ maxHeight: contextMenuImageWidth() });

      Text(this.imageSize).attributeModifier(new MooTextModifier()).opacity(0.75);
    }
    .alignItems(HorizontalAlign.Start)
    .borderRadius(defaultInnerRadius)
    .hoverEffect(HoverEffect.Highlight)
    .padding(standardSpacing * 0.5);
  }
}
