import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ehson/api/models/create_chat_model.dart';
import 'package:ehson/bloc/get_one_help/get_one_help_bloc.dart';
import 'package:ehson/bloc/message/message_list_bloc.dart';
import 'package:ehson/bloc/yordam_bloc/yordam_bloc.dart';
import 'package:ehson/screen/chat/one_chat.dart';
import 'package:ehson/screen/help_info/help_info.dart';
import 'package:ehson/screen/yordam/add_yordam.dart';
import 'package:ehson/screen/yordam/location.dart';
import 'package:ehson/screen/yordam/show_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/models/user_model.dart';
import '../../api/models/yordam_model.dart';
import '../../api/repository.dart';
import '../../constants/constants.dart';
import '../../mywidgets/mywidgets.dart';

class Yordam extends StatefulWidget {
  const Yordam({super.key});

  @override
  State<Yordam> createState() => _YordamState();
}

//endi buyogini ui uzin tugirla
//home screendan kurib tugirlaysan
//yordam page shu xay
//block tayyor endi uni ishlatish kerak shuyogiga urna qani xay

//add yordam borku ushanga lokatsiyani qerligi emas lat long save qilish kerak apiga lat long ni post qil xay

class _YordamState extends State<Yordam> {

  LatLng? _selectedLocation;
  Timer? _debounce;
  final _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPrefs();
    BlocProvider.of<YordamBloc>(context).add(ReloadYordamEvent(date: ""));
    _scrollController.addListener(_onScroll);
  }
  Future<void> create_chat(int user_one,int user_two)async{
    if(user_one == user_id && user_two == user_id){
      Fluttertoast.showToast(
          msg: "O'zingiz bilan chat qura olmaysiz!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    else{
      context.loaderOverlay.show();
      try{
        CreateChatModel? createChatModel = await EhsonRepository().create_my_chat(user_one,user_two);
        if(createChatModel!=null){
          String name = createChatModel.chat!.userOneId == user_id ? createChatModel.chat!.userTwoName.toString() : createChatModel.chat!.userOneName.toString();
          String avatar = createChatModel.chat!.userOneId == user_id ? createChatModel.chat!.userTwoAvatar.toString() : createChatModel.chat!.userOneAvatar.toString();
          int? another_id = createChatModel.chat!.userOneId == user_id ? createChatModel.chat!.userTwoId : createChatModel.chat!.userOneId;
          Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) {
                    return BlocProvider(
                      create: (ctx) => MessageListBloc(),
                      child:  OneChatPage(chat_id: createChatModel.chat!.chatId,name: name.toString(),avatar: avatar,my_id: user_id,another_id: another_id ?? 0,),
                    );
                  }));
        } else {
          Fluttertoast.showToast(
              msg: "Serverda xatolik qayta urunib ko'ring!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);

        }
        context.loaderOverlay.hide();
      }
      catch (e) {
        context.loaderOverlay.hide();
        Fluttertoast.showToast(
            msg: "Serverda xatolik qayta urunib ko'ring!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

  }

  void makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch $phoneNumber');
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<bool> delete_help(int? help_id) async {
    String add_like = await EhsonRepository().delete_help(help_id);
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

  bool _isNearBottom() {
    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent == 0) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  int user_id = 0;
  bool admin = false;

  Future<void> getSharedPrefs() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    //tokenni login qigan paytimiz sharedga saqlab qoyganbiza
    final SharedPreferences prefs = await _prefs;
    setState(() {
      user_id = prefs.getInt("user_id") ?? 0;
      admin = prefs.getBool("admin") ?? false;
    });
  }


  void _onScroll() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_isNearBottom()) {
        print("Keldi");
        BlocProvider.of<YordamBloc>(context).add(GetYordamEvent(date: ""));
      }
    });
  }

  bool server_error = false;
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  YordamModel? yordamModel;




  //yordamga pastdan yuqoriga tushirsa refresh qiladigani qo'shopsanmi?
  //buni oso yuli boku
  //nimaga boshiga 2 ta chiqoropti serverdan bitta keloptiku
  Future<void> _onrefresh() async {
    //hozircha push qilchi anabu yordamni bitta tugirlayman uzim push qilchi
    //yana nima qmoqchisan kn anabu profil qitti bowqacha darrav save chiqadi hechnimadan oldin kn ikkaviyam birxil buladi norm
    //shuni choqirsan buldi uzi hamma olinganlarni tozalab qayta olishga zapros yuboradi kurdinmi ososngina
    BlocProvider.of<YordamBloc>(context).add(ReloadYordamEvent(date: ""));
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                builder: (context) => AddYordam(),
              ),
            );
          }),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Yordam"),
      ),
      body: LoaderOverlay(
        child: SafeArea(
          child: SmartRefresher(
            onRefresh: _onrefresh,
            controller: _refreshController,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<YordamBloc, YordamState>(
                builder: (context, state) {
                  switch (state.status) {
                    case YordamProduct.loading:
                      return Center(
                        child: CircularProgressIndicator(),
                      );

                      //nimani taxlayopsan? maanbu profilga kirsa bunam buladiku shuni taxlaykondim
                    case YordamProduct.success:
                      if (state.products.isEmpty) {
                        return Container(
                          child: MyWidget().mywidget("Hech narsa topilmadi!"),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.86,
                        );
                      }
                      return ListView.builder(
                          controller: _scrollController,
                          itemCount: state.islast
                              ? state.products.length
                              : state.products.length + 1,
                          itemBuilder: (context, index) {
                            return index >= state.products.length
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Column(
                                  children: [
                                    ListTile(
                                      onTap: (){
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                            return BlocProvider(
                                                              create: (ctx) =>
                                                                  GetOneHelpBloc(),
                                                              child: HelpInfo(
                                                                help_id: state
                                                                    .products[index].id!,
                                                              )
                                                            );
                                                          }));
                                      },
                                      shape: Border(
                                        bottom: BorderSide(
                                          width: 0.1
                                        ),
                                      ),
                                      trailing: admin || state.products[index].userId == user_id ? IconButton(icon: Icon(Icons.delete,color: Colors.red,),
                                      onPressed: (){
                                        Dialogs.materialDialog(
                                            color: Colors.white,
                                            msg: "Ushbu "+state.products[index].title.toString()+" nomli mahsulotni o'chirishni xoxlaysizmi?",
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

                                                  int? help_id = state.products[index].id;
                                                  bool
                                                  delete_p =
                                                  await delete_help(
                                                      help_id);

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
                                    leading:  state.products[index].img == null || state.products[index].img == ""
                                      ?   ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: MediaQuery.of(context).size.width*0.2,
                                      maxWidth: MediaQuery.of(context).size.width*0.2,
                                    ),
                                    child: MyWidget().defimagehelpwidget(context),)
                                      :CachedNetworkImage(
                                      imageUrl:AppConstans.BASE_URL2 + "images/" +state.products[index].img.toString(),
                                      placeholder: (context, url) => CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              minWidth: MediaQuery.of(context).size.width*0.2,
                                              maxWidth: MediaQuery.of(context).size.width*0.2,
                                            ),
                                            child: MyWidget().defimagehelpwidget(context),)
                                                                ),
                                                                title: Text(state.products[index].title.toString(),style: TextStyle(fontSize: 18),maxLines: 1,),
                                                                subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(state.products[index].info.toString(),style: TextStyle(fontSize: 16),maxLines: 2,),
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.end,
                                      //   children: [
                                      //     CircleAvatar(backgroundColor: Colors.white,child: IconButton(  onPressed:
                                      //         () {
                                      //       if(state
                                      //           .products[index]
                                      //           .phone != null){
                                      //         Dialogs.materialDialog(
                                      //             color: Colors.white,
                                      //             msg: "Telefon raqam orqali bog'lanishni xoxlaysizmi?",
                                      //             titleStyle: TextStyle(fontSize: 20),
                                      //             titleAlign: TextAlign.center,
                                      //             title: "Mehr",
                                      //             customViewPosition: CustomViewPosition.BEFORE_ACTION,
                                      //             context: context,
                                      //             actions: [
                                      //               TextButton(onPressed: (){
                                      //                 Navigator.pop(context);
                                      //               }, child: Text("Orqaga qaytish")),
                                      //               IconsButton(
                                      //                 onPressed: () async{
                                      //                   makePhoneCall(state
                                      //                       .products[index]
                                      //                       .phone!);
                                      //                 },
                                      //                 text: 'Telefon qilish',
                                      //                 // iconData: Icons.done,
                                      //                 color: Colors.blue,
                                      //                 textStyle: TextStyle(color: Colors.white),
                                      //                 iconColor: Colors.white,
                                      //               ),
                                      //             ]);
                                      //       }
                                      //       else{
                                      //         Fluttertoast.showToast(
                                      //             msg: "Bu foydalanuvchi telefon raqamini hali kiritmagan!",
                                      //             toastLength: Toast.LENGTH_SHORT,
                                      //             gravity: ToastGravity.BOTTOM,
                                      //             timeInSecForIosWeb: 1,
                                      //             backgroundColor: Colors.red,
                                      //             textColor: Colors.white,
                                      //             fontSize: 16.0);
                                      //       }
                                      //     }, icon: Icon(Icons.phone,color: Colors.green,))),
                                      //     CircleAvatar(backgroundColor: Colors.white,child: IconButton(onPressed:
                                      //         () {
                                      //       Dialogs.materialDialog(
                                      //           color: Colors.white,
                                      //           msg: "Chatni boshlashni xoxlaysizmi?",
                                      //           titleStyle: TextStyle(fontSize: 18),
                                      //           titleAlign: TextAlign.center,
                                      //           title: "Mehr",
                                      //           customViewPosition: CustomViewPosition.BEFORE_ACTION,
                                      //           context: context,
                                      //           actions: [
                                      //             TextButton(onPressed: (){
                                      //               Navigator.pop(context);
                                      //             }, child: Text("Orqaga qaytish")),
                                      //             IconsButton(
                                      //               onPressed: () async{
                                      //                 Navigator.pop(context);
                                      //                 await create_chat(user_id,state.products[index].userId ?? 0);
                                      //               },
                                      //               text: 'Chatni boshlash',
                                      //               // iconData: Icons.done,
                                      //               color: Colors.blue,
                                      //               textStyle: TextStyle(color: Colors.white),
                                      //               iconColor: Colors.white,
                                      //             ),
                                      //           ]);
                                      //     }, icon: Icon(Icons.chat,color: Colors.blue,))),
                                      //     CircleAvatar(backgroundColor: Colors.white,child: IconButton(onPressed: ()async{
                                      //     Navigator
                                      //               .push(
                                      //         context,
                                      //         MaterialPageRoute(
                                      //           builder:
                                      //               (context) =>
                                      //                   ShowLocationScreen(location: state.products[index].location.toString()),
                                      //         ),
                                      //       );
                                      //     }, icon: Icon(Icons.location_on_sharp,color: Colors.red,))),
                                      //   ],
                                      // ),
                                      SizedBox(height: 5,),
                                    ],
                                                                ),
                                                              ),

                                  ],
                                );

                                // : Container(
                                //     height:
                                //         MediaQuery.of(context).size.height * 0.20,
                                //     child: Padding(
                                //       padding:
                                //           const EdgeInsets.symmetric(horizontal: 5),
                                //       child: InkWell(
                                //         borderRadius: BorderRadius.circular(15),
                                //         onTap: () {
                                //           Navigator.of(context)
                                //               .push(MaterialPageRoute(
                                //               builder: (context) => HelpInfo(
                                //                 help_id: state
                                //                     .products[index].id!,
                                //               )));
                                //         },
                                //         child: Card(
                                //           // shadowColor: Colors.black,
                                //           color: Colors.white,
                                //           child: Row(
                                //             children: [
                                //               Container(
                                //                 width: MediaQuery.of(context)
                                //                         .size
                                //                         .width *
                                //                     0.37,
                                //                 child: Stack(
                                //                   children: [
                                //                     Column(
                                //                       mainAxisAlignment:
                                //                           MainAxisAlignment.center,
                                //                       children: [
                                //                         Padding(
                                //                           padding: const EdgeInsets.all(8.0),
                                //                           child: Text(
                                //                             maxLines: 1,
                                //                             overflow: TextOverflow.ellipsis,
                                //                             state
                                //                                 .products[index].title
                                //                                 .toString(),
                                //                             style: GoogleFonts.roboto(
                                //                               textStyle: TextStyle(
                                //                                   fontSize: 15,
                                //                                   fontWeight:
                                //                                       FontWeight
                                //                                           .bold),
                                //                             ),
                                //                           ),
                                //                         ),
                                //                         SizedBox(
                                //                           width:
                                //                               MediaQuery.of(context)
                                //                                       .size
                                //                                       .width *
                                //                                   0.3,
                                //                           child: Divider(
                                //                             color: Colors.grey[400],
                                //                           ),
                                //                         ),
                                //                         Padding(
                                //                           padding: const EdgeInsets.all(8.0),
                                //                           child: Text(
                                //                             state.products[index].info
                                //                                 .toString(),
                                //                             maxLines: 2,
                                //                             overflow:
                                //                                 TextOverflow.ellipsis,
                                //                             style: GoogleFonts.roboto(
                                //                               textStyle: TextStyle(
                                //                                 fontSize: 10,
                                //                               ),
                                //                             ),
                                //                           ),
                                //                         ),
                                //                       ],
                                //                     ),
                                //                     // SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                                //                     Positioned(
                                //                       left: 6,
                                //                       bottom: 1,
                                //                       child: Row(
                                //                         mainAxisAlignment:
                                //                             MainAxisAlignment.start,
                                //                         crossAxisAlignment:
                                //                             CrossAxisAlignment
                                //                                 .start,
                                //                         children: [
                                //                           Container(
                                //                             height: 30,
                                //                             width: 30,
                                //                             decoration:
                                //                                 BoxDecoration(
                                //                               color: Colors.white,
                                //                               shape:
                                //                                   BoxShape.circle,
                                //                             ),
                                //                             alignment:
                                //                                 Alignment.center,
                                //                             child: IconButton(
                                //                               style: IconButton
                                //                                   .styleFrom(
                                //                                 minimumSize:
                                //                                     Size.zero,
                                //                                 padding:
                                //                                     EdgeInsets.zero,
                                //                               ),
                                //                               onPressed: () {},
                                //                               icon: Icon(
                                //                                 Icons.phone,
                                //                                 color: Colors.green,
                                //                                 size: 20,
                                //                               ),
                                //                             ),
                                //                           ),
                                //                           // SizedBox(height: 8),
                                //                           Container(
                                //                             height: 30,
                                //                             width: 30,
                                //                             decoration:
                                //                                 BoxDecoration(
                                //                               color: Colors.white,
                                //                               shape:
                                //                                   BoxShape.circle,
                                //                             ),
                                //                             alignment:
                                //                                 Alignment.center,
                                //                             child: IconButton(
                                //                               style: IconButton
                                //                                   .styleFrom(
                                //                                 minimumSize:
                                //                                     Size.zero,
                                //                                 padding:
                                //                                     EdgeInsets.zero,
                                //                               ),
                                //                               onPressed: () {},
                                //                               icon: Icon(
                                //                                 Icons.chat,
                                //                                 color: Colors
                                //                                     .blueAccent,
                                //                                 size: 20,
                                //                               ),
                                //                             ),
                                //                           ),
                                //                           // SizedBox(height: 8),
                                //                           Container(
                                //                             height: 30,
                                //                             width: 30,
                                //                             decoration:
                                //                                 BoxDecoration(
                                //                               color: Colors.white,
                                //                               shape:
                                //                                   BoxShape.circle,
                                //                             ),
                                //                             alignment:
                                //                                 Alignment.center,
                                //                             child: IconButton(
                                //                               style: IconButton
                                //                                   .styleFrom(
                                //                                 minimumSize:
                                //                                     Size.zero,
                                //                                 padding:
                                //                                     EdgeInsets.zero,
                                //                               ),
                                //                               onPressed: () async {
                                //                                 // final result =
                                //                                 //     await Navigator
                                //                                 //         .push(
                                //                                 //   context,
                                //                                 //   MaterialPageRoute(
                                //                                 //     builder:
                                //                                 //         (context) =>
                                //                                 //             Location(),
                                //                                 //   ),
                                //                                 // );
                                //                                 //
                                //                                 // if (result !=
                                //                                 //     null) {
                                //                                 //   setState(() {
                                //                                 //     _selectedLocation =
                                //                                 //         result;
                                //                                 //   });
                                //                                 // }
                                //                               },
                                //                               icon: Icon(
                                //                                 Icons.location_on,
                                //                                 color: Colors.red,
                                //                                 size: 20,
                                //                               ),
                                //                             ),
                                //                           ),
                                //                         ],
                                //                       ),
                                //                     ),
                                //                   ],
                                //                 ),
                                //               ),
                                //               Container(
                                //                 width: MediaQuery.of(context)
                                //                         .size
                                //                         .width *
                                //                     0.54,
                                //                 child: ClipRRect(
                                //                   borderRadius:
                                //                       BorderRadius.circular(12),
                                //                   // child: Image.network(
                                //                   //   state.products[index].img,
                                //                   //   "https://www.shutterstock.com/image-photo/two-poor-african-children-front-600nw-2123588717.jpg",
                                //                   //   fit: BoxFit.cover,
                                //                   // ),
                                //
                                //                   child: asosiy_img == null &&
                                //                           state.products.length >
                                //                               index
                                //                       ? Image.network(
                                //                           "https://www.shutterstock.com/image-photo/two-poor-african-children-front-600nw-2123588717.jpg",
                                //                           // "images/1722061202.jpg",
                                //                           fit: BoxFit.cover,
                                //                         )
                                //                       : Image.network(
                                //                           AppConstans.BASE_URL2 +
                                //                               "/images/" +
                                //                               asosiy_img!,
                                //                           fit: BoxFit.cover,
                                //                         ),
                                //                 ),
                                //
                                //                 //polvon ui ni tugirlang lekn norm edi xay qayti kuraman
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   );
                          });
                    case YordamProduct.error:
                      return Center(
                        child: Text("Internet error"),
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
