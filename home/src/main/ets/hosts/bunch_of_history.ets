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

  add_history(history: history_record, no_reconstruct_plain_history?: boolean) {
    let insert_position = this.find_index_of_first_not_smaller_than_timestamp(history.accessed_time);
    if (insert_position < 0) {
      insert_position = this.history_list.length;
    }
    this.history_list.splice(insert_position, 0, history);
    // console.log("[Meow][bunch_of_history] Added History @" + insert_position.toString() + ", link: " + history.link);
    if (no_reconstruct_plain_history) {
      return;
    }
    // get only 10000 records
    let slice: history_record[];
    if (this.history_list.length > 10000) {
      slice = this.history_list.slice(this.history_list.length - 10000);
    } else {
      slice = this.history_list;
    }
    this.reconstruct_cached_plain_history(slice);
  }

  remove_history(index: number) {
    this.history_list.splice(index, 1);
    // get only 10000 records
    let slice: history_record[];
    if (this.history_list.length > 10000) {
      slice = this.history_list.slice(this.history_list.length - 10000);
    } else {
      slice = this.history_list;
    }
    this.reconstruct_cached_plain_history(slice);
  }

  /**
   *
   * @param timestamp The target of timestamp.
   * @returns The first index of history item whose access_time is not smaller than Target;
   * @returns -1 if list is empty;
   * @returns -2 if Target is bigger than all histories。
   * */
  find_index_of_first_not_smaller_than_timestamp(timestamp: number) {
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
   * @param from The earliest timestamp.
   * @param to The most recent timestamp.
   * @returns The list of history[] in this period.
   * */
  get_history_slice(from?: number, to?: number) {
    if (this.history_list.length == 0) {
      return [];
    }
    if (from == undefined) {
      from = 0;
    }
    if (to == undefined) {
      to = this.history_list[this.history_list.length-1].accessed_time + 1;
    }
    if (from > to) {
      return [];
    }
    let from_index = this.find_index_of_first_not_smaller_than_timestamp(from);
    let to_index = this.find_index_of_first_not_smaller_than_timestamp(to);
    // Slice
    if (from_index < 0) {
      return [];
    }
    if (to_index < 0) {
      return this.history_list.slice(from_index);
    }
    return this.history_list.slice(from_index, to_index);
  }

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

  reconstruct_cached_plain_history(from_history_list: history_record[]) {
    this.cached_plain_history = [];
    for (let index = 0; index < from_history_list.length; index++) {
      let history_item = from_history_list[index];
      this.cached_plain_history.push([history_item.label, history_item.link]);
    }
    console.log("[bunch_of_history][plain_history] Reconstructed plain history! length: " +
    this.cached_plain_history.length.toString());
  }

  get_plain_label_link(): string[][] {
    if (this.cached_plain_history.length == 0) {
      // get only 10000 records
      let slice: history_record[];
      if (this.history_list.length > 10000) {
        slice = this.history_list.slice(this.history_list.length - 10000);
      } else {
        slice = this.history_list;
      }
      this.reconstruct_cached_plain_history(slice);
    }
    return this.cached_plain_history;
  }
}