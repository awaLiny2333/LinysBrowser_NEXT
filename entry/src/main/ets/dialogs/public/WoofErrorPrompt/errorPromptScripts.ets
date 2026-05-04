export interface ErrorPromptDetails {
  isError: boolean;
  title?: ResourceStr;
  contents?: ResourceStr;
  changes?: ResourceStr[]; // To mark some changed made to the user's data. E.g. when importing App settings.
}
