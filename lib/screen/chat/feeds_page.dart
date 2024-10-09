import 'dart:async';

import 'package:ehson/bloc/one_feed_block/one_feed_bloc.dart';
import 'package:ehson/screen/chat/comment.dart';
import 'package:ehson/screen/chat/lichka.dart';
import 'package:ehson/screen/chat/one_feed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../bloc/chat/chat_bloc.dart';
import 'add_mavzu.dart';

class FeedsPage extends StatefulWidget {
  const FeedsPage({super.key});

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

final _scrollController = ScrollController();
Timer? _debounce;

class _FeedsPageState extends State<FeedsPage> {
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatBloc>(context).add(ReloadchatEvent(date: ""));
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _debounce?.cancel();
    super.dispose();
  }
  //chat qani?
  //uwa hechnima kursatmayopti
  //add_chatci?

  bool _isNearBottom() {
    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent == 0) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_isNearBottom()) {
        print("Keldi");
        BlocProvider.of<ChatBloc>(context).add(GetchatEvent(date: ""));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMavzu(),
                ),
              );
            }),
        appBar: AppBar(
          // elevation: 2.0,
          actions: [
            Container(
              margin: EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.filter_alt_rounded,
                      size: 25,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.search,
                      size: 25,
                    ),
                  )
                ],
              ),
            ),
          ],
          centerTitle: true,
          title: Text("Chat"),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              switch (state.status) {
                case ChatProduct.loading:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                case ChatProduct.success:
                  if (state.products.isEmpty) {
                    return Center(
                      child: Text("Empty"),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    // physics: NeverScrollableScrollPhysics(),
                    itemCount: state.islast
                        ? state.products.length
                        : state.products.length + 2,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return index >= state.products.length
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Expanded(
                            child: Column(
                                children: [
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                                        return BlocProvider(
                                          create: (ctx) => OneFeedBloc(),
                                          child: OneFeedPage(mavzu_id: state.products[index].id!),
                                        );
                                      }));
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //       builder: (context) => OneFeedPage(mavzu_id: state.products[index].id!)),
                                      // );
                                    },
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCaRg8BaRhDfuniljt47zyIWn03gFyE7T28w&s",
                                      ),
                                    ),
                                    title: Text(
                                        state.products[index].body.toString()),
                                    subtitle: Text(
                                        state.products[index].title.toString(),
                                        maxLines: 1),
                                    trailing: Text("10:10"),
                                  ),
                                  Container(
                                    child: Divider(
                                      color: Colors.grey[300],
                                    ),
                                    width: 400,
                                  )
                                ],
                              ),
                          );
                    },
                  );
                case ChatProduct.error:
                  return Center(
                    child: Text("Internet error"),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
