import { collections, MessageEvents, worker } from '@kit.ArkTS';
import { sandbox_read_text_sync, sandbox_save } from '../utils/storage_tools';
import { bunch_of_history_index } from './bunch_of_history_index';
import { bunch_of_history_index_lite } from './bunch_of_history_index_lite';
import { fileIo } from '@kit.CoreFileKit';
import { meowContext } from '../utils/environment_tools';


/**
 * Calls a worker thread to load built index from disk.
 * @param load_type either "normal" or "reindex".
 * */
export function history_index_load_from_disk_worker(load_type: string) {
  let history_index_saving = AppStorage.get('history_index_saving') as boolean | undefined;
  let history_index_loading = AppStorage.get('history_index_loading') as boolean | undefined;
  let reindexing = AppStorage.get('reindexing_history') as boolean | undefined;

  if (history_index_saving == true) {
    console.log(bunch_of_history_index.log_head() +
      " A history_index_saving task is ongoing! Interrupted this history_index_load_from_disk_worker.")
    return;
  }
  if (history_index_loading == true) {
    console.log(bunch_of_history_index.log_head() +
      " Another history_index_loading task is ongoing! Interrupted this history_index_load_from_disk_worker.")
    return;
  }
  if (reindexing == true && load_type != 'reindex') {
    console.log(bunch_of_history_index.log_head() +
      " A reindexing task is ongoing! Interrupted this history_index_load_from_disk_worker.")
    return;
  }

  AppStorage.set('history_index_loading', true);

  ensure_this_month_index_file();

  let workerInstance = new worker.ThreadWorker("home/ets/workers/History_index_loader.ets");
  workerInstance.postMessage(AppStorage.get('history_index_load_quantity') as number);
  workerInstance.postMessage(meowContext().filesDir);

  console.log(bunch_of_history_index.log_head() + " Full Index loader worker CREATED!");

  workerInstance.onmessage = (e: MessageEvents): void => {
    if (typeof e.data == "string") {
      // Coming back with progress
      let data: string = e.data;
      AppStorage.set('history_index_loading_progress', data);
    } else {
      // Coming back with the whole set
      let result: collections.Array<collections.Map<string, collections.Array<number>>> = e.data;
      bunch_of_history_index.index_map = result[0];
      bunch_of_history_index_lite.index_map = result[1];

      // Set info for month_host (bunch_of_history_index_lite)
      const current_year: number = new Date().getUTCFullYear();
      const current_month: number = new Date().getUTCMonth() + 1;
      bunch_of_history_index_lite.this_year = current_year;
      bunch_of_history_index_lite.this_month = current_month;

      // STOP
      workerInstance.terminate();
      console.log(bunch_of_history_index.log_head() + " Got load result. Whole Map size: " + bunch_of_history_index.index_map.size.toString() + ".");
      console.log(bunch_of_history_index_lite.log_head() + " Got load result. Month Map size: " + bunch_of_history_index_lite.index_map.size.toString() + ".");
    }
  }
  workerInstance.onexit = (() => {
    console.log(bunch_of_history_index.log_head() + " Index loader worker TERMINATED!");

    // Set status
    if (load_type == 'reindex') {
      // Set status if this is part of reindexing
      console.log(bunch_of_history_index.log_head() + ' Index loader finished!');
      AppStorage.set('reindexing_history', false);
    }
    AppStorage.set('history_index_loading', false);
  })
}

/**
 * Calls a worker thread to save built index to disk.
 * @param map the map to be saved.
 * @param file_name the name of stored file, like 'index_2024_04_00_00_00_00_000'
 * */
