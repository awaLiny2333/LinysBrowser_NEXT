import lazy { url } from '@kit.ArkTS';
import lazy { concatSearchWithEngine } from '../../hosts/app/tabs/scripts/searchEngines';
import lazy { SINGLE_LABEL_ALLOWLIST, LEGAL_TOP_LEVEL_DOMAINS } from './url-ext';
import { Want, common } from '@kit.AbilityKit';
import { UIContext } from '@kit.ArkUI';

/**
 * Get keyword entries from a URL.
 *
 * @param sourceUrl the url.
 * @returns the keyword entries.
 */
export function getKeywordEntries(sourceUrl: string): [string, string][] {
  try {
    const theUrl = url.URL.parseURL(sourceUrl);
    const iterator = theUrl.params.entries();
    return Array.from(iterator);
  } catch (e) {
    return [];
  }
}

export enum UnifiedDestinationResultType {
  URL_UNSCHEMED,
  URL_SCHEMED,
  SEARCH
}

export interface UnifiedDestinationResult {
  type: UnifiedDestinationResultType;
  url: string;
}

/**
 * Checks if a test url belongs to a specific domain.
 * @param testUrl The url to be tested.
 * @param domain The domain.
 * @returns True or false.
 */
export function belongsToDomain(testUrl: string, domain: string) {
  try {
    const theUrl = url.URL.parseURL(testUrl);
    const result = theUrl.host.endsWith(domain);
    // console.log(`[belongsToDomain] [${testUrl}] host: (${theUrl.host}) ${result ? 'belongs to' : 'is not under'} [${domain}]`);
    return result;
  } catch (e) {
    // console.error(`[belongsToDomain] [${testUrl}]?→[${domain}] error: ${e}`);
    return false;
  }
}

/**
 * Get the domain of a URL.
 * @param sourceUrl The source URL.
 * @returns The host without a leading 'www.' prefix.
 */
export function domainOf(sourceUrl?: string): string {
  if (!sourceUrl) return '';
  try {
    const theUrl = url.URL.parseURL(sourceUrl);
    let host = theUrl.host;
    if (host && host.startsWith('www.')) {
      host = host.slice(4); // remove 'www.'
    }
    return host || '';
  } catch (e) {
    console.error(`[domainOf] [${sourceUrl}] error: ${e}`);
    return '';
  }
}

/**
 * Jumps to an external link using want.
 * @param url the link
 * */
export function jumpUrl(url: string, context?: common.UIAbilityContext) {
  const want: Want = {
    uri: url
  };
  if (!context) {
    context = UIContext.getLastFocusedUIContext()?.getHostContext() as common.UIAbilityContext;
  }
  context.startAbility(want).then(() => {
    // Pull up success
    console.log('[Meow][jumpUrl] Pull up application for want ' + url + ' Success!');
  }).catch(() => {
    // Pull up failure
    console.error('[Meow][jumpUrl] Pull up application for want ' + url + ' Failed!');
  });
}

/**
 * Unify a destination URL.
 *
 * @param content The string content.
 * @param useHttps Whether to use https when unifying the URL.
 * @returns The unified url.
 */
export function unifyDestination(content: string, useHttps: boolean): UnifiedDestinationResult {
  const isLegalResult = isLegalUrl(content);
  if (isLegalResult[0]) {
    if (isLegalResult[1]) {
      return { type: UnifiedDestinationResultType.URL_SCHEMED, url: content };
    } else {
      return { type: UnifiedDestinationResultType.URL_UNSCHEMED, url: `http${useHttps ? 's' : ''}://${content}` };
    }
  }
  return { type: UnifiedDestinationResultType.SEARCH, url: concatSearchWithEngine(content).result };
}

// Constants of regex for some parts of url validation
const IPV4_MATCH_REGEX = /(.*):((\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3}))$/;
const IPV6_PREFIX_MATCH_REGEX = /^[0-9a-fA-F]{1,4}$/;
const IS_VALID_DOMAIN_ASCII_REGEX = /^[A-Z0-9]([A-Z0-9-]*[A-Z0-9])?$/;
const IS_VALID_DOMAIN_LOOSE_REGEX = /^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$/;

