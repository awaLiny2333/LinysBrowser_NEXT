import { default_search_engine } from '../hosts/bunch_of_defaults';
import { Want } from '@kit.AbilityKit';
import { meowContext } from './environment_tools';

2

/**
 * Process the search_input into a visitable address.
 * @param search_input A string, the user input to search or visit.
 * @returns A [string, boolean] array, string for the unified, visitable address,
 * while the boolean for whether the input itself is an address.
 * */
export function unify_search_input_into_url(search_input: string, auto_scheme_overwrite?: string) {
  if (search_input == "") {
    // if is empty
    return ["", false];
  }

  if (is_legal_ipv4(search_input)) {
    return [ensure_scheme(search_input, auto_scheme_overwrite ? auto_scheme_overwrite : "http") as string, true];
  }

  if (is_legal_url(search_input)) {
    return [ensure_scheme(search_input, auto_scheme_overwrite ? auto_scheme_overwrite : "https") as string, true];
  }

  let search_engine = AppStorage.get('search_engine') as string;
  if (search_engine === undefined) {
    search_engine = default_search_engine();
  }
  let url_processed = search_engine.replaceAll("%s", encodeURIComponent(search_input));
  return [url_processed as string, false];
}

function is_pure_number(input: string) {
  let processed_input = Number.parseInt(input).toString()
  if (processed_input == "NaN") {
    // If the first letter of input is not a number
    return false
  }
  return processed_input.length == input.length
}

function is_containing_number(input: string) {
  let input_replaced = input.replace(/\d+/g, "")
  if (input_replaced.length != input.length) {
    // if contains number
    return true;
  } else {
    return false;
  }
}

export function ensure_scheme(input: string, scheme?: string) {
  let url = input
  if (url.substring(0, 5) == 'data:') {
    // If is data
    return url;
  }
  if (url.includes("://")) {
    let url_split = url.split("/")
    if ((url_split[0].substring(url_split[0].length - 1) == ":") && (url_split[1] == "")) {
      // if input has a valid scheme
      return url;
    }
  }
  // if input needs a scheme
  if (scheme) {
    return scheme + "://" + url
  }
  return "http://" + url
}

function is_legal_ipv4(input: string) {
  if (input == "") {
    // if is empty
    return false;
  }

  // input = "https://114.114.114.114:32767/somewhat"

  input = match_domain(input)[1]
  // input = "114.114.114.114:32767/somewhat"
  input = input.split("/")[0]
  // eliminate slashes
  // input = "114.114.114.114:32767"
  let split_ports = input.split(":");
  input = split_ports[0]
  // eliminate ports
  // input = "114.114.114.114"

  let input_split = input.split(".")
  if (input_split.length != 4) {
    return false;
    // if the length of parts isn't 4
  }

  for (let index = 0; index < 4; index++) {
    let part = input_split[index]
    if (!is_pure_number(part)) {
      // if any part isn't a pure number
      return false;
    }
    let pure_number = Number.parseInt(part)
    if (!(0 <= pure_number && pure_number <= 255)) {
      // if any part not in legal range [0, 255]
      return false;
    }
  }

  // if there is a port
  if (split_ports.length == 2) {
    let port = split_ports[1];
    // examine ports, like 32767
    if (!is_pure_number(port)) {
      return false;
    }
    let port_int = Number.parseInt(port);
    if (!(0 <= port_int && port_int <= 65535)) {
      // if any part not in legal range [0, 255]
      // or port not in legal range [0, 65535]
      return false;
    }
  }

  return true;
}

function is_legal_url(input: string) {
  if (input == "") {
    // if is empty
    return false;
  }

  // input = "https://www.google.com/about"

  let scheme_result = match_domain(input);
  // scheme_result = ["https","www.google.com/about"]

  let scheme: string = scheme_result[0];

  // Other schemes, directly jump
  if (scheme.length >= 1 && !viewable_domains().includes(scheme)) {
    return true;
  }

  let url_first_part = scheme_result[1].split("/")[0].split(".")
  // eliminate slashes and split by dots
  // url_first_part = ["www", "google", "com"]

  if (url_first_part.length < 2 && scheme == "") {
    // if doesn't contain dots and has no scheme
    return false;
  }

  let top_domain = url_first_part[url_first_part.length - 1]
  // top_domain = "com"

  if (top_domain.length == 0) {
    // if url ends with a dot
    return false;
  }

  if (is_containing_number(top_domain)) {
    // if top domain contains numbers
    return false;
  }

  return true
}

let urls: string[] = [
  "resource://rawfile/home.html"
]

let built_ins: string[] = [
  "meow://home"
]

/**
 * Translates a url with resource:// to meow://
 * @param url The url.
 * @returns The translated url.
 * */
export function url_resource_to_meow(url: string) {
  let result: string = url;

  if (url == undefined) {
    return result;
  }
  if (url == null) {
    return result;
  }
  if (url == "") {
    return result;
  }
  // No process for empty inputs

  if (url.length > 11) {
    if (url.substring(0, 11) == "resource://") {
      let index = urls.indexOf(url)
      if (index != -1) {
        result = built_ins[index]
      } else {
        // If input is a non-existing resource:// url
      }
    }
  }
  return result;
}

/**
 * Translates a url with meow:// to resource://
 * @param url The url.
 * @returns The translated url.
 * */
export function url_meow_to_resource(url: string) {
  let result: string = url;

  if (url == undefined || url == null) {
    return result;
  }
  // No process for empty inputs

  if (url.length > 7) {
    if (url.substring(0, 7) == "meow://") {
      // if is meow:// scheme
      let index = built_ins.indexOf(url);
      if (index != -1) {
        // if this link exists
        result = urls[index];
      } else {
        // if this link of meow:// scheme doesn't exist
      }
    }
  }
  return result;
}

