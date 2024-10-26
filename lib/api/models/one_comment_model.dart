class OneCommentModel {
  bool? status;
  String? message;
  Comment? comment;

  OneCommentModel({this.status, this.message, this.comment});

  OneCommentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    comment =
    json['comment'] != null ? new Comment.fromJson(json['comment']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.comment != null) {
      data['comment'] = this.comment!.toJson();
    }
    return data;
  }
}

class Comment {
  int? id;
  int? userId;
  Null? replyUserId;
  int? feedId;
  String? body;
  String? createdAt;
  String? updatedAt;
  String? commentOwnerUserName;
  Null? commentOwnerUserAvatar;

  Comment(
      {this.id,
        this.userId,
        this.replyUserId,
        this.feedId,
        this.body,
        this.createdAt,
        this.updatedAt,
        this.commentOwnerUserName,
        this.commentOwnerUserAvatar});

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    replyUserId = json['reply_user_id'];
    feedId = json['feed_id'];
    body = json['body'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    commentOwnerUserName = json['comment_owner_user_name'];
    commentOwnerUserAvatar = json['comment_owner_user_avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['reply_user_id'] = this.replyUserId;
    data['feed_id'] = this.feedId;
    data['body'] = this.body;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['comment_owner_user_name'] = this.commentOwnerUserName;
    data['comment_owner_user_avatar'] = this.commentOwnerUserAvatar;
    return data;
  }
}
