package im.zego.liveaudioroom.live_audio_room_flutter

import android.app.Application
import im.zego.liveaudioroom.util.TokenServerAssistant
import im.zego.zim.ZIM
import im.zego.zim.callback.ZIMEventHandler
import im.zego.zim.callback.ZIMLogUploadedCallback
import im.zego.zim.callback.ZIMLoggedInCallback
import im.zego.zim.callback.ZIMRoomAttributesBatchOperatedCallback
import im.zego.zim.callback.ZIMRoomAttributesOperatedCallback
import im.zego.zim.entity.*
import im.zego.zim.enums.*
import io.flutter.app.FlutterActivityEvents
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.ArrayList

class ZIMPlugin: EventChannel.StreamHandler {

    private var zim: ZIM? = null
    private var appID: Int = 0
    private var appSign: String = ""
    private var serverSecret: String = ""

    fun createZIM(call: MethodCall, result: MethodChannel.Result , application: Application) {
        if (zim != null) {
            result.error("-1", "", null)
            return
        }
        appID = call.argument<Int>("appID")!!
        appSign = call.argument<String>("appSign").toString()
        serverSecret = call.argument<String>("serverSecret").toString()
        zim = ZIM.create(appID?.toLong()!!, application)
//        zim.setEventHandler(handler)
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
        var token: String? = call.argument<String>("token")
        if (token?.length == 0) {
            token = TokenServerAssistant
                .generateToken(appID.toLong(), userID, serverSecret, 60 * 60 * 24).data
        }
        var user = ZIMUserInfo()
        user.userID = userID
        user.userName = userName
        zim?.login(user, token, ZIMLoggedInCallback {
            result.success(mapOf("errorCode" to it.code.value()))
        })
    }

    fun logout(call: MethodCall, result: MethodChannel.Result) {
        zim?.logout()
        result.success(null)
    }

    fun createRoom(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        val roomName: String? = call.argument<String>("roomName")
        val hostID: String? = call.argument<String>("hostID")
        val seatNum: String? = call.argument<String>("seatNum")

        val roomInfo = ZIMRoomInfo()
        roomInfo.roomID = roomID
        roomInfo.roomName = roomName
        val config = ZIMRoomAdvancedConfig()

        val json = JSONObject()
        json.put("room_id", roomID)
        json.put("room_name", roomName)
        json.put("host_id", hostID)
        json.put("num", seatNum)
        val jsonString = json.toString()

        config.roomAttributes = hashMapOf("room_info" to jsonString)
        zim?.createRoom(roomInfo, config) { roomInfo, errorInfo ->
            result.success(mapOf("errorCode" to errorInfo.code.value()))
        }
    }

    fun joinRoom(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.joinRoom(roomID) { roomInfo, errorInfo ->
            val roomInfoMap = mapOf("id" to roomInfo.baseInfo.roomID, "name" to roomInfo.baseInfo.roomName)
            result.success(mapOf("errorCode" to errorInfo.code.value(), "roomInfo" to roomInfoMap))
        }
    }

    fun leaveRoom(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.leaveRoom(roomID) { errorInfo ->
            result.success(mapOf("errorCode" to errorInfo.code.value()))
        }

    }

    fun uploadLog(call: MethodCall, result: MethodChannel.Result) {
        zim?.uploadLog(ZIMLogUploadedCallback {
            result.success(mapOf("errorCode" to it.code.value()))
        })
    }

    fun queryRoomAllAttributes(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.queryRoomAllAttributes(roomID
        ) { roomAttributes, errorInfo ->
            result.success(mapOf("errorCode" to errorInfo.code.value(), "roomAttributes" to roomAttributes))
        }
    }

    fun queryRoomOnlineMemberCount(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.queryRoomOnlineMemberCount(roomID
        ) { count, errorInfo ->
            result.success(mapOf("errorCode" to errorInfo.code.value(), "count" to count))
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
            result.success(mapOf("errorCode" to errorInfo.code.value()))
        }
    }

    fun sendRoomMessage(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        val content: String? = call.argument<String>("content")
        val isCustomMessage: Boolean? = call.argument<Boolean>("isCustomMessage")

        var message = ZIMMessage()
        if (isCustomMessage == true) {
            message = ZIMCustomMessage()
            message.message = content?.encodeToByteArray()
        } else {
            message = ZIMTextMessage()
            message.message = content
        }
        zim?.sendRoomMessage(message, roomID
        ) { message, errorInfo ->
            result.success(mapOf("errorCode" to errorInfo.code.value()))
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
                result.success(mapOf("errorCode" to (errorInfo?.code?.value() ?: 0)))
            }

            override fun onRoomAttributesOperated(errorInfo: ZIMError?) {
                result.success(mapOf("errorCode" to (errorInfo?.code?.value() ?: 0)))
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
            eventSink.success(mapOf("method" to "onConnectionStateChanged", "state" to (state?.value()
                ?: 0), "event" to (event?.value() ?: 0)
            ))
        }

        override fun onError(zim: ZIM?, errorInfo: ZIMError?) {
            super.onError(zim, errorInfo)
            eventSink.success(mapOf("method" to "onError", "code" to (errorInfo?.code ?: 0)))
        }

        override fun onReceivePeerMessage(
            zim: ZIM?,
            messageList: ArrayList<ZIMMessage>?,
            fromUserID: String?
        ) {
            super.onReceivePeerMessage(zim, messageList, fromUserID)
//            eventSink.success(mapOf("method" to "onReceivePeerMessage", "code" to (errorInfo?.code ?: 0)))
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