class MessageModel {
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;

  MessageModel(
      {this.messageId, this.createdon, this.seen, this.sender, this.text});
  MessageModel.fromMap(Map<String, dynamic> map) {
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"].toDate();
    messageId = map["messageId"];
  }

  Map<String, dynamic> toMap() {
    return {
      "createdon": createdon,
      "text": text,
      "seen": seen,
      "sender": sender,
      "messageId": messageId,
    };
  }
}
