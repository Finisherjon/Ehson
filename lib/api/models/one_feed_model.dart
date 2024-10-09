class OneFeedModel {
  bool? status;
  String? message;
  FeedData? feedData;

  OneFeedModel({this.status, this.message, this.feedData});

  OneFeedModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    feedData = json['feed_data'] != null
        ? new FeedData.fromJson(json['feed_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.feedData != null) {
      data['feed_data'] = this.feedData!.toJson();
    }
    return data;
  }
}

class FeedData {
  Feed? feed;
  FeedOwner? feedOwner;
  FeedComments? feedComments;

  FeedData({this.feed, this.feedOwner, this.feedComments});

  FeedData.fromJson(Map<String, dynamic> json) {
    feed = json['feed'] != null ? new Feed.fromJson(json['feed']) : null;
    feedOwner = json['feed_owner'] != null
        ? new FeedOwner.fromJson(json['feed_owner'])
        : null;
    feedComments = json['feed_comments'] != null
        ? new FeedComments.fromJson(json['feed_comments'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.feed != null) {
      data['feed'] = this.feed!.toJson();
    }
    if (this.feedOwner != null) {
      data['feed_owner'] = this.feedOwner!.toJson();
    }
    if (this.feedComments != null) {
      data['feed_comments'] = this.feedComments!.toJson();
    }
    return data;
  }
}

class Feed {
  int? id;
  int? userId;
  String? title;
  String? body;
  String? createdAt;
  String? updatedAt;

  Feed(
      {this.id,
        this.userId,
        this.title,
        this.body,
        this.createdAt,
        this.updatedAt});

  Feed.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    body = json['body'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['body'] = this.body;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class FeedOwner {
  int? id;
  String? name;
  String? email;
  Null? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  String? avatar;
  String? phone;

  FeedOwner(
      {this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.createdAt,
        this.updatedAt,
        this.avatar,
        this.phone});

  FeedOwner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    avatar = json['avatar'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['avatar'] = this.avatar;
    data['phone'] = this.phone;
    return data;
  }
}

class FeedComments {
  int? currentPage;
  List<Data>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  Null? nextPageUrl;
  String? path;
  int? perPage;
  Null? prevPageUrl;
  int? to;
  int? total;

  FeedComments(
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

  FeedComments.fromJson(Map<String, dynamic> json) {
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
  int? userId;
  int? feedId;
  String? body;
  String? createdAt;
  String? updatedAt;
  Null? replyUserId;
  String? commentOwnerUserName;
  String? commentOwnerUserAvatar;

  Data(
      {this.id,
        this.userId,
        this.feedId,
        this.body,
        this.createdAt,
        this.updatedAt,
        this.replyUserId,
        this.commentOwnerUserName,
        this.commentOwnerUserAvatar});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    feedId = json['feed_id'];
    body = json['body'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    replyUserId = json['reply_user_id'];
    commentOwnerUserName = json['comment_owner_user_name'];
    commentOwnerUserAvatar = json['comment_owner_user_avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['feed_id'] = this.feedId;
    data['body'] = this.body;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['reply_user_id'] = this.replyUserId;
    data['comment_owner_user_name'] = this.commentOwnerUserName;
    data['comment_owner_user_avatar'] = this.commentOwnerUserAvatar;
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
