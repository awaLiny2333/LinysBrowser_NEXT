import { MooTextModifier } from '../../../../components/common/MooTextModifier';
import { meowFlexOptions, mooTextType, standardSpacing } from '../../../../components/constants';
import { meowUiHost } from '../../../../hosts/system/windows/classes/meowUiHost';
import { CreditDetails } from '../creditDetails';
import { CreditCard } from './CreditCard';

@ComponentV2
struct CreditUser {
  @Param @Require details: CreditDetails;
  @Param @Require myUi: meowUiHost;
  // Events
  @Event requestVisit: (url: string) => void;

  build() {
    Column({ space: standardSpacing }) {
      // ID
      Text(this.details.name).attributeModifier(new MooTextModifier(mooTextType.TITLE)).padding({ left: standardSpacing * 0.5, right: standardSpacing * 0.5 });
      // Contributions
      Flex(meowFlexOptions) {
        Repeat(this.details.contributions).each((con) => {
          CreditCard({
            myUi: this.myUi,
            item: con.item,
            requestVisit: (url: string) => {
              this.requestVisit(url);
            }
          });
        });
      }
      .height('auto')
      .width('auto');
    }
    .padding({ left: standardSpacing, right: standardSpacing })
    .alignItems(HorizontalAlign.Start);
  }
}

export { CreditUser };
