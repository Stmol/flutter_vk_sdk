part of flutter_vk_sdk;

enum VKAuthorizationState {
  Unknown,
  Initialized,
  Pending,
  External,
  SafariInApp,
  Webview,
  Authorized,
  Error,
}

VKAuthorizationState _parseState(int rawValue) {
  switch (rawValue) {
    case 0:
      return VKAuthorizationState.Unknown;
    case 1:
      return VKAuthorizationState.Initialized;
    case 2:
      return VKAuthorizationState.Pending;
    case 3:
      return VKAuthorizationState.External;
    case 4:
      return VKAuthorizationState.SafariInApp;
    case 5:
      return VKAuthorizationState.Webview;
    case 6:
      return VKAuthorizationState.Authorized;
    case 7:
      return VKAuthorizationState.Error;
  }

  throw VKSdkException('Unknown VKAuthorizationState: $rawValue');
}
