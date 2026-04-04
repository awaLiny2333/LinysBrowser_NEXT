import { CatsTypicalFrameworkDevCard } from './framework/Card';
import { SettingsDevCard } from './settings/Card';
import { HistoryDevCard } from './history/Card';

@ComponentV2
struct CatsDevCards {
  build() {
    Column({ space: 5 }) {
      CatsTypicalFrameworkDevCard();
      SettingsDevCard();
      HistoryDevCard();
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%');
  }
}

export { CatsDevCards };
