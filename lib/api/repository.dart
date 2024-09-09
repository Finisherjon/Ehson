import 'dart:convert';

import 'package:ehson/api/models/category_model.dart';
import 'package:ehson/api/models/product_model.dart';
import 'package:ehson/api/models/user_model.dart';
import 'package:ehson/api/models/yordam_model.dart';
import 'package:ehson/screen/yordam/yordam.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import 'package:http/http.dart' as http;

class EhsonRepository {
  Future<CategoryModel?> get_category() async {
    //chack bu kodni tekshirishku
    CategoryModel? categoryModel;
    var url = Uri.parse(AppConstans.BASE_URL + '/getcategories');
    try {
      var response = await http.get(url, headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final response_json = json.decode(utf8.decode(response.bodyBytes));
        if (response_json['status']) {
          categoryModel = CategoryModel.fromJson(response_json);
          return categoryModel;
        } else {
          throw Exception("Server error code ${response.statusCode}");
        }
      } else {
        throw Exception("Server error code ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Server error code ${e.toString()}");
    }
  }

  Future<bool> refresh_token(String token) async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    //chack bu kodni tekshirishku
    var url = Uri.parse(AppConstans.BASE_URL + "/refreshToken");

    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map response_json = json.decode(utf8.decode(response.bodyBytes));
        if (response_json['status']) {
          print("token yangilandi.");
          print('yangilangan yoken');
          print(response_json['token']);
          final SharedPreferences prefs = await _prefs;
          prefs.setString('bearer_token', response_json['token']);
          return true;
        } else {
          return false;
        }
      } else {
        print("refresh_token->Server error code ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("refresh_token->Server error $e");
      return false;
    }
  }

