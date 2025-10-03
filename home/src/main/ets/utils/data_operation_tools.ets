import lazy { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import { url_resource_to_meow } from './url_tools';
import { collections } from '@kit.ArkTS';

/**
 * Syncs all tabs data into AppStorage.
 * */
export function sync_tabs_list_info() {
  let t0 = Date.now();
  let t = 0;
  // TODO: Efficiency can be further improved.
  // This should work
  let tabs = AppStorage.get('bunch_of_tabs') as bunch_of_tabs;
  let tab_titles = tabs.get_all_titles();
  let tab_urls = tabs.get_all_urls();
  let tab_is_loading = tabs.get_all_is_loading();
  let tab_loading_progresses = tabs.get_all_loading_progress();
  let tab_match_domains = tabs.get_all_match_domains();
  AppStorage.set('tab_titles', tab_titles);
  AppStorage.set('tab_urls', tab_urls);
  AppStorage.set('tab_is_loading', tab_is_loading);
  AppStorage.set('tab_loading_progresses', tab_loading_progresses);
  AppStorage.set('tab_match_domains', tab_match_domains);

  // Web Settings
  let tab_disable_js = tabs.get_all_disable_js();
  let tab_disable_image = tabs.get_all_disable_image();
  let tab_force_dark = tabs.get_all_force_dark();
  AppStorage.set('tab_disable_js', tab_disable_js);
  AppStorage.set('tab_disable_image', tab_disable_image);
  AppStorage.set('tab_force_dark', tab_force_dark);

  // Current
  let current_index = AppStorage.get('current_main_tab_index') as number;
  AppStorage.set('current_title', tab_titles[current_index]);
  AppStorage.set('current_url', url_resource_to_meow(tab_urls[current_index]));
  AppStorage.set('current_loading_progress', tab_loading_progresses[current_index]);
  AppStorage.set('current_is_loading', tab_is_loading[current_index]);
  AppStorage.set('current_match_domain', tab_match_domains[current_index]);
  // Set loading progress
  AppStorage.set('current_in_page_searching_keyword', tabs.workingMainTab().searching_keyword);
  AppStorage.set('current_in_page_searching_stats_current', tabs.workingMainTab().searching_keyword_stats_current);
  AppStorage.set('current_in_page_searching_stats_total', tabs.workingMainTab().searching_keyword_stats_total);
  // Web Settings
  AppStorage.set('current_disable_js', tab_disable_js[current_index]);
  AppStorage.set('current_disable_image', tab_disable_image[current_index]);
  AppStorage.set('current_force_dark', tab_force_dark[current_index]);

  // Timer
  t = Date.now() - t0;
  // console.log('[sync_tabs_list_info] Called! (' + t + ' ms)');
}

// Search and match

/**
 * Determines if a text matches with the keys given. Fuzzy to a hit rate of c.
 * @param text The text.
 * @param keys The keys.
 * @param c The minimum hit rate.
 * @returns A boolean stating they match or not.
 * */
function match_with_coefficient(text: string, keys: string[], c: number): boolean {
  let hits = 0;
  let miss = 0;
  for (let index = 0; index < keys.length; index++) {
    let hit = text.includes(keys[index]);
    hits += (hit ? 1 : 0);
    miss += (!hit ? 1 : 0);
    if (hits >= c * keys.length) {
      // console.log('[match_with_coefficient] ['+text+'] ['+keys[index]+'] Returned True');
      return true;
    }
    if (miss > (1 - c) * keys.length) {
      // console.log('[match_with_coefficient] ['+text+'] ['+keys[index]+'] Returned False');
      return false;
    }
  }
  // console.log('[match_with_coefficient] Returned Final False');
  return false;
}

/**
 * Determines if a label-link pair (label, link) matches the key word.
 * @param label The label.
 * @param link The link.
 * @param key The key to be searched.
 * @param filter The filter mode. 0 = Label, 1 = Link, 2 = Both.
 * @returns True if matches and False if doesn't meet requirement.
 * */
export function label_link_match_key(label: string, link: string, key: string[], filter: number, match_coefficient: number): boolean {
  if (filter == 0) {
    return match_with_coefficient(label, key, match_coefficient);
  }
  if (filter == 1) {
    return match_with_coefficient(link, key, match_coefficient);
  }
  return match_with_coefficient(label, key, match_coefficient) || match_with_coefficient(link, key, match_coefficient);
}

/**
 * Search a key in label_link_array.
 * @param label_link_array The label-link array. Each string[] is ['label', 'link'].
 * @param key The keyword.
 * @param match_coefficient The match coefficient, the minimum proportion of the key's components that should appear in a label-link pair.
 * @param max_result_number The maximum size of the returned array.
 * @returns The search result.
 * */
export function search_label_link(label_link_array: string[][], key: string, match_coefficient: number, max_result_number?: number) {

  // Early Exit
  if (key.length == 0) {
    return [];
  }

  // Get first filtered related items
  let result: string[][] = [];

  // Default fall back
  if (max_result_number == undefined) {
    max_result_number = 5;
  }

  // Process keyword
  key = key.toUpperCase();
  let keys: string[] = [];
  if (match_coefficient == 1) {
    keys.push(key);
  } else {
    keys = Array.from(divide_string(key));
  }
  // console.log('[Meow][search_label_link] search keywords: \n' + keys.join('\n'));

  // Add to the list
  for (let index = 0; index < label_link_array.length; index++) {
    if (label_link_match_key(label_link_array[index][0].toUpperCase(), label_link_array[index][1].toUpperCase(), keys, 2, 1)) {
      result.push(label_link_array[index]);
      if (result.length == max_result_number) {
        return result;
      }
    }
  }

  return result;
}

/**
 * Deduplicates a list of string pairs.
 * @param pairs The list of pairs of string, i.e. the list of string[] of size 2.
 * @returns A deduplicated list, with order maintained.
 * @author Generated by DeepSeek on 30th Sept, 2025, modified by awa_Liny
 * */
export function deduplicate_pairs(pairs: string[][]): string[][] {
  const seen = new Set<string>();
  const result: string[][] = [];

  for (const pair of pairs) {
    // 对每对字符串进行排序，使顺序一致
    const sortedPair = [...pair].sort();
    const key = sortedPair.join('\0'); // 使用分隔符连接

    if (!seen.has(key)) {
      seen.add(key);
      result.push(pair);
    }
  }

  return result;
}

// Array ops

/**
 * Constructs a boolean array of a specific length that contains only false values.
 * @param length The length of the array.
 * @returns The boolean array.
 * */
export function all_false(length: number) {
  let result: boolean[] = [];
  for (let index = 0; index < length; index++) {
    result.push(false);
  }
  return result;
}

/**
 * Constructs a boolean array of a specific length that contains only true values.
 * @param length The length of the array.
 * @returns The boolean array.
 * */
export function all_true(length: number) {
  let result: boolean[] = [];
  for (let index = 0; index < length; index++) {
    result.push(true);
  }
  return result;
}

/**
 * Divides an input into single chars (CJK) and leave words (Other) as words.
 * @param input the string to be divided
 * @returns a set of parts
 * @copyright Generated by DeepSeek on 13th May, 2025
 * */
export function divide_string(input: string): Set<string> {
  // 使用正则表达式匹配所有 CJK 字符（包括中文、日文汉字、韩文汉字等）
  const cjkRegex = /[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Hangul}]/gu;

  // 先按分隔符切分
  const parts = input.split(/[^\p{L}\p{N}]+/u);
  const result = new Set<string>();

  for (const part of parts) {
    if (part.length === 0) {
      continue;
    }

    let currentSegment = '';

    for (const char of part) {
      // 检查是否是 CJK 字符
      if (cjkRegex.test(char)) {
        // 如果是 CJK 字符，先把之前的非 CJK 段加入结果
        if (currentSegment.length > 0) {
          result.add(currentSegment);
          currentSegment = '';
        }
        // 加入 CJK 单字
        result.add(char);
        // 重置正则表达式的 lastIndex 因为我们在循环中使用 test()
        cjkRegex.lastIndex = 0;
      } else {
        // 非 CJK 字符，累积到当前段
        currentSegment += char;
      }
    }

    // 加入最后一个累积的非 CJK 段
    // Join the last cumulated non-CJK part
    if (currentSegment.length > 0) {
      result.add(currentSegment);
    }
  }

  return result;
}

