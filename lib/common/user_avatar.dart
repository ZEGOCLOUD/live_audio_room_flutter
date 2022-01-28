import 'dart:convert';

import 'package:crypto/crypto.dart';

int getUserAvatarIndex(String userName) {
  var avatarCode = int.parse(
      md5.convert(utf8.encode(userName)).toString().substring(0, 2),
      radix: 16);
  return avatarCode % 8;
}
