import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ehson/adjust_size.dart';
import 'package:ehson/api/models/create_chat_model.dart';
import 'package:ehson/bloc/add_product/add_product_bloc.dart';
import 'package:ehson/bloc/filter_product/filter_product_bloc.dart';
import 'package:ehson/bloc/get_filter_product/get_filter_product_bloc.dart';
import 'package:ehson/bloc/get_one_product/get_one_product_bloc.dart';
import 'package:ehson/bloc/homebloc/home_bloc.dart';
import 'package:ehson/bloc/message/message_list_bloc.dart';
import 'package:ehson/bloc/search_product/search_product_bloc.dart';
import 'package:ehson/bloc/yordam_bloc/yordam_bloc.dart';
import 'package:ehson/constants/constants.dart';
import 'package:ehson/mywidgets/mywidgets.dart';
import 'package:ehson/screen/add_product/screen/add_product_screen.dart';
import 'package:ehson/screen/chat/one_chat.dart';
import 'package:ehson/screen/filter/filter_screen.dart';
import 'package:ehson/screen/product_info/product_info.dart';
import 'package:ehson/screen/profile/profile.dart';
import 'package:ehson/screen/yordam/yordam.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/models/product_model.dart';
import '../../api/repository.dart';
import '../search_page.dart';
import '../verification/log_In_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();

      final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      final SharedPreferences prefs = await _prefs;
      prefs.setBool("regstatus", false);
      prefs.setString("email", '');
      prefs.setString("name", '');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return true;
    } on Exception catch (_) {
      return false;
    }
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

  //shera norm qilib chiqor mahsulotlani ui taxla olxdanam dizayn ol manam tashagandan ol rasmla borediku ui qilivur image bilan productni qushadigani qilamiz
  Future<bool> add_like_product(int? product_id) async {
    String add_like = await EhsonRepository().add_like(product_id);
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

  Future<bool> delete_product(int? product_id) async {
    String add_like = await EhsonRepository().delete_product(product_id);
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

  bool _heartIcon = false;

  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPrefs();
    BlocProvider.of<HomeBloc>(context).add(ReloadProductEvent(date: ""));
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

  //hulayam esdan chiqmasin
  //home block emas yordam block buladi reloadproductevent emas reloadyordam event buladi shulaga etibor ber

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
    // print(_scrollController.position.pixels);
    _debounce = Timer(const Duration(milliseconds: 300), () {
      // if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
      //   print("Keldi");
      //   BlocProvider.of<HomeBloc>(context).add(GetProductEvent(date: ""));
      // }
      //mana tayyor
      if (_isNearBottom()) {
        print("Keldi");
        BlocProvider.of<HomeBloc>(context).add(GetProductEvent(date: ""));
      }
    });
  }

  // void _launchURL(Uri uri, bool inApp) async {
  //   try {
  //     if (await canLaunchUrl(uri)) {
  //       if (inApp) {
  //         await launchUrl(uri, mode: LaunchMode.inAppWebView);
  //       } else {
  //         await launchUrl(uri, mode: LaunchMode.externalApplication);
  //       }
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  void makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch $phoneNumber');
    }
  }
  bool server_error = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ProductModel? productModel;

  Future<void> _onrefresh() async {
    BlocProvider.of<HomeBloc>(context).add(ReloadProductEvent(date: ""));
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      //bottombardayn yoq u avvalam shunay bulib utirodi kuproq rasm quwib billim
      child: LoaderOverlay(
        child: Scaffold(
          body: SmartRefresher(
            onRefresh: _onrefresh,
            controller: _refreshController,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: Sizes.heights(context) * 0.005,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        //nima qimoqchisan pasroqa tushurdim bul
                        IconButton(
                          icon: Icon(
                            Icons.person,
                            size: IconSize.largeIconSize(context),
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => Profile()));
                          },
                        ),
                        Expanded(
                          // decoration: BoxDecoration(
                          //   borderRadius: BorderRadius.circular(15),
                          // ),

                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return BlocProvider(
                                  create: (ctx) => SearchProductBloc(),
                                  child: SearchPage(),
                                );
                              }));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: Colors.grey),
                                  SizedBox(width: 8.0),
                                  Text('Nima qidiryapsiz',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            // Container(
                            //   height: Sizes.heights(context) * 0.066,
                            //   child: TextFormField(
                            //     autofocus: false,
                            //     decoration: InputDecoration(
                            //       hintText: 'Nimani qidiryapsiz?',
                            //       hintStyle: TextStyle(color: Colors.grey),
                            //       border: OutlineInputBorder(
                            //         borderRadius:
                            //             BorderRadius.all(Radius.circular(20.0)),
                            //         borderSide: BorderSide(color: Colors.white),
                            //       ),
                            //       prefixIcon: Icon(
                            //         Icons.search,
                            //         color: Colors.grey,
                            //         size: IconSize.smallIconSize(context),
                            //       ),
                            //     ),
                            //     style: TextStyle(color: Colors.grey),
                            //     onChanged: (query) {},
                            //   ),
                            // ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.filter_alt,
                            size: IconSize.largeIconSize(context),
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => FilterScreen(),
                            //   ),
                            // );

                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return BlocProvider(
                                    create: (ctx) => GetFilterProductBloc(),
                                    child: FilterScreen(),
                                  );
                                }));
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Sizes.heights(context) * 0.005,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: Sizes.widths(context) * 0.4,
                        height: Sizes.heights(context) * 0.07,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent),
                          onPressed: () {},
                          child: Text(
                            "Xayriya",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigator.of(context).push(
                            //     MaterialPageRoute(builder: (context) => Yordam()));
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return BlocProvider(
                                create: (ctx) => YordamBloc(),
                                child: Yordam(),
                              );
                            }));
                          },
                          child: Text(
                            "Yordam",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //mana shu home screen va home blockdan kuchir xuddi shunay buladi faqat model boshqa
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BlocBuilder<HomeBloc, ProductState>(
                      builder: (context, state) {
                        switch (state.status) {
                          case Product.loading:
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          case Product.success:
                            if (state.products.isEmpty) {
                              return Container(
                                child: MyWidget().mywidget("Hech narsa topilmadi!"),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * 0.86,
                              );
                            }
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.707,
                              child: MasonryGridView.count(
                                  controller: _scrollController,
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  crossAxisSpacing: 15,
                                  crossAxisCount: 2,
                                  itemCount: state.islast
                                      ? state.products.length
                                      : state.products.length + 2,
                                  scrollDirection: Axis.vertical,
                                  mainAxisSpacing: 10,
                                  itemBuilder: (BuildContext context, index) {
                                    if (index >= state.products.length) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    //telefonchani bosa endi telefon raqam bod api bilan kelopti
                                    //bulimi? ha zabanca
                                    String? asosiy_img;
                                    if (state.products.length > index) {
                                      if (state.products[index].img1 != null) {
                                        asosiy_img = state.products[index].img1;
                                      } else if (state.products[index].img2 !=
                                          null) {
                                        asosiy_img = state.products[index].img2;
                                      } else if (state.products[index].img3 !=
                                          null) {
                                        asosiy_img = state.products[index].img3;
                                      } else {
                                        asosiy_img = null;
                                      }
                                    }
                                    return index >= state.products.length
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : Container(
                                            child: Stack(
                                              children: [
                                                InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 5,
                                                          spreadRadius: 1,
                                                          offset:
                                                              const Offset(1, 1),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                          child: Stack(
                                                            children: [
                                                              asosiy_img ==
                                                                          null &&
                                                                      state.products
                                                                              .length >
                                                                          index
                                                                  ? MyWidget().defimagewidget(context)
                                                              :CachedNetworkImage(
                                                                imageUrl:AppConstans.BASE_URL2 + "images/" + asosiy_img!,
                                                                placeholder: (context, url) => Container(
                                                                    width: MediaQuery.of(context).size.width*0.5,
                                                                    height:MediaQuery.of(context).size.height*0.2,
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        CircularProgressIndicator(),
                                                                      ],
                                                                    )
                                                                ),
                                                                errorWidget: (context, url, error) =>
                                                                    MyWidget().defimagewidget(context)
                                                              ),
                                                              admin || user_id == state.products[index].userId ?  Positioned(
                                                                left: 10,
                                                                top: 10,
                                                                child: Container(
                                                                  height: Sizes
                                                                      .heights(
                                                                      context) *
                                                                      0.04,
                                                                  width: Sizes.widths(
                                                                      context) *
                                                                      0.07,
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                  Alignment
                                                                      .center,
                                                                  child:
                                                                  IconButton(
                                                                    style: IconButton
                                                                        .styleFrom(
                                                                      minimumSize:
                                                                      Size.zero,
                                                                      padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                    ),
                                                                    onPressed:
                                                                        () async {
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

                                                                                    int? product_id = state
                                                                                        .products[
                                                                                    index]
                                                                                        .id;
                                                                                    bool
                                                                                    delete_p =
                                                                                    await delete_product(
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

                                                                    },
                                                                    //productlani oladigan api borku uwani uzgartiramiz man usha productga like bosganmi yoqmi ushaniyam beraman keyen usha bilan aniqlaymiz
                                                                    icon: Icon(
                                                                      Icons.delete,
                                                                      color: Colors.redAccent,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ):SizedBox(),
                                                              Positioned(
                                                                right: 10,
                                                                top: 10,
                                                                child: Container(
                                                                  height: Sizes
                                                                          .heights(
                                                                              context) *
                                                                      0.04,
                                                                  width: Sizes.widths(
                                                                          context) *
                                                                      0.07,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child:
                                                                      IconButton(
                                                                    style: IconButton
                                                                        .styleFrom(
                                                                      minimumSize:
                                                                          Size.zero,
                                                                      padding:
                                                                          EdgeInsets
                                                                              .zero,
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                          context.loaderOverlay.show();

                                                                          int? product_id = state
                                                                          .products[
                                                                              index]
                                                                          .id;
                                                                      bool
                                                                          add_like =
                                                                          await add_like_product(
                                                                              product_id);

                                                                      if (add_like) {
                                                                        state
                                                                            .products[
                                                                                index]
                                                                            .isliked = state.products[index].isliked ==
                                                                                0
                                                                            ? 1
                                                                            : 0;
                                                                      }

                                                                          setState(
                                                                          () {
                                                                        _heartIcon =
                                                                            !_heartIcon;
                                                                      });
                                                                          context.loaderOverlay.hide();

                                                                        },
                                                                    //productlani oladigan api borku uwani uzgartiramiz man usha productga like bosganmi yoqmi ushaniyam beraman keyen usha bilan aniqlaymiz
                                                                    icon: Icon(
                                                                      state.products[index].isliked ==
                                                                              1
                                                                          ? Icons
                                                                              .favorite
                                                                          : Icons
                                                                              .favorite_border,
                                                                      color: Colors
                                                                          .red,
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                right: 10,
                                                                bottom: 10,
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      height: Sizes.heights(
                                                                              context) *
                                                                          0.037,
                                                                      width: Sizes.widths(
                                                                              context) *
                                                                          0.077,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          IconButton(
                                                                        style: IconButton
                                                                            .styleFrom(
                                                                          minimumSize:
                                                                              Size.zero,
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                              Dialogs.materialDialog(
                                                                                  color: Colors.white,
                                                                                  msg: "Chatni boshlashni xoxlaysizmi?",
                                                                                  titleStyle: TextStyle(fontSize: 18),
                                                                                  titleAlign: TextAlign.center,
                                                                                  title: "Mehr",
                                                                                  customViewPosition: CustomViewPosition.BEFORE_ACTION,
                                                                                  context: context,
                                                                                  actions: [
                                                                                    TextButton(onPressed: (){
                                                                                      Navigator.pop(context);
                                                                                    }, child: Text("Orqaga qaytish")),
                                                                                    IconsButton(
                                                                                      onPressed: () async{
                                                                                        Navigator.pop(context);
                                                                                        await create_chat(user_id,state.products[index].userId ?? 0);
                                                                                      },
                                                                                      text: 'Chatni boshlash',
                                                                                      // iconData: Icons.done,
                                                                                      color: Colors.blue,
                                                                                      textStyle: TextStyle(color: Colors.white),
                                                                                      iconColor: Colors.white,
                                                                                    ),
                                                                                  ]);
                                                                            },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .chat,
                                                                          color: Colors
                                                                              .blue,
                                                                          size: IconSize.smallIconSize(
                                                                              context),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            8),
                                                                    Container(
                                                                      height: Sizes.heights(
                                                                              context) *
                                                                          0.04,
                                                                      width: Sizes.widths(
                                                                              context) *
                                                                          0.08,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          IconButton(
                                                                        style: IconButton
                                                                            .styleFrom(
                                                                          minimumSize:
                                                                              Size.zero,
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                        ),
                                                                            onPressed:
                                                                                () {
                                                                              if(state
                                                                                  .products[index]
                                                                                  .phone != null){
                                                                                Dialogs.materialDialog(
                                                                                    color: Colors.white,
                                                                                    msg: "Telefon raqam orqali bog'lanishni xoxlaysizmi?",
                                                                                    titleStyle: TextStyle(fontSize: 20),
                                                                                    titleAlign: TextAlign.center,
                                                                                    title: "Mehr",
                                                                                    customViewPosition: CustomViewPosition.BEFORE_ACTION,
                                                                                    context: context,
                                                                                    actions: [
                                                                                      TextButton(onPressed: (){
                                                                                        Navigator.pop(context);
                                                                                      }, child: Text("Orqaga qaytish")),
                                                                                      IconsButton(
                                                                                        onPressed: () async{
                                                                                          makePhoneCall(state
                                                                                              .products[index]
                                                                                              .phone!);
                                                                                        },
                                                                                        text: 'Telefon qilish',
                                                                                        // iconData: Icons.done,
                                                                                        color: Colors.blue,
                                                                                        textStyle: TextStyle(color: Colors.white),
                                                                                        iconColor: Colors.white,
                                                                                      ),
                                                                                    ]);
                                                                              }
                                                                              else{
                                                                                Fluttertoast.showToast(
                                                                                    msg: "Bu foydalanuvchi telefon raqamini hali kiritmagan!",
                                                                                    toastLength: Toast.LENGTH_SHORT,
                                                                                    gravity: ToastGravity.BOTTOM,
                                                                                    timeInSecForIosWeb: 1,
                                                                                    backgroundColor: Colors.red,
                                                                                    textColor: Colors.white,
                                                                                    fontSize: 16.0);
                                                                              }
                                                                            },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .phone,
                                                                          color: Colors
                                                                              .green,
                                                                          size: IconSize.smallIconSize(
                                                                              context),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 8,
                                                                  right: 8,
                                                                  top: 8),
                                                          child: Text(
                                                            state.products[index]
                                                                .title!,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            maxLines: 1,
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                          ),
                                                        ),
                                                         Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 8,
                                                                  right: 8,
                                                                  top: 8),
                                                          child: Text(state.products[index].info.toString(),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                              return BlocProvider(
                                                                create: (ctx) =>
                                                                    GetOneProductBloc(),
                                                                child: ProductInfo(
                                                                    product_id: state
                                                                        .products[
                                                                    index]!
                                                                        .id!),
                                                              );
                                                            }));
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                  }),
                            );
                          //   GridView.builder(
                          //   gridDelegate:
                          //       SliverGridDelegateWithFixedCrossAxisCount(
                          //     crossAxisCount: 2,
                          //     crossAxisSpacing: 15,
                          //     mainAxisSpacing: 10,
                          //     childAspectRatio: 0.65,
                          //   ),
                          //   // controller: _scrollController,
                          //   itemCount: state.islast
                          //       ? state.products.length
                          //       : state.products.length + 2,
                          //   scrollDirection: Axis.vertical,
                          //   shrinkWrap: true,
                          //   physics: NeverScrollableScrollPhysics(),
                          //   itemBuilder: (context, index) {
                          //     String? asosiy_img;
                          //     if (state.products.length > index) {
                          //       if (state.products[index].img1 != null) {
                          //         asosiy_img = state.products[index].img1;
                          //       } else if (state.products[index].img2 != null) {
                          //         asosiy_img = state.products[index].img2;
                          //       } else if (state.products[index].img3 != null) {
                          //         asosiy_img = state.products[index].img3;
                          //       } else {
                          //         asosiy_img = null;
                          //       }
                          //     }
                          //     return index >= state.products.length
                          //         ? Center(
                          //             child: CircularProgressIndicator(),
                          //           )
                          //         : InkWell(
                          //             child: Container(
                          //               // height: MediaQuery.of(context).size.height*0.05,
                          //               padding: EdgeInsets.only(bottom: 10),
                          //               decoration: BoxDecoration(
                          //                 borderRadius: BorderRadius.circular(25),
                          //                 color: Colors.white,
                          //                 boxShadow: [
                          //                   BoxShadow(
                          //                     color:
                          //                         Colors.black.withOpacity(0.1),
                          //                     blurRadius: 5,
                          //                     spreadRadius: 1,
                          //                     offset: const Offset(1, 1),
                          //                   ),
                          //                 ],
                          //               ),
                          //               //dizayn qichiq buliptiku
                          //               child: Container(
                          //                 decoration: BoxDecoration(
                          //                   borderRadius:
                          //                       BorderRadius.circular(25),
                          //                 ),
                          //                 child: Flex(
                          //                   crossAxisAlignment:
                          //                       CrossAxisAlignment.start,
                          //                   direction: Axis.vertical,
                          //                   children: [
                          //                     Expanded(
                          //                       child: Stack(
                          //                         //boli meni normalniy
                          //                         children: [
                          //                           Padding(
                          //                             padding:
                          //                                 const EdgeInsets.all(
                          //                                     5.0),
                          //                             child: Center(
                          //                               child: asosiy_img ==
                          //                                           null &&
                          //                                       state.products
                          //                                               .length >
                          //                                           index
                          //                                   ? Image.network(
                          //                                       AppConstans
                          //                                               .BASE_URL2 +
                          //                                           "images/1722061202.jpg",
                          //                                       fit: BoxFit
                          //                                           .fitHeight,
                          //                                     )
                          //                                   : Image.network(
                          //                                       AppConstans
                          //                                               .BASE_URL2 +
                          //                                           "images/" +
                          //                                           asosiy_img!,
                          //                                       fit: BoxFit
                          //                                           .fitHeight,
                          //                                     ),
                          //                             ),
                          //                           ),
                          //                           Positioned(
                          //                             right: 10,
                          //                             top: 10,
                          //                             child: Container(
                          //                               height: 30,
                          //                               width: 30,
                          //                               decoration: BoxDecoration(
                          //                                 color: Colors.white,
                          //                                 shape: BoxShape.circle,
                          //                               ),
                          //                               alignment:
                          //                                   Alignment.center,
                          //                               child: IconButton(
                          //                                 style: IconButton
                          //                                     .styleFrom(
                          //                                   minimumSize:
                          //                                       Size.zero,
                          //                                   padding:
                          //                                       EdgeInsets.zero,
                          //                                 ),
                          //                                 onPressed: () async {
                          //                                   setState(() {
                          //                                     _heartIcon =
                          //                                         !_heartIcon;
                          //                                   });
                          //                                 },
                          //                                 icon: Icon(
                          //                                   _heartIcon
                          //                                       ? Icons.favorite
                          //                                       : Icons
                          //                                           .favorite_border,
                          //                                   color: Colors.red,
                          //                                   size: 20,
                          //                                 ),
                          //                               ),
                          //                             ),
                          //                           ),
                          //                           Positioned(
                          //                             right: 10,
                          //                             bottom: 10,
                          //                             child: Column(
                          //                               children: [
                          //                                 Container(
                          //                                   height: 30,
                          //                                   width: 30,
                          //                                   decoration:
                          //                                       BoxDecoration(
                          //                                     color: Colors.white,
                          //                                     shape:
                          //                                         BoxShape.circle,
                          //                                   ),
                          //                                   alignment:
                          //                                       Alignment.center,
                          //                                   child: IconButton(
                          //                                     style: IconButton
                          //                                         .styleFrom(
                          //                                       minimumSize:
                          //                                           Size.zero,
                          //                                       padding:
                          //                                           EdgeInsets
                          //                                               .zero,
                          //                                     ),
                          //                                     onPressed: () {},
                          //                                     icon: Icon(
                          //                                       Icons.chat,
                          //                                       color:
                          //                                           Colors.blue,
                          //                                       size: 20,
                          //                                     ),
                          //                                   ),
                          //                                 ),
                          //                                 SizedBox(height: 8),
                          //                                 // Orasidagi bo'sh joy
                          //                                 Container(
                          //                                   height: 30,
                          //                                   width: 30,
                          //                                   decoration:
                          //                                       BoxDecoration(
                          //                                     color: Colors.white,
                          //                                     shape:
                          //                                         BoxShape.circle,
                          //                                   ),
                          //                                   alignment:
                          //                                       Alignment.center,
                          //                                   child: IconButton(
                          //                                     style: IconButton
                          //                                         .styleFrom(
                          //                                       minimumSize:
                          //                                           Size.zero,
                          //                                       padding:
                          //                                           EdgeInsets
                          //                                               .zero,
                          //                                     ),
                          //                                     onPressed: () {},
                          //                                     icon: Icon(
                          //                                       Icons.phone,
                          //                                       color:
                          //                                           Colors.green,
                          //                                       size: 20,
                          //                                     ),
                          //                                   ),
                          //                                 ),
                          //                               ],
                          //                             ),
                          //                           ),
                          //                         ],
                          //                       ),
                          //                     ),
                          //                     Padding(
                          //                       padding: EdgeInsets.only(
                          //                           left: 8, right: 8, top: 8),
                          //                       child: Text(
                          //                         state.products[index].title
                          //                             .toString(),
                          //                         style: TextStyle(
                          //                             fontWeight:
                          //                                 FontWeight.bold),
                          //                         maxLines: 1,
                          //                         overflow: TextOverflow.ellipsis,
                          //                       ),
                          //                     ),
                          //                     Padding(
                          //                       padding: EdgeInsets.only(
                          //                           left: 8, right: 8, top: 8),
                          //                       child: Row(
                          //                         children: [Text(' \$ free')],
                          //                       ),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ),
                          //             ),
                          //           );
                          //   },
                          // );
                          case Product.error:
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
                ],
              ),
            ),
          ),

          //like pageni ui taxladinmi? ha qarib
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AddProductScreen()))
                  .then((result) {
                if (result != null && result == true) {

                  _refreshController.requestRefresh();
                  // Orqaga qaytilganda xabar chiqariladi
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text("Mahsulot muvaffaqiyatli qo'shildi!"),
                  //   ),
                  // );
                }
              });
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
