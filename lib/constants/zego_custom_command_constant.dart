/// Class custom signaling.
/// <p>Description: This class contains the custom signaling related logics, such as send virtual gift, send seat-taking
/// invitation, etc.</>
enum zegoCustomCommandType {
  invitation,
  gift,
}

extension ZegoCustomCommandTypeExtension on zegoCustomCommandType {
  static const valueMap = {
    zegoCustomCommandType.invitation: 1,
    zegoCustomCommandType.gift: 2,
  };
  static const mapValue = {
    1: zegoCustomCommandType.invitation,
    2: zegoCustomCommandType.gift,
  };

  int get value => valueMap[this] ?? -1;
}
