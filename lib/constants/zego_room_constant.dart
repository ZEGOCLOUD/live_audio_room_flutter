/// Connection state.
/// Description: The state machine that identifies the current connection state.
/// Use cases: It can be used to judge whether the user enters/exit the room successfully, and handles abnormal situations such as network disconnection.
/// Caution: Please use it with the connection event parameter.
enum ZimRoomState {
  /// Description: Disconnected state.
  /// Use cases: enter this state before entering the room and after exiting the room.
  zimRoomStateDisconnected,

  /// Description: The connection state is being requested.
  /// Use cases: and it will enter this state after the action of entering the room is executed successfully. The application interface is usually displayed through this state.
  zimRoomStateConnecting,

  /// Description: The connection is successful.
  /// Use cases: Entering this state means that the room has been successfully reentered after network broken.
  zimRoomStateConnected,
}

extension ZimRoomStateExtension on ZimRoomState {
  static const valueMap = {
    ZimRoomState.zimRoomStateDisconnected: 0,
    ZimRoomState.zimRoomStateConnecting: 1,
    ZimRoomState.zimRoomStateConnected: 2,
  };
  static const mapValue = {
    0: ZimRoomState.zimRoomStateDisconnected,
    1: ZimRoomState.zimRoomStateConnecting,
    2: ZimRoomState.zimRoomStateConnected,
  };

  int get value => valueMap[this] ?? -1;
}

/// The event that caused the room connection status to change.
/// Description: The reason for the change of the connection state.
/// Use cases: It can be used to determine whether the login/logout is successful, and to handle abnormal situations such as network disconnection.
/// Caution: Please use it with the connection state parameter.
enum zimRoomEvent {
  /// Description: Success.
  zimRoomEventSuccess,

  /// Description: The network in the room is temporarily interrupted.
  zimRoomEventNetworkInterrupted,

  /// Description: The network in the room is disconnected.
  zimRoomEventNetworkDisconnected,

  /// Description: The room not exist.
  zimRoomEventRoomNotExist,

  /// Description: The user actively creates a room.
  zimRoomEventActiveCreate,

  /// Description: Failed to create room.
  zimRoomEventCreateFailed,

  /// Description: The user starts to enter the room.
  zimRoomEventActiveEnter,

  /// Description: user failed to enter the room.
  zimRoomEventEnterFailed,

  /// Description: user was kicked out of the room.
  zimRoomEventKickedOut
}

extension ZIMRoomEventExtension on zimRoomEvent {
  static const valueMap = {
    zimRoomEvent.zimRoomEventSuccess: 0,
    zimRoomEvent.zimRoomEventNetworkInterrupted: 1,
    zimRoomEvent.zimRoomEventNetworkDisconnected: 2,
    zimRoomEvent.zimRoomEventRoomNotExist: 3,
    zimRoomEvent.zimRoomEventActiveCreate: 4,
    zimRoomEvent.zimRoomEventCreateFailed: 5,
    zimRoomEvent.zimRoomEventActiveEnter: 6,
    zimRoomEvent.zimRoomEventEnterFailed: 7,
    zimRoomEvent.zimRoomEventKickedOut: 8,
  };
  static const mapValue = {
    0: zimRoomEvent.zimRoomEventSuccess,
    1: zimRoomEvent.zimRoomEventNetworkInterrupted,
    2: zimRoomEvent.zimRoomEventNetworkDisconnected,
    3: zimRoomEvent.zimRoomEventRoomNotExist,
    4: zimRoomEvent.zimRoomEventActiveCreate,
    5: zimRoomEvent.zimRoomEventCreateFailed,
    6: zimRoomEvent.zimRoomEventActiveEnter,
    7: zimRoomEvent.zimRoomEventEnterFailed,
    8: zimRoomEvent.zimRoomEventKickedOut,
  };

  int get value => valueMap[this] ?? -1;
}

enum ZegoSpeakerSeatStatus { unTaken, occupied, closed }

enum ZegoNetworkQuality {
  goodQuality,
  mediumQuality,
  badQuality,
  unknownQuality
}
