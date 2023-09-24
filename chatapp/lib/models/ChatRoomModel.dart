class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participents;
  String? lastMessage;

  ChatRoomModel({this.chatroomid, this.participents, this.lastMessage});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participents = map["participents"];
    lastMessage = map["lastMessage"];
  }

  Map<String, dynamic> toMap() {
    return {
      "participents": participents,
      "chatroomid": chatroomid,
      "lastMessage": lastMessage,
    };
  }
}