export function history_index_save_to_disk_worker(map: collections.Map<string, collections.Array<number>>, file_name: string, clear: boolean) {
  let history_index_saving = AppStorage.get('history_index_saving') as boolean | undefined;
  let history_index_loading = AppStorage.get('history_index_loading') as boolean | undefined;
  let reindexing = AppStorage.get('reindexing_history') as boolean | undefined;

  if (history_index_saving == true) {
    console.log(bunch_of_history_index.log_head() + " Another history_index_saving task is ongoing! Interrupted this history_index_save_to_disk_worker.")
    return;
  }
  if (history_index_loading == true) {
    console.log(bunch_of_history_index.log_head() + " A history_index_loading task is ongoing! Interrupted this history_index_save_to_disk_worker.")
    return;
  }
  if (reindexing == true) {
    console.log(bunch_of_history_index.log_head() + " A reindexing task is ongoing! Interrupted this history_index_save_to_disk_worker.")
    return;
  }

  AppStorage.set('history_index_saving', true);

  // Get this month params
  let workerInstance = new worker.ThreadWorker("home/ets/workers/History_index_saver.ets");
  workerInstance.postMessage('filesDir:' + meowContext().filesDir);
  // workerInstance.postMessage('file_name:' + 'index.txt');
  workerInstance.postMessage('file_name:' + file_name);
  // workerInstance.postMessageWithSharedSendable(bunch_of_history_index.index_map);
  workerInstance.postMessage('clear:' + clear ? 'true' : 'false');
  // workerInstance.postMessageWithSharedSendable(bunch_of_history_index.index_map);
  workerInstance.postMessageWithSharedSendable(map);
  console.log(bunch_of_history_index.log_head() + " Index saver worker CREATED!");

  workerInstance.onmessage = (e: MessageEvents): void => {
    let data: string = e.data;
    // console.info("main thread data is  " + data);
    if (data == "done") {
      workerInstance.terminate();
      // Set status
      AppStorage.set('history_index_saving', false);
    } else {
      // Coming back with progress
      AppStorage.set('history_index_saving_progress', data);
    }
  }
  workerInstance.onexit = (() => {
    console.log(bunch_of_history_index.log_head() + " Index saver worker TERMINATED!");
    // AppStorage.set('history_index_saving_progress', "...");
  })
}

/**
 * Calls a worker thread to rebuild index for all history and saves (overwrites) the index file onto disk.
 *
 * This could avoid blocking the main thread.
 *
 * Adapted from https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-worker
 * */
export function history_index_full_rebuild_worker() {
  let history_index_saving = AppStorage.get('history_index_saving') as boolean | undefined;
  let history_index_loading = AppStorage.get('history_index_loading') as boolean | undefined;
  let reindexing = AppStorage.get('reindexing_history') as boolean | undefined;

  if (history_index_saving == true) {
    console.log(bunch_of_history_index.log_head() +
      " A history_index_saving task is ongoing! Interrupted this history_index_full_rebuild_worker.")
    return;
  }
  if (history_index_loading == true) {
    console.log(bunch_of_history_index.log_head() +
      " A history_index_loading task is ongoing! Interrupted this history_index_full_rebuild_worker.")
    return;
  }
  if (reindexing == true) {
    console.log(bunch_of_history_index.log_head() +
      " Another reindexing task is ongoing! Interrupted this history_index_full_rebuild_worker.")
    return;
  }

  AppStorage.set('reindexing_history', true);

  let workerInstance = new worker.ThreadWorker("home/ets/workers/History_indexer.ets");
  workerInstance.postMessage(meowContext().filesDir);
  console.log(bunch_of_history_index.log_head() + " Index worker CREATED!");

  workerInstance.onmessage = (e: MessageEvents): void => {
    let message: string = e.data;
    if (message == 'done') {
      // FINISH
      workerInstance.terminate();

      // Read from disk
      console.log("[Meow][bunch_of_history_index] Calling loader worker.");
      history_index_load_from_disk_worker('reindex');
    } else {
      // Coming back with progress
      let data: string = e.data;
      AppStorage.set('reindexing_history_progress', data);
    }
  }
  workerInstance.onexit = (() => {
    console.log(bunch_of_history_index.log_head() + " Index worker TERMINATED!");

    ensure_this_month_index_file();
  })
}

/**
 * Access the disk and returns the label-link string[][] histories for given timestamps
 * @param timestamps the timestamps of history
 * @param max max number of result
 * @returns the label-link string[][] histories, for example [["SEARCH", "bing.com"], ["CCW", "ccw.site"], ...]
 * */
