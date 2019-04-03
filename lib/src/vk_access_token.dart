part of flutter_vk_sdk;

///
/// TODO: Add IterableEquality to == function for List of permissions
///
class VKAccessToken {
  final String accessToken;
  final String userId;
  final String secret;
  final String email;

  final bool isExpired;
  final bool httpsRequired;

  final List<String> permissions;
  final DateTime expiresIn;
  final VKUser localUser;

  VKAccessToken.fromMap(Map<String, dynamic> map)
      : accessToken = map['accessToken'],
        userId = map['userId'],
        secret = map['secret'],
        httpsRequired = map['httpsRequired'],
        email = map['email'],
        isExpired = map['isExpired'],
        permissions = map['permissions'] is List ? List<String>.from(map['permissions']) : null,
        expiresIn = map['expiresIn'] is int
            ? DateTime.fromMillisecondsSinceEpoch(map['expiresIn'], isUtc: true)
            : null,
        localUser = map['localUser'] != null
            ? VKUser.fromMap(Map<String, dynamic>.from(map['localUser']))
            : null;

  @override
  bool operator ==(Object o) =>
      identical(this, o) ||
      o is VKAccessToken &&
          runtimeType == o.runtimeType &&
          accessToken == o.accessToken &&
          userId == o.userId &&
          secret == o.secret &&
          email == o.email &&
          httpsRequired == o.httpsRequired &&
          isExpired == o.isExpired &&
          expiresIn == o.expiresIn &&
          localUser == o.localUser;

  @override
  int get hashCode =>
      accessToken.hashCode ^
      userId.hashCode ^
      secret.hashCode ^
      email.hashCode ^
      httpsRequired.hashCode ^
      isExpired.hashCode ^
      expiresIn.hashCode ^
      localUser.hashCode;
}
