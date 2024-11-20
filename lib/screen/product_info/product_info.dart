import 'package:cached_network_image/cached_network_image.dart';
import 'package:ehson/api/models/create_chat_model.dart';
import 'package:ehson/bloc/get_one_product/get_one_product_bloc.dart';
import 'package:ehson/bloc/message/message_list_bloc.dart';
import 'package:ehson/constants/constants.dart';
import 'package:ehson/screen/chat/one_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/repository.dart';
import '../../mywidgets/mywidgets.dart';

class ProductInfo extends StatefulWidget {
  final int product_id;

  const ProductInfo({super.key, required this.product_id});

  @override
  _ProductInfoState createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  final PageController _pageController = PageController();
  final LatLng amirTemurSquare = LatLng(41.3111, 69.2797);
  int user_id = 0;

  Future<void> getSharedPrefs() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    //tokenni login qigan paytimiz sharedga saqlab qoyganbiza
    final SharedPreferences prefs = await _prefs;
    user_id = prefs.getInt("user_id") ?? 0;
  }

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
    BlocProvider.of<GetOneProductBloc>(context)
        .add(GetOneProductLoadingData(widget.product_id));
  }

  Future<void> create_chat(int user_one,int user_two)async{
    context.loaderOverlay.show();
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

  void makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch $phoneNumber');
    }
  }

  bool _heartIcon = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<GetOneProductBloc, GetOneProductState>(
          builder: (context, state) {
            if (state is GetOneProductSuccess) {
              return Stack(
                children: [
                  // PageView to display images
                  SizedBox(
                    height: 335,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        // return state.oneProductModel.product!.img1 != null
                        //     ? Image.network(
                        //   AppConstans.BASE_URL2 +
                        //       "images/" +
                        //       state.oneProductModel.product!.img1
                        //           .toString(),
                        //   fit: BoxFit.cover,
                        // )
                        //     : SizedBox();
                        return state.oneProductModel.product!.img1 == null
                            ? MyWidget().defimagewidget(context)
                            :CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:AppConstans.BASE_URL2 + "images/" + state.oneProductModel.product!.img1.toString(),
                            placeholder: (context, url) => Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                  ],
                                )
                            ),
                            errorWidget: (context, url, error) =>
                                MyWidget().defimagewidget(context)
                        );
                      },
                    ),
                  ),
                  // Positioned(
                  //   top: 290,
                  //   // Adjust this to ensure the indicator is not hidden
                  //   left: 0,
                  //   right: 0,
                  //   child: Center(
                  //     child: SmoothPageIndicator(
                  //       controller: _pageController, // Link to PageController
                  //       count: imageUrls.length,
                  //       effect: WormEffect(
                  //         dotHeight: 10,
                  //         dotWidth: 10,
                  //         activeDotColor: Colors.blueAccent,
                  //         dotColor: Colors.black.withOpacity(0.5),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        alignment: Alignment.center,
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.arrow_back_ios,
                              size: 25,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: InkWell(
                        onTap: () async {
                          context.loaderOverlay.show();
                          int? product_id = state.oneProductModel.product!.id;
                          bool add_like = await add_like_product(product_id);
                          if (add_like) {
                            state.oneProductModel.product!.isliked =
                            state.oneProductModel.product!.isliked == 0
                                ? 1
                                : 0;
                          }
                          setState(() {
                            _heartIcon = !_heartIcon;
                          });
                          context.loaderOverlay.hide();
                        },
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              state.oneProductModel.product!.isliked == 1
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            
                  DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    maxChildSize: 0.63,
                    minChildSize: 0.6,
                    builder: (context, scrollController) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(37),
                            topRight: Radius.circular(37),
                          ),
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                state.oneProductModel.product!.title!,
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                state.oneProductModel.product!.info!,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Divider(
                                  color: Colors.grey[400],
                                ),
                              ),
                              Text(
                                state.oneProductModel.product!.createdAt!,
                                style:
                                TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: [
                                  // Text(
                                  //   "Toshkent Shahri",
                                  //   style: TextStyle(
                                  //       fontSize: 16, color: Colors.blue),
                                  // ),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.blueAccent, width: 2),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(7),
                                      child: Text(
                                        state.oneProductModel.product!.category_name.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.blueAccent, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        state.oneProductModel.product!.city_name.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Stack(
                              //       children: [
                              //         Container(
                              //           height: 180,
                              //           width: 340,
                              //           child: GoogleMap(
                              //             initialCameraPosition: CameraPosition(
                              //               target: amirTemurSquare,
                              //               zoom: 13.6,
                              //             ),
                              //             markers: {
                              //               Marker(
                              //                 markerId:
                              //                 MarkerId('amirTemurSquare'),
                              //                 position: amirTemurSquare,
                              //               ),
                              //             },
                              //           ),
                              //         ),
                              //         InkWell(
                              //           onTap: () {
                              //             Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                   builder: (context) =>
                              //                       FullScreenMapScreen()),
                              //             );
                              //           },
                              //           child: Container(
                              //             height: 180,
                              //             width: 340,
                              //           ),
                              //         )
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     GestureDetector(
                              //       onTap: () {},
                              //       child: Container(
                              //         height: 180,
                              //         width: 340,
                              //         child: GoogleMap(
                              //           initialCameraPosition: CameraPosition(
                              //             target: amirTemurSquare,
                              //             zoom: 13.6,
                              //           ),
                              //           markers: {
                              //             Marker(
                              //               markerId:
                              //                   MarkerId('amirTemurSquare'),
                              //               position: amirTemurSquare,
                              //             ),
                              //           },
                              //           zoomControlsEnabled: false,
                              //           myLocationButtonEnabled: false,
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
            
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) =>
                              //           FullScreenMapScreen()),
                              // );
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: ElevatedButton(
                                      onPressed:
                                          () {
                                        if(state
                                            .oneProductModel.product!
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
                                                        .oneProductModel.product!
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Telefon qilish",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    height: 55,
                                    width: 165,
                                  ),
                                  SizedBox(
                                    height: 55,
                                    width: 165,
                                    child: ElevatedButton(
                                      onPressed: () {
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
                                                  await create_chat(user_id,state.oneProductModel.product!.userId ?? 0);
                                                },
                                                text: 'Chatni boshlash',
                                                // iconData: Icons.done,
                                                color: Colors.blue,
                                                textStyle: TextStyle(color: Colors.white),
                                                iconColor: Colors.white,
                                              ),
                                            ]);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                      child: Row(
            
                                        children: [
                                          Text(
                                            "Xabar yozish",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                        ],
                                        mainAxisAlignment: MainAxisAlignment.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
            if (state is GetOneProductError) {
              Center(child: Text("Server connection error"));
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class FullScreenMapScreen extends StatefulWidget {
  @override
  _FullScreenMapScreenState createState() => _FullScreenMapScreenState();
}

class _FullScreenMapScreenState extends State<FullScreenMapScreen> {
  late GoogleMapController mapController;

  final LatLng amirTemurSquare = LatLng(41.31115, 69.27975);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: amirTemurSquare,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: MarkerId('amirTemurSquare'),
            position: amirTemurSquare,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed), // Red marker
          ),
        },
        zoomControlsEnabled: true,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: true,
      ),
    );
  }
}
