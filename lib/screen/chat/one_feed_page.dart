import 'dart:async';

import 'package:ehson/api/models/one_feed_model.dart';
import 'package:ehson/bloc/one_feed_block/one_feed_bloc.dart';
import 'package:ehson/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class OneFeedPage extends StatefulWidget {
  int mavzu_id;

  OneFeedPage({super.key, required this.mavzu_id});

  @override
  State<OneFeedPage> createState() => _OneFeedPageState();
}

final _scrollController = ScrollController();
Timer? _debounce;
//shu page boshla

class _OneFeedPageState extends State<OneFeedPage> {
  final TextEditingController commentController = TextEditingController();

  List<OneFeedState> comments = [];

  void addComment(int food_id, String body) {
    //mana malumotla bor yana nima muammo?
    // setState(() {
    //   comments.add(OneFeedState(
    //       feed_comment:
    //   ));
    // });
  }

  //nima qimoqchisan ?
  // comment quwmoqchiman lekn malumotlani qerdan oliwni bimayopman

  @override
  void initState() {
    BlocProvider.of<OneFeedBloc>(context).add(ReloadOneFeedEvent(feed_id: 0));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _debounce?.cancel();
    super.dispose();
  }

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
        BlocProvider.of<OneFeedBloc>(context).add(GetOneFeedEvent(feed_id: 0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Container(
              margin: EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.mail,
                      size: 25,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.menu_outlined,
                      size: 25,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<OneFeedBloc, OneFeedState>(
              builder: (context, state) {
                switch (state.status) {
                  case OneFeed.loading:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case OneFeed.success:
                    if (state.feed == null) {
                      return Center(
                        child: Text("Empty"),
                      );
                    }
                    //boshla
                    return Column(
                      children: [
                        Container(
                          height: 100, // Set the desired height here
                          padding: EdgeInsets.all(8.0), // Add padding if needed
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40, // Customize the size of the avatar
                                backgroundImage: NetworkImage(state
                                            .feedOwner!.avatar ==
                                        null
                                    ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCaRg8BaRhDfuniljt47zyIWn03gFyE7T28w&s'
                                    : AppConstans.BASE_URL2 +
                                        "images/" +
                                        state.feedOwner!.avatar.toString()),
                              ),
                              SizedBox(width: 16),
                              // Add space between the avatar and text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // Vertically center the content
                                  children: [
                                    Text(
                                        style: GoogleFonts.roboto(
                                          textStyle: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        // state.products[index].body.toString()
                                        state.feedOwner!.name.toString()),
                                    SizedBox(height: 5),
                                    Text(
                                      "19:04 13 mar.2023",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                // state.products[index].body.toString()
                                // comment malumotlari bera emasku
                                state.feed!.title.toString() ?? "",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey[800],
                                ),
                                // state.products[index].body.toString()
                                state.feed!.body.toString() ?? "",
                              ),
                            ),
                          ],
                        ),
                        //qogan ashibkalani tugirla
                        //rasm bumasa default rasm qoy  rasm null busa
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                "Javoblar",
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            // Container(
                            //   child: Row(
                            //     children: [
                            //       IconButton(
                            //         onPressed: () {},
                            //         icon: Icon(
                            //           Icons.remove_red_eye,
                            //           color: Colors.blue,
                            //         ),
                            //       ),
                            //       Text("999"),
                            //       IconButton(
                            //         onPressed: () {},
                            //         icon: Icon(
                            //           Icons.favorite,
                            //           color: Colors.red,
                            //         ),
                            //       ),
                            //       Text("999"),
                            //     ],
                            //   ),
                            // )
                          ],
                        ),
                        //qera xatolik
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 1,
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        //blockbuilderni umumiy pagega berda listviewga emas umumiy pagega berodim bowuiga xatolik berdi wuchun shunga taxladim qaytib
                        //umimiy pagega berib kur endi xay

                        Expanded(
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            controller: _scrollController,
                            itemCount: state.islast
                                ? state.feed_comment.length
                                : state.feed_comment.length + 2,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              //qaysi imageni tugirlayopsan?

                              // String? img;
                              // if (state.products.length > index) {
                              //   if (state.products[index].img != null) {
                              //     asosiy_img = state.products[index].img;
                              //   } else {
                              //     asosiy_img = "https://www.shutterstock.com/image-photo/two-poor-african-children-front-600nw-2123588717.jpg";
                              //   }
                              // }

                              return index >= state.feed_comment.length
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  //kurchi boshqa joylarini oldin kur qerni uzgartiropsan keyen uzgartirda xay
                                  //hozi qaramasam kuni buyi urnaysan oldin yaxshilab qara nimani qoyopsan keyen modelga qara usha malumot qaysi
                                  //endi commentni scrollini qilish kerak keyen add comment qiganda bera qo'shilishi kerak boshlachi
                                  : Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              //serverga bitta rasm yoq shunga shunay qilopti
                                              CircleAvatar(
                                                backgroundImage: NetworkImage(state
                                                            .feedOwner!
                                                            .avatar ==
                                                        null
                                                    ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCaRg8BaRhDfuniljt47zyIWn03gFyE7T28w&s'
                                                    : AppConstans.BASE_URL2 +
                                                        "images/" +
                                                        state
                                                            .feed_comment[index]
                                                            .commentOwnerUserAvatar
                                                            .toString()),
                                                radius: 20,
                                              ),
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        state
                                                            .feed_comment[index]
                                                            .commentOwnerUserName!,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(width: 5),
                                                      // Text('- ${comment.points}'),
                                                    ],
                                                  ),
                                                  Text(state.feed_comment[index]
                                                      .body!),
                                                ],
                                              ),
                                              Spacer(),
                                              Text(
                                                state.feed_comment[index]
                                                    .createdAt!,
                                                // "${comment.timestamp.hour}:${comment.timestamp.minute.toString().padLeft(2, '0')} "
                                                //     "${comment.timestamp.day} ${_monthToString(comment.timestamp.month)} ${comment.timestamp.year}",
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              IconButton(
                                                  icon: Icon(Icons.reply),
                                                  onPressed: () {}),
                                              Text('javob berish',
                                                  style: TextStyle(
                                                      color: Colors.blue)),
                                              // Spacer(),
                                              // IconButton(
                                              //     icon: Icon(Icons.thumb_up), onPressed: () {}),
                                              // Text("20"),
                                              // SizedBox(width: 10),
                                              // IconButton(
                                              //     icon: Icon(Icons.delete, color: Colors.red),
                                              //     onPressed: () {}),
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                          ),
                                          // if(){}
                                          //taxku bu pageni dizayni replyniki yozganga cjiqaykonniki
                                        ],
                                      ),
                                    );
                            },
                          ),
                        ),

                        //qara birinchi comment qushadigan apini kuramiz nima malumot kerak
                        // Text input fixed at the bottom
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Yozish',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.send,
                                  size: 30,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  if (commentController.text.isNotEmpty) {
                                    //food_id bilan body kerak
                                    addComment(widget.mavzu_id,
                                        commentController.text);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  case OneFeed.error:
                    return Center(
                      child: Text("Internet error"),
                    );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
