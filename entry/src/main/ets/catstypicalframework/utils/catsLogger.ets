export enum meowLevel {
  INFO = 1,
  WARN = 2,
  ERROR = 3,
}

export function meow(content: string, tag: string = '', level: meowLevel = meowLevel.INFO) {
  switch (level) {
    case meowLevel.INFO:
      console.log(`[meow][${tag}] ${content}`);
      break;
    case meowLevel.WARN:
      console.warn(`[meow][${tag}] ${content}`);
      break;
    case meowLevel.ERROR:
      console.error(`[meow][${tag}] ${content}`);
      break;
  }
}