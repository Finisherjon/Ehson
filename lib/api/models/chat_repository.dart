import 'dart:convert';

import 'package:ehson/api/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class YordamRepository {
  Future<List<ChatModel>> getData() async {
    List<ChatModel> productList = [];
    final url = Uri.parse('https://tezkor-ofitsant.uz/api/getfeed');

    ChatModel? yordamModel;

    try {
      final res = await http.get(url);
      final resData = json.decode(utf8.decode(res.bodyBytes));
      if (res.statusCode == 200) {
        for (final item in resData) {
          productList.add(ChatModel.fromJson(item));
        }
      } else {
        throw Exception('Server error error code ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Server error error code $e}');
    }

    return productList;
  }
}
