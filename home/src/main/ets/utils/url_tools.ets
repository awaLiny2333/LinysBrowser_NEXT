import { default_search_engine } from '../hosts/bunch_of_defaults';
import { common, Want } from '@kit.AbilityKit';

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

function is_ascii(str: string): boolean {
  // 匹配 ASCII 字符（0-127）
  return /^[\x00-\x7F]*$/.test(str);
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

/**
 * Determines if a port is legal.
 * @param port the port
 * @returns true if the port is legal
 * */
function is_legal_port(port: string) {
  if (!is_pure_number(port)) {
    return false;
  }
  let port_int = Number.parseInt(port);
  if (!(0 <= port_int && port_int <= 65535)) {
    // if any part not in legal range [0, 255]
    // or port not in legal range [0, 65535]
    return false;
  }
  return true;
}

export function is_legal_ipv4(input: string) {
  if (input == "") {
    // if is empty
    return false;
  }

  // input = "https://114.114.114.114:32767/somewhat"
  input = match_domain(input)[1].split("/")[0] // input = "114.114.114.114:32767"
  let split_ports = input.split(":");
  input = split_ports[0]; // input = "114.114.114.114"
  let port = split_ports[1];

  let input_parts = input.split(".");
  if (input_parts.length != 4) {
    return false;
    // if the length of parts isn't 4
  }

  // Check every part
  for (let index = 0; index < 4; index++) {
    const part = input_parts[index];
    if (!is_pure_number(part)) {
      // if any part isn't a pure number
      return false;
    }
    let pure_number = Number.parseInt(part);
    if (!(0 <= pure_number && pure_number <= 255)) {
      // if any part not in legal range [0, 255]
      return false;
    }
  }

  // meow.com::::80 is illegal
  if (split_ports.length > 2) {
    return false;
  }

  // if there is a port
  if (split_ports.length == 2) {
    // examine ports, like 32767
    if (!is_legal_port(port)) {
      return false;
    }
  }

  return true;
}

export function is_legal_url(input: string) {
  if (input == "") {
    // if is empty
    return false;
  }

  // input = "https://www.google.com:80/about"

  let scheme_result = match_domain(input); // scheme_result = ["https","www.google.com:80/about"]
  let scheme: string = scheme_result[0];
  let url_first_part = scheme_result[1].split("/")[0].split("."); // url_first_part = ["www", "google", "com:80"]
  let url_tail = url_first_part[url_first_part.length - 1]; // top_domain = "com:80"
  let split_ports = url_tail.split(":");
  let top = split_ports[0]; // top = "com"
  let port = split_ports[1];

  if (top.length < 2) {
    return false;
  }

  // Other schemes, directly jump
  if (scheme.length >= 1 && !viewable_domains().includes(scheme)) {
    return true;
  }
  // if doesn't contain dots and has no scheme
  if (url_first_part.length < 2 && scheme == "") {
    return false;
  }
  // if link ends with a dot
  if (url_tail.length == 0) {
    return false;
  }
  // meow.com::::80 is illegal
  if (split_ports.length > 2) {
    return false;
  }
  // if there is a port
  if (split_ports.length == 2) {
    // examine ports, like 32767
    if (!is_legal_port(port)) {
      return false;
    }
  }
  // if top domain contains numbers
  if (is_containing_number(top)) {
    return false;
  }
  if (is_ascii(top)) {
    if (!legal_top_domains.includes(top.toUpperCase())) {
      return false;
    }
  }
  // too long or contains spaces
  if (top.length > 63 || top.includes(' ') || top.includes('\n')) {
    return false;
  }

  return true;
}

let urls: string[] = [
  "resource://rawfile/home.html"
]

let built_ins: string[] = [
  "meow://home"
]

/**
 * Translates a link with resource:// to meow://
 * @param link The link.
 * @returns The translated link.
 * */
export function url_resource_to_meow(url: string) {
  let result: string = url;

  if (!url) {
    return result;
  }
  // No process for empty inputs

  if (url.length > 11) {
    if (url.substring(0, 11) == "resource://") {
      let index = urls.indexOf(url);
      if (index != -1) {
        result = built_ins[index];
      } else {
        // If input is a non-existing resource:// link
      }
    }
  }
  return result;
}

/**
 * Translates a link with meow:// to resource://
 * @param link The link.
 * @returns The translated link.
 * */
export function url_meow_to_resource(url: string) {
  let result: string = url;

  if (!url) {
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
 * Analyze an link and divides it into scheme and domain.
 *
 * If the input comes with no scheme then '' is returned in scheme field.
 * @param input the link
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
      // link = link.split("/").slice(2).join("/");
      url = url.split("/")[2];
      scheme = url_split[0].split(":")[0];
    }
  }
  return [scheme, url];
}

/**
 * Domains that can be loaded and displayed in web components
 * @returns ['http', 'https', 'meow', 'resource', 'file']
 * */
export function viewable_domains() {
  return ['http', 'https', 'meow', 'resource', 'file'];
}

