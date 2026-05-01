import { hiAppEvent, hilog } from "@kit.PerformanceAnalysisKit";
import { saveHybrid } from "./storage";

export enum meowLevel {
  INFO = 1,
  WARN = 2,
  ERROR = 3,
}

export function meow(content: string, tag: string = '', level: meowLevel = meowLevel.INFO) {
  switch (level) {
    case meowLevel.INFO:
      console.log(`[meow][${tag}] ${content}`);
      break;
    case meowLevel.WARN:
      console.warn(`[meow][${tag}] ${content}`);
      break;
    case meowLevel.ERROR:
      console.error(`[meow][${tag}] ${content}`);
      break;
  }
}

/**
 * Listen for crash events.
 * @see https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/hiappevent-watcher-crash-events-arkts
 */
export function listenCrash(logDir: string) {
  // 添加崩溃事件观察者
  let watcher: hiAppEvent.Watcher = {
    // 开发者可以自定义观察者名称，系统会使用名称来标识不同的观察者
    name: 'meowCrashEventWatcher',
    // 开发者可以订阅感兴趣的系统事件，此处是订阅了崩溃事件
    appEventFilters: [
      {
        domain: hiAppEvent.domain.OS,
        names: [hiAppEvent.event.APP_CRASH]
      }
    ],
    // 开发者可以自行实现订阅实时回调函数，以便对订阅获取到的事件数据进行自定义处理
    onReceive: (domain: string, appEventGroups: Array<hiAppEvent.AppEventGroup>) => {
      hilog.warn(0x0000, 'meowTag', ' \n[listenCrash] Last crash:');
      hilog.warn(0x0000, 'meowTag', `HiAppEvent onReceive: domain=${domain}, let me tell you about it ／(=∵=)＼\n `);
      for (const eventGroup of appEventGroups) {
        // 开发者可以根据事件集合中的事件名称区分不同的系统事件
        hilog.warn(0x0000, 'meowTag', `> HiAppEvent eventName=${eventGroup.name}\n `);

        // Infos
        for (const eventInfo of eventGroup.appEventInfos) {
          const eventLogString = formatEventInfoString(eventInfo);

          // Save
          const eventLogFilePath = `${logDir}/${buildCrashLogFileName(eventInfo.params['time'])}.txt`;
          saveHybrid(eventLogFilePath, eventLogString, true);

          // Log
          hilog.warn(0x0000, 'meowTag', `Saved to [${eventLogFilePath}]:`);
          hilog.warn(0x0000, 'meowTag', eventLogString);
          hilog.warn(0x0000, 'meowTag', ' '); // End
        }
      }
      hilog.warn(0x0000, 'meowTag', ' '); // End
    }
  };
  try {
    hiAppEvent.addWatcher(watcher);
    meow('hiAppEvent.addWatcher(watcher); success!', 'catsLogger][listenCrash', meowLevel.INFO);
  } catch (e) {
    meow(`hiAppEvent.addWatcher(watcher); failed: ${e}`, 'catsLogger][listenCrash', meowLevel.ERROR);
  }
}

/**
 * Formats the crash info (hiAppEvent.AppEventInfo) into a single string.
 * @param eventInfo The event info to format.
 * @returns The info string.
 */
function formatEventInfoString(eventInfo: hiAppEvent.AppEventInfo) {
  return `Domain: ${eventInfo.domain}
Name: ${eventInfo.name}
EventType: ${eventInfo.eventType}
Time: ${eventInfo.params['time']} (${new Date(eventInfo.params['time']).toString()})
Crash_type: ${eventInfo.params['crash_type']}
Foreground: ${eventInfo.params['foreground']}
Release_type: ${eventInfo.params['release_type']}
Cpu_abi: ${eventInfo.params['cpu_abi']}
App_running_unique_id: ${eventInfo.params['app_running_unique_id']}
Bundle_version: ${eventInfo.params['bundle_version']}
Bundle_name: ${eventInfo.params['bundle_name']}
Pid: ${eventInfo.params['pid']}
Uid: ${eventInfo.params['uid']}
Uuid: ${eventInfo.params['uuid']}
Hilog.size: ${eventInfo.params['hilog'].length}
Process_life_time: ${eventInfo.params['process_life_time']}
Memory: ${JSON.stringify(eventInfo.params['memory'])}
External_log: ${JSON.stringify(eventInfo.params['external_log'])}
Log_over_limit: ${eventInfo.params['log_over_limit']}
Page_switch_log: ${JSON.stringify(eventInfo.params['page_switch_log'])}
Test_data: ${eventInfo.params['test_data']}

${eventInfo.params['exception'].message}
${eventInfo.params['exception'].name}
${eventInfo.params['exception'].stack}`.trimEnd();
}

/**
 * Builds the crash log file name.
 * @param timestampMs The timestamp in milliseconds.
 * @returns The file name.
 */
function buildCrashLogFileName(timestampMs: number) {
  const date = new Date(timestampMs);
  const pad = (num: number, len = 2) => String(num).padStart(len, '0');
  const Y = date.getFullYear();
  const M = pad(date.getMonth() + 1);
  const D = pad(date.getDate());
  const h = pad(date.getHours());
  const m = pad(date.getMinutes());
  const s = pad(date.getSeconds());
  const ms = pad(date.getMilliseconds(), 3);
  return `${Y}${M}${D}_${h}${m}${s}-${ms}.log`;
}
