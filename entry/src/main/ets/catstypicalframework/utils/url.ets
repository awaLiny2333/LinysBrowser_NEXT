import lazy { url } from '@kit.ArkTS';
import lazy { concatSearchWithEngine } from '../../hosts/app/tabs/scripts/searchEngines';

/**
 * Get keyword entries from a URL.
 * @param source the url.
 * @returns the keyword entries.
 */
export function getKeywordEntries(source: string): [string, string][] {
  try {
    const theUrl = url.URL.parseURL(source);
    const iterator = theUrl.params.entries();
    return Array.from(iterator);
  } catch (e) {
    // meow(`Failed to parse URL: ${source}`, 'getKeywordEntries', meowLevel.WARN);
    return [];
  }
}

/**
 * Check if a URL is legal.
 * @param source The source string to be tested.
 * @returns true if the URL is legal, false otherwise.
 */
export function isLegalUrl(source: string): boolean {
  try {
    url.URL.parseURL(source);
    return true;
  } catch (e) {
    return false;
  }
}

export enum UnifyDestinationResultType {
  URL_UNSCHEMED,
  URL_SCHEMED,
  SEARCH
}

export interface UnifyDestinationResult {
  type: UnifyDestinationResultType
  url: string
}

/**
 * Unify a destination URL.
 * 
 * @param content The string content.
 * @param useHttps Whether to use https when unifying the URL.
 * @returns The unified url.
 */
export function unifyDestination(content: string, useHttps: boolean): UnifyDestinationResult {
  if (isLegalUrl(content)) {
    return { type: UnifyDestinationResultType.URL_SCHEMED, url: content };
  }
  if (isLegalHttpUrl(content)) {
    return { type: UnifyDestinationResultType.URL_UNSCHEMED, url: `http${useHttps ? 's' : ''}://${content}` };
  }
  return { type: UnifyDestinationResultType.SEARCH, url: concatSearchWithEngine(content).result };
}

// ↓ Coded by DeepSeek @ May 6 2026

function isLegalHttpUrl(url: string): boolean {
  // 基础类型与格式校验
  if (typeof url !== 'string' || url.length === 0) return false;
  if (url.trim() !== url) return false; // 首尾不能有空格
  if (/\s/.test(url)) return false; // 不能包含任何空白字符
  if (/[^\x21-\x7E]/.test(url)) return false; // 只能包含可打印非空格 ASCII 字符

  let remaining: string;
  const protocolMatch = url.match(/^https?:\/\//i);
  if (protocolMatch) {
    remaining = url.substring(protocolMatch[0].length);
  } else {
    // 未明确给出协议时，若包含 :// 则只允许 http/https
    if (url.includes('://')) {
      return false;
    }
    remaining = url;
  }

  // 分离 authority 和 path
  let authority: string;
  const slashIndex = remaining.indexOf('/');
  if (slashIndex === -1) {
    authority = remaining;
  } else {
    authority = remaining.substring(0, slashIndex);
  }

  if (authority.length === 0) return false; // 必须存在主机部分

  // 提取用户信息（可选）
  let hostPortPart: string;
  const atIndex = authority.lastIndexOf('@');
  if (atIndex !== -1) {
    const userinfo = authority.substring(0, atIndex);
    if (userinfo.length === 0 || /\s/.test(userinfo)) return false;
    hostPortPart = authority.substring(atIndex + 1);
  } else {
    hostPortPart = authority;
  }

  // 解析主机与端口
  let host: string;
  let port: string | undefined;

  if (hostPortPart.startsWith('[')) {
    // IPv6 地址必须被方括号包裹
    const closeBracket = hostPortPart.indexOf(']');
    if (closeBracket === -1) return false;
    host = hostPortPart.substring(0, closeBracket + 1);
    const after = hostPortPart.substring(closeBracket + 1);
    if (after === '') {
      port = undefined;
    } else if (after.startsWith(':')) {
      port = after.substring(1);
      if (port.length === 0) return false;
    } else {
      return false;
    }
  } else {
    // 域名或 IPv4，端口由最后一个冒号分隔
    const lastColon = hostPortPart.lastIndexOf(':');
    if (lastColon !== -1) {
      host = hostPortPart.substring(0, lastColon);
      port = hostPortPart.substring(lastColon + 1);
    } else {
      host = hostPortPart;
      port = undefined;
    }
  }

  if (host.length === 0) return false;

  // 校验主机
  if (host.startsWith('[')) {
    if (!host.endsWith(']')) return false;
    const ipv6 = host.substring(1, host.length - 1);
    if (!isValidIPv6(ipv6)) return false;
  } else {
    if (!isValidIPv4(host) && !isValidDomain(host)) {
      return false;
    }
  }

  // 校验端口
  if (port !== undefined) {
    if (!/^\d{1,5}$/.test(port)) return false;
    const portNum = parseInt(port, 10);
    if (portNum < 0 || portNum > 65535) return false;
  }

  // path/query/fragment 已经通过全局的 ASCII 与空白检查，无需额外处理
  return true;
}

function isValidIPv4(ip: string): boolean {
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

function isValidDomain(host: string): boolean {
  const lowerHost = host.toLowerCase();
  if (lowerHost.length > 253) return false;
  const labels = lowerHost.split('.');
  for (const label of labels) {
    if (label.length === 0 || label.length > 63) return false;
    // 标签由字母数字和连字符组成，连字符不能在首尾
    if (!/^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/.test(label)) return false;
  }
  return true;
}

function isValidIPv6(ip: string): boolean {
  // 支持 Zone ID（例如 %eth0）
  const zoneMatch = ip.match(/^([^%]+)(%[a-zA-Z0-9]+)?$/);
  if (!zoneMatch) return false;
  const address = zoneMatch[1];

  // 内嵌 IPv4（如 ::ffff:192.0.2.1）
  const ipv4Match = address.match(/(.*):((\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3}))$/);
  if (ipv4Match) {
    const prefix = ipv4Match[1];
    const ipv4 = ipv4Match[2];
    if (!isValidIPv4(ipv4)) return false;
    // 前缀部分最多允许 6 组（IPv4 占 2 组，合计 8 组）
    return isValidIPv6Prefix(prefix, 6);
  }

  return isValidIPv6Prefix(address, 8);
}

function isValidIPv6Prefix(prefix: string, maxGroups: number): boolean {
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
      if (!/^[0-9a-fA-F]{1,4}$/.test(part)) return false;
    }
    return true;
  }

  const parts = prefix.split(':');
  if (parts.length !== maxGroups) return false;
  for (const part of parts) {
    if (!/^[0-9a-fA-F]{1,4}$/.test(part)) return false;
  }
  return true;
}
