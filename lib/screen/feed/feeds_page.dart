import 'dart:async';

import 'package:ehson/api/repository.dart';
import 'package:ehson/bloc/one_feed_block/one_feed_bloc.dart';
// import 'package:ehson/screen/feed/comment.dart';
import 'package:ehson/screen/feed/lichka.dart';
import 'package:ehson/screen/feed//one_feed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/models/chat_model.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../constants/constants.dart';
import '../../mywidgets/mywidgets.dart';
import 'add_mavzu.dart';

class FeedsPage extends StatefulWidget {
  const FeedsPage({super.key});

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

Timer? _debounce;

class _FeedsPageState extends State<FeedsPage> {
  LatLng? _selectedLocation;
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    getSharedPrefs();
    BlocProvider.of<ChatBloc>(context).add(ReloadchatEvent(date: ""));
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  String formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp); // Parse the date string
    String formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(dateTime);
    return formattedDate;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _debounce?.cancel();
    super.dispose();
  }
  //feed qani?
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

  bool server_error = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ChatModel? chatModel;

  int user_id = 0;
  bool admin = false;

  Future<bool> delete_feed(int? feed_id) async {
    String add_like = await EhsonRepository().delete_feed(feed_id);
    if (add_like.contains("Success")) {
      return true;
    } else {
      Fluttertoast.showToast(
          msg: "Serverda xatolik qayta urunib ko'ring!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return false;
    }
  }

  Future<void> getSharedPrefs() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    //tokenni login qigan paytimiz sharedga saqlab qoyganbiza
    final SharedPreferences prefs = await _prefs;
    setState(() {
      user_id = prefs.getInt("user_id") ?? 0;
      admin = prefs.getBool("admin") ?? false;
    });
  }

  Future<void> _onrefresh() async {
    BlocProvider.of<ChatBloc>(context).add(ReloadchatEvent(date: ""));
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onrefresh,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ),
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
            // actions: [
            //   Container(
            //     margin: EdgeInsets.only(right: 10),
            //     child: Row(
            //       children: [
            //         IconButton(
            //           onPressed: () {},
            //           icon: Icon(
            //             color: Colors.blueAccent,
            //             Icons.filter_alt_rounded,
            //             size: 25,
            //           ),
            //         ),
            //         IconButton(
            //           onPressed: () {},
            //           icon: Icon(
            //             color: Colors.blueAccent,
            //
            //             Icons.search,
            //             size: 25,
            //           ),
            //         )
            //       ],
            //     ),
            //   ),
            // ],
            centerTitle: true,
            title: Text("Mavzu"),
          ),
          body: LoaderOverlay(
            child: Padding(
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
                        return Container(
                          child: MyWidget().mywidget("Hech narsa topilmadi!"),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.86,
                        );
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        // physics: NeverScrollableScrollPhysics(),
                        itemCount: state.islast
                            ? state.products.length
                            : state.products.length + 1,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return index >= state.products.length
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Column(
                                children: [
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(
                                              builder: (context) {
                                        return BlocProvider(
                                          create: (ctx) => OneFeedBloc(),
                                          child: OneFeedPage(
                                              mavzu_id:
                                                  state.products[index].id!),
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
                                      backgroundImage: state.products[index].avatar != null ? NetworkImage(
                                          AppConstans.BASE_URL2 + "images/" +state.products[index].avatar.toString(),
                                      ) : null,
                                      child: state.products[index].avatar == null ? Icon(Icons.person) : SizedBox(),
                                    ),
                                    title: Text(state.products[index].name.toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                    // title: Text(state.products[index].body
                                    //     .toString()),
                                    subtitle: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            state.products[index].title
                                                .toString(),
                                            maxLines: 1,
                                          overflow: TextOverflow
                                              .ellipsis,
                                          style: TextStyle(fontSize: 14),

                                        ),
                                        Text(
                                            state.products[index].body
                                                .toString(),
                                            maxLines: 1,
                                          overflow: TextOverflow
                                              .ellipsis,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: admin || state.products[index].userId == user_id ? MainAxisAlignment.spaceBetween: MainAxisAlignment.center,
                                      children: [
                                        admin || state.products[index].userId == user_id ? InkWell(child: Icon(Icons.delete,color: Colors.red,),onTap: (){
                                          Dialogs.materialDialog(
                                              color: Colors.white,
                                              msg: "Ushbu "+state.products[index].title.toString()+" nomli mavzuni o'chirishni xoxlaysizmi?",
                                              titleStyle: TextStyle(fontSize: 18),
                                              titleAlign: TextAlign.center,
                                              title: "Mehr",
                                              customViewPosition: CustomViewPosition.BEFORE_ACTION,
                                              context: context,
                                              actions: [
                                                TextButton(onPressed: (){
                                                  Navigator.pop(context);
                                                }, child: Text("Yo'q")),
                                                IconsButton(
                                                  onPressed: () async{
                                                    context.loaderOverlay.show();

                                                    int? product_id = state
                                                        .products[
                                                    index]
                                                        .id;
                                                    bool
                                                    delete_p =
                                                    await delete_feed(
                                                        product_id);

                                                    if (delete_p == true) {
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        state.products.removeAt(index);
                                                      });
                                                    }

                                                    context.loaderOverlay.hide();
                                                  },
                                                  text: 'Ha',
                                                  // iconData: Icons.done,
                                                  color: Colors.blue,
                                                  textStyle: TextStyle(color: Colors.white),
                                                  iconColor: Colors.white,
                                                ),
                                              ]);
                                        },):SizedBox(),
                                        Text(formatTimestamp(state.products[index].createdAt.toString()),style: TextStyle(fontSize: 8),),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Divider(
                                      color: Colors.grey[300],
                                    ),
                                    width: 400,
                                  )
                                ],
                              );
                        },
                      );
                    case ChatProduct.error:
                      return Container(

                        child: Column(
                          children: [
                            Center(
                              child: Text("Internet bilan bog'liq xatolik!",style: TextStyle(fontSize: 20),),
                            ),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.65,
                                  height: MediaQuery.of(context).size.height *
                                      0.06,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                    ),
                                    onPressed: (){
                                      _refreshController.requestRefresh();
                                    },
                                    child: Text(
                                      "Qayta urunish",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        height: MediaQuery.of(context).size.height*0.6,
                      );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
