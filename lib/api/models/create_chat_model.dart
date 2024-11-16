class CreateChatModel {
  bool? status;
  String? message;
  Chat? chat;

  CreateChatModel({this.status, this.message, this.chat});

  CreateChatModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    chat = json['chat'] != null ? new Chat.fromJson(json['chat']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.chat != null) {
      data['chat'] = this.chat!.toJson();
    }
    return data;
  }
}

class Chat {
  int? chatId;
  int? userOneId;
  String? userOneAvatar;
  String? userOneName;
  int? userTwoId;
  String? userTwoName;
  String? userTwoAvatar;

  Chat(
      {this.chatId,
        this.userOneId,
        this.userOneAvatar,
        this.userOneName,
        this.userTwoId,
        this.userTwoName,
        this.userTwoAvatar});

  Chat.fromJson(Map<String, dynamic> json) {
    chatId = json['chat_id'];
    userOneId = json['user_one_id'];
    userOneAvatar = json['user_one_avatar'];
    userOneName = json['user_one_name'];
    userTwoId = json['user_two_id'];
    userTwoName = json['user_two_name'];
    userTwoAvatar = json['user_two_avatar'];
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
    return data;
  }
}
