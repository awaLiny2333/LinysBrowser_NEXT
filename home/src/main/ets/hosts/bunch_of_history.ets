import { sandbox_open_sync, sandbox_save, sandbox_unlink, sandbox_unlink_sync } from '../utils/storage_tools';
import { fileIo as fs } from '@kit.CoreFileKit';
import { bunch_of_history_index } from './bunch_of_history_index';
import {
  history_index_full_rebuild_worker,
  history_index_load_from_disk_worker,
  history_index_save_to_disk_worker
} from './bunch_of_history_index_functions';
import { bundleManager } from '@kit.AbilityKit';

export class history_record {
  accessed_time: number = Date.now();
  label: string;
  link: string;

  /**
   * history_record item, consists of a label, a link and an accessed timestamp.
   * @param label A string, the name of this bookmark.
   * @param link A string, the link of this bookmark.
   * @param accessed_time A number, the access time of this history (timestamp in milliseconds)
   * */
  constructor(label: string, link: string, accessed_time?: number) {
    if (accessed_time !== undefined) {
      this.accessed_time = accessed_time;
    }
    this.label = label;
    this.link = link;
  }

  shift_time() {
    this.accessed_time++;
  }
}

export class bunch_of_history {
  static history_index: bunch_of_history_index = new bunch_of_history_index();
  private history_this_month: history_record[] = [];
  private current_year: number = new Date().getUTCFullYear();
  private current_month: number = new Date().getUTCMonth() + 1;
  private current_opened_file_path: string = '';