/**
 * Analyze an url and divides it into scheme and domain.
 *
 * If the input comes with no scheme then '' is returned in scheme field.
 * @param input the url
 * @returns ['scheme', 'domain']
 * */
export function match_domain(input: string) {
  let url = input
  let scheme: string = ""
  if (url.substring(0, 5) == 'data:') {
    return ['data', url.substring(6)];
  }
  if (url.includes("://")) {
    // if input contains protocol scheme
    let url_split = url.split("/");
    if ((url_split[0].substring(url_split[0].length - 1) == ":") && (url_split[1] == "")) {
      // if protocol scheme is at the beginning
      // url = url.split("/").slice(2).join("/");
      url = url.split("/")[2];
      scheme = url_split[0].split(":")[0];
    }
  }
  return [scheme, url];
}

/**
 * Domains that can be loaded and displayed in web components
 * @returns
 * */
export function viewable_domains() {
  return ['http', 'https', 'meow', 'resource', 'file'];
}

/**
 * Extracts search engine and search keyword from an url
 * @param url
 * @returns ['search.engine/q=%s', 'keyword']
 * */
export function extract_search(url: string) {
  // url = decodeURI(url);
  let result: string[] = ['', ''];

  let keys: string[] = ['q', 'query', 's', 'key', 'wd', 'w', 'word', 'searchKeyWord', 'search_text', 'keyword', 'val', 'value', 'text', 'tag', 'tags'];
  let search_keys: string[] = [];
  for (let k = 0; k < keys.length; k++) {
    search_keys.push('?' + keys[k] + '=');
  }
  for (let k = 0; k < keys.length; k++) {
    search_keys.push('&' + keys[k] + '=');
  }

  // Determine keyword
  let keyword: string = '';

  for (let s = 0; s < search_keys.length; s++) {
    let search_key: string = search_keys[s];
    let search_key_length: number = search_key.length;
    let search_key_index = url.indexOf(search_key);
    if (search_key_index > -1) {

      // Search key match
      let next_and_index = url.indexOf('&', search_key_index + search_key_length);
      if (next_and_index > -1) {
        // There is an '&' for end
        keyword = url.substring(search_key_index + search_key_length, next_and_index);
      } else {
        // There is no '&' for end
        keyword = url.substring(search_key_index + search_key_length);
      }

      result[0] = url.replaceAll(search_key + keyword, search_key + '%s');
      result[1] = keyword;
      result[1] = result[1].replaceAll('+', " ");
      try {
        result[1] = decodeURIComponent(result[1]);
      } catch (e) {
        result[1] = decodeURIComponent(result[1].replaceAll('%', '%25'));
      }
      return result;
    }
  }

  // ['baidu.com/s?q=%s','awa']
  return result;
}

/**
 * Analyze and divides the text data items and out put a unified list of texts and links
 * @param data_list strings
 * @returns [extracted_data: string[], extracted_type: string[]]
 * */
export function extract_links_from_text(data_list: string[]) {
  let extracted_data: string[] = [];
  let extracted_type: string[] = [];
  for (let index = 0; index < data_list.length; index++) {
    let text = data_list[index];
    // let match = text.match(/(file|https?|meow):\/\/[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]/g);
    let match = text.match(/([a-zA-Z][a-zA-Z0-9+.-]*):\/\/[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]/g);
    console.log('[extract_links_from_text] [' + match?.join("\n") + "]");
    if (match) {
      for (let inner = 0; inner < match.length; inner++) {
        let this_url = match[inner]
        let position = text.indexOf(this_url);
        if (text.substring(0, position).replace(/\s*/, "").length > 0) {
          extracted_data.push(text.substring(0, position).replaceAll(/(^\s*)|(\s*$)/g, ""));
          extracted_type.push("text");
        }
        extracted_data.push(this_url);
        if (this_url.substring(0, 4) == 'file') {
          // TODO: this is only valid when IMAGE is the only allowed file type.
          extracted_type.push("image");
        } else {
          extracted_type.push("url");
        }
        text = text.substring(position + this_url.length);
      }
    }
    if (text.replace(/\s*/, "").length > 0) {
      extracted_data.push(text.replaceAll(/(^\s*)|(\s*$)/g, ""));
      extracted_type.push("text");
    }
  }

  return [extracted_data, extracted_type]
}

/**
 * Determines if a link is downloadable.
 * @param link The url.
 * @returns [boolean, string(filename)] If it is downloadable.
 * */
export function is_downloadable(link: string) {
  try {
    let last_part = ((link.split('&')[0]).split('/').pop() || '').split('?')[0];
    if (last_part?.includes('.')) {
      // Has dot
      let filename = last_part;
      if (filename.length > 233) {
        filename = filename.substring(filename.length - 233, filename.length);
      }
      return [true, filename];
    }
  } catch (e) {
    console.error('[url_tools][is_downloadable] ' + e);
  }
  return [false, ''];
}

/**
 * Jumps to an external link using want.
 * @param link the link
 * */
export function jump_external_link(link: string) {
  // jump to url received
  const want: Want = {
    uri: link
  };
  meowContext().startAbility(want).then(() => {
    // Pull up success
    console.log('[Meow][jump_external_link] Pull up application for link ' + link + ' Success!');
  }).catch(() => {
    // Pull up failure
    console.error('[ERROR][Meow][url_tools] Pull up application for link ' + link + ' Failed!');
  });
}