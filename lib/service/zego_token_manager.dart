import 'dart:developer';

import 'package:result_type/result_type.dart';

import '../plugin/zim_plugin.dart';

typedef TokenResult = Result<String, int>; //  <token, error>

class ZegoTokenManager {
  static var shared = ZegoTokenManager();

  String token = "";
  int expiryTime = 0;
  String userID = "";

  Future<TokenResult> getToken(String userID,
      {bool isForceUpdate = false}) async {
    //  seconds
    var currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    var isNotExpiry = (expiryTime - currentTime) > 10 * 60; //  10 minutes
    if (this.userID.isNotEmpty &&
        this.userID == userID &&
        token.isNotEmpty &&
        isNotExpiry &&
        !isForceUpdate) {
      log('[token] use old token:$token');
      return Success(token);
    }

    const effectiveTimeInSeconds = 24 * 60 * 60; // 24h
    return getTokenFromServer(userID, effectiveTimeInSeconds).then((result) {
      if (result.isSuccess) {
        token = result.success;
        this.userID = userID;
        expiryTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 +
            effectiveTimeInSeconds;
      }
      log('[token] new token:$result');
      return result;
    });
  }

  Future<TokenResult> getTokenFromServer(
      String userID, int effectiveTimeInSeconds) async {
    var result = await ZIMPlugin.getToken(userID);
    var token = result["token"];

    return Success(token);
  }
}
