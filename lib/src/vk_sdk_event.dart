part of flutter_vk_sdk;

class VKSdkEvent<T> {
  static const String EVENT_AUTH_FINISHED = 'vkSdkAccessAuthorizationFinished';
  static const String EVENT_AUTH_STATE_UPDATED = 'vkSdkAuthorizationStateUpdated';
  static const String EVENT_USER_AUTH_FAILED = 'vkSdkUserAuthorizationFailed';
  static const String EVENT_ACCESS_TOKEN_UPDATED = 'vkSdkAccessTokenUpdated';
  static const String EVENT_TOKEN_HAS_EXPIRED = 'vkSdkTokenHasExpired';
  static const String EVENT_WILL_DISMISS = 'vkSdkWillDismiss';
  static const String EVENT_DID_DISMISS = 'vkSdkDidDismiss';
  static const String EVENT_SHOULD_PRESENT = 'vkSdkShouldPresent';
  static const String EVENT_NEED_CAPTCHA = 'vkSdkNeedCaptchaEnter';

  final String eventName;
  final T eventObject;

  VKSdkEvent({@required this.eventName, @required this.eventObject});

  @override
  bool operator ==(Object o) =>
      identical(this, o) ||
      o is VKSdkEvent && eventName == o.eventName && eventObject == o.eventObject;

  @override
  int get hashCode => eventName.hashCode ^ eventObject.hashCode;
}
