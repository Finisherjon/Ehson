import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ehson/bloc/get_like/get_like_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/models/get_like_model.dart';
import '../../api/repository.dart';
import '../../constants/constants.dart';
import '../../mywidgets/mywidgets.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  bool _heartIcon = false;

  late ScrollController _scrollController;
  Timer? _debounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<GetLikeBloc>(context).add(ReloadLikeEvent(date: ""));
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

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
        BlocProvider.of<GetLikeBloc>(context).add(GetLikeEvent(date: ""));
      }
    });
  }

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
  GetLIkeModel? getLIkeModel;

  Future<void> _onrefresh() async {
    BlocProvider.of<GetLikeBloc>(context).add(ReloadLikeEvent(date: ""));
    _refreshController.refreshCompleted();
  }

  //davom et urganimi? ha
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Like Page"),
          centerTitle: true,
        ),
        body: LoaderOverlay(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  //buyogini tugirla malumot kelopti ui qarab tugirla yordam dartga qarab tugirla
                  //shunca productni get qilishni block yozishni nechi marta busa uzim qaytib qlopman nechi marta kuring buyogiga uzin qil endi xay
                  padding: const EdgeInsets.all(8.0),
                  child: BlocBuilder<GetLikeBloc, GetLikeState>(
                    builder: (context, state) {
                      switch (state.status) {
                        case GetLike.loading:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        case GetLike.success:
                          if (state.products.isEmpty) {
                            return Container(
                              child: MyWidget().mywidget("Hech narsa topilmadi!"),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.86,
                            );
                          }
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: SmartRefresher(
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
                                    //hozi showshma bunga phone bilan user malumotlariniyam beraman bu productni uzi kim add qiganini apini uzgartiray
                                    //yuqorisiga sariqcha busa uzgartirilgan san tomondan usha uchun tabni yopasan va qayta ochasan
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
                                                              // Image.network(
                                                              //     "https://scotch-soda.com.au/cdn/shop/products/NOMM166920-0008-FNT.jpg?v=1712104589&width=1000"),
                                                              asosiy_img ==
                                                                  null &&
                                                                  state.products
                                                                      .length >
                                                                      index
                                                                  ? CachedNetworkImage(
                                                                imageUrl:AppConstans.BASE_URL2 + "images/defrasm.png",
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
                                                                    Container(
                                                                        width: MediaQuery.of(context).size.width*0.5,
                                                                        height:MediaQuery.of(context).size.height*0.2,
                                                                        child: Icon(Icons.error)
                                                                    ),
                                                              )
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
                                                                    Container(
                                                                        width: MediaQuery.of(context).size.width*0.5,
                                                                        height:MediaQuery.of(context).size.height*0.2,
                                                                        child: Icon(Icons.error)
                                                                    ),
                                                              ),
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
                                                                          bool
                                                                          add_like =
                                                                          await add_like_product(
                                                                              state.products[index].id);
                          
                                                                          if (add_like) {
                                                                            setState(() {
                                                                              state.products.removeAt(index);
                                                                            });
                                                                          }
                                                                          context.loaderOverlay.hide();
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .favorite,
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
                                                                              EdgeInsets.zero,
                                                                        ),
                                                                        onPressed:
                                                                            () {},
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .chat,
                                                                          color: Colors
                                                                              .blue,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            8),
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
                                                                              EdgeInsets.zero,
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          makePhoneCall(state
                                                                              .products[index]
                                                                              .productOwnerPhone!);
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .phone,
                                                                          color: Colors
                                                                              .green,
                                                                          size:
                                                                              20,
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
                                                  onTap: () {},
                                                ),
                                              ],
                                            ),
                                          );
                                  }),
                              controller: _refreshController,
                              onRefresh: _onrefresh,
                            ),
                          );
                        case GetLike.error:
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
      ),
    );
  }
}
