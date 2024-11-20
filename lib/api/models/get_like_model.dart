class GetLIkeModel {
  bool? status;
  String? message;
  LikedProducts? likedProducts;

  GetLIkeModel({this.status, this.message, this.likedProducts});

  GetLIkeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    likedProducts = json['liked_products'] != null
        ? new LikedProducts.fromJson(json['liked_products'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.likedProducts != null) {
      data['liked_products'] = this.likedProducts!.toJson();
    }
    return data;
  }
}

class LikedProducts {
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

  LikedProducts(
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

  LikedProducts.fromJson(Map<String, dynamic> json) {
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
  int? productId;
  String? createdAt;
  String? updatedAt;
  String? title;
  String? info;
  String? img1;
  String? img2;
  String? img3;
  int? categoryId;
  bool? status;
  int? productOwnerUserId;
  String? productOwnerPhone;

  Data(
      {this.id,
        this.userId,
        this.productId,
        this.createdAt,
        this.updatedAt,
        this.title,
        this.info,
        this.img1,
        this.img2,
        this.img3,
        this.categoryId,
        this.status,
        this.productOwnerUserId,
        this.productOwnerPhone});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    productId = json['product_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    title = json['title'];
    info = json['info'];
    img1 = json['img1'];
    img2 = json['img2'];
    img3 = json['img3'];
    categoryId = json['category_id'];
    status = json['status'];
    productOwnerUserId = json['product_owner_user_id'];
    productOwnerPhone = json['product_owner_phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['product_id'] = this.productId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['title'] = this.title;
    data['info'] = this.info;
    data['img1'] = this.img1;
    data['img2'] = this.img2;
    data['img3'] = this.img3;
    data['category_id'] = this.categoryId;
    data['status'] = this.status;
    data['product_owner_user_id'] = this.productOwnerUserId;
    data['product_owner_phone'] = this.productOwnerPhone;
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
