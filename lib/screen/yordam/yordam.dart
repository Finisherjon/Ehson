import 'dart:async';

import 'package:ehson/bloc/yordam_bloc/yordam_bloc.dart';
import 'package:ehson/screen/yordam/add_yordam.dart';
import 'package:ehson/screen/yordam/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/constants.dart';

class Yordam extends StatefulWidget {
  const Yordam({super.key});

  @override
  State<Yordam> createState() => _YordamState();
}

//endi buyogini ui uzin tugirla
//home screendan kurib tugirlaysan
//yordam page shu xay
//block tayyor endi uni ishlatish kerak shuyogiga urna qani xay

final _scrollController = ScrollController();
Timer? _debounce;

class _YordamState extends State<Yordam> {
  LatLng? _selectedLocation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<YordamBloc>(context).add(ReloadYordamEvent(date: ""));
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
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_isNearBottom()) {
        print("Keldi");
        BlocProvider.of<YordamBloc>(context).add(GetYordamEvent(date: ""));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<YordamBloc, YordamState>(
            builder: (context, state) {
              switch (state.status) {
                case YordamProduct.loading:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                case YordamProduct.success:
                  if (state.products.isEmpty) {
                    return Center(
                      child: Text("Empty"),
                    );
                  }
                  return ListView.builder(
                      controller: _scrollController,
                      itemCount: state.islast
                          ? state.products.length
                          : state.products.length + 2,
                      itemBuilder: (context, index) {
                        String? asosiy_img;
                        if (state.products.length > index) {
                          if (state.products[index].img != null) {
                            asosiy_img = state.products[index].img;
                          } else {
                            asosiy_img = null;
                          }
                        }

                        return index >= state.products.length
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.20,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () {},
                                    child: Card(
                                      // shadowColor: Colors.black,
                                      color: Colors.white,
                                      child: Row(
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.37,
                                            child: Stack(
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      state
                                                          .products[index].title
                                                          .toString(),
                                                      style: GoogleFonts.roboto(
                                                        textStyle: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: Divider(
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                    Text(
                                                      state.products[index].info
                                                          .toString(),
                                                      style: GoogleFonts.roboto(
                                                        textStyle: TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                                                Positioned(
                                                  left: 6,
                                                  bottom: 1,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        height: 30,
                                                        width: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: IconButton(
                                                          style: IconButton
                                                              .styleFrom(
                                                            minimumSize:
                                                                Size.zero,
                                                            padding:
                                                                EdgeInsets.zero,
                                                          ),
                                                          onPressed: () {},
                                                          icon: Icon(
                                                            Icons.phone,
                                                            color: Colors.green,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Container(
                                                        height: 30,
                                                        width: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: IconButton(
                                                          style: IconButton
                                                              .styleFrom(
                                                            minimumSize:
                                                                Size.zero,
                                                            padding:
                                                                EdgeInsets.zero,
                                                          ),
                                                          onPressed: () {},
                                                          icon: Icon(
                                                            Icons.chat,
                                                            color: Colors
                                                                .blueAccent,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Container(
                                                        height: 30,
                                                        width: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: IconButton(
                                                          style: IconButton
                                                              .styleFrom(
                                                            minimumSize:
                                                                Size.zero,
                                                            padding:
                                                                EdgeInsets.zero,
                                                          ),
                                                          onPressed: () async {
                                                            // final result =
                                                            //     await Navigator
                                                            //         .push(
                                                            //   context,
                                                            //   MaterialPageRoute(
                                                            //     builder:
                                                            //         (context) =>
                                                            //             Location(),
                                                            //   ),
                                                            // );
                                                            //
                                                            // if (result !=
                                                            //     null) {
                                                            //   setState(() {
                                                            //     _selectedLocation =
                                                            //         result;
                                                            //   });
                                                            // }
                                                          },
                                                          icon: Icon(
                                                            Icons.location_on,
                                                            color: Colors.red,
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
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.53,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              // child: Image.network(
                                              //   state.products[index].img,
                                              //   "https://www.shutterstock.com/image-photo/two-poor-african-children-front-600nw-2123588717.jpg",
                                              //   fit: BoxFit.cover,
                                              // ),

                                              child: asosiy_img == null &&
                                                      state.products.length >
                                                          index
                                                  ? Image.network(
                                                      AppConstans.BASE_URL +
                                                          "images/1722061202.jpg",
                                                      fit: BoxFit.fitHeight,
                                                    )
                                                  : Image.network(
                                                      AppConstans.BASE_URL +
                                                          "images/" +
                                                          asosiy_img!,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
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
    );
  }
}
