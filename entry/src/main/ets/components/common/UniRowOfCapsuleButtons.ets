import { standardSpacing, isPreferRightHand } from '../settings';

/**
 * The special container to fit a row of capsule buttons, smart reachability compatible.
 * Use this container to contain a row of MooCapsuleButtons!
 */
@ComponentV2
struct UniRowOfCapsuleButtons {
  @BuilderParam contentsBuilder: () => void;

  build() {
    Row({ space: standardSpacing }) {
      this.contentsBuilder();
    }
    .direction(isPreferRightHand() ? Direction.Rtl : Direction.Ltr)
    .alignSelf(isPreferRightHand() ? ItemAlign.End : ItemAlign.Start);
  }
}

export { UniRowOfCapsuleButtons };
