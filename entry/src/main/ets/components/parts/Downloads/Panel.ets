import { MooTextModifier } from "../../common/MooTextModifier";
import { mooTextType, standardSpacing } from "../../constants";

@ComponentV2
export struct DownloadsPanel {
  @Param @Once needPadding: boolean = true;

  build() {
    Column() {
      Text($r('app.string.Downloads_title')).width('100%').attributeModifier(new MooTextModifier(mooTextType.TITLE)).opacity(0.75).textAlign(TextAlign.Center).padding(standardSpacing * 2);
    }
    .padding(this.needPadding ? standardSpacing : 0)
    .width('100%');
  }
}
