package im.zego.liveaudioroom.live_audio_room_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val pluginHandler = ZIMPlugin()

        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val channel = MethodChannel(messenger, "ZIMPlugin")

        channel.setMethodCallHandler { call, result ->
            when(call.method) {
                "createZIM" -> { pluginHandler.createZIM(call, result, application) }
                "destroyZIM" -> { pluginHandler.destroyZIM(call, result) }
                "login" -> { pluginHandler.login(call, result) }
                "logout" -> { pluginHandler.logout(call, result) }
                "createRoom" -> { pluginHandler.createRoom(call, result) }
                "joinRoom" -> { pluginHandler.joinRoom(call, result) }
                "leaveRoom" -> { pluginHandler.leaveRoom(call, result) }
                "uploadLog" -> { pluginHandler.uploadLog(call, result) }
                "renewToken" -> { pluginHandler.renewToken(call, result) }
                "queryRoomAllAttributes" -> { pluginHandler.queryRoomAllAttributes(call, result) }
                "queryRoomOnlineMemberCount" -> { pluginHandler.queryRoomOnlineMemberCount(call, result) }
                "sendPeerMessage" -> { pluginHandler.sendPeerMessage(call, result) }
                "sendRoomMessage" -> { pluginHandler.sendRoomMessage(call, result) }
                "setRoomAttributes" -> { pluginHandler.setRoomAttributes(call, result) }
                "getToken" -> { pluginHandler.getToken(call, result) }
                "getZIMVersion" -> { pluginHandler.getZIMVersion(call, result)}
                else -> { result.error("error_code", "error_message", null) }
            }
        }

        EventChannel(flutterEngine.dartExecutor, "ZIMPluginEventChannel").setStreamHandler(pluginHandler)

    }
}

