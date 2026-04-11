@ObservedV2
export class meowAvoid {
  @Trace top: number = 0;
  @Trace left: number = 0;
  @Trace right: number = 0;
  @Trace bottom: number = 0;

  constructor(t: number, b: number, l: number, r: number) {
    this.top = t;
    this.bottom = b;
    this.left = l;
    this.right = r;
  }
}
