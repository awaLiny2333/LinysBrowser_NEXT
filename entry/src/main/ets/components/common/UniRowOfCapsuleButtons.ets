import { standardSpacing, summarizedPreferRightHand } from './constants';

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
    .direction(summarizedPreferRightHand() ? Direction.Rtl : Direction.Ltr)
    .alignSelf(summarizedPreferRightHand() ? ItemAlign.End : ItemAlign.Start);
  }
}

export { UniRowOfCapsuleButtons };
