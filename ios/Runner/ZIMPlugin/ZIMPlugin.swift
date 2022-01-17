//
//  ZIMPlugin.swift
//  Runner
//
//  Created by Larry on 2022/1/11.
//

import UIKit
import ZIM
import Flutter
import fluttertoast

class ZIMPlugin: NSObject {
    
    static let shared = ZIMPlugin()
    private override init() {}
    
    var events: FlutterEventSink?
    var appID: UInt32 = 0
    var appSign: String = ""
    var serverSecret: String = ""
    
    var zim: ZIM?
    
    func registerChannel() {
         guard let flutterViewController = UIApplication.shared.windows.first?.rootViewController as? FlutterViewController else { return }
         
         FlutterEventChannel(name: "ZIMPluginEventChannel", binaryMessenger: flutterViewController.binaryMessenger).setStreamHandler(self)
         
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
         var token = params!["token"] as? String ?? ""
         serverSecret = params!["serverSecret"] as? String ?? ""
         if token.count == 0 {
             token = AppToken.getZIMToken(withUserID: userID, appID: appID, secret: serverSecret) ?? ""
         }
         
         let user = ZIMUserInfo()
         user.userID = userID
         user.userName = userName
         zim?.login(user, token: token, callback: { error in
             result(["errorCode": NSNumber(value: error.code.rawValue)])
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
             result(["errorCode": NSNumber(value: error.code.rawValue)])
         })
     }

     func joinRoom(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
         if (params == nil) { return }
         let roomID = params!["roomID"] as? String ?? ""
         zim?.joinRoom(roomID, callback: { roomInfo, error in
             let dic = ["id": roomInfo.baseInfo.roomID, "name": roomInfo.baseInfo.roomName]
             result(["errorCode": NSNumber(value: error.code.rawValue), "roomInfo": dic])
         })
     }

     func leaveRoom(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
         if (params == nil) { return }
         let roomID = params!["roomID"] as? String ?? ""
         zim?.leaveRoom(roomID, callback: { error in
             result(["errorCode": NSNumber(value: error.code.rawValue)])
         })
     }

     func uploadLog(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         zim?.uploadLog({ error in
             result(["errorCode": NSNumber(value: error.code.rawValue)])
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
             result(["errorCode": NSNumber(value: error.code.rawValue), "count": count])
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
             result(["errorCode": NSNumber(value: error.code.rawValue)])
         })
     }

     func sendRoomMessage(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
                 if (params == nil) { return }
         let roomID = params!["roomID"] as? String ?? ""
         let content = params!["content"] as? String ?? ""
         let isCustomMessage = params!["isCustomMessage"] as? Bool ?? false
         var message: ZIMMessage?
         if (isCustomMessage) {
             let contentData = content.data(using: .utf8) ?? Data()
             message = ZIMCustomMessage(message: contentData)
         } else {
             message = ZIMTextMessage(message: content)
         }
         guard let message = message else {
             return
         }

         zim?.sendRoomMessage(message, toRoomID: roomID, callback: { message, error in
             result(["errorCode": NSNumber(value: error.code.rawValue)])
         })
     }

     func setRoomAttributes(_ call: FlutterMethodCall, result:@escaping FlutterResult)  {
         let params = call.arguments as? NSDictionary
                 if (params == nil) { return }
         let roomID = params!["roomID"] as? String ?? ""
         let attributes = params!["attributes"] as? String ?? ""
         let isDeleteAfterOwnerLeft = params!["delete"] as? Bool ?? false
         let dic = convertJSONStringToDictionary(json:attributes) ?? Dictionary<String, String>()
         let config = ZIMRoomAttributesSetConfig()
         config.isForce = true
         config.isDeleteAfterOwnerLeft = isDeleteAfterOwnerLeft
         zim?.setRoomAttributes(dic, roomID: roomID, config: config, callback: { error in
             result(["errorCode": NSNumber(value: error.code.rawValue)])
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
    
    func convertJSONStringToDictionary(json: String?)->Dictionary<String, String>? {
        guard let data = json?.data(using: .utf8) else { return nil }
        
        do {
            let dic = try JSONSerialization.jsonObject(with: data, options:.allowFragments)
            return dic as? Dictionary<String, String> ?? nil
        } catch {
            return nil
        }
    }
}

extension ZIMPlugin: ZIMEventHandler {
    func zim(_ zim: ZIM, connectionStateChanged state: ZIMConnectionState, event: ZIMConnectionEvent, extendedData: [AnyHashable : Any]) {
        guard let events = self.events else { return }
        events(["connectionStateChanged", state, event])
    }
    
    // MARK: - Main
    func zim(_ zim: ZIM, errorInfo: ZIMError) {
        guard let events = self.events else { return }
        events(["zim", errorInfo.code])
    }
    
    func zim(_ zim: ZIM, tokenWillExpire second: UInt32) {
        guard let events = self.events else { return }
        events(["tokenWillExpire", second])
        
    }
    
    // MARK: - Message
    func zim(_ zim: ZIM, receivePeerMessage messageList: [ZIMMessage], fromUserID: String) {
        guard let events = self.events else { return }
        events(["receivePeerMessage", messageList, fromUserID])
    }
    
    func zim(_ zim: ZIM, receiveRoomMessage messageList: [ZIMMessage], fromRoomID: String) {
        guard let events = self.events else { return }
        events(["receiveRoomMessage", messageList, fromRoomID])
    }
    
    // MARK: - Room
    func zim(_ zim: ZIM, roomMemberJoined memberList: [ZIMUserInfo], roomID: String) {
        guard let events = self.events else { return }
        events(["roomMemberJoined", memberList, roomID])
    }
    
    func zim(_ zim: ZIM, roomMemberLeft memberList: [ZIMUserInfo], roomID: String) {
        guard let events = self.events else { return }
        events(["roomMemberLeft", memberList, roomID])
        
    }
    
    func zim(_ zim: ZIM, roomStateChanged state: ZIMRoomState, event: ZIMRoomEvent, extendedData: [AnyHashable : Any], roomID: String) {
        guard let events = self.events else { return }
        events(["roomStateChanged", state, event])
    }
    
//    func zim(_ zim: ZIM, roomAttributesUpdated updateInfo: ZIMRoomAttributesUpdateInfo, roomID: String) {
//        guard let events = self.events else { return }
//        events(["roomAttributesUpdated", updateInfo, roomID])
//    }
}

extension ZIMPlugin : FlutterStreamHandler {
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.events = events
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        events = nil
        return nil
    }
    
}
