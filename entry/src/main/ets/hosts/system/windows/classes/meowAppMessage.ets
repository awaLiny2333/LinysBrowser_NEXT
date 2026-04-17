import { meowAppMessageType } from "../scripts/messaging";

/**
 * The message that can be shared across the entire app, across different windows / instances.
 */
@ObservedV2
export class meowAppMessage {
  @Trace type: meowAppMessageType;
  @Trace payload: object | string | boolean | number | undefined;
  @Trace timestamp: number = Date.now();

  constructor(type: meowAppMessageType, payload: object | string | boolean | number | undefined = undefined) {
    this.type = type;
    this.payload = payload;
  }
}
