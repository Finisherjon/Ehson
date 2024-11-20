class OneProductModel {
  bool? status;
  String? message;
  Product? product;

  OneProductModel({this.status, this.message, this.product});

  OneProductModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    product =
    json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    return data;
  }
}

class Product {
  int? id;
  int? userId;
  String? title;
  String? info;
  String? img1;
  String? img2;
  String? img3;
  int? categoryId;
  int? cityId;
  bool? status;
  String? createdAt;
  String? updatedAt;
  String? phone;
  String? avatar;
  String? category_name;
  String? city_name;
  int? isliked;

  Product(
      {this.id,
        this.userId,
        this.title,
        this.info,
        this.img1,
        this.img2,
        this.img3,
        this.categoryId,
        this.cityId,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.phone,
        this.avatar,
        this.category_name,
        this.city_name,
        this.isliked});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    info = json['info'];
    img1 = json['img1'];
    img2 = json['img2'];
    img3 = json['img3'];
    categoryId = json['category_id'];
    cityId = json['city_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    phone = json['phone'];
    avatar = json['avatar'];
    category_name = json['category_name'];
    city_name = json['city_name'];
    isliked = json['isliked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['info'] = this.info;
    data['img1'] = this.img1;
    data['img2'] = this.img2;
    data['img3'] = this.img3;
    data['category_id'] = this.categoryId;
    data['city_id'] = this.cityId;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['phone'] = this.phone;
    data['avatar'] = this.avatar;
    data['category_name'] = this.category_name;
    data['city_name'] = this.city_name;
    data['isliked'] = this.isliked;
    return data;
  }
}