// More
const LEGAL_CHARACTERS_REGEX = /^[A-Za-z0-9\-._~:/?#[\]@!$&'()*+,;=%]+$/; // RFC 3986 allowed chars
const INVALID_PERCENT_ENCODING_REGEX = /%(?![0-9A-Fa-f]{2})/; // Illegal percent encoding ( % not followed by two hex characters )
const SCHEME_REGEX = /^([a-zA-Z][a-zA-Z0-9+\-.]*):/; // Extract Scheme ( protocol name )
const PORT_REGEX = /^\d{1,5}$/; // Port number format ( 1-5 digits )

// Matches for tail elimination: if it ends with ) ' " and there is no corresponding opening symbol before it
const UNMATCHED_CLOSING_PAREN_REGEX = /^[^(]*\)$/;
const UNMATCHED_CLOSING_QUOTE_REGEX = /^[^']*'$/;
const UNMATCHED_CLOSING_DOUBLE_QUOTE_REGEX = /^[^"]*"$/;

/**
 * Check if a string is a valid IPv4 address.
 *
 * @param ip The address.
 * @returns True or false.
 * @author DeepSeek @ May 6 2026
 */
export function isValidIPv4(ip: string): boolean {
  const parts = ip.split('.');
  if (parts.length !== 4) return false;
  for (const part of parts) {
    if (part.length === 0 || part.length > 3) return false;
    if (!/^\d+$/.test(part)) return false;
    const num = parseInt(part, 10);
    if (num < 0 || num > 255) return false;
    // 禁止前导零，例如 "01"
    if (part.length > 1 && part[0] === '0') return false;
  }
  return true;
}

/**
 * Check if a string is a valid IPv6 address.
 *
 * @param ip The address.
 * @returns True or false.
 * @author DeepSeek @ May 6 2026
 */
export function isValidIPv6(ip: string): boolean {
  // 支持 Zone ID（例如 %eth0）
  const zoneMatch = ip.match(/^([^%]+)(%[a-zA-Z0-9]+)?$/);
  if (!zoneMatch) return false;
  const address = zoneMatch[1];

  // 内嵌 IPv4（如 ::ffff:192.0.2.1）
  const ipv4Match = address.match(IPV4_MATCH_REGEX);
  if (ipv4Match) {
    const prefix = ipv4Match[1];
    const ipv4 = ipv4Match[2];
    if (!isValidIPv4(ipv4)) return false;
    // 前缀部分最多允许 6 组（IPv4 占 2 组，合计 8 组）
    return isValidIPv6Prefix(prefix, 6);
  }

  return isValidIPv6Prefix(address, 8);
}

/**
 * Check if a string is a valid IPv6 prefix.
 *
 * @param prefix The prefix.
 * @param maxGroups The maximum number of groups allowed.
 * @returns True or false.
 * @author DeepSeek @ May 6 2026
 */
export function isValidIPv6Prefix(prefix: string, maxGroups: number): boolean {
  if (prefix === '::') return true;
  if (prefix.includes('::')) {
    const dcidx = prefix.indexOf('::');
    const left = prefix.substring(0, dcidx);
    const right = prefix.substring(dcidx + 2);
    const leftParts = left ? left.split(':') : [];
    const rightParts = right ? right.split(':') : [];
    const total = leftParts.length + rightParts.length;
    // :: 至少省略 1 组，因此总组数不得超过 maxGroups - 1
    if (total > maxGroups - 1) return false;
    for (const part of leftParts.concat(rightParts)) {
      if (!IPV6_PREFIX_MATCH_REGEX.test(part)) return false;
    }
    return true;
  }

  const parts = prefix.split(':');
  if (parts.length !== maxGroups) return false;
  for (const part of parts) {
    if (!IPV6_PREFIX_MATCH_REGEX.test(part)) return false;
  }
  return true;
}

/**
 * Checks if a host is a legal HTTP(s) domain.
 *
 * @param host The host.
 * @returns True or false.
 * @author DeepSeek @ May 6 2026
 */
export function isValidDomainHttp(host: string): boolean {
  const upperHost = host.toUpperCase();

  // 单标签域名：白名单放行（全部大写）
  if (!upperHost.includes('.')) {
    return SINGLE_LABEL_ALLOWLIST.has(upperHost);
  }

  // 多标签域名：总长度限制（大写后长度不变）
  if (upperHost.length > 253) return false;

  const labels = upperHost.split('.');

  // 顶级域直接与大写集合匹配
  const tld = labels[labels.length - 1];
  if (!LEGAL_TOP_LEVEL_DOMAINS.has(tld)) return false;

  // 逐标签检查（使用大写字母正则）
  for (const label of labels) {
    if (label.length === 0 || label.length > 63) return false;
    if (!IS_VALID_DOMAIN_ASCII_REGEX.test(label)) return false;
  }
  return true;
}

/**
 * Checks if a host is a legal HTTP(s) domain.
 * This method should be used if the scheme is clearly set as HTTP(s), and this doesn't block host names with only one word.
 *
 * @param host The host.
 * @returns True or false.
 * @author DeepSeek @ May 6 2026
 */
export function isValidDomainHttpSchemed(host: string): boolean {
  const upperHost = host.toUpperCase();

  // 单标签域名：全部放行！
  if (!upperHost.includes('.')) {
    return true;
  }

  // 多标签域名：总长度限制（大写后长度不变）
  if (upperHost.length > 253) return false;

  const labels = upperHost.split('.');

  // 顶级域直接与大写集合匹配
  const tld = labels[labels.length - 1];
  if (!LEGAL_TOP_LEVEL_DOMAINS.has(tld)) return false;

  // 逐标签检查（使用大写字母正则）
  for (const label of labels) {
    if (label.length === 0 || label.length > 63) return false;
    if (!IS_VALID_DOMAIN_ASCII_REGEX.test(label)) return false;
  }
  return true;
}

/**
 * Validate domain name (RFC 3986 lenient specification)
 * No requirement for public top-level suffixes (.com, etc.), supports custom domain names / suffixes
 *
 * @param domain The host.
 * @returns True or false.
 * @author ChatGLM Web @ May 13 2026
 */
export function isValidDomainLoose(domain: string): boolean {
  // 整体长度限制 (DNS 规范最长 253)
  if (domain.length > 253 || domain.length === 0) return false;

  // 标签不能以点开头或结尾，且不能连续点
  if (domain.startsWith('.') || domain.endsWith('.') || domain.includes('..')) return false;

  const labels = domain.split('.');
  return labels.every(label => {
    // 每个标签最长 63
    if (label.length === 0 || label.length > 63) return false;
    // 允许字母、数字、连字符，且不能以连字符开头或结尾
    return IS_VALID_DOMAIN_LOOSE_REGEX.test(label);
  });
}

/**
 * Check if a URL is legal.
 * Supports all schemes (http, ftp, mailto, data, file, etc.).
 * Also accepts protocol-relative URLs (//example.com) or scheme-less URLs (example.com).
 *
 * @param url The URL string to validate.
 * @returns A tuple [isLegal, hasScheme]:
 *  - isLegal: True if the URL is structurally legal.
 *  - hasScheme: True if a valid scheme (like http:, mailto:) was explicitly provided.
 *               If false, the URL is legal but may require manually prepending "http://" .
 * @author ChatGLM Web @ May 13 2026
 */
export function isLegalUrl(url: string): [boolean, boolean] {
  const schemeMatch = url.match(SCHEME_REGEX);

  if (schemeMatch) {
    const scheme = schemeMatch[1].toLowerCase();
    // 明确指定了 http 或 https，走严格 HTTP 校验
    if (scheme === 'http' || scheme === 'https') {
      return validateUrlCore(url, isValidDomainHttpSchemed);
    } else {
      // 明确指定了其他协议，走宽松校验
      return validateUrlCore(url, isValidDomainLoose);
    }
  } else {
    // 没有指定协议 (如 example.com 或 //example.com)，预期后续补 http，走严格 HTTP 校验
    return validateUrlCore(url, isValidDomainHttp);
  }
}

/**
 * Shared logic of core url validation.
 *
 * @param url The url.
 * @param domainValidator The domain validation function.
 * @returns A tuple [isLegal, hasScheme]:
 *  - isLegal: True if the URL is structurally legal.
 *  - hasScheme: True if a valid scheme (like http:, mailto:) was explicitly provided.
 *               If false, the URL is legal but may require manually prepending "http://" .
 * @author ChatGLM Web @ May 13 2026
 */
function validateUrlCore(url: string, domainValidator: (host: string) => boolean): [boolean, boolean] {
  // 1. 基础类型与格式校验
  if (typeof url !== 'string' || url.length === 0) return [false, false];
  if (url.trim() !== url) return [false, false];

  if (!LEGAL_CHARACTERS_REGEX.test(url)) return [false, false]; // 合法字符白名单 (拒绝双引号、尖括号等非法字符)
  if (INVALID_PERCENT_ENCODING_REGEX.test(url)) return [false, false]; // 严格的百分号编码校验

  // 【新增】启发式脏数据拦截：防止从自然语言文本中错误提取的尾部标点
  if (UNMATCHED_CLOSING_PAREN_REGEX.test(url)) return [false, false];
  if (UNMATCHED_CLOSING_QUOTE_REGEX.test(url)) return [false, false];
  if (UNMATCHED_CLOSING_DOUBLE_QUOTE_REGEX.test(url)) return [false, false];

  // 2. 提取 Scheme
  const schemeMatch = url.match(SCHEME_REGEX);
  let remaining: string;
  let hasScheme = false;

  if (schemeMatch) {
    hasScheme = true;
    remaining = url.substring(schemeMatch[0].length);

    if (remaining.startsWith('//')) {
      remaining = remaining.substring(2);
    } else if (remaining.startsWith('/')) {
      return [false, hasScheme]; // 残缺的层级 URL
    } else {
      // Opaque URI (如 mailto:test@a.com)
      if (remaining.length === 0) return [false, hasScheme];
      return [true, hasScheme];
    }
  } else {
    if (url.startsWith('//')) {
      remaining = url.substring(2);
    } else {
      if (url.includes('://')) return [false, false];
      remaining = url;
    }
  }

  // 3. 分离 authority 和 path
  const slashIndex = remaining.indexOf('/');
  const authority = slashIndex === -1 ? remaining : remaining.substring(0, slashIndex);

  if (authority.length === 0) {
    const isFileScheme = schemeMatch != null && schemeMatch[1].toLowerCase() === 'file';
    return [isFileScheme && slashIndex !== -1, hasScheme];
  }

  // 4. 提取用户信息并分离 Host/Port
  const atIndex = authority.lastIndexOf('@');
  const hostPortPart = atIndex !== -1 ? authority.substring(atIndex + 1) : authority;

  let host: string;
  let port: string | undefined;

  if (hostPortPart.startsWith('[')) {
    const closeBracket = hostPortPart.indexOf(']');
    if (closeBracket === -1) return [false, hasScheme];
    host = hostPortPart.substring(0, closeBracket + 1);
    const after = hostPortPart.substring(closeBracket + 1);
    if (after === '') port = undefined;
    else if (after.startsWith(':')) {
      port = after.substring(1);
      if (port.length === 0) return [false, hasScheme];
    } else return [false, hasScheme];
  } else {
    const lastColon = hostPortPart.lastIndexOf(':');
    if (lastColon !== -1) {
      host = hostPortPart.substring(0, lastColon);
      port = hostPortPart.substring(lastColon + 1);
    } else {
      host = hostPortPart;
    }
  }

  if (host.length === 0) return [false, hasScheme];

  // 5. 校验主机 (使用注入的 domainValidator)
  if (host.startsWith('[')) {
    if (!host.endsWith(']')) return [false, hasScheme];
    if (!isValidIPv6(host.substring(1, host.length - 1))) return [false, hasScheme];
  } else {
    if (!isValidIPv4(host) && !domainValidator(host)) return [false, hasScheme];
  }

  // 6. 校验端口
  if (port !== undefined) {
    if (!PORT_REGEX.test(port)) return [false, hasScheme];
    const portNum = parseInt(port, 10);
    if (portNum > 65535) return [false, hasScheme];
  }

  return [true, hasScheme];
}