  /**
   * A class holding a history_record[] array, in which there stores history_record objects.
   * @param no_init Will not open any data from disk nor do anything else.
   * Usually set true if this object is only created to sit the place of StorageLink initialization.
   */
  constructor(no_init?: boolean) {
    if (no_init == true) {
      return;
    }

    // // Compatibility path for older BrowserCats
    this.patch_old_history_files();
    this.patch_history_files_before_index_era();

    // Load today
    this.open_month_from_disk_sync(this.current_year, this.current_month);

    let data_raw = sandbox_open_sync('history-index/index.txt');
    if (data_raw == 'undefined') {
      console.log(bunch_of_history_index.log_head_worker() + ' No index found. ')
      console.log(bunch_of_history_index.log_head_worker() + ' Rebuilding... ')
      history_index_full_rebuild_worker();
    } else {
      // Load index
      // In a concurrent way?!
      history_index_load_from_disk_worker();
    }

    // Log
    console.log('[Meow][bunch_of_history] bunch_of_history initialization finished!');

    // Get app version info
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      sandbox_save("last_app_versionCode.txt", bundleInfo.versionCode.toString());
      sandbox_save("last_app_versionName.txt", bundleInfo.versionName);
    })
  }

  // Statics

  /**
   * Constructs the file name of history records in which history in [year, month] should be.
   * @param year A number, the year, like 2024.
   * @param month A number, the month, like 12.
   * @returns A string, 'history/history_year_month.txt'
   * */
  static history_path_of_month(year: number, month: number) {
    let month_unified = month.toString();
    if (month_unified.length == 1) {
      month_unified = '0' + month_unified;
    }
    return 'history/history_' + year.toString() + "_" + month_unified + '.txt';
  }

  /**
   * Connects a year and a month to string.
   * @param year A number, the year.
   * @param month A number, the month.
   * @returns A string, in the format (year - month).
   * */
  static year_month_to_string(year: number, month: number) {
    return "(" + year.toString() + " - " + month.toString() + ")"
  }

  /**
   * Lists all the months in which ther are history records made.
   * @returns A number[][] array, e.g. [[2024, 2], [2023, 4], ...].
   * */
  static get_history_months(context_filesDir?: string) {
    bunch_of_history.check_disk_month(new Date().getUTCFullYear(), new Date().getUTCMonth() + 1, context_filesDir);
    let filesDir: string = context_filesDir || getContext().filesDir;
    let result: number[][] = [];
    let history_files = fs.listFileSync(filesDir + '/history', { recursion: false });
    for (let index = 0; index < history_files.length; index++) {
      let f_name = history_files[index].split('.')[0];
      // 'history_2024_02.txt'
      let f_split = f_name.split('_');
      let year = parseInt(f_split[1]);
      let month = parseInt(f_split[2]);
      result.push([year, month]);
    }
    result = result.sort((a, b) => (b[0] * 12 + b[1]) - (a[0] * 12 + a[1]));
    console.log('[Meow][bunch_of_history] Got_available_months. Result: ' + result.join(' ') + '.')
    return result;
  }

  /**
   * Check the history file structure on disk.
   * After executing this, there will be ENSURED a history/history_year_month.txt existing for use.
   * */
  static check_disk_month(year: number, month: number, context_filesDir?: string) {
    let filesDir: string = context_filesDir || getContext().filesDir;
    let new_history = true;
    try {
      fs.mkdirSync(filesDir + '/history');
    } catch (e) {
      // console.log('[Meow][bunch_of_history] Check disk of month: E: /history folder already exists.')
      new_history = false;
    }

    let history_year_month_path = bunch_of_history.history_path_of_month(year, month);

    if (new_history) {
      // no history before, like the first use of entire app
      console.log("[Meow][bunch_of_history] Check disk of month: NO HISTORY EVER BEFORE! Creating an empty one.");
      sandbox_save(history_year_month_path, '', context_filesDir);
    } else {
      // check if this month have a history
      let this_month_history = sandbox_open_sync(history_year_month_path, context_filesDir);
      if (this_month_history as string == "undefined") {
        // This month doesn't have a history file
        console.log("[Meow][bunch_of_history] Check disk of month: NO HISTORY FOR " +
        bunch_of_history.year_month_to_string(year, month) + ', creating an empty one.');
        sandbox_save(history_year_month_path, '', context_filesDir);
      } else {
        // This month has an existing history file
        console.log("[Meow][bunch_of_history] Check disk of month: Found existing history for this month " +
        bunch_of_history.year_month_to_string(year, month) + "!");
      }
    }
  }

  /**
   * Search all histories with help of index
   * @param key the search key
   * @param max_result_number max result number. if not filled then unlimited.
   * @returns label-link string[][]
   * */
  static search_with_index(key: string, max_result_number?: number): string[][] {
    // Timer
    let s = Date.now();
    // console.log('[Meow][bunch_of_history_index] Start Searching with Index! Start: ' + s.toString())

    let result = bunch_of_history_index.search_history_label_link(key, max_result_number);
    let result_count = result.length;
    if (result.length > 0) {
      console.log('[Meow][bunch_of_history][bunch_of_history_index] ' + result_count.toString() + ' results of Key "' +
        key + '" searched in ' + (Date.now() - s).toString() + "ms among " +
      bunch_of_history_index.index_map.size.toString() + " possibilities!");
    }
    return result;
  }

  // PATCHES

  /**
   * Executed when an old format history.txt is found.
   * This migrates old histories to new format and deletes the old file.
   * */
  patch_old_history_files() {
    let old_history = sandbox_open_sync('history.txt');
    if (old_history != 'undefined') {
      console.log('[Meow][bunch_of_history] Patch old history: found old history:\n' + old_history.toString())
      this.import_string_full(old_history);
      sandbox_unlink_sync('history.txt');
    }
  }

  /**
   * This migration happens between 1.7.6(1000024) and 1.7.7(1000025)
   * to switch all original timestamps into UTC time.
   * */
  patch_history_files_before_index_era() {
    let version_file = sandbox_open_sync('last_app_versionCode.txt');
    if (version_file != 'undefined') {
      return;
    }
    console.log('[Meow][bunch_of_history] Patch old history of migration happens between 1.7.6(1000024) and 1.7.7(1000025).')

    let result: string = "";
    let months = bunch_of_history.get_history_months();
    for (let index = 0; index < months.length; index++) {
      const year = months[index][0];
      const month = months[index][1];
      const path = bunch_of_history.history_path_of_month(year, month);
      if (result == "") {
        result = sandbox_open_sync(path);
      } else {
        result = result + "\n" + sandbox_open_sync(path);
      }
      // console.log(result.split("\n").length.toString());
    }

    // clear history
    try {
      let filesDir = getContext().filesDir;
      fs.rmdirSync(filesDir + "/history");
      fs.mkdirSync(filesDir + "/history")
    } catch (e) {
      console.error(e)
    }

    this.import_string_full(result);
  }

  // Properties

  get_current_year() {
    return this.current_year;
  }

  get_current_month() {
    return this.current_month;
  }

  get_history_this_month() {
    return this.history_this_month;
  }

  // Operations

  /**
   * Adds a history, automatically puts it in the order of time.
   * @param history A history_record object.
   * @param no_reconstruct_plain_history A boolean, will not reconstruct plain history cache if set true.
   * */
  add_history(history: history_record, instantly_save_to_disk: boolean) {
    let history_date = new Date(history.accessed_time);
    let year = history_date.getUTCFullYear();
    let month = history_date.getUTCMonth() + 1;

    // Opens the month required
    this.open_month_from_disk_sync(year, month);

    let insert_position = this.index_of_first_record_at_or_after_time(history.accessed_time);
    if (insert_position < 0) {
      insert_position = this.history_this_month.length;
    } else {
      // Avoid same accessed_time
      while (this.history_this_month[insert_position].accessed_time == history.accessed_time) {
        insert_position++;
        history.shift_time();
        if (insert_position >= this.history_this_month.length) {
          insert_position = this.history_this_month.length;
          break;
        }
      }
    }
    // check if this reaches next month
    let new_history_date = new Date(history.accessed_time);
    let new_year = new_history_date.getUTCFullYear();
    let new_month = new_history_date.getUTCMonth() + 1;
    if (new_year * 100 + new_month != year * 100 + month) {
      // Reaches another month
      this.add_history(history, instantly_save_to_disk);
    } else {
      // Still in this month
      this.history_this_month.splice(insert_position, 0, history);
      // Saving
      if (instantly_save_to_disk) {
        this.save_month_to_disk();
        // Indexing
        let history_index_loading = AppStorage.get('history_index_loading') as boolean;
        if (history_index_loading) {
          // Loading task is ongoing
          console.log("[Meow][bunch_of_history][bunch_of_history_index] History_index_loading task is ongoing! " +
            "Interrupted this one.")
        } else {
          // Add to index
          try {
            // TODO: IMPROVE THIS LOGIC to avoid missing add_index_string jobs.
            // This try catch is just to avoid crashes.
            bunch_of_history_index.add_index_string(history.label + " " + encodeURI(history.link),
              history.accessed_time);
          } catch (e) {
            console.error(e);
          }
        }

        console.log("[Meow][bunch_of_history][bunch_of_history_index] Storing index. Size: " +
        bunch_of_history_index.index_map.size.toString());
        // save_index_ext(bunch_of_history_index.index_map);
        history_index_save_to_disk_worker();
      }
    }
  }

  /**
   * Removes some selected histories, according to a given array of indices.
   *
   * Should be preferred when deleting a lot of history records.
   * @param indices A number[] array, indicating the indices of the items to be deleted.
   * @param no_reconstruct_plain_history A boolean, will not reconstruct plain history cache if set true.
   * */
  remove_history_at_indices(year: number, month: number, indices: number[], instantly_save_to_disk: boolean) {

    // Opens the month required
    this.open_month_from_disk_sync(year, month);

    indices.sort((a, b) => {
      return a - b;
    });

    let selected = new Array<boolean>(this.history_this_month.length);
    let result_history: history_record[] = [];

    for (let i = 0; i < indices.length; i++) {
      selected[indices[i]] = true;
    }

    for (let i = 0; i < this.history_this_month.length; i++) {
      if (selected[i] == true) {
        // Marked to be deleted
      } else {
        result_history.push(this.history_this_month[i]);
      }
    }

    this.history_this_month = result_history;

    // Save
    if (instantly_save_to_disk) {
      this.save_month_to_disk();
    }

    // TODO: this should be improved to save rebuild time when deleting something!!
    // bunch_of_history_index.rebuild_full_history_index();
  }

  /**
   * Get the index of the first history item whose access_time is not smaller than Target.
   * @param timestamp The limit of earliest timestamp.
   * @returns A positive number, the index.
   * @returns -1 if list is empty.
   * @returns -2 if Target is bigger than all histories.
   * */
  index_of_first_record_at_or_after_time(timestamp: number) {
    if (this.history_this_month.length == 0) {
      return -1;
    }
    if (timestamp > this.history_this_month[this.history_this_month.length - 1].accessed_time) {
      return -2;
    }
    if (timestamp <= this.history_this_month[0].accessed_time) {
      return 0;
    }

    // Binary search
    let start = 0;
    let end = this.history_this_month.length - 1;
    let mid = Math.floor((start + end) / 2);
    while (start <= end) {
      mid = Math.floor((start + end) / 2);
      let mid_time = this.history_this_month[mid].accessed_time;
      if (mid_time > timestamp) {
        end = mid - 1;
      }
      if (mid_time < timestamp) {
        start = mid + 1;
      }
      if (mid_time == timestamp) {
        while (mid > 0 && this.history_this_month[mid].accessed_time == timestamp) {
          // in case of same access_time
          // choose the front-most
          mid -= 1;
        }
        break;
      }
    }
    if (mid + 1 < this.history_this_month.length && this.history_this_month[mid].accessed_time < timestamp) {
      // Make sure the history at mid has an access_time equal to or larger than Target timestamp
      mid = mid + 1;
    }
    return mid;
  }

  // Saving

  /**
   * Opens a month of history using lite import, that is, assuming all of them are in time range one month.
   * @param path A string, the path of the file.
   * */
  open_month_from_disk_sync(year: number, month: number) {
    if (bunch_of_history.history_path_of_month(year, month) == this.current_opened_file_path) {
      // Already opened
      // console.log('already opened')
      return;
    }
    bunch_of_history.check_disk_month(year, month);
    let path = bunch_of_history.history_path_of_month(year, month);
    let the_file = sandbox_open_sync(path);
    this.current_opened_file_path = path;
    this.current_year = year;
    this.current_month = month;
    if (the_file == "undefined") {
      return;
    }
    this.import_string_lite(the_file);
  }

  /**
   * Saves the current opened file to disk
   * */
  save_month_to_disk() {
    sandbox_save(this.current_opened_file_path, this.export_string());
  }

  /**
   * Export history records in a specific plain text format.
   * @returns "\n" connected string of history records in the format of:
   * @example 'bing\nbing.com\n127771721'
   * */
  private export_string() {
    let export_list: string[] = []
    for (let index = 0; index < this.history_this_month.length; index++) {
      let history_item: history_record = this.history_this_month[index];
      export_list.push(history_item.label);
      export_list.push(history_item.link);
      export_list.push(history_item.accessed_time.toString());
    }
    return export_list.join("\n");
  }

  /**
   * Import history records in a specific plain text format.
   *
   * In default overwrites whatever was in this history_list.
   * @param imp The string in the correct format:
   * @example 'bing\nbing.com\n127771721'
   * */
  private import_string_full(imp: string) {
    let import_list: string[] = imp.split("\n");
    if (import_list.length % 3 > 0) {
      // Incorrect format, log an error.
      // Though this is not very likely to happen so often
      // since all the txt files are generated by a fixed algorithm.
      console.error("[ERROR][Meow][bunch_of_history] Import history Error: not 3*n length. Raw string: \n" + imp)
      return;
    }

    console.log("[Meow][bunch_of_history] Starting to import history");
    let start_time = Date.now();

    // Clear
    this.history_this_month = [];

    let last_month = [0, 0];
    for (let index = 0; index < import_list.length; index += 3) {
      // if (index % (3 * 10) == 0) {
      //   console.log("[Meow][bunch_of_history] Import progress: " + (index * 100 / import_list.length).toFixed(2) + "%")
      // }
      if (import_list[index] != "") {
        let access_time = Number.parseInt(import_list[index+2]);
        let access_Date = new Date(access_time);
        let new_month = [new Date(access_time).getUTCFullYear(), new Date(access_time).getUTCMonth() + 1];

        if ((last_month[0] != new_month[0]) || (last_month[1] != new_month[1])) {
          // if changed month, then save this file
          if ((last_month[0] != 0) && (last_month[1] != 0)) {
            console.log('[Meow][bunch_of_history] Import history saved month ' + last_month.toString() + 'to disk.');
            this.save_month_to_disk();
            this.history_this_month = []; // I believe this should be added
          }
        }

        let new_history_record = new history_record(import_list[index], import_list[index+1], access_time);
        this.add_history(new_history_record, false);

        last_month = [access_Date.getUTCFullYear(), access_Date.getUTCMonth() + 1];
      }
    }
    this.save_month_to_disk();
    console.log('[Meow][bunch_of_history] Import history success! Time used: ' +
    (Date.now() - start_time).toString() + "ms.");
  }

  /**
   * Import history records in a specific plain text format.
   *
   * Assuming that all records are in one month.
   *
   * In default overwrites whatever was in this history_list.
   * @param imp The string in the correct format:
   * @example 'bing\nbing.com\n127771721'
   * */
  private import_string_lite(imp: string) {
    let import_list: string[] = imp.split("\n");
    if (import_list.length % 3 > 0) {
      // Incorrect format, log an error.
      // Though this is not very likely to happen so often
      // since all the txt files are generated by a fixed algorithm.
      console.error("[ERROR][Meow][bunch_of_history][lite] Import history Error: not 3*n length. Raw string: \n" + imp)
      return;
    }

    console.log("[Meow][bunch_of_history][lite] Starting to import history");
    let start_time = Date.now();

    // Clear
    this.history_this_month = [];

    for (let index = 0; index < import_list.length; index += 3) {
      // if (index % 1000 == 0) {
      //   console.log("[Meow][bunch_of_history][lite] Import progress: " + (index * 100 / import_list.length).toFixed(2) +
      //     "%")
      // }
      let access_time = Number.parseInt(import_list[index+2]);
      let new_history_record = new history_record(import_list[index], import_list[index+1], access_time);
      this.add_history(new_history_record, false);
    }

    console.log('[Meow][bunch_of_history][lite] Import history success! Time used: ' +
    (Date.now() - start_time).toString() + "ms.");
  }
}

/**
 * Generates fake history from 2020 to 2024 in total 60 months.
 * @param quantity
 * @author Generated by DeepSeek on 17th May, 2025, modified by awa_Liny
 * */
export function fill_fake_history(quantity: number): void {
  // 生成月份时间戳范围（明确标注返回类型）
  const getMonthRanges = (): Array<[number, number]> => {
    const ranges: Array<[number, number]> = [];

    // 明确循环参数类型
    for (let year: number = 2020; year <= 2024; year++) {
      const maxMonth: number = (year === 2024) ? 11 : 11;

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
  const quantities: number[] = distributeQuantity(quantity, 60);

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