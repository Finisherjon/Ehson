class OneHelpModel {
  bool? status;
  String? message;
  Help? help;

  OneHelpModel({this.status, this.message, this.help});

  OneHelpModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    help = json['help'] != null ? new Help.fromJson(json['help']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.help != null) {
      data['help'] = this.help!.toJson();
    }
    return data;
  }
}

class Help {
  int? id;
  int? userId;
  String? title;
  String? info;
  String? img;
  String? phone;
  String? location;
  bool? status;
  String? createdAt;
  String? updatedAt;

  Help(
      {this.id,
        this.userId,
        this.title,
        this.info,
        this.img,
        this.phone,
        this.location,
        this.status,
        this.createdAt,
        this.updatedAt});

  Help.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    info = json['info'];
    img = json['img'];
    phone = json['phone'];
    location = json['location'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['info'] = this.info;
    data['img'] = this.img;
    data['phone'] = this.phone;
    data['location'] = this.location;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
