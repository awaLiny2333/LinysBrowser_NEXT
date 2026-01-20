@ObservedV2
export class CatStorage {
  public static singleton_: CatStorage;

  static instance() {
    if (!CatStorage.singleton_) {
      CatStorage.singleton_ = new CatStorage();
    }
    return CatStorage.singleton_;
  }
  @Trace public meow: string = 'woof';
}