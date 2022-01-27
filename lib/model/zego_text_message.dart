
class ZegoTextMessage {
  String userID = "";
  String message = "";
  int timestamp = 0;
  int messageID = 0;
  int type = 0;

  ZegoTextMessage();

  ZegoTextMessage.formJson(Map<String, dynamic> json)
      : userID = json['userID'],
        message = json['message'],
        timestamp = json['timestamp'],
        messageID = json['messageID'],
        type = json['type'];

  Map<String, dynamic> toJson() => {
    'messageID': messageID,
    'userID': userID,
    'message': message,
    'timestamp': timestamp,
    'type': type
  };
}