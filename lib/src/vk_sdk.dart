part of flutter_vk_sdk;

class VKSdk {
  static const MethodChannel methodChannel = MethodChannel('me.stmol.flutter_vk_sdk_plugin/method');
  static const EventChannel eventChannel = EventChannel('me.stmol.flutter_vk_sdk_plugin/event');

  static Future<VKSdk> initialize({@required String appId, String apiVersion}) async {
    final instance = VKSdk._();
    await instance._setupVKSdk(appId, apiVersion);

    eventChannel.receiveBroadcastStream().listen(instance._onEvent);

    return instance;
  }

  static Future<bool> initialized() async => await _callMethod('initialized') as bool;

  static Future<bool> vkAppMayExists() async => await _callMethod('vkAppMayExists') as bool;

  static Future<void> setSchedulerEnabled(bool isEnabled) async =>
      await _callMethod('setSchedulerEnabled');

  VKSdk._();

  final _vkSdkEvents = StreamController<VKSdkEvent>.broadcast();

  Stream<VKAuthorizationResult> get accessAuthorizationFinished => _vkSdkEvents.stream
      .where((e) => e.eventName == VKSdkEvent.EVENT_AUTH_FINISHED)
      .map((e) => e.eventObject);

  Stream<VKAuthorizationResult> get authorizationStateUpdated => _vkSdkEvents.stream
      .where((e) => e.eventName == VKSdkEvent.EVENT_AUTH_STATE_UPDATED)
      .map((e) => e.eventObject);

  Stream<void> get userAuthorizationFailed => _vkSdkEvents.stream
      .where((e) => e.eventName == VKSdkEvent.EVENT_USER_AUTH_FAILED)
      .map((_) => null);

  Stream<void> get shouldPresent => _vkSdkEvents.stream
      .where((e) => e.eventName == VKSdkEvent.EVENT_SHOULD_PRESENT)
      .map((_) => null);

  Stream<void> get willDismiss => _vkSdkEvents.stream
      .where((e) => e.eventName == VKSdkEvent.EVENT_WILL_DISMISS)
      .map((_) => null);

  Stream<void> get didDismiss => _vkSdkEvents.stream
      .where((e) => e.eventName == VKSdkEvent.EVENT_DID_DISMISS)
      .map((_) => null);

  Stream<String> get needCaptchaEnter => _vkSdkEvents.stream
      .where((e) => e.eventName == VKSdkEvent.EVENT_NEED_CAPTCHA)
      .map((e) => e.eventObject);

  Stream<VKAccessToken> get tokenHasExpired => _vkSdkEvents.stream
      .where((e) => e.eventName == VKSdkEvent.EVENT_TOKEN_HAS_EXPIRED)
      .map((e) => e.eventObject);

  Stream<Map<String, VKAccessToken>> get accessTokenUpdated => _vkSdkEvents.stream
      .where((e) => e.eventName == VKSdkEvent.EVENT_ACCESS_TOKEN_UPDATED)
      .map((e) => e.eventObject);

  Future<String> apiVersion() async => await _callMethod('apiVersion') as String;

  Future<String> currentAppId() async => await _callMethod('currentAppId') as String;

  Future<bool> isLoggedIn() async => await _callMethod('isLoggedIn') as bool;

  Future<void> forceLogout() async => await _callMethod('forceLogout');

  Future<void> authorize(List<String> permissions, {bool isSafariDisabled = false}) async {
    await _callMethod('authorize', {
      'permissions': permissions,
      'isSafariDisabled': isSafariDisabled,
    });
  }

  Future<VKAccessToken> accessToken() async {
    final result = await _callMethod('accessToken');
    return VKAccessToken.fromMap(Map<String, dynamic>.from(result));
  }

  Future<VKWakeUpSessionResult> wakeUpSession(List<String> permissions) async {
    final result = await _callMethod('wakeUpSession', {
      'permissions': permissions,
    });

    return VKWakeUpSessionResult(Map<String, dynamic>.from(result));
  }

  Future<void> _setupVKSdk(String appId, String apiVersion) async {
    await _callMethod('setupVKSdk', {
      'appId': appId,
      'apiVersion': apiVersion,
    });
  }

  void _onEvent(Object event) {
    final response = Map<String, dynamic>.from(event);
    final eventName = response['eventName'];

    switch (eventName) {
      case VKSdkEvent.EVENT_AUTH_FINISHED:
      case VKSdkEvent.EVENT_AUTH_STATE_UPDATED:
        final payload = Map<String, dynamic>.from(response['payload']);
        _vkSdkEvents.add(VKSdkEvent<VKAuthorizationResult>(
          eventName: eventName,
          eventObject: VKAuthorizationResult.fromMap(payload),
        ));
        break;

      case VKSdkEvent.EVENT_NEED_CAPTCHA:
        final payload = Map<String, dynamic>.from(response['payload']);
        _vkSdkEvents.add(VKSdkEvent<String>(
          eventName: eventName,
          eventObject: payload['error'],
        ));
        break;

      case VKSdkEvent.EVENT_TOKEN_HAS_EXPIRED:
        final payload = Map<String, dynamic>.from(response['payload']);
        _vkSdkEvents.add(VKSdkEvent<VKAccessToken>(
          eventName: eventName,
          eventObject: payload['token'] != null
              ? VKAccessToken.fromMap(Map<String, dynamic>.from(payload['token']))
              : null,
        ));
        break;

      case VKSdkEvent.EVENT_ACCESS_TOKEN_UPDATED:
        final payload = Map<String, dynamic>.from(response['payload']);
        final newToken = VKAccessToken.fromMap(Map<String, dynamic>.from(payload['newToken']));
        final oldToken = VKAccessToken.fromMap(Map<String, dynamic>.from(payload['oldToken']));

        _vkSdkEvents.add(VKSdkEvent<Map<String, VKAccessToken>>(
          eventName: eventName,
          eventObject: {
            'newToken': newToken,
            'oldToken': oldToken,
          },
        ));

        break;

      case VKSdkEvent.EVENT_USER_AUTH_FAILED:
      case VKSdkEvent.EVENT_SHOULD_PRESENT:
      case VKSdkEvent.EVENT_WILL_DISMISS:
      case VKSdkEvent.EVENT_DID_DISMISS:
        _vkSdkEvents.add(VKSdkEvent<void>(eventName: eventName, eventObject: null));
        break;

      default:
        _vkSdkEvents.addError('Event $eventName has no handlers.');
    }
  }

  static Future<dynamic> _callMethod(String method,
      [Map<String, dynamic> arguments = const {}]) async {
    final Map<dynamic, dynamic> result = await methodChannel.invokeMethod(method, arguments);

    if (result['status'] == 'failure') {
      throw VKSdkException(result['payload']);
    }

    if (result['status'] == 'success') {
      return result['payload'];
    }

    throw VKSdkException('Invalid result response');
  }
}
