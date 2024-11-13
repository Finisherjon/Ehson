class ChatListModel {
  bool? status;
  String? message;
  List<Chats>? chats;

  ChatListModel({this.status, this.message, this.chats});

  ChatListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['chats'] != null) {
      chats = <Chats>[];
      json['chats'].forEach((v) {
        chats!.add(new Chats.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.chats != null) {
      data['chats'] = this.chats!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Chats {
  int? chatId;
  int? userOneId;
  String? userOneAvatar;
  String? userOneName;
  int? userTwoId;
  String? userTwoName;
  String? userTwoAvatar;
  String? chatCreatedAt;
  String? lastMessage;
  String? lastMessageCreatedAt;
  int? lastMessageSenderId;

  Chats(
      {this.chatId,
        this.userOneId,
        this.userOneAvatar,
        this.userOneName,
        this.userTwoId,
        this.userTwoName,
        this.userTwoAvatar,
        this.chatCreatedAt,
        this.lastMessage,
        this.lastMessageCreatedAt,
        this.lastMessageSenderId});

  Chats.fromJson(Map<String, dynamic> json) {
    chatId = json['chat_id'];
    userOneId = json['user_one_id'];
    userOneAvatar = json['user_one_avatar'];
    userOneName = json['user_one_name'];
    userTwoId = json['user_two_id'];
    userTwoName = json['user_two_name'];
    userTwoAvatar = json['user_two_avatar'];
    chatCreatedAt = json['chat_created_at'];
    lastMessage = json['last_message'];
    lastMessageCreatedAt = json['last_message_created_at'];
    lastMessageSenderId = json['last_message_sender_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chat_id'] = this.chatId;
    data['user_one_id'] = this.userOneId;
    data['user_one_avatar'] = this.userOneAvatar;
    data['user_one_name'] = this.userOneName;
    data['user_two_id'] = this.userTwoId;
    data['user_two_name'] = this.userTwoName;
    data['user_two_avatar'] = this.userTwoAvatar;
    data['chat_created_at'] = this.chatCreatedAt;
    data['last_message'] = this.lastMessage;
    data['last_message_created_at'] = this.lastMessageCreatedAt;
    data['last_message_sender_id'] = this.lastMessageSenderId;
    return data;
  }
}
