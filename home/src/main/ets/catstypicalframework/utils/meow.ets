/**
 * Have some fun ヽ(°◇° )ノ
 */

/**
 * Meow meowme owowwow.
 */
const emoticons = [
  'ฅ(❀ ´꒳`)ฅ',
  '꒰ᐡ•̀ᴗ•́ᐡ꒱',
  '(❀・ω・)',
  '(・ω・)',
  '∪･ω･∪',
  '(๑و•̀ω•́)و',
  'ฅ^•ω•^ฅ',
  '／˃̵ ֊ ˂̵ マ Ⳋ',
  'ฅ(•ㅅ•❀)ฅ',
  '(=①ω①=)',
  'ヽ(°◇° )ノ'
];

/**
 * Returns a random emoticon from the list.
 * @returns A random emoticon string.
 */
export function getRandomEmoticon() {
  return emoticons[Math.floor(Math.random() * emoticons.length)];
}

/**
 * The meowy links.
 */
export enum MeowLinks {
  BILI = 'https://space.bilibili.com/678438347',
  GITHUB = 'https://github.com/awaLiny2333/LinysBrowser_NEXT',
  GITEE = 'https://gitee.com/awa_Liny/LinysBrowser_NEXT'
}
