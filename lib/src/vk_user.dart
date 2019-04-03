part of flutter_vk_sdk;

class VKUser {
  final int id;
  final String firstName;
  final String lastName;
  final int sex;
  final int online;
  final String bdate;
  final String photoMax;
  final String photo50;
  final String photo100;
  final String photo200;
  final String photo200orig;
  final String photo400orig;
  final String photoMaxOrig;

  VKUser.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        firstName = map['firstName'],
        lastName = map['lastName'],
        sex = map['sex'],
        online = map['online'],
        bdate = map['bdate'],
        photoMax = map['photoMax'],
        photo50 = map['photo50'],
        photo100 = map['photo100'],
        photo200 = map['photo200'],
        photo200orig = map['photo200orig'],
        photo400orig = map['photo400orig'],
        photoMaxOrig = map['photoMaxOrig'];

  @override
  bool operator ==(Object o) =>
      identical(this, o) ||
      o is VKUser &&
          runtimeType == o.runtimeType &&
          id == o.id &&
          firstName == o.firstName &&
          lastName == o.lastName &&
          sex == o.sex &&
          online == o.online &&
          bdate == o.bdate &&
          photoMax == o.photoMax &&
          photo50 == o.photo50 &&
          photo100 == o.photo100 &&
          photo200 == o.photo200 &&
          photo200orig == o.photo200orig &&
          photo400orig == o.photo400orig &&
          photoMaxOrig == o.photoMaxOrig;

  @override
  int get hashCode =>
      id.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      sex.hashCode ^
      online.hashCode ^
      bdate.hashCode ^
      photoMax.hashCode ^
      photo50.hashCode ^
      photo100.hashCode ^
      photo200.hashCode ^
      photo200orig.hashCode ^
      photo400orig.hashCode ^
      photoMaxOrig.hashCode;
}
