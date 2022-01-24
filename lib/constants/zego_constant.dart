/// Connection state.
/// Description: The state machine that identifies the current connection state.
/// Use cases: It can be used to determine whether the login/logout is successful, and to handle abnormal situations such as network disconnection.
/// Caution: Please use it with the connection event parameter.
enum zimConnectionState {
  /// Description: Unconnected state, enter this state before logging in and after logging out.
  /// Use cases: If there is a steady state abnormality in the process of logging in, such as AppID or Token are incorrect, or if the same user name is logged in elsewhere and the local end is kicked out, it will enter this state.
  zimConnectionStateDisconnected,

  /// Description: The state that the connection is being requested. It will enter this state after successful execution login function.
  /// Use cases: The display of the UI is usually performed using this state. If the connection is interrupted due to poor network quality, the SDK will perform an internal retry and will return to this state.
  zimConnectionStateConnecting,

  /// Description: The state that is successfully connected.
  /// Use cases: Entering this state indicates that login successfully and the user can use the SDK functions normally.
  zimConnectionStateConnected,

  ///  Description: The state that the reconnection is being requested. It will enter this state after successful execution login function.
  ///  Use cases: The display of the UI is usually performed using this state. If the connection is interrupted due to poor network quality, the SDK will perform an internal retry and will return to this state.
  zimConnectionStateReconnecting
}

extension zimConnectionStateExtension on zimConnectionState {
  static const valueMap = {
    zimConnectionState.zimConnectionStateDisconnected: 0,
    zimConnectionState.zimConnectionStateConnecting: 1,
    zimConnectionState.zimConnectionStateConnected: 2,
    zimConnectionState.zimConnectionStateReconnecting: 3,
  };
  static const mapValue = {
    0: zimConnectionState.zimConnectionStateDisconnected,
    1: zimConnectionState.zimConnectionStateConnecting,
    2: zimConnectionState.zimConnectionStateConnected,
    3: zimConnectionState.zimConnectionStateReconnecting,
  };

  int get value => valueMap[this] ?? -1;
}

/// The event that caused the connection status to change.
/// Description: The reason for the change of the connection state.
/// Use cases: It can be used to determine whether the login/logout is successful, and to handle abnormal situations such as network disconnection.
/// Caution: Please use it with the connection state parameter.
enum zimConnectionEvent {
  /// Description: Success.
  zimConnectionEventSuccess,

  /// Description: The user actively logs in.
  zimConnectionEventActiveLogin,

  /// Description: Connection timed out.
  zimConnectionEventLoginTimeout,

  /// Description: The network connection is temporarily interrupted.
  zimConnectionEventLoginInterrupted,

  /// Description: Being kicked out.
  zimConnectionEventKickedOut,
}

extension zimConnectionEventExtension on zimConnectionEvent {
  static const valueMap = {
    zimConnectionEvent.zimConnectionEventSuccess: 0,
    zimConnectionEvent.zimConnectionEventActiveLogin: 1,
    zimConnectionEvent.zimConnectionEventLoginTimeout: 2,
    zimConnectionEvent.zimConnectionEventLoginInterrupted: 3,
    zimConnectionEvent.zimConnectionEventKickedOut: 4,
  };
  static const mapValue = {
    0: zimConnectionEvent.zimConnectionEventSuccess,
    1: zimConnectionEvent.zimConnectionEventActiveLogin,
    2: zimConnectionEvent.zimConnectionEventLoginTimeout,
    3: zimConnectionEvent.zimConnectionEventLoginInterrupted,
    4: zimConnectionEvent.zimConnectionEventKickedOut,
  };

  int get value => valueMap[this] ?? -1;
}

/// Connection state.
/// Description: The state machine that identifies the current connection state.
/// Use cases: It can be used to judge whether the user enters/exit the room successfully, and handles abnormal situations such as network disconnection.
/// Caution: Please use it with the connection event parameter.
enum zimRoomState {
  /// Description: Disconnected state.
  /// Use cases: enter this state before entering the room and after exiting the room.
  zimRoomStateDisconnected,

  /// Description: The connection state is being requested.
  /// Use cases: and it will enter this state after the action of entering the room is executed successfully. The application interface is usually displayed through this state.
  zimRoomStateConnecting,

  /// Description: The connection is successful.
  /// Use cases: Entering this state means that the room has been successfully entered, and the user can use the room's functions normally.
  zimRoomStateConnected,
}

extension zimRoomStateExtension on zimRoomState {
  static const valueMap = {
    zimRoomState.zimRoomStateDisconnected: 0,
    zimRoomState.zimRoomStateConnecting: 1,
    zimRoomState.zimRoomStateConnected: 2,
  };
  static const mapValue = {
    0: zimRoomState.zimRoomStateDisconnected,
    1: zimRoomState.zimRoomStateConnecting,
    2: zimRoomState.zimRoomStateConnected,
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

extension zimRoomEventExtension on zimRoomEvent {
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
