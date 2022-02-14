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
import org.json.JSONArray
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
        var token: String? = call.argument<String>("token")
        if (token?.length == 0) {
            token = TokenServerAssistant
                .generateToken(appID.toLong(), userID, serverSecret, 60 * 60 * 24).data
        }
        var user = ZIMUserInfo()
        user.userID = userID
        user.userName = userName
        zim?.login(user, token, ZIMLoggedInCallback {
            result.success(mapOf("errorCode" to it.code.value(), "message" to it.message))
        })
    }

    fun logout(call: MethodCall, result: MethodChannel.Result) {
        zim?.logout()
        result.success(mapOf("errorCode" to 0))
    }

    fun createRoom(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        val roomName: String? = call.argument<String>("roomName")
        val hostID: String? = call.argument<String>("hostID")
        val seatNum: Int? = call.argument<Int>("seatNum")

        val roomInfo = ZIMRoomInfo()
        roomInfo.roomID = roomID
        roomInfo.roomName = roomName
        val config = ZIMRoomAdvancedConfig()

        val json = JSONObject()
        json.put("id", roomID)
        json.put("name", roomName)
        json.put("host_id", hostID)
        json.put("num", seatNum)
        json.put("disable", false)
        json.put("close", false)
        val jsonString = json.toString()

        config.roomAttributes = hashMapOf("room_info" to jsonString)
        zim?.createRoom(roomInfo, config) { roomInfo, errorInfo ->
            result.success(mapOf("errorCode" to errorInfo.code.value(), "message" to errorInfo.message))
        }
    }

    fun joinRoom(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.joinRoom(roomID) { roomInfo, errorInfo ->
            val roomInfoMap = mapOf("id" to roomInfo.baseInfo.roomID, "name" to roomInfo.baseInfo.roomName)
            result.success(mapOf("errorCode" to errorInfo.code.value(), "message" to errorInfo.message, "roomInfo" to roomInfoMap))
        }
    }

    fun leaveRoom(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.leaveRoom(roomID) { errorInfo ->
            result.success(mapOf("errorCode" to errorInfo.code.value(), "message" to errorInfo.message))
        }

    }

    fun uploadLog(call: MethodCall, result: MethodChannel.Result) {
        zim?.uploadLog(ZIMLogUploadedCallback {
            result.success(mapOf("errorCode" to it.code.value(), "message" to it.message))
        })
    }

    fun queryRoomAllAttributes(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.queryRoomAllAttributes(roomID
        ) { roomAttributes, errorInfo ->
            result.success(mapOf("errorCode" to errorInfo.code.value(), "message" to errorInfo.message, "roomAttributes" to roomAttributes))
        }
    }

    fun queryRoomOnlineMemberCount(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        zim?.queryRoomOnlineMemberCount(roomID
        ) { count, errorInfo ->
            result.success(mapOf("errorCode" to errorInfo.code.value(), "message" to errorInfo.message, "count" to count))
        }
    }

    fun sendPeerMessage(call: MethodCall, result: MethodChannel.Result) {
        val userID: String? = call.argument<String>("userID")
        val content: String? = call.argument<String>("content")
        val actionType: Int? = call.argument<Int>("actionType")

        var userJsonArray = JSONArray()
        userJsonArray.put(userID)
        val json = JSONObject()
        json.put("target", userJsonArray)
        json.put("content", content)
        json.put("actionType", actionType)

        val jsonString = json.toString()

        val customMessage = ZIMCustomMessage()
        customMessage.message = jsonString.encodeToByteArray()
        zim?.sendPeerMessage(customMessage, userID
        ) { message, errorInfo ->
            result.success(mapOf("errorCode" to errorInfo.code.value(), "message" to errorInfo.message))
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
            result.success(mapOf("errorCode" to errorInfo.code.value(), "message" to errorInfo.message))
        }
    }

    fun setRoomAttributes(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        val attributes: String? = call.argument<String>("attributes")
        val isDeleteAfterOwnerLeft: Boolean? = call.argument<Boolean>("delete")

        val json = JSONObject(attributes)
        val map = HashMap<String, String>()

        json.keys().forEach {
            map[it] = json.getString(it)
        }

        val config = ZIMRoomAttributesSetConfig()
        config.isForce = true
        config.isDeleteAfterOwnerLeft = isDeleteAfterOwnerLeft == true

        zim?.setRoomAttributes(map, roomID, config, object : ZIMRoomAttributesBatchOperatedCallback,
            ZIMRoomAttributesOperatedCallback {
            override fun onRoomAttributesBatchOperated(errorInfo: ZIMError?) {
                result.success(mapOf("errorCode" to (errorInfo?.code?.value() ?: 0), "message" to errorInfo?.message))
            }

            override fun onRoomAttributesOperated(errorInfo: ZIMError?) {
                result.success(mapOf("errorCode" to (errorInfo?.code?.value() ?: 0), "message" to errorInfo?.message))
            }

        })
    }

    fun getSDKToken(call: MethodCall, result: MethodChannel.Result) {
        val roomID: String? = call.argument<String>("roomID")
        val userID: String? = call.argument<String>("userID")

        val token = TokenServerAssistant
            .generateToken(appID.toLong(), userID, serverSecret, 60 * 60 * 24).data
        result.success(mapOf("errorCode" to 0, "token" to token))
    }

    fun getZIMVersion(call: MethodCall, result: MethodChannel.Result) {
        val version = ZIM.getVersion()
        result.success(mapOf("errorCode" to 0, "version" to version))
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
            eventSink.success(mapOf("method" to "connectionStateChanged", "state" to (state?.value()
                ?: 0), "event" to (event?.value() ?: 0)
            ))
        }

        override fun onError(zim: ZIM?, errorInfo: ZIMError?) {
            super.onError(zim, errorInfo)
            eventSink.success(mapOf("method" to "onError", "code" to (errorInfo?.code ?: 0), "message" to errorInfo?.message))
        }

        override fun onReceivePeerMessage(
            zim: ZIM?,
            messageList: ArrayList<ZIMMessage>?,
            fromUserID: String?
        ) {
            super.onReceivePeerMessage(zim, messageList, fromUserID)
            var customMessageJson = JSONArray()
            var textMessageJson = JSONArray()
            messageList?.forEach {
                var json = JSONObject()
                if (it.type == ZIMMessageType.CUSTOM) {
                    var customMessage = it as ZIMCustomMessage
                    json.put("messageID", customMessage.messageID)
                    json.put("userID", customMessage.userID)
                    json.put("message", String(customMessage.message))
                    json.put("type", customMessage.type.value())
                    customMessageJson.put(json)
                } else {
                    var textMessage = it as ZIMTextMessage
                    json.put("messageID", textMessage.messageID)
                    json.put("userID", textMessage.userID)
                    json.put("message", textMessage.message)
                    json.put("type", textMessage.type.value())
                    textMessageJson.put(json)
                }
            }
            if (customMessageJson.length() > 0) {
                eventSink.success(mapOf("method" to "receiveCustomPeerMessage", "messageList" to customMessageJson.toString()))
            } else {
                eventSink.success(mapOf("method" to "receiveTextPeerMessage", "messageList" to textMessageJson.toString()))
            }
        }

        override fun onReceiveRoomMessage(
            zim: ZIM?,
            messageList: ArrayList<ZIMMessage>?,
            fromRoomID: String?
        ) {
            super.onReceiveRoomMessage(zim, messageList, fromRoomID)
            var customMessageJson = JSONArray()
            var textMessageJson = JSONArray()
            messageList?.forEach {
                var json = JSONObject()
                if (it.type == ZIMMessageType.CUSTOM) {
                    var customMessage = it as ZIMCustomMessage
                    json.put("messageID", customMessage.messageID)
                    json.put("userID", customMessage.userID)
                    json.put("message", String(customMessage.message))
                    json.put("type", customMessage.type.value())
                    json.put("timestamp", customMessage.timestamp)
                    customMessageJson.put(json)
                } else {
                    var textMessage = it as ZIMTextMessage
                    json.put("messageID", textMessage.messageID)
                    json.put("userID", textMessage.userID)
                    json.put("message", textMessage.message)
                    json.put("type", textMessage.type.value())
                    json.put("timestamp", textMessage.timestamp)
                    textMessageJson.put(json)
                }
            }
            if (customMessageJson.length() > 0) {
                eventSink.success(mapOf("method" to "receiveCustomRoomMessage", "messageList" to customMessageJson.toString(), "roomID" to fromRoomID))
            } else {
                eventSink.success(mapOf("method" to "receiveTextRoomMessage", "messageList" to textMessageJson.toString(), "roomID" to fromRoomID))
            }
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
            var json = JSONObject()
            info?.roomAttributes?.forEach { (t, u) ->
                json.put(t, u)
            }
            eventSink.success(mapOf("method" to "roomAttributesUpdated", "updateInfo" to json.toString(), "roomID" to roomID))
        }

        override fun onRoomMemberJoined(
            zim: ZIM?,
            memberList: ArrayList<ZIMUserInfo>?,
            roomID: String?
        ) {
            super.onRoomMemberJoined(zim, memberList, roomID)
            var array  = memberList?.map {
                mapOf("userID" to it.userID, "userName" to it.userName)
            }
            eventSink.success(mapOf("method" to "roomMemberJoined", "memberList" to array, "roomID" to roomID))
        }

        override fun onRoomMemberLeft(
            zim: ZIM?,
            memberList: ArrayList<ZIMUserInfo>?,
            roomID: String?
        ) {
            super.onRoomMemberLeft(zim, memberList, roomID)
            var array  = memberList?.map {
                mapOf("userID" to it.userID, "userName" to it.userName)
            }
            eventSink.success(mapOf("method" to "roomMemberLeave", "memberList" to array, "roomID" to roomID))
        }

        override fun onRoomStateChanged(
            zim: ZIM?,
            state: ZIMRoomState?,
            event: ZIMRoomEvent?,
            extendedData: JSONObject?,
            roomID: String?
        ) {
            super.onRoomStateChanged(zim, state, event, extendedData, roomID)
            eventSink.success(mapOf("method" to "roomStateChanged", "state" to (state?.value() ?: 0), "event" to (event?.value()
                ?: 0)))
        }

        override fun onTokenWillExpire(zim: ZIM?, second: Int) {
            super.onTokenWillExpire(zim, second)
            eventSink.success(mapOf("method" to "tokenWillExpire", "second" to second, ))
        }
    }

    private fun setZIMHandler(){
        zim?.setEventHandler(handler)
    }
}