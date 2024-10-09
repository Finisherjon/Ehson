// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class LikeModel {
//   final String id;
//   bool isLiked;
//
//   LikeModel({required this.id, this.isLiked = false});
// }
//
// class LikeManager with ChangeNotifier {
//   Set<String> likedProductIds = {}; // Store the liked product IDs
//
//   Future<void> toggleLike(LikeModel product) async {
//     if (likedProductIds.contains(product.id)) {
//       likedProductIds.remove(product.id);
//       product.isLiked = false;
//       await postProductLike(product.id, false); // Un-liking a product
//     } else {
//       likedProductIds.add(product.id);
//       product.isLiked = true;
//       await postProductLike(product.id, true); // Liking a product
//     }
//     notifyListeners(); // Notify listeners to update UI
//   }
//
//   // Post product like/unlike status to API
//   Future<void> postProductLike(String productId, bool isLiked) async {
//     String url = 'https://tezkor-ofitsant.uz/api/addlike'; // Your API URL
//
//     try {
//       var response = await http.post(
//         Uri.parse(url),
//         body: {
//           'product_id': productId,
//           'is_liked': isLiked.toString(), // true if liked, false if unliked
//         },
//       );
//
//       if (response.statusCode == 200) {
//         print('Product ID $productId posted successfully');
//       } else {
//         print('Failed to post Product ID $productId');
//       }
//     } catch (e) {
//       print('Error posting Product ID $productId: $e');
//     }
//   }
// }

class LikeModel {
  final String id;
  bool isLiked;

  LikeModel({required this.id, this.isLiked = false});
}