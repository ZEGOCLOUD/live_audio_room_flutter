//
//  ZegoToken.m
//  ZIMChatRoomDemo
//
//  Created by Kael Ding on 2021/11/24.
//

#import "ZegoToken.h"
#import "ZegoRTCServerAssistant.h"
#import "ZegoServerAssistant.h"

@implementation ZegoToken

+ (NSString *)getRTCTokenWithRoomID:(NSString *)roomID
                             userID:(NSString *)userID
                              appID:(uint32_t)appID
                          appSecret:(NSString *)appSercret {
    std::map<int, int> privilege;
    privilege.insert(std::make_pair(ZEGO::SERVER_ASSISTANT03::kPrivilegeLogin, 1));
    privilege.insert(std::make_pair(ZEGO::SERVER_ASSISTANT03::kPrivilegePublish, 1));
    
    auto RTCTokenResult = ZEGO::SERVER_ASSISTANT03::ZegoRTCServerAssistant::GenerateToken(appID, roomID.UTF8String, userID.UTF8String, privilege, appSercret.UTF8String, 3600 * 24);

    NSString *rtcToken = [NSString stringWithCString:RTCTokenResult.token.c_str() encoding:NSUTF8StringEncoding];
    return rtcToken;
}

+ (NSString *)getZIMTokenWithUserID:(NSString *)userID
                              appID:(uint32_t)appID
                          appSecret:(NSString *)appSecret {
    auto tokenResult = ZEGO::SERVER_ASSISTANT::ZegoServerAssistant::GenerateToken(appID,
                                                                                  userID.UTF8String,
                                                                                  appSecret.UTF8String,
                                                                                  3600 * 24);
    NSString *token = [NSString stringWithCString:tokenResult.token.c_str() encoding:NSUTF8StringEncoding];
    return token;
}

@end
