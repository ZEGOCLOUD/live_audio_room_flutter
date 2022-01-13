package im.zego.liveaudioroom.live_audio_room_flutter

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.os.Bundle
import im.zego.zim.ZIM
import im.zego.zim.entity.ZIMRoomInfo
import im.zego.zim.entity.ZIMRoomAdvancedConfig


class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        GeneratedPluginRegistrant.registerWith(this)
        print("=======configureFlutterEngine")
//        MethodChannel(flutterView, CHANNEL).setMethodCallHandler {
//                call, result ->
//            // Note: this method is invoked on the main thread.
//            // TODO
//            print("=======configureFlutterEngine")
//        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        print("=======configureFlutterEngine")
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // 新建一个 Channel 对象
        val channel = MethodChannel(messenger, "ZIMPlugin")

        // 为 channel 设置回调
        channel.setMethodCallHandler { call, res ->
            // 根据方法名，分发不同的处理
            when(call.method) {

                "createZIM" -> {
                    // 获取传入的参数
                    val pid = call.argument<String>("pid")
//                    Log.i("ZHP", "正在执行原生方法，传入的参数是：「$pid」")
                    // 通知执行成功
                    print("正在执行原生方法")
                    res.success("这是执行的结果")
//                    ZIM.create(pid ?? "")
                } else -> {
                    // 如果有未识别的方法名，通知执行失败
//                    res.error("error_code", "error_message", null)
                }
            }
        }
    }

    private val zim: ZIM?
    fun createZIM(call: MethodCall, result: Result) {
        let params = call.arguments as? NSDictionary
        var pid = ""
        if (params != nil) {
            pid = params!["pid"] as? String ?? ""
        }
        zim = ZIM.create(pid)
        print("createZIM：" + pid)
        result(nil)
    }

    fun destoryZIM(call: MethodCall, result: Result) {
        zim.destroy()
        zim = nil
        print("destoryZIM")
        result(nil)
    }

    fun login(call: MethodCall, result: Result) {
        let params = call.arguments as? NSDictionary
        if (params == nil) { return }
        var userID = params!["userID"] as? String ?? ""
        var userName = params!["userName"] as? String ?? ""
        var token = params!["token"] as? String ?? ""
        let user = ZIMUserInfo()
        user.userID = userID
        user.userName = userName
        zim.login(user, token, errorInfo -> {
            result(nil)
        })
    }

    fun logout(call: MethodCall, result: Result) {
        zim.logout()
    }

    fun createRoom(call: MethodCall, result: Result) {
        let params = call.arguments as? NSDictionary

        if (params == nil) {
            return
        }
        var roomID = params!["roomID"] as? String ?? ""
        var roomName = params!["roomName"] as? String ?? ""

        let roomInfo = ZIMRoomInfo(roomID, roomName)
        let config = ZIMRoomAdvancedConfig()
        config.roomAttributes = {"room_Info": {"room_id": roomID, "room_name": roomName}}
        zim.createRoom(zimRoomInfo, config, (roomInfo, errorInfo) -> {
            result(roomInfo)
        });
    }

    fun joinRoom(call: MethodCall, result: Result) {
        let params = call.arguments as? NSDictionary
        if (params == nil) {
            return
        }
        var roomID = params!["roomID"] as? String ?? ""
        zim.joinRoom(roomID, (roomInfo, errorInfo) -> {
            result(roomInfo)
        });
    }

    fun leaveRoom(call: MethodCall, result: Result) {
        let params = call.arguments as? NSDictionary
                if (params == nil) {
                    return
                }
        var roomID = params!["roomID"] as? String ?? ""
        zim.leaveRoom(roomID, (roomInfo, errorInfo) -> {
            result(roomInfo)
        });
    }

    fun uploadLog(call: MethodCall, result: Result) {
        zim.uploadLog(errorInfo -> callback.roomCallback(errorInfo.code.value()))
    }

    fun queryRoomAllAttributes(call: MethodCall, result: Result) {
        let params = call.arguments as? NSDictionary
        if (params == nil) { return }
        var roomID = params!["roomID"] as? String ?? ""
        zim.queryRoomAllAttributes(roomID, (roomInfo, errorInfo) -> {
            result(roomInfo)
        });
    }

    fun queryRoomOnlineMemberCount(call: MethodCall, result: Result) {
        let params = call.arguments as? NSDictionary
                if (params == nil) { return }
        var roomID = params!["roomID"] as? String ?? ""
        zim.queryRoomOnlineMemberCount(roomID, (count, errorInfo) -> {
            result(count)
        });
    }

    fun sendPeerMessage(call: MethodCall, result: Result) {
        let params = call.arguments as? NSDictionary
                if (params == nil) { return }
        var userID = params!["userID"] as? String ?? ""
        var json = params!["json"] as? Dictionary ?? ""
        var actionType = params!["actionType"] as? Int ?? 0
        let command = ZegoCustomCommand()
        command.actionType = actionType
        command.userID = userID
        commmand.content = json.getBytes(StandardCharsets.UTF_8)
        zim.sendPeerMessage(command, userID, (message, errorInfo) -> {
            result(errorInfo)
        });
    }

    fun sendRoomMessage(call: MethodCall, result: Result) {
        let params = call.arguments as? NSDictionary
                if (params == nil) { return }
        var roomID = params!["roomID"] as? String ?? ""
        var textMessage = params!["text"] as? String ?? ""
        zim.sendRoomMessage(textMessage, roomID, (message, errorInfo) -> {
        });
    }

    fun setRoomAttributes(call: MethodCall, result: Result) {
        let params = call.arguments as? NSDictionary
                if (params == nil) { return }
        var roomID = params!["roomID"] as? String ?? ""
        var attributes = params!["attributes"] as? String ?? ""
        var isDeleteAfterOwnerLeft = params!["delete"] as? BOOL ?? false

        let config = ZIMRoomAttributesSetConfig()
        config.isForce = true
        config.isDeleteAfterOwnerLeft = isDeleteAfterOwnerLeft
        zim.setRoomAttributes(attributes, roomID, config, errorInfo -> {
            result(errorInfo)
        }
    }


}
