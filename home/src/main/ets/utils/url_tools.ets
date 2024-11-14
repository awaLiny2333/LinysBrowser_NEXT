export function unify_search_input_into_url(search_input: string) {
  let url = search_input

  if (url == "") {
    // if is empty
    return ""
  }

  if (is_legal_ipv4(url)) {
    return ensure_scheme_or_https(encodeURI(url)) as string
  }

  if (is_legal_url(url)) {
    return ensure_scheme_or_https(encodeURI(url)) as string
  }

  let search_engine = AppStorage.get('search_engine') as string;
  if (search_engine === undefined) {
    search_engine = "https://bing.com/search?q=%s";
  }
  let url_processed = search_engine.replace("%s", url);
  return encodeURI(url_processed) as string;
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

function eliminate_protocol_scheme(input: string) {
  let url = input
  let scheme: string = ""
  if (url.includes("://")) {
    // if input contains protocol scheme
    let url_split = url.split("/")
    if ((url_split[0].substring(url_split[0].length - 1) == ":") && (url_split[1] == "")) {
      // if protocol scheme is at the beginning
      url = url.split("/").slice(2).join("/")
      scheme = url_split[0].split(":")[0]
    }
  }
  return [scheme, url];
}

export function ensure_scheme_or_https(input: string) {
  let url = input
  if (url.includes("://")) {
    let url_split = url.split("/")
    if ((url_split[0].substring(url_split[0].length - 1) == ":") && (url_split[1] == "")) {
      // if input has a valid scheme
      return url;
    }
  }
  // if input needs a scheme
  return "https://" + url
}

function is_legal_ipv4(input: string) {
  if (input == "") {
    // if is empty
    return false;
  }

  // input = "https://114.114.114.114/somewhat"

  input = eliminate_protocol_scheme(input)[1]
  // input = "114.114.114.114/somewhat"
  input = input.split("/")[0]
  // eliminate slashes
  // input = "114.114.114.114"

  let input_split = input.split(".")
  if (input_split.length != 4) {
    return false;
    // if the length of parts isn't 4
  }

  for (let index = 0; index < input_split.length; index++) {
    let part = input_split[index]
    if (is_pure_number(part)) {
      let pure_number = Number.parseInt(part)
      if (pure_number > 255) {
        // if any part not in legal range
        return false;
      }
    } else {
      // if any part isn't a pure number
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

  let scheme_result = eliminate_protocol_scheme(input)
  // scheme_result = ["https","www.google.com/about"]

  let scheme: string = scheme_result[0]

  let url_first_part = scheme_result[1].split("/")[0].split(".")
  // eliminate slashes and split by dots
  // url_first_part = ["www"."google","com"]

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
  "resource://rawfile/home_light.html",
  "resource://rawfile/home_dark.html"
]

let built_ins: string[] = [
  "meow://home_light",
  "meow://home_dark"
]

export function url_resource_to_meow(input: string) {
  let result: string = input;

  if (input == undefined) {
    return result;
  }
  if (input == null) {
    return result;
  }
  // No process for empty inputs

  if (input.length > 11) {
    if (input.substring(0, 11) == "resource://") {
      let index = urls.indexOf(input)
      if (index != -1) {
        result = built_ins[index]
      } else {
        // If input is a non-existing resource:// url
      }
    }
  }
  return result;
}

export function url_meow_to_resource(input: string) {
  let result: string = input;

  if (input == undefined) {
    return result;
  }
  if (input == null) {
    return result;
  }
  // No process for empty inputs

  if (input.length > 7) {
    if (input.substring(0, 7) == "meow://") {
      // if is meow:// scheme
      let index = built_ins.indexOf(input)
      if (index != -1) {
        // if this link exists
        result = urls[index]
      } else {
        // if this link of meow:// scheme doesn't exist
      }
    }
  }
  return result;
}

export function match_domain(input: string) {
  if (input.includes("//")) {
    let split_list = input.split("\/");
    if (split_list.length > 2) {
      input = split_list[2];
    }
  }
  return input;
}