  Future<UserModel> get_me() async {
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    //tokenni login qigan paytimiz sharedga saqlab qoyganbiza
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    UserModel? userModel;
    var url = Uri.parse(AppConstans.BASE_URL + "/getme");
    try {
      var response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $token',
      });
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      print(resdata);
      if (response.statusCode == 200) {
        if (resdata['status']) {
          userModel = UserModel.fromJson(resdata);
          return userModel;
        } else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          //agar token expired deb kesa tokenni yangila deganbiza
          //tokenni yangilash funksiyasi
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await get_me();
          } else {
            throw Exception("Server error code ${response.statusCode}");
          }
        } else {
          throw Exception(
              "getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
        }
      } else {
        throw Exception("getData->Server error code ${response.statusCode}");
      }
    } catch (e) {
      print(("getData->Server error $e"));
      throw Exception("getData->Server error $e");
    }
  }

  Future<String> add_info(String name, String phone, String avatar) async {
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    //tokenni login qigan paytimiz sharedga saqlab qoyganbiza
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    var uri = Uri.parse(AppConstans.BASE_URL + '/update');
    Map data;
    if (avatar == "") {
      data = {"name": name, "phone": phone};
    } else {
      data = {"name": name, "phone": phone, "avatar": avatar};
    }

    //tokenni qushamiz

    var body = json.encode(data);

    try {
      //tokenniyam qushish kerak bumasa succsess bumaydi
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        final resdata = json.decode(utf8.decode(response.bodyBytes));
        if (resdata["status"] == true) {
          return "Success";
        } else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          //agar token eskirgan busa yangilashimiz kerak
          //tokenni yangilashga murojaat
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            //token yangilansa qayta add infoga murojaat
            return await add_info(name, phone, avatar);
          } else {
            return "Error: ${response.statusCode}";
          }
        } else {
          return "Error: ${response.statusCode}";
        }
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      print("Error: $e");
      return "Exception: $e";
    }
  }

  //

  Future<String> add_yordam(String title, String info, String phone,
      String image, String location) async {
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    var uri = Uri.parse(AppConstans.BASE_URL + '/addhelp');
    Map data;
    {
      data = {
        "title": title,
        "info": info,
        "phone": phone,
        "location": location,
        "img": image
      };
    }

    var body = json.encode(data);

    try {
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        final resdata = json.decode(utf8.decode(response.bodyBytes));
        if (resdata["status"] == true) {
          return "Success";
        } else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            //token yangilansa qayta add infoga murojaat
            return await add_yordam(title, info, phone, image, location);
          } else {
            return "Error: ${response.statusCode}";
          }
        } else {
          return "Error: ${response.statusCode}";
        }
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      print("Error: $e");
      return "Exception: $e";
    }
  }

  //

  Future<ProductModel?> getproduct(String? next_page_url, String date) async {
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    ProductModel? productModel;
    if (token == '') {
      print("Token yoq");
      Map data = {
        'email': prefs.getString('email'),
        'password': prefs.getString('password')
      };
      var url = Uri.parse(AppConstans.BASE_URL + '/login');

      //malumotlani jsonga moslashtirish
      var body = json.encode(data);
      try {
        var response = await http.post(url,
            headers: {"Content-Type": "application/json"}, body: body);
        final resdata = json.decode(utf8.decode(response.bodyBytes));
        print(resdata);
        if (response.statusCode == 200) {
          if (resdata['status']) {
            final SharedPreferences prefs = await _prefs;
            prefs.setString('bearer_token', resdata['token']);
            return await getproduct(next_page_url, date);
          } else if (resdata['status'] == false &&
              resdata['message'].toString().contains("Token expired")) {
            bool token_isrefresh = await refresh_token(token);
            if (token_isrefresh) {
              return await getproduct(next_page_url, date);
            } else {
              print("Server error code ${response.statusCode}");
              throw Exception("Server error code ${response.statusCode}");
            }
          } else {
            print(
                "getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
            throw Exception(
                "getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
          }
        } else {
          print("Server error code ${response.statusCode}");
          throw Exception("Server error code ${response.statusCode}");
        }
      } catch (e) {
        print("Server error $e");
        throw Exception("Server error $e");
      }
    } else {
      print("token bor");
      var url;
      if (next_page_url == null) {
        return productModel;
      } else if (next_page_url == '') {
        //

        url = Uri.parse(AppConstans.BASE_URL + "/getproduct");
      } else {
        url = Uri.parse(next_page_url);
      }
      final SharedPreferences prefs = await _prefs;
      var token = prefs.getString('bearer_token') ?? '';
      try {
        var response = await http.get(url, headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
        });
        final resdata = json.decode(utf8.decode(response.bodyBytes));
        print(resdata);
        if (response.statusCode == 200) {
          if (resdata['status']) {
            print(token);
            productModel = ProductModel.fromJson(resdata);
            return productModel;
          } else if (resdata['status'] == false &&
              resdata['message'].toString().contains("Token expired")) {
            bool token_isrefresh = await refresh_token(token);
            if (token_isrefresh) {
              return await getproduct(next_page_url, date);
            } else {
              throw Exception("Server error code ${response.statusCode}");
            }
          } else {
            throw Exception(
                "getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
          }
        } else {
          throw Exception("getData->Server error code ${response.statusCode}");
        }
      } catch (e) {
        print(("getData->Server error $e"));
        throw Exception("getData->Server error $e");
      }
    }
  }

  Future<YordamModel?> getyordam(String? next_page_url, String date) async {
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    YordamModel? yordamModel;
      print("token bor");
      var url;
      if (next_page_url == null) {
        return yordamModel;
      } else if (next_page_url == '') {
        //

        url = Uri.parse(AppConstans.BASE_URL + "/gethelp");
      } else {
        url = Uri.parse(next_page_url);
      }
      try {
        var response = await http.get(url, headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
        });
        final resdata = json.decode(utf8.decode(response.bodyBytes));
        if (response.statusCode == 200) {
          if (resdata['status']) {
            yordamModel = YordamModel.fromJson(resdata);
            return yordamModel;
          } else if (resdata['status'] == false &&
              resdata['message'].toString().contains("Token expired")) {
            bool token_isrefresh = await refresh_token(token);
            if (token_isrefresh) {
              return await getyordam(next_page_url, date);
            } else {
              throw Exception("Server error code ${response.statusCode}");
            }
          } else {
            throw Exception(
                "getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
          }
        } else {
          throw Exception("getData->Server error code ${response.statusCode}");
        }
      } catch (e) {
        print(("getData->Server error $e"));
        throw Exception("getData->Server error $e");
      }
  }
}
