class UserInfoModel {
  bool? status;
  String? message;
  UserInfo? userInfo;

  UserInfoModel({this.status, this.message, this.userInfo});

  UserInfoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    userInfo = json['user_info'] != null
        ? new UserInfo.fromJson(json['user_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.userInfo != null) {
      data['user_info'] = this.userInfo!.toJson();
    }
    return data;
  }
}

class UserInfo {
  int? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? avatar;
  String? phone;
  String? createdAt;
  String? updatedAt;
  bool? admin;
  String? fcmToken;

  UserInfo(
      {this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.avatar,
        this.phone,
        this.createdAt,
        this.updatedAt,
        this.admin,
        this.fcmToken});

  UserInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    avatar = json['avatar'];
    phone = json['phone'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    admin = json['admin'];
    fcmToken = json['fcm_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['avatar'] = this.avatar;
    data['phone'] = this.phone;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['admin'] = this.admin;
    data['fcm_token'] = this.fcmToken;
    return data;
  }
}
