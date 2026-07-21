import { meow } from "../utils/catsLogger";

@ObservedV2
export class meowMisc {
  @Trace launchStartTime: number = Date.now();
  @Trace launchEndTime: number = -1;

  constructor() {
    meow('Initialized. launchStartTime: ' + this.launchStartTime, 'meowMisc');
  }
}
