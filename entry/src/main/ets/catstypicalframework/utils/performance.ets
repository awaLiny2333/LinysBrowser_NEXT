import { hiAppEvent, hilog } from '@kit.PerformanceAnalysisKit';

/**
 * Use hiAppEvent to monitor launch time.
 * @see https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/hiappevent-watcher-app-launch-arkts
 */
export function watchLaunch() {
  try {
    hiAppEvent.addWatcher({
      // 开发者可以自定义观察者名称，系统会使用名称来标识不同的观察者
      name: "watchLaunch",
      // 开发者可以订阅感兴趣的系统事件，此处是订阅了启动耗时事件
      appEventFilters: [
        {
          domain: hiAppEvent.domain.OS,
          names: [hiAppEvent.event.APP_LAUNCH]
        }
      ],
      // 开发者可以自行实现订阅回调函数，以便对订阅获取到的事件数据进行自定义处理
      onReceive: (domain: string, appEventGroups: Array<hiAppEvent.AppEventGroup>) => {
        hilog.warn(0x0000, 'testTag', `HiAppEvent onReceive: domain=${domain}`);
        for (const eventGroup of appEventGroups) {
          // 开发者可以根据事件集合中的事件名称区分不同的系统事件
          hilog.warn(0x0000, 'testTag', `HiAppEvent eventName=${eventGroup.name}`);
          for (const eventInfo of eventGroup.appEventInfos) {
            // 开发者可以对事件集合中的事件数据进行自定义处理，此处是将事件数据打印在日志中
            hilog.warn(0x0000, 'testTag', `HiAppEvent eventInfo=${JSON.stringify(eventInfo)}`);
          }
        }
      }
    });
  } catch (e) {
    hilog.error(0x0000, 'testTag', `HiAppEvent addWatcher error: ${JSON.stringify(e)}`);
  }
}