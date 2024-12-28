import 'package:ehson/api/models/user_info_model.dart';
import 'package:ehson/api/repository.dart';
import 'package:ehson/constants/constants.dart';
import 'package:ehson/screen/chat/chats_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
class ProfileInfo extends StatefulWidget {
  final int profile_id;
  final String? avatar;
  final String name;
  const ProfileInfo({super.key,required this.profile_id,required this.avatar,required this.name});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {

  UserInfoModel? _userInfoModel;

  RefreshController _refreshController =
  RefreshController(initialRefresh: true);
  String phone_num = "";

  Future<void> user_info()async{
    try{
      UserInfoModel? userInfoModel = await EhsonRepository().user_info(widget.profile_id);
      setState(() {
        _userInfoModel = userInfoModel;
        phone_num = _userInfoModel!.userInfo!.phone.toString();
      });
    }
    catch (e) {
      _userInfoModel = UserInfoModel(
        status: false
      );
      _refreshController.refreshCompleted();
      throw Exception("Server error $e");
    }

  }

  Future<void> _onrefresh() async {
    setState(() {
      _userInfoModel = null;
    });
    await user_info();
    _refreshController.refreshCompleted();
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

      ),
      body: SafeArea(
          child:SmartRefresher(
            controller: _refreshController,
            onRefresh:_onrefresh ,
            child: _userInfoModel == null ? SizedBox() : _userInfoModel!.status == false ?
            Container(

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
            )
                : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(100)),
                        width: 100,
                        height: 100,
                        child: InkWell(
                          onTap: () {

                          },
                          child:widget.avatar == null ? Icon(Icons.person,size: 30,) : Image.network(
                            AppConstans.BASE_URL2 + "images/" + widget.avatar!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04,),
                Text(
                  widget.name,
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon:Icon(Icons.phone),color: Colors.blue, onPressed: () {
                      if(_userInfoModel!.userInfo!.phone != null){
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
                                  makePhoneCall(_userInfoModel!.userInfo!.phone!);
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
                    },),
                    SizedBox(width: 10,),
                    Text(
                      "Phone:-"+phone_num,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }
}
