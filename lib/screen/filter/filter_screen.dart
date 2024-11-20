import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ehson/bloc/get_filter_product/get_filter_product_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../adjust_size.dart';
import '../../api/models/category_model.dart';
import '../../api/repository.dart';
import '../../bloc/filter_product/filter_product_bloc.dart';
import '../../constants/constants.dart';
import '../../mywidgets/mywidgets.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? selectedValue;

  final List<String> items = [];
  final List<String> cities = [];
  String? selectedValuee;
  String? selectedValue_city;
  int category_id = 0;
  int city_id = 0;

  // Future<String> filter_product(int category_id, int city_id) async {
  //   var uri = Uri.parse(AppConstans.BASE_URL + '/filterproduct');
  //   var token = '';
  //   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //   final SharedPreferences prefs = await _prefs;
  //   token = prefs.getString('bearer_token') ?? '';
  //   Map data = {"category_id": 1, "city_id": 1};
  //   var body = json.encode(data);
  //   try {
  //     final response = await http.post(
  //       uri,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": 'Bearer $token',
  //       },
  //       body: body,
  //     );
  //     if (response.statusCode == 200) {
  //       final resdata = json.decode(utf8.decode(response.bodyBytes));
  //       print(resdata);
  //       if (resdata["status"] == true) {
  //         return "Success";
  //       } else {
  //         return "Error: ${response.statusCode}";
  //       }
  //     } else {
  //       return "Error: ${response.statusCode}";
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     return "Exception: $e";
  //   }
  // }

  RefreshController _refreshController =
  RefreshController(initialRefresh: true);

  final List<String> imageUrl = [
    "https://scotch-soda.com.au/cdn/shop/products/NOMM166920-0008-FNT.jpg?v=1712104589&width=1000",
    "https://target.scene7.com/is/image/Target/GUEST_bb901552-2436-4cb6-b805-ce34b1a41d55?wid=488&hei=488&fmt=pjpeg",
    "https://contents.mediadecathlon.com/p2399053/d375fff1f5ba3c9b5457bd801a2bea00/p2399053.jpg?format=auto&quality=70&f=650x0",
    "https://tinkerlust.s3.ap-southeast-1.amazonaws.com/products/ebc022cb-d957-4825-8689-5ee6647742d3/original/1280x1280/31803884ece6d68110a0-PhotoRoom_MP-21276-JC-34.png",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPCm1XE1KRdq27NwcSZPsJ2Q96neNQ7muapndKMa6AW18wyEMbdgZRtOgP_sNH4g9r3nI&usqp=CAU",
    "https://m.media-amazon.com/images/I/61tilO4erpL._AC_UF1000,1000_QL80_.jpg",
    "https://m.media-amazon.com/images/I/61tilO4erpL._AC_UF1000,1000_QL80_.jpg",
    "https://scotch-soda.com.au/cdn/shop/products/NOMM166920-0008-FNT.jpg?v=1712104589&width=1000",
    "https://m.media-amazon.com/images/I/61tilO4erpL._AC_UF1000,1000_QL80_.jpg",
    "https://target.scene7.com/is/image/Target/GUEST_bb901552-2436-4cb6-b805-ce34b1a41d55?wid=488&hei=488&fmt=pjpeg",
  ];

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
      if (_isNearBottom()) {
        print("Keldi");
        BlocProvider.of<GetFilterProductBloc>(context)
            .add(FilterProductGetEvent(category_id: 1, city_id: 1));
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.blueAccent,
          ),
        ),
        title: Text('Filter Page'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            BlocBuilder<FilterProductBloc, FilterProductState>(
              builder: (context, state) {
                if (state is FilterProductSuccess) {
                  items.clear();
                  cities.clear();
                  for (var category in state.categoryModel.categories!) {
                    items.add(category.name.toString());
                  }
                  for (var city in state.categoryModel.cities!) {
                    cities.add(city.name.toString());
                  }
                  selectedValue = items.first;
                  selectedValue_city = cities.first;
                  category_id = state.categoryModel.categories!.first.id!;
                  city_id = state.categoryModel.cities!.first.id!;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: Sizes.heights(context) * 0.02,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 170, // Set the desired width here
                              child: DropdownButtonFormField2(
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                value: items.first,
                                isExpanded: true,
                                hint: Text(
                                  'Viloyat',
                                  style: TextStyle(fontSize: 16),
                                ),
                                items: items
                                    .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                                    .toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select gender.';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value.toString();
                                    Categories cat = state
                                        .categoryModel.categories!
                                        .firstWhere((category) =>
                                    category.name == selectedValue);
                                    category_id = cat.id!;
                                    print(category_id);
                                  });
                                },
                                onSaved: (value) {
                                  selectedValue = value.toString();
                                  Categories cat = state
                                      .categoryModel.categories!
                                      .firstWhere((category) =>
                                  category.name == selectedValue);
                                  category_id = cat.id!;
                                },
                                buttonStyleData: const ButtonStyleData(
                                  height: 60,
                                  padding: EdgeInsets.only(left: 20, right: 10),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                  iconSize: 30,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 170,
                              child: DropdownButtonFormField2(
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                value: cities.first,
                                isExpanded: true,
                                hint: Text(
                                  'Category',
                                  style: TextStyle(fontSize: 16),
                                ),
                                items: cities
                                    .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                                    .toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select gender.';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue_city = value.toString();

                                    Cities citis = state.categoryModel.cities!
                                        .firstWhere((city) =>
                                    city.name == selectedValue_city);

                                    city_id = citis.id!;
                                    print(city_id);
                                  });
                                },
                                onSaved: (value) {
                                  selectedValue_city = value.toString();
                                  Cities citis = state.categoryModel.cities!
                                      .firstWhere((city) =>
                                  city.name == selectedValue_city);

                                  city_id = citis.id!;
                                },
                                buttonStyleData: const ButtonStyleData(
                                  height: 60,
                                  padding: EdgeInsets.only(left: 20, right: 10),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                  iconSize: 30,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                if (state is FilterProductError) {
                  Center(child: Text("Server connection error"));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
            //filter product apiga murojjat qilib productlani olasan block bilan apidagi city va category idni boshiga 1 berasan
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<GetFilterProductBloc, GetFilterProductState>(
                builder: (context, state) {
                  switch (state.status) {
                    case FilterProduct.loading:
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.86,
                        child: Center(
                          child: Text(
                            "Nimadir qidirib ko'ring\n biz albatta topamiz",
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    case FilterProduct.success:
                      if (state.products.isEmpty) {
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
                                } else if (state.products[index].img2 != null) {
                                  asosiy_img = state.products[index].img2;
                                } else if (state.products[index].img3 != null) {
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
                                              offset: const Offset(1, 1),
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
                                                        color:
                                                        Colors.white,
                                                        shape: BoxShape
                                                            .circle,
                                                      ),
                                                      alignment: Alignment
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
                                                          int?
                                                          product_id =
                                                              state
                                                                  .products[
                                                              index]
                                                                  .id;
                                                          bool add_like =
                                                          await add_like_product(
                                                              product_id);

                                                          if (add_like) {
                                                            state
                                                                .products[
                                                            index]
                                                                .isliked = state
                                                                .products[index]
                                                                .isliked ==
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
                                                          color:
                                                          Colors.red,
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
                                                              Icons.chat,
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
                                                              Icons.phone,
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
                                                    FontWeight.bold),
                                                maxLines: 1,
                                                overflow:
                                                TextOverflow.ellipsis,
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
                    case FilterProduct.error:
                      return Center(
                        child: Text("Internet error"),
                      );
                  }
                },
              ),
            ),

            ///
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //     height: MediaQuery.of(context).size.height * 0.78,
            //     child: MasonryGridView.count(
            //         // controller: _scrollController,
            //         physics: BouncingScrollPhysics(),
            //         padding: EdgeInsets.symmetric(vertical: 10),
            //         crossAxisSpacing: 15,
            //         crossAxisCount: 2,
            //         itemCount: imageUrl.length,
            //         // itemCount: state.islast
            //         //     ? state.products.length
            //         //     : state.products.length + 2,
            //         scrollDirection: Axis.vertical,
            //         mainAxisSpacing: 10,
            //         itemBuilder: (BuildContext context, index) {
            //           // if (index >= state.products.length) {
            //           //   return Center(
            //           //       child: CircularProgressIndicator());
            //           // }
            //           // //telefonchani bosa endi telefon raqam bod api bilan kelopti
            //           // //bulimi? ha zabanca
            //           // String? asosiy_img;
            //           // if (state.products.length > index) {
            //           //   if (state.products[index].img1 != null) {
            //           //     asosiy_img = state.products[index].img1;
            //           //   } else if (state.products[index].img2 !=
            //           //       null) {
            //           //     asosiy_img = state.products[index].img2;
            //           //   } else if (state.products[index].img3 !=
            //           //       null) {
            //           //     asosiy_img = state.products[index].img3;
            //           //   } else {
            //           //     asosiy_img = null;
            //           //   }
            //           // }
            //           // return index >= state.products.length
            //           //     ? Center(
            //           //   child: CircularProgressIndicator(),
            //           // )
            //           //     :
            //           return Container(
            //             child: Stack(
            //               children: [
            //                 InkWell(
            //                   borderRadius: BorderRadius.circular(30),
            //                   child: Container(
            //                     padding: EdgeInsets.only(bottom: 10),
            //                     decoration: BoxDecoration(
            //                       borderRadius: BorderRadius.circular(25),
            //                       color: Colors.white,
            //                       boxShadow: [
            //                         BoxShadow(
            //                           color: Colors.black.withOpacity(0.1),
            //                           blurRadius: 5,
            //                           spreadRadius: 1,
            //                           offset: const Offset(1, 1),
            //                         ),
            //                       ],
            //                     ),
            //                     child: Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         ClipRRect(
            //                           borderRadius: BorderRadius.circular(25),
            //                           child: Stack(
            //                             children: [
            //                               // asosiy_img ==
            //                               //     null &&
            //                               //     state.products
            //                               //         .length >
            //                               //         index
            //                               //     ? CachedNetworkImage(
            //                               //   imageUrl:
            //                               //   AppConstans.BASE_URL2 +
            //                               //       "images/defrasm.png",
            //                               //   placeholder:
            //                               //       (context, url) =>
            //                               Container(
            //                                 width: MediaQuery.of(context)
            //                                         .size
            //                                         .width *
            //                                     0.5,
            //                                 height: MediaQuery.of(context)
            //                                         .size
            //                                         .height *
            //                                     0.2,
            //                                 child: Row(
            //                                   mainAxisAlignment:
            //                                       MainAxisAlignment.center,
            //                                   children: [
            //                                     CircularProgressIndicator(),
            //                                   ],
            //                                 ),
            //                               ),
            //                               // errorWidget: (context,
            //                               //     url,
            //                               //     error) =>
            //                               Container(
            //                                 width: MediaQuery.of(context)
            //                                         .size
            //                                         .width *
            //                                     0.5,
            //                                 height: MediaQuery.of(context)
            //                                         .size
            //                                         .height *
            //                                     0.2,
            //                                 child: Icon(Icons.error),
            //                               ),
            //                               Image.network(
            //                                 imageUrl[index],
            //                                 fit: BoxFit.cover,
            //                               ),
            //                               //     CachedNetworkImage(
            //                               //   imageUrl: AppConstans
            //                               //       .BASE_URL2 +
            //                               //       "images/" +
            //                               //       asosiy_img!,
            //                               //   placeholder:
            //                               //       (context, url) =>
            //                               //       Container(
            //                               //         width: MediaQuery.of(context).size.width *
            //                               //             0.5,
            //                               //         height: MediaQuery.of(context).size.height *
            //                               //             0.2,
            //                               //         child:
            //                               //         Row(
            //                               //           mainAxisAlignment:
            //                               //           MainAxisAlignment.center,
            //                               //           children: [
            //                               //             CircularProgressIndicator(),
            //                               //           ],
            //                               //         ),
            //                               //       ),
            //                               //   errorWidget: (context, url, error) => Container(
            //                               //       width: MediaQuery.of(context).size.width *
            //                               //           0.5,
            //                               //       height: MediaQuery.of(context).size.height *
            //                               //           0.2,
            //                               //       child:
            //                               //       Icon(Icons.error)),
            //                               // ),
            //                               Positioned(
            //                                 left: 10,
            //                                 top: 10,
            //                                 child: Container(
            //                                   height:
            //                                       Sizes.heights(context) * 0.04,
            //                                   width:
            //                                       Sizes.widths(context) * 0.07,
            //                                   decoration: BoxDecoration(
            //                                     color: Colors.white,
            //                                     shape: BoxShape.circle,
            //                                   ),
            //                                   alignment: Alignment.center,
            //                                   child: IconButton(
            //                                     onPressed: () {},
            //                                     icon: FaIcon(
            //                                       FontAwesomeIcons.trashCan,
            //                                       color: Colors.red,
            //                                       size: 18,
            //                                     ),
            //                                   ),
            //                                 ),
            //                               ),
            //                               Positioned(
            //                                 left: 10,
            //                                 top: 10,
            //                                 child: Container(
            //                                   height:
            //                                       Sizes.heights(context) * 0.04,
            //                                   width:
            //                                       Sizes.widths(context) * 0.07,
            //                                   decoration: BoxDecoration(
            //                                     color: Colors.white,
            //                                     shape: BoxShape.circle,
            //                                   ),
            //                                   child: Center(
            //                                     child: IconButton(
            //                                       onPressed: () {},
            //                                       icon: FaIcon(
            //                                         FontAwesomeIcons.trashCan,
            //                                         color: Colors.red,
            //                                         size: 17,
            //                                       ),
            //                                       padding: EdgeInsets.zero,
            //                                       alignment: Alignment.center,
            //                                     ),
            //                                   ),
            //                                 ),
            //                               ),
            //                               Positioned(
            //                                 right: 10,
            //                                 top: 10,
            //                                 child: Container(
            //                                   height:
            //                                       Sizes.heights(context) * 0.04,
            //                                   width:
            //                                       Sizes.widths(context) * 0.07,
            //                                   decoration: BoxDecoration(
            //                                     color: Colors.white,
            //                                     shape: BoxShape.circle,
            //                                   ),
            //                                   alignment: Alignment.center,
            //                                   child: IconButton(
            //                                     style: IconButton.styleFrom(
            //                                       minimumSize: Size.zero,
            //                                       padding: EdgeInsets.zero,
            //                                     ),
            //                                     onPressed: () async {
            //                                       // context
            //                                       //     .loaderOverlay
            //                                       //     .show();
            //                                       //
            //                                       // int? product_id = state
            //                                       //     .products[
            //                                       // index]
            //                                       //     .id;
            //                                       // bool
            //                                       // add_like =
            //                                       // await add_like_product(
            //                                       //     product_id);
            //                                       //
            //                                       // if (add_like) {
            //                                       //   state
            //                                       //       .products[
            //                                       //   index]
            //                                       //       .isliked = state.products[index].isliked ==
            //                                       //       0
            //                                       //       ? 1
            //                                       //       : 0;
            //                                       // }
            //                                       // setState(
            //                                       //         () {
            //                                       //       _heartIcon =
            //                                       //       !_heartIcon;
            //                                       //     });
            //                                       // context
            //                                       //     .loaderOverlay
            //                                       //     .hide();
            //                                     },
            //                                     icon: Icon(
            //                                       // state.products[index].isliked == 1
            //                                       //     ? Icons
            //                                       //     .favorite
            //                                       //     : Icons
            //                                       //     .favorite_border,
            //                                       Icons.favorite_border,
            //                                       color: Colors.red,
            //                                       size: 20,
            //                                     ),
            //                                   ),
            //                                 ),
            //                               ),
            //                               Positioned(
            //                                 right: 10,
            //                                 bottom: 10,
            //                                 child: Column(
            //                                   children: [
            //                                     Container(
            //                                       height:
            //                                           Sizes.heights(context) *
            //                                               0.037,
            //                                       width: Sizes.widths(context) *
            //                                           0.077,
            //                                       decoration: BoxDecoration(
            //                                         color: Colors.white,
            //                                         shape: BoxShape.circle,
            //                                       ),
            //                                       alignment: Alignment.center,
            //                                       child: IconButton(
            //                                         style: IconButton.styleFrom(
            //                                           minimumSize: Size.zero,
            //                                           padding: EdgeInsets.zero,
            //                                         ),
            //                                         onPressed: () {},
            //                                         icon: Icon(
            //                                           Icons.chat,
            //                                           color: Colors.blue,
            //                                           size: IconSize
            //                                               .smallIconSize(
            //                                                   context),
            //                                         ),
            //                                       ),
            //                                     ),
            //                                     SizedBox(height: 8),
            //                                     Container(
            //                                       height:
            //                                           Sizes.heights(context) *
            //                                               0.04,
            //                                       width: Sizes.widths(context) *
            //                                           0.08,
            //                                       decoration: BoxDecoration(
            //                                         color: Colors.white,
            //                                         shape: BoxShape.circle,
            //                                       ),
            //                                       alignment: Alignment.center,
            //                                       child: IconButton(
            //                                         style: IconButton.styleFrom(
            //                                           minimumSize: Size.zero,
            //                                           padding: EdgeInsets.zero,
            //                                         ),
            //                                         onPressed: () {},
            //                                         // state.products[index].phone !=
            //                                         //     null
            //                                         //     ? () {
            //                                         //   makePhoneCall(state.products[index].phone!);
            //                                         // }
            //                                         //     : null,
            //                                         icon: Icon(
            //                                           Icons.phone,
            //                                           color: Colors.green,
            //                                           size: IconSize
            //                                               .smallIconSize(
            //                                                   context),
            //                                         ),
            //                                       ),
            //                                     ),
            //                                   ],
            //                                 ),
            //                               ),
            //                             ],
            //                           ),
            //                         ),
            //                         Padding(
            //                           padding: EdgeInsets.only(
            //                               left: 8, right: 8, top: 8),
            //                           child: Text(
            //                             "Test",
            //                             // state
            //                             //     .products[index]
            //                             //     .title!,
            //                             style: TextStyle(
            //                                 fontWeight: FontWeight.bold),
            //                             maxLines: 1,
            //                             overflow: TextOverflow.ellipsis,
            //                           ),
            //                         ),
            //                         Padding(
            //                           padding: EdgeInsets.only(
            //                               left: 8, right: 8, top: 8),
            //                           child: Text(
            //                             "test",
            //                             // state
            //                             //     .products[index]
            //                             //     .info
            //                             //     .toString(),
            //                             maxLines: 1,
            //                             overflow: TextOverflow.ellipsis,
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                   ),
            //                   onTap: () {
            //                     Navigator.of(context).push(
            //                       MaterialPageRoute(
            //                         builder: (context) => ProductInfo(),
            //                       ),
            //                     );
            //                   },
            //                 ),
            //               ],
            //             ),
            //           );
            //         }),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
