import 'dart:convert';

import 'package:crypto/crypto.dart';

int getUserAvatarIndex(String userName) {
  if(userName.isEmpty) {
    return 0;
  }

  var digest = md5.convert(utf8.encode(userName));
  var value0 = digest.bytes[0] & 0xff;
  return (value0 % 8).abs();

  // var avatarCode = int.parse(
  //     md5.convert(utf8.encode(userName)).toString().substring(0, 2),
  //     radix: 16);
  // return avatarCode % 8;
}
