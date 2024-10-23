import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductInfo extends StatefulWidget {
  const ProductInfo({super.key});

  @override
  State<ProductInfo> createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  final PageController _controller = PageController();
  final int _pageCount = 3; // Number of pages
  final List<String> _imagePaths = [
    'https://images.squarespace-cdn.com/content/v1/5d777de8109c315fd22faf3a/1693407136044-G90XQURX1GABMYGAS8K1/shutterstock_1288634614.jpg?format=2500w',
    'https://images.squarespace-cdn.com/content/v1/5d777de8109c315fd22faf3a/1693407136044-G90XQURX1GABMYGAS8K1/shutterstock_1288634614.jpg?format=2500w',
    'https://images.squarespace-cdn.com/content/v1/5d777de8109c315fd22faf3a/1693407136044-G90XQURX1GABMYGAS8K1/shutterstock_1288634614.jpg?format=2500w',
  ]; // List of asset image paths

  final List<String> _captions = [
    "Beautiful Sunset",
    "Mountain Adventure",
    "Serene Beach",
    "Night Cityscape",
    "Lush Forest"
  ]; // List of captions

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Go to next page function
  void nextPage() {
    if (_controller.page!.toInt() < _pageCount - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // SizedBox(
            //   height: 300,
            //   width: double.infinity,
            //   child: PageView.builder(
            //     itemCount: imageUrls.length,
            //     itemBuilder: (context, index) {
            //       return Image.network(
            //         imageUrls[index],
            //         fit: BoxFit.cover,
            //       );
            //     },
            //   ),
            // ),
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageCount,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_imagePaths[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16),
            SmoothPageIndicator(
              controller: _controller,
              count: _pageCount,
              effect: WormEffect(
                dotColor: Colors.grey.shade400,
                activeDotColor: Colors.teal,
                dotHeight: 12,
                dotWidth: 12,
                spacing: 12,
                paintStyle: PaintingStyle.fill,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            Icons.favorite,
                            size: 20,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
