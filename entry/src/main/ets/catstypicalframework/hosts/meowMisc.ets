import { meow } from "../utils/catsLogger";

@ObservedV2
export class meowMisc {
  @Trace launchStartTime: number;
  @Trace launchEndTime: number = -1;

  constructor(launchStartTime: number) {
    this.launchStartTime = launchStartTime;
    meow('Initialized. launchStartTime: ' + this.launchStartTime, 'meowMisc');
  }
}