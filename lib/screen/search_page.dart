import 'dart:async';

import 'package:ehson/bloc/search_product/search_product_bloc.dart';
import 'package:ehson/mywidgets/mywidgets.dart';
import 'package:ehson/screen/home/home_screen.dart';
import 'package:ehson/screen/profile/profile.dart';
import 'package:ehson/screen/verification/log_In_screen.dart';
import 'package:ehson/screen/yordam/yordam.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../adjust_size.dart';
import '../api/repository.dart';
import '../bloc/yordam_bloc/yordam_bloc.dart';
import '../constants/constants.dart';
import 'add_product/screen/add_product_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

//oldin apisiz shunay ui ni taxla
class _SearchPageState extends State<SearchPage> {
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

  final TextEditingController _search_controller = TextEditingController();

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

  bool _heartIcon = false;

  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_onScroll);
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
        BlocProvider.of<SearchProductBloc>(context)
            .add(GetSearchProductEvent(text: ""));
      }
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.blueAccent,
                    ),
                    Container(
                      height: Sizes.heights(context) * 0.066,
                      width: Sizes.widths(context) * 0.7,
                      child: TextFormField(
                        controller: _search_controller,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Nimani qidiryapsiz?',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                            borderSide: BorderSide(
                                color: Colors.blueAccent, width: 2.0),
                          ),
                          //empty uchun bita widget taxla constanta widget hamma joyga ushani qoyib chiq
                          //empty emas boshqa so'z bo'sin hamma joyga
                          //rangiyam uziyam zur
                          //nma qilopsan?
                          //manabuni rangini uzgartiriwni kurib utirodim
                          // prefixIcon: Icon(
                          //   Icons.search,
                          //   color: Colors.grey,
                          //   size: IconSize.smallIconSize(context),
                          // ),
                        ),
                        style: TextStyle(color: Colors.black87),
                        onChanged: (query) {},
                      ),
                    ),

                    //pasga nimadir chiqopti ui tugirla
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        size: IconSize.largeIconSize(context),
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        BlocProvider.of<SearchProductBloc>(context).add(
                            ReloadSearchProductEvent(
                                text: _search_controller.text.toString()));

                        // Navigator.of(context).push(
                        //     MaterialPageRoute(builder: (context) => Profile()));
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: Sizes.heights(context) * 0.005,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BlocBuilder<SearchProductBloc, SearchProductState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case SearchProduct.loading:
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.86,
                          child: Center(
                            //create accaunt kerak emas va ui ni tugirla
                            //xay uzim kurivuramanok
                            //xulas bugan shu mayda chudala bilan ishla ja kup vaqtam sarfla norm tushunarli busa buli
                            child: Text(
                              //shoshm//kurdina nima qilim shunoqa mayda chuda ishlani qilib chiqish kerak
                              //textin urtaga emas va center ham emas
                              // biz albatta topamiz urtaroqa turishi kerak shunoqa ishlani qilib chiquvurchi
                              "Nimadir qidirib ko'ring\n biz albatta topamiz",
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      case SearchProduct.success:
                        if (state.products.isEmpty) {
                          //
                          return Container(
                            child: MyWidget().mywidget("Hech narsa topilmadi!"),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.86,
                          );
                        }
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.86,
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
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(bottom: 10),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      child: Stack(
                                                        children: [
                                                          asosiy_img == null &&
                                                                  state.products
                                                                          .length >
                                                                      index
                                                              ? Image.network(
                                                                  AppConstans
                                                                          .BASE_URL2 +
                                                                      "images/1722061202.jpg",
                                                                  fit: BoxFit
                                                                      .fitHeight,
                                                                )
                                                              : Image.network(
                                                                  AppConstans
                                                                          .BASE_URL2 +
                                                                      "images/" +
                                                                      asosiy_img!,
                                                                  fit: BoxFit
                                                                      .fitHeight,
                                                                ),
                                                          Positioned(
                                                            right: 10,
                                                            top: 10,
                                                            child: Container(
                                                              height: Sizes.heights(
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
                                                              child: IconButton(
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
                                                                  setState(() {
                                                                    _heartIcon =
                                                                        !_heartIcon;
                                                                  });
                                                                },
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
                                                                  height: Sizes
                                                                          .heights(
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
                                                                          EdgeInsets
                                                                              .zero,
                                                                    ),
                                                                    onPressed:
                                                                        () {},
                                                                    icon: Icon(
                                                                      Icons
                                                                          .chat,
                                                                      color: Colors
                                                                          .blue,
                                                                      size: IconSize
                                                                          .smallIconSize(
                                                                              context),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 8),
                                                                Container(
                                                                  height: Sizes
                                                                          .heights(
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
                                                                          EdgeInsets
                                                                              .zero,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      makePhoneCall(state
                                                                          .products[
                                                                              index]
                                                                          .phone!);
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .phone,
                                                                      color: Colors
                                                                          .green,
                                                                      size: IconSize
                                                                          .smallIconSize(
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
                                                      padding: EdgeInsets.only(
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
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 8,
                                                          right: 8,
                                                          top: 8),
                                                      child: Row(
                                                        children: [
                                                          Text(' \$ free')
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {},
                                            ),
                                          ],
                                        ),
                                      );
                              }),
                        );
                      case SearchProduct.error:
                        return Center(
                          child: Text("Internet error"),
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(
      //         MaterialPageRoute(builder: (context) => AddProductScreen()));
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
