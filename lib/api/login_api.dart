import 'dart:convert';
import 'package:ehson/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PostLogin {
  Future<String> postLogin(
      String name,
      String email,
      String password,String fcm_token) async {
    var url = Uri.parse( AppConstans.BASE_URL+"/register");

    try {
      Map data = { "name": name,
        "email": email, "password": password,"fcm_token":fcm_token};
      //malumotlani jsonga moslashtirish
      var body = json.encode(data);
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            // "Authorization": 'Bearer $token',
          },
          body: body);
      print(response.body.toString());
      if (response.statusCode == 200) {

        //buyogla dabdalaku nmala qlopsan uzi
        final resdata = json.decode(utf8.decode(response.bodyBytes));
        if (resdata['status'] == true) {
          final Future<SharedPreferences> _prefs =
          SharedPreferences.getInstance();
          final SharedPreferences prefs = await _prefs;
          prefs.setBool("admin", resdata['user']['admin']);
          return resdata['message'];

        } else {
          return resdata['message'];
        }
      } else {
        return "Error";
      }
    } catch (e) {
      print(e.toString());
      return "Error";
    }
  }
}
