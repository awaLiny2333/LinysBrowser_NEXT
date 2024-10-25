export class history_record {
  accessed_time: number = Date.now();
  label: string;
  link: string;

  constructor(label: string, link: string, accessed_time?: number) {
    if (accessed_time !== undefined) {
      this.accessed_time = accessed_time;
    }
    this.label = label;
    this.link = link;
  }
}

export class bunch_of_history {
  history_list: history_record[] = [];
  cached_plain_history: string[][] = [];
  plain_history_default_max_length: number = 100;

  constructor(plain_history_max_length?: number) {
    if (plain_history_max_length) {
      this.plain_history_default_max_length = plain_history_max_length;
    }
  }

  // Settings

  /**
   * @param max_length The default max length of plain history reconstruction.
   * */
  set_plain_max_length(max_length: number) {
    this.plain_history_default_max_length = max_length;
    this.reconstruct_plain_history();
  }

  // Use

  add_history(history: history_record, no_reconstruct_plain_history?: boolean) {
    let insert_position = this.index_of_record_after_time(history.accessed_time);
    if (insert_position < 0) {
      insert_position = this.history_list.length;
    }
    this.history_list.splice(insert_position, 0, history);

    if (no_reconstruct_plain_history) {
      return;
    }
    // reconstruct plain from only part of the records
    this.reconstruct_plain_history();
  }

  remove_history(index: number, no_reconstruct_plain_history?: boolean) {
    this.history_list.splice(index, 1);

    if (no_reconstruct_plain_history) {
      return;
    }
    // reconstruct plain from only part of the records
    this.reconstruct_plain_history();
  }

  // Internal functions

  /**
   *
   * @param timestamp The target of timestamp.
   * @returns The first index of history item whose access_time is not smaller than Target;
   * @returns -1 if list is empty;
   * @returns -2 if Target is bigger than all histories。
   * */
  index_of_record_after_time(timestamp: number) {
    if (this.history_list.length == 0) {
      return -1;
    }
    if (timestamp > this.history_list[this.history_list.length - 1].accessed_time) {
      return -2;
    }
    if (timestamp <= this.history_list[0].accessed_time) {
      return 0;
    }

    let start = 0;
    let end = this.history_list.length - 1;
    let mid = Math.floor((start + end) / 2);
    while (start <= end) {
      mid = Math.floor((start + end) / 2);
      let mid_time = this.history_list[mid].accessed_time;
      if (mid_time > timestamp) {
        end = mid - 1;
      }
      if (mid_time < timestamp) {
        start = mid + 1;
      }
      if (mid_time == timestamp) {
        while (mid > 0 && this.history_list[mid].accessed_time == timestamp) {
          // in case of same access_time
          // choose the front-most
          mid -= 1;
        }
        break;
      }
    }
    if (mid + 1 < this.history_list.length && this.history_list[mid].accessed_time < timestamp) {
      // Make sure the history at mid has an access_time equal to or larger than Target timestamp
      mid = mid + 1;
    }
    return mid;
  }

  /**
   *
   * @returns The list of history[] being less or equal than plain_history_default_max_length in length.
   * */
  get_latest_slice() {
    let max_length = this.plain_history_default_max_length;
    let slice: history_record[];

    if (this.history_list.length > max_length) {
      slice = this.history_list.slice(this.history_list.length - max_length);
    } else {
      slice = this.history_list;
    }
    return slice;
  }

  /**
   *
   * @param from_time The earliest timestamp.
   * @param to_time The most recent timestamp.
   * @returns The list of history[] in this period.
   * */
  get_part_slice(from_time?: number, to_time?: number) {
    if (this.history_list.length == 0) {
      return [];
    }
    if (from_time == undefined) {
      from_time = 0;
    }
    if (to_time == undefined) {
      to_time = this.history_list[this.history_list.length-1].accessed_time + 1;
    }
    if (from_time > to_time) {
      return [];
    }
    let from_index = this.index_of_record_after_time(from_time);
    let to_index = this.index_of_record_after_time(to_time);
    // Slice
    if (from_index < 0) {
      return [];
    }
    if (to_index < 0) {
      return this.history_list.slice(from_index);
    }
    return this.history_list.slice(from_index, to_index);
  }

  /**
   *
   * @param from_history_list The source of history records.
   * @abstract Sets / refreshes cached_plain_history: string[][].
   * */
  reconstruct_plain_history(from_history_list?: history_record[]) {
    // Default fallback
    if (from_history_list === undefined) {
      from_history_list = this.get_latest_slice();
    }

    this.cached_plain_history = [];
    for (let index = 0; index < from_history_list.length; index++) {
      let history_item = from_history_list[index];
      this.cached_plain_history.push([history_item.label, history_item.link]);
    }
    console.log("[bunch_of_history][plain_history] Reconstructed plain history! length: " +
    this.cached_plain_history.length.toString());
  }

  /**
   * @returns cached_plain_history.
   * @abstract if no cached history constructed, then reconstruct
   * */
  get_plain_history(): string[][] {
    if (this.cached_plain_history.length == 0) {
      this.reconstruct_plain_history();
    }
    return this.cached_plain_history;
  }

  // External interaction

  /**
   * @returns "\n" connected string of history records in the format of:
   * @returns [label] [link] [accessed_time]
   * */
  export_string() {
    let export_list: string[] = []
    for (let index = 0; index < this.history_list.length; index++) {
      let history_item: history_record = this.history_list[index];
      export_list.push(history_item.label);
      export_list.push(history_item.link);
      export_list.push(history_item.accessed_time.toString());
    }
    return export_list.join("\n");
  }

  /**
   * @param imp store string
   * @abstract In default overwrites whatever was in this history_list
   * */
  import_string(imp: string) {
    // console.log("[Meow][debug] Import " + imp.replaceAll("\n", " "));

    if (imp.split("\n").length % 3 > 0) {
      console.log("[Meow][bunch_of_history] Import Error: not 3*n length: " + imp)
      return;
    }

    this.history_list = [];
    // Clear
    let import_list: string[] = imp.split("\n");
    for (let index = 0; index < import_list.length; index += 3) {
      if (import_list[index] != "") {
        let new_history_record =
          new history_record(import_list[index], import_list[index+1], Number.parseInt(import_list[index+2]));
        this.add_history(new_history_record, true);
      }
    }
    console.log("[Meow][bunch_of_history] Import history success, length: " + this.history_list.length.toString())
  }
}