export function get_histories_from_disk(timestamps: number[], max?: number): string[][] {
  let result: string[][] = [];
  if (timestamps.length == 0) {
    return [];
  }
  // console.log(log_head() + 'Starting to get history.')
  let year = new Date(timestamps[0]).getUTCFullYear();
  let month = new Date(timestamps[0]).getUTCMonth() + 1;
  let last_year = year;
  let last_month = month;
  let imp = sandbox_read_text_sync(history_path_of_month(year, month)).split("\n");
  // console.log(imp.join("\n"));
  let temp_pointer = -1;
  for (let index = 0; index < timestamps.length; index++) {
    const stamp = timestamps[index];
    // console.log("considering stamp: " + stamp.toString())

    year = new Date(stamp).getUTCFullYear();
    month = new Date(stamp).getUTCMonth() + 1;

    // Check if need to change file
    if (last_year != year || last_month != month) {
      imp = sandbox_read_text_sync(history_path_of_month(year, month)).split("\n");

      if (imp.length % 3 > 0 && imp.length > 1) {
        console.error("[ERROR][Meow][bunch_of_history_index] Open history Error: not 3*n length. Raw string: " + imp)
        return [];
      }
      last_year = year;
      last_month = month;
      temp_pointer = -1;
    }

    while (true) {
      temp_pointer += 3;
      if (parseInt(imp[temp_pointer]) > stamp) {
        // This history doesn't exist.
        // Maybe is deleted?
        // console.log(parseInt(imp[temp_pointer]).toString());
        // console.log(stamp.toString());
        console.error("[Meow][bunch_of_history_index] History missing!");
        temp_pointer -= 3;
        break;
      } else if (temp_pointer >= imp.length) {
        console.log(timestamps.toString());
        console.log(imp.join("\n"));
        console.error("[Meow][bunch_of_history_index] Rushed over end?");
        break;
      } else if (parseInt(imp[temp_pointer]) == stamp) {
        // Found
        result.push([imp[temp_pointer-2], imp[temp_pointer-1]]);
        if (max) {
          if (result.length >= max) {
            // Meets requirement of max results;
            // console.log("[Meow][bunch_of_history_index][get_history] Met max results! Quitting in advance.")
            return result;
          }
        }
        break;
      }
    }
  }

  // console.log(log_head() + "get_history result: " + result.toString());
  return result;
}

/**
 * Constructs the file path of history records in which history in [year, month] should be.
 * @param year A number, the year, like 2024.
 * @param month A number, the month, like 12.
 * @returns A string, 'history/history_year_month.txt'
 * */
export function history_path_of_month(year: number, month: number) {
  return 'history/' + history_file_name_of_month(year, month);
}

/**
 * Constructs the file name of history records in which history in [year, month] should be.
 * @param year A number, the year, like 2024.
 * @param month A number, the month, like 12.
 * @returns A string, 'history_YYYY_MM.txt'
 * */
export function history_file_name_of_month(year: number, month: number) {
  let month_unified = month.toString();
  if (month_unified.length == 1) {
    month_unified = '0' + month_unified;
  }
  return 'history_' + year.toString() + "_" + month_unified + '.txt';
}

/**
 * Constructs the file path of history index data in which history in [year, month] should be.
 * @param year A number, the year, like 2024.
 * @param month A number, the month, like 12.
 * @returns A string, 'history-index/index_year_month_00_00_00_00_000.txt'
 * */
export function index_path_of_month(year: number, month: number) {
  return 'history-index/' + index_file_name_of_month(year, month);
}

/**
 * Constructs the file name of history index data in which history in [year, month] should be.
 * @param year A number, the year, like 2024.
 * @param month A number, the month, like 12.
 * @returns A string, 'index_year_month_00_00_00_00_000.txt'
 * */
export function index_file_name_of_month(year: number, month: number) {
  let month_unified = month.toString();
  if (month_unified.length == 1) {
    month_unified = '0' + month_unified;
  }
  return 'index_' + year.toString() + "_" + month_unified + '_00_00_00_00_000.txt';
}

/**
 * Ensures that this month has an index file.
 *
 * If there doesn't exist such, then create one.
 * */
export function ensure_this_month_index_file() {
  // Create this month index
  const current_year: number = new Date().getUTCFullYear();
  const current_month: number = new Date().getUTCMonth() + 1;
  const this_month_file_path = index_path_of_month(current_year, current_month);
  if (!fileIo.accessSync(meowContext().filesDir + '/' + this_month_file_path)) {
    // If this month have no index
    console.log(bunch_of_history_index.log_head() + ' No this month index found. Creating one.')
    bunch_of_history_index_lite.this_year = current_year;
    bunch_of_history_index_lite.this_month = current_month;
    sandbox_save(this_month_file_path, '');
  }
}

