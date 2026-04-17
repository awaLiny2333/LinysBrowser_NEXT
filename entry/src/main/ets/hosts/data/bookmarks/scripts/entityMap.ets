/**
 * 命名实体查找表（使用 Map 彻底规避 arkts-no-untyped-obj-literals）
 * 
 * @author ChatGPT @ Apr 15 2026
 */
export const ENTITY_MAP = new Map<string, string>();

// 基础转义
ENTITY_MAP.set('amp', '&');                // &（和号）
ENTITY_MAP.set('lt', '<');                 // <（小于号）
ENTITY_MAP.set('gt', '>');                 // >（大于号）
ENTITY_MAP.set('quot', '"');               // "（双引号）
ENTITY_MAP.set('apos', "'");               // '（单引号）

// 空白 / 排版控制
ENTITY_MAP.set('nbsp', '\u00A0');          // 不换行空格
ENTITY_MAP.set('ensp', '\u2002');          // En 空格
ENTITY_MAP.set('emsp', '\u2003');          // Em 空格
ENTITY_MAP.set('thinsp', '\u2009');        // Thin 空格
ENTITY_MAP.set('zwnj', '\u200C');          // Zero Width Non-Joiner
ENTITY_MAP.set('zwj', '\u200D');           // Zero Width Joiner
ENTITY_MAP.set('lrm', '\u200E');           // Left to Right Mark
ENTITY_MAP.set('rlm', '\u200F');           // Right to Left Mark

// 引号
ENTITY_MAP.set('lsquo', '\u2018');         // 左单引号
ENTITY_MAP.set('rsquo', '\u2019');         // 右单引号
ENTITY_MAP.set('sbquo', '\u201A');         // 单低引号
ENTITY_MAP.set('ldquo', '\u201C');         // 左双引号
ENTITY_MAP.set('rdquo', '\u201D');         // 右双引号
ENTITY_MAP.set('bdquo', '\u201E');         // 双低引号

// 破折号
ENTITY_MAP.set('ndash', '\u2013');         // en dash
ENTITY_MAP.set('mdash', '\u2014');         // em dash

// 标点符号
ENTITY_MAP.set('iexcl', '\u00A1');         // ¡（倒叹号）
ENTITY_MAP.set('iquest', '\u00BF');        // ¿（倒问号）
ENTITY_MAP.set('laquo', '\u00AB');         // 《（左双角引号）
ENTITY_MAP.set('raquo', '\u00BB');         // 》（右双角引号）
ENTITY_MAP.set('lsaquo', '\u2039');        // ‹（左单角引号）
ENTITY_MAP.set('rsaquo', '\u203A');        // ›（右单角引号）
ENTITY_MAP.set('bull', '\u2022');          // •（项目符号）
ENTITY_MAP.set('hellip', '\u2026');        // …（省略号）
ENTITY_MAP.set('prime', '\u2032');         // ′（分钟符号）
ENTITY_MAP.set('Prime', '\u2033');         // ″（秒符号）
ENTITY_MAP.set('dagger', '\u2020');        // †（匕首符号）
ENTITY_MAP.set('Dagger', '\u2021');        // ‡（双匕首符号）
ENTITY_MAP.set('permil', '\u2030');        // ‰（千分号）
ENTITY_MAP.set('sect', '\u00A7');          // §（段落符号）
ENTITY_MAP.set('para', '\u00B6');          // ¶（段落符号）
ENTITY_MAP.set('middot', '\u00B7');        // ·（间隔点）
ENTITY_MAP.set('shy', '\u00AD');           // Soft hyphen（软连字符）
ENTITY_MAP.set('brvbar', '\u00A6');        // ¦（断裂符号）

// 数学符号
ENTITY_MAP.set('times', '\u00D7');         // ×（乘号）
ENTITY_MAP.set('divide', '\u00F7');        // ÷（除号）
ENTITY_MAP.set('plusmn', '\u00B1');        // ±（正负号）
ENTITY_MAP.set('minus', '\u2212');         // −（减号）
ENTITY_MAP.set('deg', '\u00B0');           // °（度符号）
ENTITY_MAP.set('micro', '\u00B5');         // µ（微符号）
ENTITY_MAP.set('not', '\u00AC');           // ¬（非符号）
ENTITY_MAP.set('infin', '\u221E');         // ∞（无穷大）
ENTITY_MAP.set('ne', '\u2260');            // ≠（不等于符号）
ENTITY_MAP.set('le', '\u2264');            // ≤（小于等于）
ENTITY_MAP.set('ge', '\u2265');            // ≥（大于等于）
ENTITY_MAP.set('frac14', '\u00BC');        // ¼（四分之一）
ENTITY_MAP.set('frac12', '\u00BD');        // ½（二分之一）
ENTITY_MAP.set('frac34', '\u00BE');        // ¾（三分之二）

// 货币符号
ENTITY_MAP.set('euro', '\u20AC');          // €（欧元符号）
ENTITY_MAP.set('pound', '\u00A3');         // £（英镑符号）
ENTITY_MAP.set('yen', '\u00A5');           // ¥（日元符号）
ENTITY_MAP.set('cent', '\u00A2');          // ¢（美分符号）
ENTITY_MAP.set('curren', '\u00A4');        // ¤（货币符号）

// 拉丁补充 / 商标
ENTITY_MAP.set('copy', '\u00A9');          // ©（版权符号）
ENTITY_MAP.set('reg', '\u00AE');           // ®（注册商标符号）
ENTITY_MAP.set('trade', '\u2122');         // ™（商标符号）
ENTITY_MAP.set('uml', '\u00A8');           // ¨（分隔符）
ENTITY_MAP.set('macr', '\u00AF');          // ¯（长划线）
ENTITY_MAP.set('acute', '\u00B4');         // ´（尖音符）
ENTITY_MAP.set('cedil', '\u00B8');         // ¸（轻音符）
ENTITY_MAP.set('ordf', '\u00AA');          // ª（女性序数符号）
ENTITY_MAP.set('ordm', '\u00BA');          // º（男性序数符号）
ENTITY_MAP.set('sup1', '\u00B9');          // ¹（上标1）
ENTITY_MAP.set('sup2', '\u00B2');          // ²（上标2）
ENTITY_MAP.set('sup3', '\u00B3');          // ³（上标3）

// 其他常见符号
ENTITY_MAP.set('nbsp', '\u00A0');          // Non-breaking space
ENTITY_MAP.set('copy', '\u00A9');          // Copyright symbol
ENTITY_MAP.set('reg', '\u00AE');           // Registered trademark
ENTITY_MAP.set('trade', '\u2122');         // Trademark symbol
