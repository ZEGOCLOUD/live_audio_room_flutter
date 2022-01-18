package im.zego.liveaudioroom.live_audio_room_flutter

import android.app.Application
import im.zego.zim.ZIM
import im.zego.zim.callback.ZIMEventHandler
import im.zego.zim.callback.ZIMLogUploadedCallback
import im.zego.zim.callback.ZIMLoggedInCallback
import im.zego.zim.callback.ZIMRoomAttributesBatchOperatedCallback
import im.zego.zim.callback.ZIMRoomAttributesOperatedCallback
import im.zego.zim.entity.*
import im.zego.zim.enums.*
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.ArrayList

class ZIMPlugin: EventChannel.StreamHandler {

    private var zim: ZIM? = null
    fun createZIM(call: MethodCall, result: MethodChannel.Result , application: Application) {
        val appID: Int? = call.argument<Int>("appID")
        zim = ZIM.create(appID?.toLong()!!, application)
        setZIMHandler()
        result.success(null)
    }

    fun destroyZIM(call: MethodCall, result: MethodChannel.Result) {
        zim?.destroy()
        zim = null
        result.success(null)
    }

    fun login(call: MethodCall, result: MethodChannel.Result) {
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

    fun logout(call: MethodCall, result: MethodChannel.Result) {
        zim?.logout()
    }

    fun createRoom(call: MethodCall, result: MethodChannel.Result) {
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

    fun joinRoom(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.joinRoom(roomID) { roomInfo, errorInfo ->
            if (errorInfo?.code?.value() == ZIMErrorCode.SUCCESS.value()) {
                result.success(null)
            } else {
                result.error(errorInfo?.code.toString(), errorInfo?.message, null)
            }
        }
    }

    fun leaveRoom(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.leaveRoom(roomID) { errorInfo ->
            if (errorInfo?.code?.value() == ZIMErrorCode.SUCCESS.value()) {
                result.success(null)
            } else {
                result.error(errorInfo?.code.toString(), errorInfo?.message, null)
            }
        }

    }

    fun uploadLog(call: MethodCall, result: MethodChannel.Result) {
        zim?.uploadLog(ZIMLogUploadedCallback {
            if (it.code.value() == ZIMErrorCode.SUCCESS.value()) {
                result.success(null)
            } else {
                result.error(it.code.toString(), it.message, null)
            }
        })
    }

    fun queryRoomAllAttributes(call: MethodCall, result: MethodChannel.Result) {
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

    fun queryRoomOnlineMemberCount(call: MethodCall, result: MethodChannel.Result) {
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

    fun sendPeerMessage(call: MethodCall, result: MethodChannel.Result) {
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

    fun sendRoomMessage(call: MethodCall, result: MethodChannel.Result) {
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

    fun setRoomAttributes(call: MethodCall, result: MethodChannel.Result) {
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

        zim?.setRoomAttributes(map, roomID, config, object : ZIMRoomAttributesBatchOperatedCallback,
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

    private lateinit var eventSink: EventChannel.EventSink
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events != null) {
            eventSink = events
        }
    }

    override fun onCancel(arguments: Any?) {
    }

    val handler = object: ZIMEventHandler() {
        override fun onConnectionStateChanged(
            zim: ZIM?,
            state: ZIMConnectionState?,
            event: ZIMConnectionEvent?,
            extendedData: JSONObject?
        ) {
            super.onConnectionStateChanged(zim, state, event, extendedData)
            eventSink.success(arrayOf("onConnectionStateChanged", state, event))
        }

        override fun onError(zim: ZIM?, errorInfo: ZIMError?) {
            super.onError(zim, errorInfo)
            eventSink.success(arrayOf("onError", errorInfo))
        }

        override fun onReceivePeerMessage(
            zim: ZIM?,
            messageList: ArrayList<ZIMMessage>?,
            fromUserID: String?
        ) {
            super.onReceivePeerMessage(zim, messageList, fromUserID)
            eventSink.success(arrayOf("onReceivePeerMessage", messageList, fromUserID))
        }

        override fun onReceiveRoomMessage(
            zim: ZIM?,
            messageList: ArrayList<ZIMMessage>?,
            fromRoomID: String?
        ) {
            super.onReceiveRoomMessage(zim, messageList, fromRoomID)
            eventSink.success(arrayOf("onReceiveRoomMessage", messageList, fromRoomID))
        }

        override fun onRoomAttributesBatchUpdated(
            zim: ZIM?,
            infos: ArrayList<ZIMRoomAttributesUpdateInfo>?,
            roomID: String?
        ) {
            super.onRoomAttributesBatchUpdated(zim, infos, roomID)
            eventSink.success(arrayOf("onRoomAttributesBatchUpdated", infos, roomID))
        }

        override fun onRoomAttributesUpdated(
            zim: ZIM?,
            info: ZIMRoomAttributesUpdateInfo?,
            roomID: String?
        ) {
            super.onRoomAttributesUpdated(zim, info, roomID)
            eventSink.success(arrayOf("onRoomAttributesUpdated", info, roomID))
        }

        override fun onRoomMemberJoined(
            zim: ZIM?,
            memberList: ArrayList<ZIMUserInfo>?,
            roomID: String?
        ) {
            super.onRoomMemberJoined(zim, memberList, roomID)
            eventSink.success(arrayOf("onRoomMemberJoined", memberList, roomID))
        }

        override fun onRoomMemberLeft(
            zim: ZIM?,
            memberList: ArrayList<ZIMUserInfo>?,
            roomID: String?
        ) {
            super.onRoomMemberLeft(zim, memberList, roomID)
            eventSink.success(arrayOf("onRoomMemberLeft", memberList, roomID))
        }

        override fun onRoomStateChanged(
            zim: ZIM?,
            state: ZIMRoomState?,
            event: ZIMRoomEvent?,
            extendedData: JSONObject?,
            roomID: String?
        ) {
            super.onRoomStateChanged(zim, state, event, extendedData, roomID)
            eventSink.success(arrayOf("onRoomStateChanged", state, event, extendedData, roomID))
        }

        override fun onTokenWillExpire(zim: ZIM?, second: Int) {
            super.onTokenWillExpire(zim, second)
            eventSink.success(arrayOf("onTokenWillExpire", second))
        }
    }

    private fun setZIMHandler(){
        zim?.setEventHandler(handler)
    }
}