/**
 * Extracts search engine and search keyword from an link
 * @param link
 * @returns ['search.engine/q=%s', 'keyword']
 * */
export function extract_search(url: string) {
  // link = decodeURI(link);
  let result: string[] = ['', ''];

  let keys: string[] = ['q', 'query', 's', 'key', 'wd', 'w', 'word', 'searchKeyWord', 'search_text', 'keyword', 'val', 'value', 'text', 'tag', 'tags', 'search'];
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
 * Determines if a url is a web page or not.
 * @param url The url to be checked.
 * @returns True if is a web page that can be displayed.
 */
export function is_web_page(url: string): boolean {
  // Commonly seen web extensions
  const webPageExtensions = [
    '.html', '.htm', '.xhtml', '.shtml',
    '.php', '.php3', '.php4', '.php5', '.phtml', '.pdf',
    '.asp', '.aspx',
    '.jsp', '.jspx',
    '.cgi',
    '.pl',
    '.rb', // '.r', // '.r' is what?
    '.py',
    '.do',
    '.action',
    '.cfm',
    '.dhtml',
    '.md',
    '.markdown',
    '.xml',
    '.json',
    '.rss',
    '.atom'
  ];

  // Remove query and hash part.
  const cleanUrl = url.split('?')[0].split('#')[0];

  // Check if there are any extension names.
  const lastSlashIndex = cleanUrl.lastIndexOf('/');
  const lastPart = cleanUrl.substring(lastSlashIndex + 1);

  // No extension name, is webpage.
  if (!lastPart.includes('.') || lastPart.endsWith('/')) {
    return true;
  }

  // Get extension name
  const extension = '.' + lastPart.toLowerCase().split('.').pop()!;
  console.log(`[is_web_page] extension: [${extension}]`);

  // Check if is in list
  return webPageExtensions.includes(extension);
}

/**
 * Determines if a link is downloadable.
 * @param link The link.
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
      console.log(`[url_tools][is_downloadable] ${link} is downloadable!`);
      return [true, filename];
    }
  } catch (e) {
    console.error('[url_tools][is_downloadable] ' + e);
  }
  console.log(`[url_tools][is_downloadable] ${link} is NOT downloadable!`);
  return [false, ''];
}

/**
 * Jumps to an external link using want.
 * @param link the link
 * */
export function jump_external_link(link: string, context: Context) {
  // jump to link received
  const want: Want = {
    uri: link
  };
  (context as common.UIAbilityContext).startAbility(want).then(() => {
    // Pull up success
    console.log('[Meow][jump_external_link] Pull up application for link ' + link + ' Success!');
  }).catch(() => {
    // Pull up failure
    console.error('[ERROR][Meow][url_tools] Pull up application for link ' + link + ' Failed!');
  });
}

/**
 * THIS IS NOT ELEGANT TODO: Help with this
 * */
export const legal_top_domains: string[] = [
  'AAA',
  'AARP',
  'ABB',
  'ABBOTT',
  'ABBVIE',
  'ABC',
  'ABLE',
  'ABOGADO',
  'ABUDHABI',
  'AC',
  'ACADEMY',
  'ACCENTURE',
  'ACCOUNTANT',
  'ACCOUNTANTS',
  'ACO',
  'ACTOR',
  'AD',
  'ADS',
  'ADULT',
  'AE',
  'AEG',
  'AERO',
  'AETNA',
  'AF',
  'AFL',
  'AFRICA',
  'AG',
  'AGAKHAN',
  'AGENCY',
  'AI',
  'AIG',
  'AIRBUS',
  'AIRFORCE',
  'AIRTEL',
  'AKDN',
  'AL',
  'ALIBABA',
  'ALIPAY',
  'ALLFINANZ',
  'ALLSTATE',
  'ALLY',
  'ALSACE',
  'ALSTOM',
  'AM',
  'AMAZON',
  'AMERICANEXPRESS',
  'AMERICANFAMILY',
  'AMEX',
  'AMFAM',
  'AMICA',
  'AMSTERDAM',
  'ANALYTICS',
  'ANDROID',
  'ANQUAN',
  'ANZ',
  'AO',
  'AOL',
  'APARTMENTS',
  'APP',
  'APPLE',
  'AQ',
  'AQUARELLE',
  'AR',
  'ARAB',
  'ARAMCO',
  'ARCHI',
  'ARMY',
  'ARPA',
  'ART',
  'ARTE',
  'AS',
  'ASDA',
  'ASIA',
  'ASSOCIATES',
  'AT',
  'ATHLETA',
  'ATTORNEY',
  'AU',
  'AUCTION',
  'AUDI',
  'AUDIBLE',
  'AUDIO',
  'AUSPOST',
  'AUTHOR',
  'AUTO',
  'AUTOS',
  'AW',
  'AWS',
  'AX',
  'AXA',
  'AZ',
  'AZURE',
  'BA',
  'BABY',
  'BAIDU',
  'BANAMEX',
  'BAND',
  'BANK',
  'BAR',
  'BARCELONA',
  'BARCLAYCARD',
  'BARCLAYS',
  'BAREFOOT',
  'BARGAINS',
  'BASEBALL',
  'BASKETBALL',
  'BAUHAUS',
  'BAYERN',
  'BB',
  'BBC',
  'BBT',
  'BBVA',
  'BCG',
  'BCN',
  'BD',
  'BE',
  'BEATS',
  'BEAUTY',
  'BEER',
  'BERLIN',
  'BEST',
  'BESTBUY',
  'BET',
  'BF',
  'BG',
  'BH',
  'BHARTI',
  'BI',
  'BIBLE',
  'BID',
  'BIKE',
  'BING',
  'BINGO',
  'BIO',
  'BIZ',
  'BJ',
  'BLACK',
  'BLACKFRIDAY',
  'BLOCKBUSTER',
  'BLOG',
  'BLOOMBERG',
  'BLUE',
  'BM',
  'BMS',
  'BMW',
  'BN',
  'BNPPARIBAS',
  'BO',
  'BOATS',
  'BOEHRINGER',
  'BOFA',
  'BOM',
  'BOND',
  'BOO',
  'BOOK',
  'BOOKING',
  'BOSCH',
  'BOSTIK',
  'BOSTON',
  'BOT',
  'BOUTIQUE',
  'BOX',
  'BR',
  'BRADESCO',
  'BRIDGESTONE',
  'BROADWAY',
  'BROKER',
  'BROTHER',
  'BRUSSELS',
  'BS',
  'BT',
  'BUILD',
  'BUILDERS',
  'BUSINESS',
  'BUY',
  'BUZZ',
  'BV',
  'BW',
  'BY',
  'BZ',
  'BZH',
  'CA',
  'CAB',
  'CAFE',
  'CAL',
  'CALL',
  'CALVINKLEIN',
  'CAM',
  'CAMERA',
  'CAMP',
  'CANON',
  'CAPETOWN',
  'CAPITAL',
  'CAPITALONE',
  'CAR',
  'CARAVAN',
  'CARDS',
  'CARE',
  'CAREER',
  'CAREERS',
  'CARS',
  'CASA',
  'CASE',
  'CASH',
  'CASINO',
  'CAT',
  'CATERING',
  'CATHOLIC',
  'CBA',
  'CBN',
  'CBRE',
  'CC',
  'CD',
  'CENTER',
  'CEO',
  'CERN',
  'CF',
  'CFA',
  'CFD',
  'CG',
  'CH',
  'CHANEL',
  'CHANNEL',
  'CHARITY',
  'CHASE',
  'CHAT',
  'CHEAP',
  'CHINTAI',
  'CHRISTMAS',
  'CHROME',
  'CHURCH',
  'CI',
  'CIPRIANI',
  'CIRCLE',
  'CISCO',
  'CITADEL',
  'CITI',
  'CITIC',
  'CITY',
  'CK',
  'CL',
  'CLAIMS',
  'CLEANING',
  'CLICK',
  'CLINIC',
  'CLINIQUE',
  'CLOTHING',
  'CLOUD',
  'CLUB',
  'CLUBMED',
  'CM',
  'CN',
  'CO',
  'COACH',
  'CODES',
  'COFFEE',
  'COLLEGE',
  'COLOGNE',
  'COM',
  'COMMBANK',
  'COMMUNITY',
  'COMPANY',
  'COMPARE',
  'COMPUTER',
  'COMSEC',
  'CONDOS',
  'CONSTRUCTION',
  'CONSULTING',
  'CONTACT',
  'CONTRACTORS',
  'COOKING',
  'COOL',
  'COOP',
  'CORSICA',
  'COUNTRY',
  'COUPON',
  'COUPONS',
  'COURSES',
  'CPA',
  'CR',
  'CREDIT',
  'CREDITCARD',
  'CREDITUNION',
  'CRICKET',
  'CROWN',
  'CRS',
  'CRUISE',
  'CRUISES',
  'CU',
  'CUISINELLA',
  'CV',
  'CW',
  'CX',
  'CY',
  'CYMRU',
  'CYOU',
  'CZ',
  'DAD',
  'DANCE',
  'DATA',
  'DATE',
  'DATING',
  'DATSUN',
  'DAY',
  'DCLK',
  'DDS',
  'DE',
  'DEAL',
  'DEALER',
  'DEALS',
  'DEGREE',
  'DELIVERY',
  'DELL',
  'DELOITTE',
  'DELTA',
  'DEMOCRAT',
  'DENTAL',
  'DENTIST',
  'DESI',
  'DESIGN',
  'DEV',
  'DHL',
  'DIAMONDS',
  'DIET',
  'DIGITAL',
  'DIRECT',
  'DIRECTORY',
  'DISCOUNT',
  'DISCOVER',
  'DISH',
  'DIY',
  'DJ',
  'DK',
  'DM',
  'DNP',
  'DO',
  'DOCS',
  'DOCTOR',
  'DOG',
  'DOMAINS',
  'DOT',
  'DOWNLOAD',
  'DRIVE',
  'DTV',
  'DUBAI',
  'DUPONT',
  'DURBAN',
  'DVAG',
  'DVR',
  'DZ',
  'EARTH',
  'EAT',
  'EC',
  'ECO',
  'EDEKA',
  'EDU',
  'EDUCATION',
  'EE',
  'EG',
  'EMAIL',
  'EMERCK',
  'ENERGY',
  'ENGINEER',
  'ENGINEERING',
  'ENTERPRISES',
  'EPSON',
  'EQUIPMENT',
  'ER',
  'ERICSSON',
  'ERNI',
  'ES',
  'ESQ',
  'ESTATE',
  'ET',
  'EU',
  'EUROVISION',
  'EUS',
  'EVENTS',
  'EXCHANGE',
  'EXPERT',
  'EXPOSED',
  'EXPRESS',
  'EXTRASPACE',
  'FAGE',
  'FAIL',
  'FAIRWINDS',
  'FAITH',
  'FAMILY',
  'FAN',
  'FANS',
  'FARM',
  'FARMERS',
  'FASHION',
  'FAST',
  'FEDEX',
  'FEEDBACK',
  'FERRARI',
  'FERRERO',
  'FI',
  'FIDELITY',
  'FIDO',
  'FILM',
  'FINAL',
  'FINANCE',
  'FINANCIAL',
  'FIRE',
  'FIRESTONE',
  'FIRMDALE',
  'FISH',
  'FISHING',
  'FIT',
  'FITNESS',
  'FJ',
  'FK',
  'FLICKR',
  'FLIGHTS',
  'FLIR',
  'FLORIST',
  'FLOWERS',
  'FLY',
  'FM',
  'FO',
  'FOO',
  'FOOD',
  'FOOTBALL',
  'FORD',
  'FOREX',
  'FORSALE',
  'FORUM',
  'FOUNDATION',
  'FOX',
  'FR',
  'FREE',
  'FRESENIUS',
  'FRL',
  'FROGANS',
  'FRONTIER',
  'FTR',
  'FUJITSU',
  'FUN',
  'FUND',
  'FURNITURE',
  'FUTBOL',
  'FYI',
  'GA',
  'GAL',
  'GALLERY',
  'GALLO',
  'GALLUP',
  'GAME',
  'GAMES',
  'GAP',
  'GARDEN',
  'GAY',
  'GB',
  'GBIZ',
  'GD',
  'GDN',
  'GE',
  'GEA',
  'GENT',
  'GENTING',
  'GEORGE',
  'GF',
  'GG',
  'GGEE',
  'GH',
  'GI',
  'GIFT',
  'GIFTS',
  'GIVES',
  'GIVING',
  'GL',
  'GLASS',
  'GLE',
  'GLOBAL',
  'GLOBO',
  'GM',
  'GMAIL',
  'GMBH',
  'GMO',
  'GMX',
  'GN',
  'GODADDY',
  'GOLD',
  'GOLDPOINT',
  'GOLF',
  'GOO',
  'GOODYEAR',
  'GOOG',
  'GOOGLE',
  'GOP',
  'GOT',
  'GOV',
  'GP',
  'GQ',
  'GR',
  'GRAINGER',
  'GRAPHICS',
  'GRATIS',
  'GREEN',
  'GRIPE',
  'GROCERY',
  'GROUP',
  'GS',
  'GT',
  'GU',
  'GUCCI',
  'GUGE',
  'GUIDE',
  'GUITARS',
  'GURU',
  'GW',
  'GY',
  'HAIR',
  'HAMBURG',
  'HANGOUT',
  'HAUS',
  'HBO',
  'HDFC',
  'HDFCBANK',
  'HEALTH',
  'HEALTHCARE',
  'HELP',
  'HELSINKI',
  'HERE',
  'HERMES',
  'HIPHOP',
  'HISAMITSU',
  'HITACHI',
  'HIV',
  'HK',
  'HKT',
  'HM',
  'HN',
  'HOCKEY',
  'HOLDINGS',
  'HOLIDAY',
  'HOMEDEPOT',
  'HOMEGOODS',
  'HOMES',
  'HOMESENSE',
  'HONDA',
  'HORSE',
  'HOSPITAL',
  'HOST',
  'HOSTING',
  'HOT',
  'HOTELS',
  'HOTMAIL',
  'HOUSE',
  'HOW',
  'HR',
  'HSBC',
  'HT',
  'HU',
  'HUGHES',
  'HYATT',
  'HYUNDAI',
  'IBM',
  'ICBC',
  'ICE',
  'ICU',
  'ID',
  'IE',
  'IEEE',
  'IFM',
  'IKANO',
  'IL',
  'IM',
  'IMAMAT',
  'IMDB',
  'IMMO',
  'IMMOBILIEN',
  'IN',
  'INC',
  'INDUSTRIES',
  'INFINITI',
  'INFO',
  'ING',
  'INK',
  'INSTITUTE',
  'INSURANCE',
  'INSURE',
  'INT',
  'INTERNATIONAL',
  'INTUIT',
  'INVESTMENTS',
  'IO',
  'IPIRANGA',
  'IQ',
  'IR',
  'IRISH',
  'IS',
  'ISMAILI',
  'IST',
  'ISTANBUL',
  'IT',
  'ITAU',
  'ITV',
  'JAGUAR',
  'JAVA',
  'JCB',
  'JE',
  'JEEP',
  'JETZT',
  'JEWELRY',
  'JIO',
  'JLL',
  'JM',
  'JMP',
  'JNJ',
  'JO',
  'JOBS',
  'JOBURG',
  'JOT',
  'JOY',
  'JP',
  'JPMORGAN',
  'JPRS',
  'JUEGOS',
  'JUNIPER',
  'KAUFEN',
  'KDDI',
  'KE',
  'KERRYHOTELS',
  'KERRYPROPERTIES',
  'KFH',
  'KG',
  'KH',
  'KI',
  'KIA',
  'KIDS',
  'KIM',
  'KINDLE',
  'KITCHEN',
  'KIWI',
  'KM',
  'KN',
  'KOELN',
  'KOMATSU',
  'KOSHER',
  'KP',
  'KPMG',
  'KPN',
  'KR',
  'KRD',
  'KRED',
  'KUOKGROUP',
  'KW',
  'KY',
  'KYOTO',
  'KZ',
  'LA',
  'LACAIXA',
  'LAMBORGHINI',
  'LAMER',
  'LAND',
  'LANDROVER',
  'LANXESS',
  'LASALLE',
  'LAT',
  'LATINO',
  'LATROBE',
  'LAW',
  'LAWYER',
  'LB',
  'LC',
  'LDS',
  'LEASE',
  'LECLERC',
  'LEFRAK',
  'LEGAL',
  'LEGO',
  'LEXUS',
  'LGBT',
  'LI',
  'LIDL',
  'LIFE',
  'LIFEINSURANCE',
  'LIFESTYLE',
  'LIGHTING',
  'LIKE',
  'LILLY',
  'LIMITED',
  'LIMO',
  'LINCOLN',
  'LINK',
  'LIVE',
  'LIVING',
  'LK',
  'LLC',
  'LLP',
  'LOAN',
  'LOANS',
  'LOCKER',
  'LOCUS',
  'LOL',
  'LONDON',
  'LOTTE',
  'LOTTO',
  'LOVE',
  'LPL',
  'LPLFINANCIAL',
  'LR',
  'LS',
  'LT',
  'LTD',
  'LTDA',
  'LU',
  'LUNDBECK',
  'LUXE',
  'LUXURY',
  'LV',
  'LY',
  'MA',
  'MADRID',
  'MAIF',
  'MAISON',
  'MAKEUP',
  'MAN',
  'MANAGEMENT',
  'MANGO',
  'MAP',
  'MARKET',
  'MARKETING',
  'MARKETS',
  'MARRIOTT',
  'MARSHALLS',
  'MATTEL',
  'MBA',
  'MC',
  'MCKINSEY',
  'MD',
  'ME',
  'MED',
  'MEDIA',
  'MEET',
  'MELBOURNE',
  'MEME',
  'MEMORIAL',
  'MEN',
  'MENU',
  'MERCKMSD',
  'MG',
  'MH',
  'MIAMI',
  'MICROSOFT',
  'MIL',
  'MINI',
  'MINT',
  'MIT',
  'MITSUBISHI',
  'MK',
  'ML',
  'MLB',
  'MLS',
  'MM',
  'MMA',
  'MN',
  'MO',
  'MOBI',
  'MOBILE',
  'MODA',
  'MOE',
  'MOI',
  'MOM',
  'MONASH',
  'MONEY',
  'MONSTER',
  'MORMON',
  'MORTGAGE',
  'MOSCOW',
  'MOTO',
  'MOTORCYCLES',
  'MOV',
  'MOVIE',
  'MP',
  'MQ',
  'MR',
  'MS',
  'MSD',
  'MT',
  'MTN',
  'MTR',
  'MU',
  'MUSEUM',
  'MUSIC',
  'MV',
  'MW',
  'MX',
  'MY',
  'MZ',
  'NA',
  'NAB',
  'NAGOYA',
  'NAME',
  'NAVY',
  'NBA',
  'NC',
  'NE',
  'NEC',
  'NET',
  'NETBANK',
  'NETFLIX',
  'NETWORK',
  'NEUSTAR',
  'NEW',
  'NEWS',
  'NEXT',
  'NEXTDIRECT',
  'NEXUS',
  'NF',
  'NFL',
  'NG',
  'NGO',
  'NHK',
  'NI',
  'NICO',
  'NIKE',
  'NIKON',
  'NINJA',
  'NISSAN',
  'NISSAY',
  'NL',
  'NO',
  'NOKIA',
  'NORTON',
  'NOW',
  'NOWRUZ',
  'NOWTV',
  'NP',
  'NR',
  'NRA',
  'NRW',
  'NTT',
  'NU',
  'NYC',
  'NZ',
  'OBI',
  'OBSERVER',
  'OFFICE',
  'OKINAWA',
  'OLAYAN',
  'OLAYANGROUP',
  'OLLO',
  'OM',
  'OMEGA',
  'ONE',
  'ONG',
  'ONL',
  'ONLINE',
  'OOO',
  'OPEN',
  'ORACLE',
  'ORANGE',
  'ORG',
  'ORGANIC',
  'ORIGINS',
  'OSAKA',
  'OTSUKA',
  'OTT',
  'OVH',
  'PA',
  'PAGE',
  'PANASONIC',
  'PARIS',
  'PARS',
  'PARTNERS',
  'PARTS',
  'PARTY',
  'PAY',
  'PCCW',
  'PE',
  'PET',
  'PF',
  'PFIZER',
  'PG',
  'PH',
  'PHARMACY',
  'PHD',
  'PHILIPS',
  'PHONE',
  'PHOTO',
  'PHOTOGRAPHY',
  'PHOTOS',
  'PHYSIO',
  'PICS',
  'PICTET',
  'PICTURES',
  'PID',
  'PIN',
  'PING',
  'PINK',
  'PIONEER',
  'PIZZA',
  'PK',
  'PL',
  'PLACE',
  'PLAY',
  'PLAYSTATION',
  'PLUMBING',
  'PLUS',
  'PM',
  'PN',
  'PNC',
  'POHL',
  'POKER',
  'POLITIE',
  'PORN',
  'POST',
  'PR',
  'PRAXI',
  'PRESS',
  'PRIME',
  'PRO',
  'PROD',
  'PRODUCTIONS',
  'PROF',
  'PROGRESSIVE',
  'PROMO',
  'PROPERTIES',
  'PROPERTY',
  'PROTECTION',
  'PRU',
  'PRUDENTIAL',
  'PS',
  'PT',
  'PUB',
  'PW',
  'PWC',
  'PY',
  'QA',
  'QPON',
  'QUEBEC',
  'QUEST',
  'RACING',
  'RADIO',
  'RE',
  'READ',
  'REALESTATE',
  'REALTOR',
  'REALTY',
  'RECIPES',
  'RED',
  'REDUMBRELLA',
  'REHAB',
  'REISE',
  'REISEN',
  'REIT',
  'RELIANCE',
  'REN',
  'RENT',
  'RENTALS',
  'REPAIR',
  'REPORT',
  'REPUBLICAN',
  'REST',
  'RESTAURANT',
  'REVIEW',
  'REVIEWS',
  'REXROTH',
  'RICH',
  'RICHARDLI',
  'RICOH',
  'RIL',
  'RIO',
  'RIP',
  'RO',
  'ROCKS',
  'RODEO',
  'ROGERS',
  'ROOM',
  'RS',
  'RSVP',
  'RU',
  'RUGBY',
  'RUHR',
  'RUN',
  'RW',
  'RWE',
  'RYUKYU',
  'SA',
  'SAARLAND',
  'SAFE',
  'SAFETY',
  'SAKURA',
  'SALE',
  'SALON',
  'SAMSCLUB',
  'SAMSUNG',
  'SANDVIK',
  'SANDVIKCOROMANT',
  'SANOFI',
  'SAP',
  'SARL',
  'SAS',
  'SAVE',
  'SAXO',
  'SB',
  'SBI',
  'SBS',
  'SC',
  'SCB',
  'SCHAEFFLER',
  'SCHMIDT',
  'SCHOLARSHIPS',
  'SCHOOL',
  'SCHULE',
  'SCHWARZ',
  'SCIENCE',
  'SCOT',
  'SD',
  'SE',
  'SEARCH',
  'SEAT',
  'SECURE',
  'SECURITY',
  'SEEK',
  'SELECT',
  'SENER',
  'SERVICES',
  'SEVEN',
  'SEW',
  'SEX',
  'SEXY',
  'SFR',
  'SG',
  'SH',
  'SHANGRILA',
  'SHARP',
  'SHELL',
  'SHIA',
  'SHIKSHA',
  'SHOES',
  'SHOP',
  'SHOPPING',
  'SHOUJI',
  'SHOW',
  'SI',
  'SILK',
  'SINA',
  'SINGLES',
  'SITE',
  'SJ',
  'SK',
  'SKI',
  'SKIN',
  'SKY',
  'SKYPE',
  'SL',
  'SLING',
  'SM',
  'SMART',
  'SMILE',
  'SN',
  'SNCF',
  'SO',
  'SOCCER',
  'SOCIAL',
  'SOFTBANK',
  'SOFTWARE',
  'SOHU',
  'SOLAR',
  'SOLUTIONS',
  'SONG',
  'SONY',
  'SOY',
  'SPA',
  'SPACE',
  'SPORT',
  'SPOT',
  'SR',
  'SRL',
  'SS',
  'ST',
  'STADA',
  'STAPLES',
  'STAR',
  'STATEBANK',
  'STATEFARM',
  'STC',
  'STCGROUP',
  'STOCKHOLM',
  'STORAGE',
  'STORE',
  'STREAM',
  'STUDIO',
  'STUDY',
  'STYLE',
  'SU',
  'SUCKS',
  'SUPPLIES',
  'SUPPLY',
  'SUPPORT',
  'SURF',
  'SURGERY',
  'SUZUKI',
  'SV',
  'SWATCH',
  'SWISS',
  'SX',
  'SY',
  'SYDNEY',
  'SYSTEMS',
  'SZ',
  'TAB',
  'TAIPEI',
  'TALK',
  'TAOBAO',
  'TARGET',
  'TATAMOTORS',
  'TATAR',
  'TATTOO',
  'TAX',
  'TAXI',
  'TC',
  'TCI',
  'TD',
  'TDK',
  'TEAM',
  'TECH',
  'TECHNOLOGY',
  'TEL',
  'TEMASEK',
  'TENNIS',
  'TEVA',
  'TF',
  'TG',
  'TH',
  'THD',
  'THEATER',
  'THEATRE',
  'TIAA',
  'TICKETS',
  'TIENDA',
  'TIPS',
  'TIRES',
  'TIROL',
  'TJ',
  'TJMAXX',
  'TJX',
  'TK',
  'TKMAXX',
  'TL',
  'TM',
  'TMALL',
  'TN',
  'TO',
  'TODAY',
  'TOKYO',
  'TOOLS',
  'TOP',
  'TORAY',
  'TOSHIBA',
  'TOTAL',
  'TOURS',
  'TOWN',
  'TOYOTA',
  'TOYS',
  'TR',
  'TRADE',
  'TRADING',
  'TRAINING',
  'TRAVEL',
  'TRAVELERS',
  'TRAVELERSINSURANCE',
  'TRUST',
  'TRV',
  'TT',
  'TUBE',
  'TUI',
  'TUNES',
  'TUSHU',
  'TV',
  'TVS',
  'TW',
  'TZ',
  'UA',
  'UBANK',
  'UBS',
  'UG',
  'UK',
  'UNICOM',
  'UNIVERSITY',
  'UNO',
  'UOL',
  'UPS',
  'US',
  'UY',
  'UZ',
  'VA',
  'VACATIONS',
  'VANA',
  'VANGUARD',
  'VC',
  'VE',
  'VEGAS',
  'VENTURES',
  'VERISIGN',
  'VERSICHERUNG',
  'VET',
  'VG',
  'VI',
  'VIAJES',
  'VIDEO',
  'VIG',
  'VIKING',
  'VILLAS',
  'VIN',
  'VIP',
  'VIRGIN',
  'VISA',
  'VISION',
  'VIVA',
  'VIVO',
  'VLAANDEREN',
  'VN',
  'VODKA',
  'VOLVO',
  'VOTE',
  'VOTING',
  'VOTO',
  'VOYAGE',
  'VU',
  'WALES',
  'WALMART',
  'WALTER',
  'WANG',
  'WANGGOU',
  'WATCH',
  'WATCHES',
  'WEATHER',
  'WEATHERCHANNEL',
  'WEBCAM',
  'WEBER',
  'WEBSITE',
  'WED',
  'WEDDING',
  'WEIBO',
  'WEIR',
  'WF',
  'WHOSWHO',
  'WIEN',
  'WIKI',
  'WILLIAMHILL',
  'WIN',
  'WINDOWS',
  'WINE',
  'WINNERS',
  'WME',
  'WOLTERSKLUWER',
  'WOODSIDE',
  'WORK',
  'WORKS',
  'WORLD',
  'WOW',
  'WS',
  'WTC',
  'WTF',
  'XBOX',
  'XEROX',
  'XIHUAN',
  'XIN',
  'XN--11B4C3D',
  'XN--1CK2E1B',
  'XN--1QQW23A',
  'XN--2SCRJ9C',
  'XN--30RR7Y',
  'XN--3BST00M',
  'XN--3DS443G',
  'XN--3E0B707E',
  'XN--3HCRJ9C',
  'XN--3PXU8K',
  'XN--42C2D9A',
  'XN--45BR5CYL',
  'XN--45BRJ9C',
  'XN--45Q11C',
  'XN--4DBRK0CE',
  'XN--4GBRIM',
  'XN--54B7FTA0CC',
  'XN--55QW42G',
  'XN--55QX5D',
  'XN--5SU34J936BGSG',
  'XN--5TZM5G',
  'XN--6FRZ82G',
  'XN--6QQ986B3XL',
  'XN--80ADXHKS',
  'XN--80AO21A',
  'XN--80AQECDR1A',
  'XN--80ASEHDB',
  'XN--80ASWG',
  'XN--8Y0A063A',
  'XN--90A3AC',
  'XN--90AE',
  'XN--90AIS',
  'XN--9DBQ2A',
  'XN--9ET52U',
  'XN--9KRT00A',
  'XN--B4W605FERD',
  'XN--BCK1B9A5DRE4C',
  'XN--C1AVG',
  'XN--C2BR7G',
  'XN--CCK2B3B',
  'XN--CCKWCXETD',
  'XN--CG4BKI',
  'XN--CLCHC0EA0B2G2A9GCD',
  'XN--CZR694B',
  'XN--CZRS0T',
  'XN--CZRU2D',
  'XN--D1ACJ3B',
  'XN--D1ALF',
  'XN--E1A4C',
  'XN--ECKVDTC9D',
  'XN--EFVY88H',
  'XN--FCT429K',
  'XN--FHBEI',
  'XN--FIQ228C5HS',
  'XN--FIQ64B',
  'XN--FIQS8S',
  'XN--FIQZ9S',
  'XN--FJQ720A',
  'XN--FLW351E',
  'XN--FPCRJ9C3D',
  'XN--FZC2C9E2C',
  'XN--FZYS8D69UVGM',
  'XN--G2XX48C',
  'XN--GCKR3F0F',
  'XN--GECRJ9C',
  'XN--GK3AT1E',
  'XN--H2BREG3EVE',
  'XN--H2BRJ9C',
  'XN--H2BRJ9C8C',
  'XN--HXT814E',
  'XN--I1B6B1A6A2E',
  'XN--IMR513N',
  'XN--IO0A7I',
  'XN--J1AEF',
  'XN--J1AMH',
  'XN--J6W193G',
  'XN--JLQ480N2RG',
  'XN--JVR189M',
  'XN--KCRX77D1X4A',
  'XN--KPRW13D',
  'XN--KPRY57D',
  'XN--KPUT3I',
  'XN--L1ACC',
  'XN--LGBBAT1AD8J',
  'XN--MGB9AWBF',
  'XN--MGBA3A3EJT',
  'XN--MGBA3A4F16A',
  'XN--MGBA7C0BBN0A',
  'XN--MGBAAM7A8H',
  'XN--MGBAB2BD',
  'XN--MGBAH1A3HJKRD',
  'XN--MGBAI9AZGQP6J',
  'XN--MGBAYH7GPA',
  'XN--MGBBH1A',
  'XN--MGBBH1A71E',
  'XN--MGBC0A9AZCG',
  'XN--MGBCA7DZDO',
  'XN--MGBCPQ6GPA1A',
  'XN--MGBERP4A5D4AR',
  'XN--MGBGU82A',
  'XN--MGBI4ECEXP',
  'XN--MGBPL2FH',
  'XN--MGBT3DHD',
  'XN--MGBTX2B',
  'XN--MGBX4CD0AB',
  'XN--MIX891F',
  'XN--MK1BU44C',
  'XN--MXTQ1M',
  'XN--NGBC5AZD',
  'XN--NGBE9E0A',
  'XN--NGBRX',
  'XN--NODE',
  'XN--NQV7F',
  'XN--NQV7FS00EMA',
  'XN--NYQY26A',
  'XN--O3CW4H',
  'XN--OGBPF8FL',
  'XN--OTU796D',
  'XN--P1ACF',
  'XN--P1AI',
  'XN--PGBS0DH',
  'XN--PSSY2U',
  'XN--Q7CE6A',
  'XN--Q9JYB4C',
  'XN--QCKA1PMC',
  'XN--QXA6A',
  'XN--QXAM',
  'XN--RHQV96G',
  'XN--ROVU88B',
  'XN--RVC1E0AM3E',
  'XN--S9BRJ9C',
  'XN--SES554G',
  'XN--T60B56A',
  'XN--TCKWE',
  'XN--TIQ49XQYJ',
  'XN--UNUP4Y',
  'XN--VERMGENSBERATER-CTB',
  'XN--VERMGENSBERATUNG-PWB',
  'XN--VHQUV',
  'XN--VUQ861B',
  'XN--W4R85EL8FHU5DNRA',
  'XN--W4RS40L',
  'XN--WGBH1C',
  'XN--WGBL6A',
  'XN--XHQ521B',
  'XN--XKC2AL3HYE2A',
  'XN--XKC2DL3A5EE0H',
  'XN--Y9A3AQ',
  'XN--YFRO4I67O',
  'XN--YGBI2AMMX',
  'XN--ZFR164B',
  'XXX',
  'XYZ',
  'YACHTS',
  'YAHOO',
  'YAMAXUN',
  'YANDEX',
  'YE',
  'YODOBASHI',
  'YOGA',
  'YOKOHAMA',
  'YOU',
  'YOUTUBE',
  'YT',
  'YUN',
  'ZA',
  'ZAPPOS',
  'ZARA',
  'ZERO',
  'ZIP',
  'ZM',
  'ZONE',
  'ZUERICH',
  'ZW'
];
