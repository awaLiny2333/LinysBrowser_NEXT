import { defaultRoundedRadius } from "../../../catstypicalframework/utils/ui";

/**
 * Container for displaying content with a title (optional) and rounded corners (defaultRoundedRadius).
 */
@ComponentV2
struct UniContentCard {
  @BuilderParam contentsBuilder: () => void;
  @Param title: ResourceStr = '';
  @Param roundedRadius: number = defaultRoundedRadius;
  @Param blurRadius: number = 0;

  build() {
    Column({ space: 8 }) {
      if (this.title) {
        Text(this.title)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .padding({ bottom: 3 });
      }

      this.contentsBuilder();
    }
    .width('100%')
    .backgroundEffect({ color: $r('app.color.blur_background'), radius: this.blurRadius })
    .backgroundColor($r('app.color.blur_background'))
    .border({ radius: this.roundedRadius, width: 1, color: $r('sys.color.icon_fourth') })
    .padding(12)
    .alignItems(HorizontalAlign.Start);
  }
}

export { UniContentCard };