//
//  AppToken.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/17.
//

import Foundation

struct AppToken {
    static func getToken(withUserID userID: String?, appID: UInt32, secret: String) -> String? {
        guard let userID = userID else { return nil }

        let token = ZegoToken.getZIMToken(withUserID: userID,
                                          appID: appID,
                                          appSecret:secret)
        
        return token
    }
}
