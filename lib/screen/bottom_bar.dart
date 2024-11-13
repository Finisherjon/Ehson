import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ehson/screen/add_product/screen/add_product_screen.dart';
import 'package:ehson/screen/chat/chats_page.dart';
import 'package:ehson/screen/feed/feeds_page.dart';
import 'package:ehson/screen/home/home_screen.dart';
import 'package:ehson/screen/profile/profile.dart';
import 'package:ehson/screen/wishlist/like.dart';
import 'package:flutter/material.dart';

import '../adjust_size.dart';
import 'feed/comment.dart';

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
    ChatsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      // bottomNavigationBar: BottomNavigationBar(
      //
      //   type: BottomNavigationBarType.fixed,
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.business),
      //       label: 'Business',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.school),
      //       label: 'School',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.school),
      //       label: 'School',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.amber[800],
      //   onTap: _onItemTapped,
      // ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.blueAccent,
        color: Colors.blueAccent,
        height: Sizes.heights(context) * 0.08,
        animationDuration: const Duration(milliseconds: 450),
        items: <Widget>[
          Icon(
            Icons.home,
            size: IconSize.mediumIconSize(context),
            color: Colors.white,
          ),
          Icon(
            Icons.favorite,
            size: IconSize.mediumIconSize(context),
            color: Colors.white,
          ),
          Icon(
            Icons.feed,
            size: IconSize.mediumIconSize(context),
            color: Colors.white,
          ),
          Icon(
            Icons.chat,
            size: IconSize.mediumIconSize(context),
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
