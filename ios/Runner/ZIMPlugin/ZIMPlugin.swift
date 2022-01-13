//
//  ZIMPlugin.swift
//  Runner
//
//  Created by Larry on 2022/1/11.
//

import UIKit
// import ZIM
import Flutter

class ZIMPlugin: NSObject {

//     func registerChannel() {
// //        let channel = FlutterMethodChannel(name: "ZIMPlugin", binaryMessenger: self.binaryMessenger)
// //        channel.setMethodCallHandler { (call, res) in
// //            // 根据函数名做不同的处理
// //            switch(call.method) {
// //                case "createZIM":
// //                    createZIM(call, res)
// //                default:
// //                    res(nil)
// //            }
// //        }
//     }
//
//     private val zim: ZIM?
//     func createZIM(call: FlutterMethodCall, result: FlutterResult)  {
//         let params = call.arguments as? NSDictionary
//         if (params == nil) { return }
//         let pid = params!["pid"] as? String ?? ""
//         zim = ZIM.create(pid)
//     }
//
//     func destoryZIM(call: FlutterMethodCall, result: FlutterResult)  {
//         zim.destroy()
//         zim = nil
//         print("destoryZIM")
//         result(nil)
//     }
//
//     func login(call: FlutterMethodCall, result: FlutterResult)  {
//         let params = call.arguments as? NSDictionary
//         if (params == nil) { return }
//         var userID = params!["userID"] as? String ?? ""
//         var userName = params!["userName"] as? String ?? ""
//         var token = params!["token"] as? String ?? ""
//         let user = ZIMUserInfo()
//         user.userID = userID
//         user.userName = userName
//         zim.login(user, token, errorInfo -> {
//             result(nil)
//         })
//     }
//
//     func logout(call: FlutterMethodCall, result: FlutterResult)  {
//
//     }
//
//     func createRoom(call: FlutterMethodCall, result: FlutterResult)  {
//         let params = call.arguments as? NSDictionary
//
//         if (params == nil) {
//             return
//         }
//         var roomID = params!["roomID"] as? String ?? ""
//         var roomName = params!["roomName"] as? String ?? ""
//
//         let roomInfo = ZIMRoomInfo(roomID, roomName)
//         let config = ZIMRoomAdvancedConfig()
//         config.roomAttributes = {"room_Info": {"room_id": roomID, "room_name": roomName}}
//         zim.createRoom(zimRoomInfo, config, (roomInfo, errorInfo) -> {
//             result(roomInfo)
//         });
//     }
//
//     func joinRoom(call: FlutterMethodCall, result: FlutterResult)  {
//         let params = call.arguments as? NSDictionary
//         if (params == nil) {
//             return
//         }
//         var roomID = params!["roomID"] as? String ?? ""
//         zim.joinRoom(roomID, (roomInfo, errorInfo) -> {
//             result(roomInfo)
//         });
//     }
//
//     func leaveRoom(call: FlutterMethodCall, result: FlutterResult)  {
//         let params = call.arguments as? NSDictionary
//                 if (params == nil) {
//                     return
//                 }
//         var roomID = params!["roomID"] as? String ?? ""
//         zim.leaveRoom(roomID, (roomInfo, errorInfo) -> {
//             result(roomInfo)
//         });
//     }
//
//     func uploadLog(call: FlutterMethodCall, result: FlutterResult)  {
//         zim.uploadLog(errorInfo -> callback.roomCallback(errorInfo.code.value()))
//     }
//
//     func queryRoomAllAttributes(call: FlutterMethodCall, result: FlutterResult)  {
//         let params = call.arguments as? NSDictionary
//         if (params == nil) { return }
//         var roomID = params!["roomID"] as? String ?? ""
//         zim.queryRoomAllAttributes(roomID, (roomInfo, errorInfo) -> {
//             result(roomInfo)
//         });
//     }
//
//     func queryRoomOnlineMemberCount(call: FlutterMethodCall, result: FlutterResult)  {
//         let params = call.arguments as? NSDictionary
//                 if (params == nil) { return }
//         var roomID = params!["roomID"] as? String ?? ""
//         zim.queryRoomOnlineMemberCount(roomID, (count, errorInfo) -> {
//             result(count)
//         });
//     }
//
//     func sendPeerMessage(call: FlutterMethodCall, result: FlutterResult)  {
//         let params = call.arguments as? NSDictionary
//                 if (params == nil) { return }
//         var userID = params!["userID"] as? String ?? ""
//         var json = params!["json"] as? Dictionary ?? ""
//         var actionType = params!["actionType"] as? Int ?? 0
//         let command = ZegoCustomCommand()
//         command.actionType = actionType
//         command.userID = userID
//         commmand.content = json.getBytes(StandardCharsets.UTF_8)
//         zim.sendPeerMessage(command, userID, (message, errorInfo) -> {
//             result(errorInfo)
//         });
//     }
//
//     func sendRoomMessage(call: FlutterMethodCall, result: FlutterResult)  {
//         let params = call.arguments as? NSDictionary
//                 if (params == nil) { return }
//         var roomID = params!["roomID"] as? String ?? ""
//         var textMessage = params!["text"] as? String ?? ""
//         zim.sendRoomMessage(textMessage, roomID, (message, errorInfo) -> {
//         });
//     }
//
//     func setRoomAttributes(call: FlutterMethodCall, result: FlutterResult)  {
//         let params = call.arguments as? NSDictionary
//                 if (params == nil) { return }
//         var roomID = params!["roomID"] as? String ?? ""
//         var attributes = params!["attributes"] as? String ?? ""
//         var isDeleteAfterOwnerLeft = params!["delete"] as? BOOL ?? false
//
//         let config = ZIMRoomAttributesSetConfig()
//         config.isForce = true
//         config.isDeleteAfterOwnerLeft = isDeleteAfterOwnerLeft
//         zim.setRoomAttributes(attributes, roomID, config, errorInfo -> {
//             result(errorInfo)
//         }
//     }


}

// extension ZIMPlugin: FlutterStreamHandler {
//
//     func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
// //        let key = call.method ?? ""
// //        if key == "createZIM" {
// //            let appID = call.arguments as Int32
// //            createZIM(appID)
// //        }
//     }
//
//
// }

