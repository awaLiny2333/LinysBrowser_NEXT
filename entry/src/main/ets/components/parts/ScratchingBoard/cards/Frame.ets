import { defaultInnerRadius } from "../../../../catstypicalframework/utils/ui";
import { meowThemeColorType, standardSpacing } from "../../../constants";
import { getColor, useEffects } from "../../../settings";

@ComponentV2
export struct ScratchingBoardCardFrame {
  @BuilderParam contentsBuilder: () => void;

  build() {
    Column() {
      this.contentsBuilder();
    }
    .width('100%')
    .backgroundColor(getColor(useEffects() ? meowThemeColorType.PRIMARY : meowThemeColorType.SECONDARY))
    .border({ radius: defaultInnerRadius, width: useEffects() ? 1 : 0, color: $r('sys.color.icon_fourth') })
    .padding(standardSpacing * 0.7)
    .alignItems(HorizontalAlign.Start);
  }
}
