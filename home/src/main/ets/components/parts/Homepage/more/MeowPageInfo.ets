import { MooTextButton } from "../../../common/MooTextButton";
import { mooTextType } from "../../../constants";
import { isPreferRightHand } from "../../../settings";

@ComponentV2
export struct MeowPageInfo {
  @Param @Require title: string = 'Title';
  @Param @Require url: string = 'Url';
  // Events
  @Event requestCopy: (text: string) => void;

  build() {
    Column() {
      MooTextButton({
        text: this.title,
        opacityMe: 0.9,
        style: mooTextType.TITLE,
        maxLines: 3,
        clickAction: () => {
          this.requestCopy(this.title);
        }
      });
      MooTextButton({
        text: this.url,
        opacityMe: 0.75,
        maxLines: 3,
        clickAction: () => {
          this.requestCopy(this.url);
        }
      });
    }
    .alignItems(isPreferRightHand() ? HorizontalAlign.End : HorizontalAlign.Start)
    .width('100%');
  }
}
