package im.zego.liveaudioroom.live_audio_room_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import im.zego.zim.ZIM
import im.zego.zim.callback.*
import im.zego.zim.entity.*
import im.zego.zim.enums.ZIMErrorCode
import io.flutter.plugin.common.MethodCall
import org.json.JSONObject

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val channel = MethodChannel(messenger, "ZIMPlugin")
        channel.setMethodCallHandler { call, result ->
            when(call.method) {
                "createZIM" -> { createZIM(call, result) }
                "destoryZIM" -> { destoryZIM(call, result) }
                "login" -> { login(call, result) }
                "logout" -> { logout(call, result) }
                "createRoom" -> { createRoom(call, result) }
                "joinRoom" -> { joinRoom(call, result) }
                "leaveRoom" -> { leaveRoom(call, result) }
                "uploadLog" -> { uploadLog(call, result) }
                "queryRoomAllAttributes" -> { queryRoomAllAttributes(call, result) }
                "queryRoomOnlineMemberCount" -> { queryRoomOnlineMemberCount(call, result) }
                "sendPeerMessage" -> { sendPeerMessage(call, result) }
                "sendRoomMessage" -> { sendRoomMessage(call, result) }
                "setRoomAttributes" -> { setRoomAttributes(call, result) }
                else -> { result.error("error_code", "error_message", null) }
            }
        }
    }

    private var zim: ZIM? = null
    private fun createZIM(call: MethodCall, result: MethodChannel.Result) {
        val appID: Int? = call.argument<Int>("appID")
        zim = ZIM.create(appID?.toLong()!!, application)
        result.success(null)
    }

    private fun destoryZIM(call: MethodCall, result: MethodChannel.Result) {
        zim?.destroy()
        zim = null
        result.success(null)
    }

    private fun login(call: MethodCall, result: MethodChannel.Result) {
        val userID: String? = call.argument<String>("userID")
        val userName: String? = call.argument<String>("userName")
        val token: String? = call.argument<String>("token")

        var user = ZIMUserInfo()
        user.userID = userID
        user.userName = userName
        zim?.login(user, token, ZIMLoggedInCallback {
            if (it.code.value() == ZIMErrorCode.SUCCESS.value()) {
                result.success(null)
            } else {
                result.error(it.code.toString(), it.message, null)
            }
        })
    }

    private fun logout(call: MethodCall, result: MethodChannel.Result) {
        zim?.logout()
    }

    private fun createRoom(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        val roomName: String? = call.argument<String>("roomName")

        val roomInfo = ZIMRoomInfo()
        roomInfo.roomID = roomID
        roomInfo.roomName = roomName
        val config = ZIMRoomAdvancedConfig()

        val json = JSONObject()
        json.put("room_id", roomID)
        json.put("room_name", roomName)
        val jsonString = json.toString()


        config.roomAttributes = hashMapOf("room_info" to jsonString)
        zim?.createRoom(roomInfo, config) { roomInfo, errorInfo ->
            if (errorInfo?.code?.value() == ZIMErrorCode.SUCCESS.value()) {
                result.success(null)
            } else {
                result.error(errorInfo?.code.toString(), errorInfo?.message, null)
            }
        }
    }

    private fun joinRoom(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.joinRoom(roomID) { roomInfo, errorInfo ->
            if (errorInfo?.code?.value() == ZIMErrorCode.SUCCESS.value()) {
                result.success(null)
            } else {
                result.error(errorInfo?.code.toString(), errorInfo?.message, null)
            }
        }
    }

    private fun leaveRoom(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.leaveRoom(roomID) { errorInfo ->
            if (errorInfo?.code?.value() == ZIMErrorCode.SUCCESS.value()) {
                result.success(null)
            } else {
                result.error(errorInfo?.code.toString(), errorInfo?.message, null)
            }
        }

    }

    private fun uploadLog(call: MethodCall, result: MethodChannel.Result) {
        zim?.uploadLog(ZIMLogUploadedCallback {
            if (it.code.value() == ZIMErrorCode.SUCCESS.value()) {
                result.success(null)
            } else {
                result.error(it.code.toString(), it.message, null)
            }
        })
    }

    private fun queryRoomAllAttributes(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.queryRoomAllAttributes(roomID
        ) { roomAttributes, errorInfo ->
            if (errorInfo?.code?.value() == ZIMErrorCode.SUCCESS.value()) {
                result.success(null)
            } else {
                result.error(errorInfo?.code.toString(), errorInfo?.message, null)
            }
        }
    }

    private fun queryRoomOnlineMemberCount(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.queryRoomOnlineMemberCount(roomID
        ) { count, errorInfo ->
            if (errorInfo?.code?.value() == ZIMErrorCode.SUCCESS.value()) {
                result.success(null)
            } else {
                result.error(errorInfo?.code.toString(), errorInfo?.message, null)
            }
        }
    }

    private fun sendPeerMessage(call: MethodCall, result: MethodChannel.Result) {
        val userID: String? = call.argument<String>("userID")
        val content: String? = call.argument<String>("content")
        val actionType: Int? = call.argument<Int>("actionType")

        val json = JSONObject()
        json.put("user_id", userID)
        json.put("content", content)
        json.put("action_type", actionType)

        val jsonString = json.toString()

        val customMessage = ZIMCustomMessage()
        customMessage.message = jsonString.encodeToByteArray()
        zim?.sendPeerMessage(customMessage, userID
        ) { message, errorInfo ->
            if (errorInfo?.code?.value() == ZIMErrorCode.SUCCESS.value()) {
                result.success(null)
            } else {
                result.error(errorInfo?.code.toString(), errorInfo?.message, null)
            }
        }
    }

    private fun sendRoomMessage(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        val textMessage: String? = call.argument<String>("textMessage")

        val message = ZIMTextMessage()
        message.message = textMessage
        zim?.sendRoomMessage(message, roomID
        ) { message, errorInfo ->
            if (errorInfo?.code?.value() == ZIMErrorCode.SUCCESS.value()) {
                result.success(null)
            } else {
                result.error(errorInfo?.code.toString(), errorInfo?.message, null)
            }
        }
    }

    private fun setRoomAttributes(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        val attributes: String? = call.argument<String>("attributes")
        val isDeleteAfterOwnerLeft: Boolean? = call.argument<Boolean>("isDeleteAfterOwnerLeft")

        val json = JSONObject(attributes)
        val map = HashMap<String, String>()

        json.keys().forEach {
            map[it] = json.getString(it)
        }

        val config = ZIMRoomAttributesSetConfig()
        config.isForce = true
        config.isDeleteAfterOwnerLeft = isDeleteAfterOwnerLeft!!

        zim?.setRoomAttributes(map, roomID, config, object :ZIMRoomAttributesBatchOperatedCallback,
            ZIMRoomAttributesOperatedCallback {
            override fun onRoomAttributesBatchOperated(errorInfo: ZIMError?) {
                if (errorInfo?.code?.value() == ZIMErrorCode.SUCCESS.value()) {
                    result.success(null)
                } else {
                    result.error(errorInfo?.code.toString(), errorInfo?.message, null)
                }
            }

            override fun onRoomAttributesOperated(errorInfo: ZIMError?) {
                if (errorInfo?.code?.value() == ZIMErrorCode.SUCCESS.value()) {
                    result.success(null)
                } else {
                    result.error(errorInfo?.code.toString(), errorInfo?.message, null)
                }
            }

        })
    }


}
