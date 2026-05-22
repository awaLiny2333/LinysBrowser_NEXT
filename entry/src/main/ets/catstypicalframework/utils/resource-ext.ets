export const exactMimeSymbols = new Map<string, Resource>([
  // TEXT
  ['text/html', $r('sys.symbol.worldclock')],
  ['text/csv', $r('sys.symbol.Investment_stable_value_add')],
  ['text/plain', $r('sys.symbol.doc_text')],
  ['text/markdown', $r('sys.symbol.doc_plaintext_and_pencil')],
  ['text/calendar', $r('sys.symbol.calendar')],
  ['application/json', $r('sys.symbol.doc_text_badge_magnifyingglass')],
  ['application/rtf', $r('sys.symbol.doc_text')],

  // ARCHIVES
  ['application/zip', $r('sys.symbol.doc_zipper')],
  ['application/x-rar-compressed', $r('sys.symbol.doc_zipper')],
  ['application/x-7z-compressed', $r('sys.symbol.doc_zipper')],
  ['application/x-tar', $r('sys.symbol.doc_zipper')],
  ['application/gzip', $r('sys.symbol.doc_zipper')],
  ['application/x-bzip2', $r('sys.symbol.doc_zipper')],
  ['application/x-xz', $r('sys.symbol.doc_zipper')],
  ['application/x-compress', $r('sys.symbol.doc_zipper')],
  ['application/vnd.rar', $r('sys.symbol.doc_zipper')],

  // DOCUMENTS
  ['application/pdf', $r('sys.symbol.pdf_doc')],
  ['application/msword', $r('sys.symbol.doc_text')],
  ['application/vnd.openxmlformats-officedocument.wordprocessingml.document', $r('sys.symbol.doc_text')],
  ['application/vnd.ms-excel', $r('sys.symbol.Investment_stable_value_add')],
  ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', $r('sys.symbol.Investment_stable_value_add')],
  ['application/vnd.ms-powerpoint', $r('sys.symbol.square_text_rectangle')],
  ['application/vnd.openxmlformats-officedocument.presentationml.presentation', $r('sys.symbol.square_text_rectangle')],
  ['application/epub+zip', $r('sys.symbol.book')],

  // EXECUTABLES
  ['application/vnd.android.package-archive', $r('sys.symbol.robot')],
  ['application/x-msdownload', $r('sys.symbol.cube_and_arrow_down')],
  ['application/vnd.huawei.hap', $r('sys.symbol.HarmonyOS_Next')],
  ['application/x-elf', $r('sys.symbol.root')],
  ['application/x-mach-binary', $r('sys.symbol.root')],

  // IMAGES
  ['image/jpeg', $r('sys.symbol.picture')],
  ['image/png', $r('sys.symbol.picture')],
  ['image/gif', $r('sys.symbol.gif')],
  ['image/webp', $r('sys.symbol.picture')],
  ['image/svg+xml', $r('sys.symbol.picture')],
  ['image/bmp', $r('sys.symbol.picture')],
  ['image/x-icon', $r('sys.symbol.star')],

  // AUDIO
  ['audio/mpeg', $r('sys.symbol.music')],
  ['audio/ogg', $r('sys.symbol.music')],
  ['audio/wav', $r('sys.symbol.music')],
  ['audio/flac', $r('sys.symbol.music')],
  ['audio/x-m4a', $r('sys.symbol.music')],
  ['audio/aac', $r('sys.symbol.music')],

  // VIDEO
  ['video/mp4', $r('sys.symbol.video')],
  ['video/mpeg', $r('sys.symbol.video')],
  ['video/x-msvideo', $r('sys.symbol.video')],
  ['video/quicktime', $r('sys.symbol.video')],
  ['video/x-matroska', $r('sys.symbol.video')],
  ['video/webm', $r('sys.symbol.video')],

  // SCRIPTS & CODE
  ['text/javascript', $r('sys.symbol.code')],
  ['application/x-python', $r('sys.symbol.code')],
  ['application/x-java', $r('sys.symbol.code')],
  ['text/x-c', $r('sys.symbol.code')],
  ['text/x-c++', $r('sys.symbol.code')],
  ['application/x-shellscript', $r('sys.symbol.root')],

  // FONTS
  ['font/ttf', $r('sys.symbol.textformat')],
  ['font/otf', $r('sys.symbol.textformat')],
  ['font/woff', $r('sys.symbol.textformat')],
  ['font/woff2', $r('sys.symbol.textformat')],
]);

export interface MimeSymbolRule {
  prefix: string;
  symbol: Resource;
}

export const prefixRules: MimeSymbolRule[] = [
  { prefix: 'image/', symbol: $r('sys.symbol.picture') },
  { prefix: 'video/', symbol: $r('sys.symbol.video') },
  { prefix: 'audio/', symbol: $r('sys.symbol.music') },
  { prefix: 'text/', symbol: $r('sys.symbol.doc_text') },
  { prefix: 'application/', symbol: $r('sys.symbol.more') },
];
