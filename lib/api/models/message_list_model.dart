class MessageListModel {
  bool? status;
  String? message;
  Messages? messages;

  MessageListModel({this.status, this.message, this.messages});

  MessageListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    messages = json['messages'] != null
        ? new Messages.fromJson(json['messages'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.messages != null) {
      data['messages'] = this.messages!.toJson();
    }
    return data;
  }
}

class Messages {
  int? currentPage;
  List<Data>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  Messages(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.links,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total});

  Messages.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(new Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class Data {
  int? id;
  int? chatId;
  int? senderId;
  int? receiverId;
  String? message;
  String? createdAt;
  String? updatedAt;
  String? senderName;
  String? senderAvatar;
  String? receiverName;
  String? receiverAvatar;

  Data(
      {this.id,
        this.chatId,
        this.senderId,
        this.receiverId,
        this.message,
        this.createdAt,
        this.updatedAt,
        this.senderName,
        this.senderAvatar,
        this.receiverName,
        this.receiverAvatar});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatId = json['chat_id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    message = json['message'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    senderName = json['sender_name'];
    senderAvatar = json['sender_avatar'];
    receiverName = json['receiver_name'];
    receiverAvatar = json['receiver_avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['chat_id'] = this.chatId;
    data['sender_id'] = this.senderId;
    data['receiver_id'] = this.receiverId;
    data['message'] = this.message;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['sender_name'] = this.senderName;
    data['sender_avatar'] = this.senderAvatar;
    data['receiver_name'] = this.receiverName;
    data['receiver_avatar'] = this.receiverAvatar;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}
