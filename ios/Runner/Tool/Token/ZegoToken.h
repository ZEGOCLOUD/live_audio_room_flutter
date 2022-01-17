//
//  ZegoToken.h
//  ZIMChatRoomDemo
//
//  Created by Kael Ding on 2021/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoToken : NSObject

+ (NSString *)getRTCTokenWithRoomID:(NSString *)roomID
                             userID:(NSString *)userID
                              appID:(uint32_t)appID
                          appSecret:(NSString *)appSercret;

+ (NSString *)getZIMTokenWithUserID:(NSString *)userID
                              appID:(uint32_t)appID
                          appSecret:(NSString *)appSecret;

@end

NS_ASSUME_NONNULL_END
