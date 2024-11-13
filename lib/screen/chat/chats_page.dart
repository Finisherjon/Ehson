import 'dart:async';

import 'package:ehson/bloc/chat_list/chat_list_bloc.dart';
import 'package:ehson/bloc/message/message_list_bloc.dart';
import 'package:ehson/bloc/one_feed_block/one_feed_bloc.dart';
import 'package:ehson/screen/chat/one_chat.dart';
// import 'package:ehson/screen/feed/comment.dart';
import 'package:ehson/screen/feed/lichka.dart';
import 'package:ehson/screen/feed//one_feed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/models/chat_model.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../constants/constants.dart';
import '../../mywidgets/mywidgets.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

Timer? _debounce;
int user_id = 0;

Future<void> getSharedPrefs() async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //tokenni login qigan paytimiz sharedga saqlab qoyganbiza
  final SharedPreferences prefs = await _prefs;
  user_id = prefs.getInt("user_id") ?? 0;
  print(user_id);
}

class _ChatsPageState extends State<ChatsPage> {
  LatLng? _selectedLocation;
  // late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    getSharedPrefs();
    BlocProvider.of<ChatListBloc>(context).add(ChatListLoadingData());
    // _scrollController = ScrollController();
    // _scrollController.addListener(_onScroll);
  }

  String formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp); // Parse the date string
    String formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(dateTime);
    return formattedDate;
  }


  bool server_error = false;
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  ChatModel? chatModel;

  Future<void> _onrefresh() async {
    BlocProvider.of<ChatListBloc>(context).add(ChatListLoadingData());
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
          title: Text("Chat"),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: BlocBuilder<ChatListBloc, ChatListState>(
            builder: (context, state) {

              if (state is ChatListSuccess) {
                return SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onrefresh,
                  child: ListView.builder(
                    // controller: _scrollController,
                    // physics: NeverScrollableScrollPhysics(),
                    itemCount: state.chatListModel.chats!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      String? name = null;
                      String? avatar = null;
                      int another_id = 0;
                      if(user_id == state.chatListModel.chats![index].userOneId){
                        another_id = state.chatListModel.chats![index].userTwoId!;
                        name = state.chatListModel.chats![index].userTwoName.toString();
                        avatar = state.chatListModel.chats![index].userTwoAvatar;
                      }
                      else{
                        another_id = state.chatListModel.chats![index].userOneId!;
                        name = state.chatListModel.chats![index].userOneName.toString();
                        avatar = state.chatListModel.chats![index].userOneAvatar;
                      }
                      return  Column(
                        children: [
                          ListTile(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context) {
                                        return BlocProvider(
                                          create: (ctx) => MessageListBloc(),
                                          child:  OneChatPage(chat_id: state.chatListModel.chats![index].chatId,name: name.toString(),avatar: avatar,my_id: user_id,another_id: another_id,),
                                        );
                                      }));
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => OneChatPage(chat_id: state.chatListModel!.chats![index].chatId,),
                              // ));
                            },
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: avatar != null ? NetworkImage(
                                AppConstans.BASE_URL2 + "images/" +state.chatListModel.chats![index].userOneAvatar.toString(),
                              ) : null,
                              child: avatar == null ? Icon(Icons.person,size: 30,) : SizedBox(),
                            ),
                            title: Text(name,style: TextStyle(fontWeight: FontWeight.bold),),
                            subtitle: state.chatListModel.chats![index].lastMessage == null ? Text("Yangi chat") : Text(state.chatListModel.chats![index].lastMessage.toString()),
                            // title: Text(state.products[index].body
                            //     .toString()),
                            // subtitle: Column(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Text(
                            //       state.products[index].title
                            //           .toString(),
                            //       maxLines: 1,
                            //       overflow: TextOverflow
                            //           .ellipsis,
                            //       style: TextStyle(fontSize: 14),
                            //
                            //     ),
                            //     Text(
                            //       state.products[index].body
                            //           .toString(),
                            //       maxLines: 1,
                            //       overflow: TextOverflow
                            //           .ellipsis,
                            //       style: TextStyle(fontSize: 12),
                            //     ),
                            //   ],
                            // ),
                            trailing: state.chatListModel.chats![index].lastMessage == null ? Text("") : Text(formatTimestamp(state.chatListModel.chats![index].lastMessageCreatedAt.toString()),style: TextStyle(fontSize: 8),),
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
                  ),
                );
              }
              if (state is ChatListError) {
                Center(child: Text("Server connection error"));
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
