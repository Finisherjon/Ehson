import 'dart:convert';
import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ehson/api/models/create_chat_model.dart';
import 'package:ehson/api/repository.dart';
import 'package:ehson/bloc/message/message_list_bloc.dart';
import 'package:ehson/mywidgets/mywidgets.dart';
import 'package:ehson/screen/chat/one_chat.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/get_one_help/get_one_help_bloc.dart';
import '../../constants/constants.dart';

class HelpInfo extends StatefulWidget {
  final int help_id;

  const HelpInfo({super.key, required this.help_id});

  @override
  _HelpInfoState createState() => _HelpInfoState();
}

class _HelpInfoState extends State<HelpInfo> {
  final List<String> imageUrls = [
    'https://paragonfootwear.com/cdn/shop/files/MK8009K-NYB_LS.jpg?v=1718789930&width=1920',
  ];

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

  int user_id = 0;

  Future<void> getSharedPrefs() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    //tokenni login qigan paytimiz sharedga saqlab qoyganbiza
    final SharedPreferences prefs = await _prefs;
    user_id = prefs.getInt("user_id") ?? 0;
  }

  final PageController _pageController = PageController();
  final LatLng amirTemurSquare = LatLng(41.3111, 69.2797);
  LatLng stringToLatLng(String str) {
    final parts = str.split(',');
    if (parts.length != 2) {
      throw FormatException("Invalid LatLng string format");
    }
    final latitude = double.parse(parts[0]);
    final longitude = double.parse(parts[1]);
    return LatLng(latitude, longitude);
  }
  @override
  void initState() {
    super.initState();
    getSharedPrefs();
    BlocProvider.of<GetOneHelpBloc>(context)
        .add(GetOneHelpLoadingDate(widget.help_id));
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
      body: LoaderOverlay(
        child: SafeArea(
          child: BlocBuilder<GetOneHelpBloc, GetOneHelpState>(
            builder: (context, state) {
              if (state is GetOneHelpSuccess) {
                return Stack(
                  children: [
                    SizedBox(
                      height: 335,
                      width: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return state.oneHelpModel.help!.img == null ||  state.oneHelpModel.help!.img == ""
                              ? MyWidget().defimagewidget(context)
                              :CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:AppConstans.BASE_URL2 + "images/" + state.oneHelpModel.help!.img.toString(),
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
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),
                                Text(
                                  state.oneHelpModel.help!.title!,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  state.oneHelpModel.help!.info!,
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                  style: GoogleFonts
                                      .roboto(
                                    textStyle:
                                    TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Divider(
                                    color: Colors.grey[400],
                                  ),
                                ),
                                Text(
                                  state.oneHelpModel.help!.createdAt!,
                                  style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
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
                                          'Ayollar Ko\'ylagi',
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
                                          'Toshkent shahri',
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

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 180,
                                          width: 340,
                                          child: GoogleMap(
                                            initialCameraPosition: CameraPosition(
                                              zoom: 13.6,
                                              target: stringToLatLng(state.oneHelpModel.help!.location.toString()),
                                            ),
                                            markers: {
                                              Marker(
                                                markerId:
                                                MarkerId('amirTemurSquare'),
                                                position: stringToLatLng(state.oneHelpModel.help!.location.toString()),
                                              ),
                                            },
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator
                                                .push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                    ShowLocationScreen(location: state.oneHelpModel.help!.location.toString()),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: 180,
                                            width: 340,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                // Two buttons
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      child: ElevatedButton(
                                        onPressed:
                                            () {
                                          if(state
                                              .oneHelpModel.help!
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
                                                      makePhoneCall(
                                                          state.oneHelpModel.help!.phone.toString());
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
                                              "Phone",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Icon(
                                              Icons.phone,
                                              color: Colors.white,
                                            )
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
                                                    await create_chat(user_id,state.oneHelpModel.help!.userId ?? 0);
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
                                              "Massage",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Icon(
                                              Icons.chat,
                                              color: Colors.white,
                                            )
                                          ],
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
              if (state is GetOneHelpError) {
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

class MapScreen extends StatelessWidget {
  final LatLng location;

  MapScreen({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: location,
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: MarkerId('selected_location'),
            position: location,
            infoWindow: InfoWindow(title: "Selected Location"),
          ),
        },
      ),
    );
  }
}

class FullScreenMapScreen extends StatelessWidget {
  final LatLng amirTemurSquare = LatLng(41.3111, 69.2797);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Amir Temur Square"),
        backgroundColor: Colors.blueAccent,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: amirTemurSquare,
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: MarkerId('amirTemurSquare'),
            position: amirTemurSquare,
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
