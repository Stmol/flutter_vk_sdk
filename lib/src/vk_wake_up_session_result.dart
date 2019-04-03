part of flutter_vk_sdk;

class VKWakeUpSessionResult {
  final VKAuthorizationState state;
  final String error;

  VKWakeUpSessionResult(Map<String, dynamic> map)
      : state = map['state'] != null ? _parseState(map['state']) : null,
        error = map['error'];

  @override
  bool operator ==(Object o) =>
      identical(this, o) || o is VKWakeUpSessionResult && state == o.state && error == o.error;

  @override
  int get hashCode => state.hashCode ^ error.hashCode;
}
