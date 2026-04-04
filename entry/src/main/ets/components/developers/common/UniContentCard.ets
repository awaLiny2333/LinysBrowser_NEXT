import { defaultRoundedRadius } from "../../../catstypicalframework/utils/ui";

/**
 * Container for displaying content with a title (optional) and rounded corners (defaultRoundedRadius).
 */
@ComponentV2
struct UniContentCard {
  @BuilderParam contentsBuilder: () => void;
  @Param title: ResourceStr = '';
  @Param roundedRadius: number = defaultRoundedRadius;

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
    .backgroundEffect({ color: $r('app.color.blur_background'), radius: 20 })
    .border({ radius: this.roundedRadius, width: 1, color: $r('sys.color.icon_fourth') })
    .padding(12)
    .alignItems(HorizontalAlign.Start);
  }
}

export { UniContentCard };