/**
 * Ensures that this month has an history file.
 *
 * If there doesn't exist such, then create one.
 * */
export function ensure_this_month_history_file(context_filesDir?: string) {
  let filesDir: string = context_filesDir || meowContext().filesDir;
  // Create this month history
  const current_year: number = new Date().getUTCFullYear();
  const current_month: number = new Date().getUTCMonth() + 1;
  const this_month_file_path = history_path_of_month(current_year, current_month);
  if (!fileIo.accessSync(filesDir + '/' + this_month_file_path)) {
    // If this month have no history
    console.log('[Meow][bunch_of_history] No this month history found. Creating one.')
    sandbox_save(this_month_file_path, '', context_filesDir);
  }
}

/**
 * Generates fake history from a given year to another given year, inclusive.
 * @param from_year the starting year
 * @param to_year the ending year
 * @param quantity quantity of histories
 * @author Generated by DeepSeek on 17th May, 2025, modified by awa_Liny
 * */
export function fill_fake_history(from_year: number, to_year: number, quantity: number): void {
  // 生成月份时间戳范围（明确标注返回类型）
  const getMonthRanges = (): Array<[number, number]> => {
    const ranges: Array<[number, number]> = [];

    // 明确循环参数类型
    for (let year: number = from_year; year <= to_year; year++) {
      const maxMonth: number = (year === to_year) ? 11 : 11;

      for (let month: number = 0; month <= maxMonth; month++) {
        const start: number = Date.UTC(year, month, 1);
        const end: number = Date.UTC(year, month + 1, 1) - 1;
        ranges.push([start, end]);
      }
    }
    return ranges;
  };

  // 数量分配函数（明确参数和返回类型）
  const distributeQuantity = (total: number, months: number): number[] => {
    const base: number = Math.floor(total / months);
    const remainder: number = total % months;
    const result: number[] = [];

    for (let i: number = 0; i < months; i++) {
      result.push(base + (i < remainder ? 1 : 0));
    }
    return result;
  };

  // 主逻辑（明确所有变量类型）
  const monthRanges: Array<[number, number]> = getMonthRanges();
  const quantities: number[] = distributeQuantity(quantity, (1 + to_year - from_year) * 12);

  for (let index: number = 0; index < monthRanges.length; index++) {
    const currentRange: [number, number] = monthRanges[index];
    const start: number = currentRange[0];
    const end: number = currentRange[1];

    // 生成数据
    const monthData: string[] = fake_gen(start, end, quantities[index]);

    // 构造时间标签
    const date: Date = new Date(start);
    const year: number = date.getUTCFullYear();
    const monthNumber: number = date.getUTCMonth() + 1;
    const monthString: string = monthNumber.toString().padStart(2, "0");
    const monthLabel: string = `history/history_${year}_${monthString}.txt`;

    // 控制台输出
    console.log(monthLabel + ": " + monthData);
    sandbox_save(monthLabel, monthData.join("\n"));
  }
}

/**
 *
 * @param from min timestamp
 * @param to max timestamp
 * @param quantity total quantity of histories
 * @returns a string[] of history records in ascending order of timestamp,
 * like ["Quick Zone","www.healthcloud.com","1580515200000",...]
 * @author Generated by DeepSeek on 17th May, 2025, modified by awa_Liny
 * */
