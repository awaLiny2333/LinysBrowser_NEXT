export interface ErrorPromptDetails {
  isError: boolean;
  title: ResourceStr | undefined;
  contents: ResourceStr | undefined;
  changes: ResourceStr[] | undefined; // To mark some changed made to the user's data. E.g. when importing App settings.
}
