//
//  ZIMPlugin.swift
//  Runner
//
//  Created by Larry on 2022/1/11.
//

import UIKit
import ZIM
import Flutter

class ZIMPlugin: NSObject {
    
    static let shared = ZIMPlugin()
    private override init() {}
    
    var zim: ZIM?
    
     func registerChannel() {
         guard let flutterViewController = UIApplication.shared.windows.first?.rootViewController as? FlutterViewController else { return }
         let channel = FlutterMethodChannel(name: "ZIMPlugin", binaryMessenger: flutterViewController.binaryMessenger)
         channel.setMethodCallHandler { (call, result) in
             // 根据函数名做不同的处理
             switch(call.method) {
             case "createZIM":
                self.createZIM(call, result: result)
                break
             case "destoryZIM":
                self.destoryZIM(call, result: result)
                break
             case "login":
                self.login(call, result: result)
                break
             case "logout":
                self.logout(call, result: result)
                break
             case "createRoom":
                self.createRoom(call, result: result)
                break
             case "joinRoom":
                self.joinRoom(call, result: result)
                break
             case "leaveRoom":
                self.leaveRoom(call, result: result)
                break
             case "uploadLog":
                self.uploadLog(call, result: result)
                break
             case "queryRoomAllAttributes":
                self.queryRoomAllAttributes(call, result: result)
                break
             case "queryRoomOnlineMemberCount":
                self.queryRoomOnlineMemberCount(call, result: result)
                break
             case "sendPeerMessage":
                self.sendPeerMessage(call, result: result)
                break
             case "sendRoomMessage":
                self.sendRoomMessage(call, result: result)
                break
             case "setRoomAttributes":
                self.setRoomAttributes(call, result: result)
                break
             default:
                 result(nil)
             }
         }
     }

     func createZIM(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
         if (params == nil) { return }
         let appID = params!["appID"] as? UInt32 ?? 0
         print("createZIM: %d", appID)
         zim = ZIM.create(appID)
         result(nil)
     }

     func destoryZIM(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         print("destoryZIM")
         zim?.destroy()
         zim = nil
         result(nil)
     }

     func login(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
         if (params == nil) { return }
         let userID = params!["userID"] as? String ?? ""
         let userName = params!["userName"] as? String ?? ""
         let token = params!["token"] as? String ?? ""
         let user = ZIMUserInfo()
         user.userID = userID
         user.userName = userName
         zim?.login(user, token: token, callback: { error in
             result(error.code)
         })
     }

     func logout(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         zim?.logout()
         result(nil)
     }

     func createRoom(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
         if (params == nil) { return }
         let roomID = params!["roomID"] as? String ?? ""
         let roomName = params!["roomName"] as? String ?? ""

         let roomInfo = ZIMRoomInfo()
         roomInfo.roomID = roomID
         roomInfo.roomName = roomName
         let jsonString = convertDictionaryToJSONString(dict: ["room_id": roomID, "room_name": roomName])
         let config = ZIMRoomAdvancedConfig()
         config.roomAttributes = ["room_Info": jsonString]
         zim?.createRoom(roomInfo, config: config, callback: { roomInfo, error in
             result(error.code)
         })
     }

     func joinRoom(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
         if (params == nil) { return }
         let roomID = params!["roomID"] as? String ?? ""
         zim?.joinRoom(roomID, callback: { roomInfo, error in
             result(error.code)
         })
     }

     func leaveRoom(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
         if (params == nil) { return }
         let roomID = params!["roomID"] as? String ?? ""
         zim?.leaveRoom(roomID, callback: { error in
             result(error.code)
         })
     }

     func uploadLog(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         zim?.uploadLog({ error in
             result(error.code)
         })
     }

     func queryRoomAllAttributes(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
         if (params == nil) { return }
         let roomID = params!["roomID"] as? String ?? ""
         zim?.queryRoomAllAttributes(byRoomID: roomID, callback: { roomAttributes, error in
             result(roomAttributes)
         })
     }

     func queryRoomOnlineMemberCount(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
                 if (params == nil) { return }
         let roomID = params!["roomID"] as? String ?? ""
         zim?.queryRoomOnlineMemberCount(roomID, callback: { count, error in
             result(count)
         })
     }

     func sendPeerMessage(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
                 if (params == nil) { return }
         let userID = params!["userID"] as? String ?? ""
         let content = params!["content"] as? String ?? ""
         let actionType = params!["actionType"] as? Int ?? 0
        
         let messageDic = ["userID": userID, "content": content, "actionType":actionType] as [String : Any]
         let data = convertDictionaryToData(dict: messageDic as NSDictionary)
         let customMessage = ZIMCustomMessage(message: data)
         zim?.sendPeerMessage(customMessage, toUserID: userID, callback: { message, error in
             result(error.code)
         })
     }

     func sendRoomMessage(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
                 if (params == nil) { return }
         let roomID = params!["roomID"] as? String ?? ""
         let textMessage = params!["text"] as? String ?? ""
         zim?.sendRoomMessage(textMessage, toRoomID: roomID, callback: { message, error in
             result(error.code)
         })
     }

     func setRoomAttributes(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
                 if (params == nil) { return }
         let roomID = params!["roomID"] as? String ?? ""
         let attributes = params!["attributes"] as? String ?? ""
         let isDeleteAfterOwnerLeft = params!["delete"] as? Bool ?? false

         let config = ZIMRoomAttributesSetConfig()
         config.isForce = true
         config.isDeleteAfterOwnerLeft = isDeleteAfterOwnerLeft
         zim?.setRoomAttributes(attributes, roomID: roomID, config: config, callback: { error in
             result(error.code)
         })
     }
    
    func convertDictionaryToJSONString(dict:NSDictionary?)->String {
        guard let data = try? JSONSerialization.data(withJSONObject: dict!, options: JSONSerialization.WritingOptions.init(rawValue: 0)) else { return "" }
        guard let jsonStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return "" }
        return jsonStr as String
    }
                               
   func convertDictionaryToData(dict:NSDictionary?)->Data {
       guard let data = try? JSONSerialization.data(withJSONObject: dict!, options: JSONSerialization.WritingOptions.init(rawValue: 0)) else { return Data() }
       return data
   }
    
}