/**
 * Inserts a number into given array in ascending order
 * @param arr the array
 * @param new_num the new number
 * @returns a new array of result
 * @author Generated by DeepSeek on 14th May, 2025, modified by awa_Liny
 * */
export function insert_into_array(arr: collections.Array<number>, new_num: number): collections.Array<number> {
  let left = 0;
  let right = arr.length;

  // 二分查找插入位置
  while (left < right) {
    const mid = Math.floor((left + right) / 2);
    if (arr[mid] < new_num) {
      left = mid + 1;
    } else {
      right = mid;
    }
  }

  // 创建新数组（原数组保持不变）
  try {
    return new collections.Array<number>(...arr.slice(0, left), new_num, ...arr.slice(left));
  } catch (e) {
    console.error('[insert_into_array] Error in building new array. ' + e);
    return new collections.Array<number>();
  }
}

// Types & conversions

/**
 * Converts a boolean to string.
 * @param bool A boolean.
 * @returns A string form of the boolean: 'true' | 'false'.
 * */
export function boolean_to_string(bool: boolean) {
  return bool ? 'true' : 'false';
}

/**
 * Converts a boolean to string.
 * @param str A string form of the boolean: 'true' | 'false'.
 * @returns A boolean, true if the str is exactly 'true'.
 * @returns A boolean, false if otherwise.
 * */
export function string_to_boolean(str: string) {
  return (str == 'true') ? true : false;
}