import { path_2_uri } from "../../../catstypicalframework/utils/storage";
import { defaultInnerRadius } from "../../../catstypicalframework/utils/ui";
import { contextMenuImageWidth } from "../../../hosts/app/tabs/settings";
import { MooTextButton } from "../../common/MooTextButton";
import { standardSpacing } from "../../constants";

@ComponentV2
export struct oopsPreviewImage {
  @Param @Require source: string;
  @Param @Require localImagePath: string;
  // Events
  @Event requestVisit: (url: string) => void;
  @Event requestCloseMenu: () => void;

  build() {
    Column({ space: standardSpacing }) {
      Scroll() {
        if (this.localImagePath) {
          Image(path_2_uri(this.localImagePath)).width(contextMenuImageWidth());
        } else {
          MooTextButton({ text: $r('app.string.General_wait') });
        }
      }
      .borderRadius(6)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .onClick(() => {
        // preview_image(url, this.storage);
        this.requestVisit(this.source);
        this.requestCloseMenu();
      })
      .constraintSize({ maxHeight: contextMenuImageWidth() });
    }
    .alignItems(HorizontalAlign.Start)
    .borderRadius(defaultInnerRadius)
    .hoverEffect(HoverEffect.Highlight)
    .padding(standardSpacing * 0.5);
  }
}
