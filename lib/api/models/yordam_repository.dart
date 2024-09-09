import 'dart:convert';

import 'package:ehson/api/models/yordam_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class YordamRepository {
  Future<List<YordamModel>> getData() async {
    List<YordamModel> productList = [];
    final url = Uri.parse('https://tezkor-ofitsant.uz/api/gethelp');

    YordamModel? yordamModel;

    try {
      final res = await http.get(url);
      //qani bearer token qushmagankusan
      // cahlkashi bib kettim kn manabundan kurib yozdim
      final resData = json.decode(utf8.decode(res.bodyBytes));
      if (res.statusCode == 200) {
        for (final item in resData) {
          productList.add(YordamModel.fromJson(item));
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