function fake_gen(from: number, to: number, quantity: number): string[] {
  // 生成随机网站名称
  const generateRandomName = (): string => {
    const prefixes = ['Cool', 'Best', 'Fast', 'Smart', 'Quick', 'Easy', 'Super'];
    const suffixes = ['Site', 'Web', 'Page', 'Portal', 'Hub', 'Zone'];
    const name_parts = [
      'Hub', 'Central', 'Portal', 'Network',
      "快递", "外卖", "地铁", "公交", "超市", "菜场", "早餐", "奶茶", "咖啡", "电梯",
      "充电", "流量", "WiFi", "密码", "排队", "扫码", "会员", "折扣", "发票", "收据",
      "车位", "堵车", "导航", "违章", "快递柜", "快递员", "外卖员", "保洁", "物业", "维修",
      "水电费", "燃气费", "物业费", "停车费", "话费", "宽带", "路由器", "遥控器", "充电器", "数据线",
      "洗衣机", "空调", "冰箱", "微波炉", "电磁炉", "电饭煲", "垃圾桶", "塑料袋", "保鲜膜", "洗洁精",
      "洗手液", "抽纸巾", "湿纸巾", "晾衣架", "拖把", "扫帚", "垃圾袋", "快递单", "外卖盒", "一次性",
      "便利店", "自助餐", "团购券", "优惠券", "会员卡", "积分卡", "停车场", "电梯间", "楼道灯", "门禁卡",
      "快递站", "外卖柜", "共享单车", "充电宝", "健康码", "行程码", "体温计", "口罩", "消毒液", "酒精棉",
      "工作群", "微信群", "表情包", "朋友圈", "点赞", "评论", "转发", "收藏", "截图", "录屏",
      "天气预报", "闹钟", "备忘录", "日历", "记事本", "文件夹", "打印机", "复印件", "扫描件", "电子版",
      "桌子", "椅子", "窗户", "书包", "水杯", "手机", "钥匙", "电视", "冰箱", "空调",
      "跑步", "阅读", "烹饪", "购物", "旅行", "学习", "工作", "休息", "聊天", "散步",
      "晴天", "雨天", "雪花", "云朵", "月亮", "星星", "阳光", "微风", "雷电", "彩虹",
      "医生", "教师", "司机", "厨师", "警察", "作家", "工程师", "画家", "护士", "记者",
      "苹果", "香蕉", "米饭", "面条", "鸡蛋", "牛奶", "面包", "咖啡", "西瓜", "番茄",
      "公园", "学校", "医院", "超市", "银行", "车站", "图书馆", "电影院", "健身房", "餐厅",
      "红色", "蓝色", "绿色", "黄色", "黑色", "白色", "紫色", "橙色", "灰色", "粉色",
      "猫咪", "狗狗", "鸟儿", "兔子", "金鱼", "蝴蝶", "蜜蜂", "蚂蚁", "熊猫", "老虎",
      "音乐", "电影", "游戏", "绘画", "舞蹈", "摄影", "写作", "编程", "园艺", "手工",
      "时间", "空间", "未来", "过去", "希望", "梦想", "勇气", "友谊", "爱情", "自由"
    ]
    const prefix = prefixes[Math.floor(Math.random() * prefixes.length)];
    const suffix = suffixes[Math.floor(Math.random() * suffixes.length)];
    const name1 = name_parts[Math.floor(Math.random() * name_parts.length)];
    const name2 = name_parts[Math.floor(Math.random() * name_parts.length)];
    return `${prefix} ${suffix} ${name1} ${name2}`;
  };

  const domainWords = [
    'shop', 'blog', 'news', 'tech', 'food', 'travel', 'book',
    'game', 'music', 'cloud', 'data', 'market', 'art', 'edu',
    'health', 'hub', 'lab', 'live', 'media', 'space', 'store',
    'tech', 'web', 'net', 'data', 'info', 'digital', 'cloud',
    'ai', 'code', 'app', 'dev', 'blog', 'news', 'world', 'online'
  ];

  // 生成有意义的域名组合
  const generateMeaningfulDomain = (): string => {
    // 随机选取两个单词组合
    const getRandomWord = () => domainWords[Math.floor(Math.random() * domainWords.length)];
    const word1 = getRandomWord();
    const word2 = getRandomWord();
    const word3 = getRandomWord();

    // 确保组合长度合理 (3-15字符)
    const combined = word1 + "." + word2 + "." + word3;
    return combined;
  };

  // 生成并排序时间戳
  const timestamps: number[] = [];
  for (let i = 0; i < quantity; i++) {
    const timestamp = Math.floor(Math.random() * (to - from + 1)) + from;
    timestamps.push(timestamp);
  }
  timestamps.sort((a, b) => a - b);

  // 构建结果数组
  const result: string[] = [];
  for (const timestamp of timestamps) {
    result.push(
      generateRandomName(),
      generateMeaningfulDomain(),
      timestamp.toString()
    );
  }

  return result;
}