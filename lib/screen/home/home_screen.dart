import 'dart:async';

import 'package:ehson/adjust_size.dart';
import 'package:ehson/bloc/add_product/add_product_bloc.dart';
import 'package:ehson/bloc/homebloc/home_bloc.dart';
import 'package:ehson/bloc/yordam_bloc/yordam_bloc.dart';
import 'package:ehson/constants/constants.dart';
import 'package:ehson/screen/add_product/screen/add_product_screen.dart';
import 'package:ehson/screen/profile/profile.dart';
import 'package:ehson/screen/yordam/yordam.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/repository.dart';
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
    BlocProvider.of<HomeBloc>(context).add(ReloadProductEvent(date: ""));
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      //bottombardayn yoq u avvalam shunay bulib utirodi kuproq rasm quwib billim
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.person,
                  size: IconSize.mediumIconSize(context),
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => Profile()));
                },
              ),
              Expanded(
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(15),
                // ),

                child: Container(
                  height: Sizes.heights(context) * 0.065,
                  child: TextFormField(
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Nimani qidiryapsiz?',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey,size: IconSize.smallIconSize(context),),
                    ),
                    style: TextStyle(color: Colors.grey),
                    onChanged: (query) {},
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.filter_alt,
                  size: IconSize.mediumIconSize(context),
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  // Define your onPressed functionality here
                },
              ),
            ],
          ),
          // actions: <Widget>[
          //   Padding(
          //     padding: const EdgeInsets.only(right: 10),
          //     child: IconButton(
          //       icon: Icon(Icons.filter_alt),
          //       onPressed: () {},
          //       color: Colors.blueAccent,
          //     ),
          //   ),
          // ],
        ),
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: Sizes.heights(context) * 0.01,
              ),
              // Row(
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.only(top: 20, left: 20),
              //       child: Text(
              //         "Category",
              //         style: GoogleFonts.roboto(
              //             textStyle: TextStyle(
              //                 fontSize: 25, fontWeight: FontWeight.bold)),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              // //--> Category
              //
              // Container(
              //   height: 140,
              //   width: double.infinity,
              //   child: ListView.builder(
              //       scrollDirection: Axis.horizontal,
              //       itemCount: imageUrls.length,
              //       itemBuilder: (context, index) {
              //         return Column(
              //           children: [
              //             InkWell(
              //               borderRadius: BorderRadius.circular(100),
              //               // splashFactory: InkRRectSplashFactory(),
              //               enableFeedback: false,
              //               onTap: () {
              //                 print('Image ${index + 1} tapped');
              //               },
              //               child: Container(
              //                 margin: EdgeInsets.all(8.0),
              //                 decoration: BoxDecoration(
              //                   shape: BoxShape.circle,
              //                   // borderRadius: BorderRadius.circular(100.0),
              //                   boxShadow: [
              //                     BoxShadow(
              //                       color: Colors.black.withOpacity(0.2),
              //                       spreadRadius: 2,
              //                       blurRadius: 5,
              //                       offset: Offset(0, 3),
              //                     ),
              //                   ],
              //                 ),
              //                 child: Container(
              //                     height: 100,
              //                     width: 100,
              //                     child: CircleAvatar(
              //                       radius: 56,
              //                       backgroundColor: Colors.white,
              //                       child: Padding(
              //                         padding: const EdgeInsets.all(8),
              //                         // Border radius
              //                         child: ClipOval(
              //                           child: Image.network(
              //                             imageUrls[index],
              //                           ),
              //                         ),
              //                       ),
              //                     )),
              //               ),
              //             ),
              //             Text("Category")
              //           ],
              //         );
              //       }),
              // ),
              //--> 2 button

              //xush nimala bulopti
              //push qilchi shuyogini

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: Sizes.widths(context) * 0.4,
                    height: Sizes.heights(context) * 0.07,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "Xayriya",
                        style: TextStyle(
                            color: Colors.black,
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
                          return Center(
                            child: Text("Empty"),
                          );
                        }
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.7,
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
                                                          // Image.network(
                                                          //   imageUrl[index],
                                                          //   fit: BoxFit.cover,
                                                          // ),
                                                          Positioned(
                                                            right: 10,
                                                            top: 10,
                                                            child: Container(
                                                              height: 30,
                                                              width: 30,
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
                                                                  //shuni taxla
                                                                  // state.products[index].phone
                                                                  //qara statega phoneyam kelopti telefonchani bossa telefon qilishga utsin nomer terib shunoqa package bor

                                                                  //kurdinmi jura ha

                                                                  //san chatga utgan payt awibka chiqopti ui bilan manimca uwani tugirla man apini update qilay getproductni xay

                                                                  //hozir like quwish post buli faqat ui bilan integratsiya qilish kerak
                                                                  setState(() {
                                                                    _heartIcon =
                                                                        !_heartIcon;
                                                                  });
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
                                                                  height: 30,
                                                                  width: 30,
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
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 8),
                                                                Container(
                                                                  height: 30,
                                                                  width: 30,
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
                                                                      size: 20,
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

        //like pageni ui taxladinmi? ha qarib
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddProductScreen()));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
