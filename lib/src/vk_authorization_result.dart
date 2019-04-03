part of flutter_vk_sdk;

class VKAuthorizationResult {
  final VKAccessToken token;
  final VKAuthorizationState state;
  final String error;
  final VKUser user;

  VKAuthorizationResult.fromMap(Map<String, dynamic> map)
      : token = map['token'] != null
            ? VKAccessToken.fromMap(Map<String, dynamic>.from(map['token']))
            : null,
        user = map['user'] != null ? VKUser.fromMap(Map<String, dynamic>.from(map['user'])) : null,
        state = map['state'] != null ? _parseState(map['state']) : null,
        error = map['error'];

  @override
  bool operator ==(Object o) =>
      identical(this, o) ||
      o is VKAuthorizationResult &&
          token == o.token &&
          state == o.state &&
          error == o.error &&
          user == o.user;

  @override
  int get hashCode => token.hashCode ^ state.hashCode ^ error.hashCode ^ user.hashCode;
}
