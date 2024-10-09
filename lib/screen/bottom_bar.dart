import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ehson/screen/add_product/screen/add_product_screen.dart';
import 'package:ehson/screen/chat/feeds_page.dart';
import 'package:ehson/screen/home/home_screen.dart';
import 'package:ehson/screen/profile/profile.dart';
import 'package:ehson/screen/wishlist/like.dart';
import 'package:flutter/material.dart';

import '../adjust_size.dart';
import 'chat/comment.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    LikePage(),
    // AddProductScreen(),
    FeedsPage(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.blueAccent,
        color: Colors.blueAccent,
        height: 70,
        animationDuration: const Duration(milliseconds: 400),
        items: <Widget>[
          Icon(
            Icons.home,
            size: IconSize.mediumIconSize(context),
            color: Colors.white,
          ),
          Icon(
            Icons.favorite,
            size: 23,
            color: Colors.white,
          ),
          Icon(
            Icons.chat,
            size: 26,
            color: Colors.white,
          ),
          Icon(
            Icons.person,
            size: 26,
            color: Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
