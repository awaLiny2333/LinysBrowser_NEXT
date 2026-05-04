export interface ErrorPromptDetails {
  isError: boolean;
  title: ResourceStr | undefined;
  contents: ResourceStr | undefined;
  additional: ResourceStr[] | undefined;
}
