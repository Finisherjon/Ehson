import 'dart:async';

import 'package:ehson/bloc/message/message_list_bloc.dart';
import 'package:ehson/constants/constants.dart';
import 'package:ehson/mywidgets/mywidgets.dart';
import 'package:ehson/screen/service/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../api/models/message_list_model.dart';

class OneChatPage extends StatefulWidget {
  final int? chat_id;
  final int my_id;
  final int another_id;
  final String name;
  final String? avatar;

  const OneChatPage({super.key, required this.chat_id,required this.name,required this.avatar,required this.my_id,required this.another_id});

  @override
  _OneChatPageState createState() => _OneChatPageState();
}

class _OneChatPageState extends State<OneChatPage> {
  final List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  final SocketService socketService = SocketService();
  final _scrollController = ScrollController();
  Timer? _debounce;
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      socketService.sendMessage(widget.chat_id.toString(), widget.my_id.toString(), widget.another_id.toString(), _controller.text.toString());
      DateTime now = new DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      final new_msg = new Data(
          chatId: widget.chat_id,
          message:_controller.text.toString(),
          senderId: widget.my_id,
          receiverId: widget.another_id,
          createdAt: formattedDate
      );
      setState(() {
        mes.insert(0,new_msg);
      });
      // setState(() {
      //   messages.insert(
      //     0,
      //     Message(text: _controller.text, isMe: true, time: "10:10 "),
      //   );
      // });
      _controller.clear();
    }
  }

  void connect() {
    socketService.connectToSocket(widget.my_id.toString());

    // Listen for messages and add them to the list
    socketService.socket.on('receiveMessage', (data) {
      String chatId = data['chatId'];
      if(chatId.contains(widget.chat_id.toString())){
        String fromUserId = data['fromUserId'];
        String toUserId = data['toUserId'];
        String message = data['message'];
        DateTime now = new DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
        final new_msg = new Data(
          chatId: widget.chat_id,
          message:message.toString(),
          senderId: int.parse(fromUserId),
          receiverId: int.parse(toUserId),
          createdAt: formattedDate
        );
        setState(() {
          mes.insert(0,new_msg);
        });

      }
      // setState(() {
      //   String fromPhoneNumber = data['fromPhoneNumber'];
      //   String message = data['message'];
      //   messages.add('Message from $fromPhoneNumber: $message');
      // });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connect();
    BlocProvider.of<MessageListBloc>(context).add(ReloadMessageListEvent(chat_id: widget.chat_id!));
    _scrollController.addListener(_onScroll);
  }

  Future<void> _closeSocket() async {
    socketService.socket.close();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _debounce?.cancel();
    _closeSocket();
    super.dispose();
  }

  bool _isNearTop() {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= maxScroll;
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // print(_scrollController.position.pixels);
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      // if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
      //   print("Keldi");
      //   BlocProvider.of<HomeBloc>(context).add(GetProductEvent(date: ""));
      // }
      //mana tayyor
      if (_isNearTop()) {
        context.loaderOverlay.show();
        await Future.delayed(const Duration(milliseconds: 300));
        print("Eng yuqoriga yetildi!");
        BlocProvider.of<MessageListBloc>(context).add(GetMessageListEvent(chat_id: widget.chat_id!));
        await Future.delayed(const Duration(milliseconds: 300));
        context.loaderOverlay.hide();
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent-10,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  List<Data> mes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        centerTitle: true,
        title: Text(widget.name),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(50)),
                    width: 45,
                    height: 45,
                    child: InkWell(
                      onTap: () {},
                      child:widget.avatar == null ? Icon(Icons.person,size: 30,) : Image.network(
                        AppConstans.BASE_URL2 + "images/" + widget.avatar!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: LoaderOverlay(
        child: BlocBuilder<MessageListBloc, MessageListState>(
          builder: (context, state) {
            switch(state.status){
              case MessageList.success:
                // if(state.messages.isEmpty){
                //   return Container(
                //     child: MyWidget().mywidget("Chat bo'sh"),
                //     width: MediaQuery.of(context).size.width,
                //     height: MediaQuery.of(context).size.height * 0.86,
                //   );
                // }
                mes.addAll(state.messages);
                return SafeArea(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          itemCount: mes.length,
                          itemBuilder: (context, index) {
                            return ChatBubble(
                              text: mes[index].message.toString(),
                              isMe: mes[index].senderId == widget.my_id,
                              time: mes[index].createdAt.toString(),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: "Xabar yozing...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                onSubmitted: (value) {
                                  _sendMessage();
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              onPressed: _sendMessage,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              case MessageList.error:
                return Center(
                  child: Text("Internet error"),
                );
              case MessageList.loading:
                return Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  ChatBubble({required this.text, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              color: isMe ? Colors.blueAccent : Colors.grey[300],
              borderRadius: BorderRadius.circular(10.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final String text;
  final bool isMe;
  final String time;

  Message({required this.text, required this.isMe, required this.time});
}
