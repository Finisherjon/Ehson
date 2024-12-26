import 'dart:convert';
import 'dart:io';

import 'package:ehson/api/models/user_model.dart';
import 'package:ehson/api/repository.dart';
import 'package:ehson/screen/home/home_screen.dart';
import 'package:ehson/screen/verification/log_In_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constants.dart';
import '../../mywidgets/mywidgets.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  UserModel? userModel;

  final TextEditingController _controller_name = TextEditingController();
  final TextEditingController _controller_phone = TextEditingController();
  bool server_error = false;

  Future<void> _onrefresh() async {
    try {
      //getme funksiyasi faqat usermodel qaytaradi yoki null qaytaradi
      setState(() {
        userModel = null;
      });
      UserModel userModel_server = await EhsonRepository().get_me();
      setState(() {
        server_error = false;
        userModel = userModel_server;
        _controller_name.text = userModel!.user!.name.toString();
        if (userModel!.user!.phone != null) {
          _controller_phone.text = userModel!.user!.phone.toString();
        }
      });
    } catch (e) {
      //agar server bilan nimadir xatolik bugan paytga server_error degan uzgaruvchi olim ui ga xatolik buganini bildirish uchun
      setState(() {
        server_error = true;
      });
      //server bilan boglanishda xatolik
    }
    _refreshController.refreshCompleted();
  }

  String? profilePicture;
  String? _errorname;
  String? _errornumber;

  Future<void> _validateFields() async {
    setState(() {
      _errorname =
          _controller_name.text.isEmpty ? 'Iltimos Ismingizni kiriting' : null;
      _errornumber = _controller_phone.text.isEmpty
          ? 'Iltimos reqamingizni kiriting'
          : null;
    });
    if (_controller_name.text.isEmpty || _controller_phone.text.isEmpty) {
      return;
    } else {
      String name = _controller_name.text.toString();
      String phone = _controller_phone.text.toString();
      context.loaderOverlay.show();
      String add_info_response = await EhsonRepository()
          .add_info(name, phone, profilePicture == null ? "" : profilePicture!);
      if (add_info_response.contains("Success")) {
        context.loaderOverlay.hide();
        Fluttertoast.showToast(
            msg: "Ma'lumotlar yangilandi!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Profile()));
      } else {
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

  //
  //
  //

  final ImagePicker _picker = ImagePicker();
  File? _images;

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

      final SharedPreferences prefs = await _prefs;
      prefs.setBool("regstatus", false);
      prefs.setString("email", "");
      prefs.setString("name", "");
      prefs.setString("password", "");
      prefs.setString("fcmtoken", "");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        //bulimi polvon ha davom et xay
      );
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<String> _uploadImage(XFile image) async {
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    try{
      var uri = Uri.parse(AppConstans.BASE_URL + '/imageupload');
      Map <String,String>  headers = {"Authorization": 'Bearer $token',};
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', image!.path));
      request.headers.addAll(headers);
      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final decodedJson = jsonDecode(respStr);
        print(decodedJson);
        print(decodedJson['image_name']);
        return decodedJson['image_name'];
      } else {
        print('Image upload failed.');
        return "Error";
      }
    }
    catch(e){
      print(e.toString());
      return "Error";
    }

  }

  //

  Future<void> _pickImagesFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {

      //qani berra image berganin _uploadImage funksiyaga murojat uchun ichiga file qoymaysanmi?
      String uploaded_image_name = await _uploadImage(pickedFile);
      if (uploaded_image_name != "Error") {
        // setState(() {
        //   _images = File(pickedFile.path); // Assigning the picked image
        // });
        setState(() {
          profilePicture = uploaded_image_name;
          if (pickedFile != null) {
            _images = File(pickedFile.path);
          }
        });
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // setState(() {
      //   _images = File(pickedFile.path); // Assigning the picked image
      // });
      setState(() {
        if (pickedFile != null) {
          _images = File(pickedFile.path);
        }
      });
    }
  }

  //endi yordamni taxlaymiz yordamni taxlaysan

  Future _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galereyadan tanlash'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImagesFromGallery();
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.photo_camera),
            //   title: Text('Kameradan olish'),
            //   onTap: () {
            //     Navigator.of(context).pop();
            //     _pickImageFromCamera();
            //   },
            // ),
          ],
        ),
      ),
    );
  }
  //tax buliptiku
  //like pagedagi hamma productga like bosilgan tursin keyen yanam bossa apiga post qilib listdan uchirib tawasin
  @override
  Widget build(BuildContext context) {
    //bitta smartrefresher qoyamiz
    return Scaffold(
      appBar: AppBar(
        title: Text("Ma'lumotlarim"),
        centerTitle: true,
      ),
      body: LoaderOverlay(
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onrefresh,
          child: server_error
                ? Container(
              child: MyWidget().mywidget("Serverda xatolik!"),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.86,
            )
                : userModel == null
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              //
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: _showImageSourceActionSheet,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        width: 100,
                                        height: 100,
                                        child:
                                        // _images == null
                                        //   ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                                        //     : Image.file(_images!, fit: BoxFit.cover),
                                        //endi tayor buli jurajon
                                        _images != null ?
                                        Image.file(
                                                _images!,
                                                fit: BoxFit.cover,
                                              )
                                        :
                                        userModel!.user!.avatar == "" || userModel!.user!.avatar == null
                                            ? Icon(Icons.person,
                                            size: 60, color: Colors.blue)
                                            :
                                        Image.network(
                                          AppConstans
                                              .BASE_URL2 +"images/"+
                                              userModel!.user!.avatar.toString(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // CircleAvatar(
                                  //   backgroundColor: Colors.black,
                                  //   radius: 55,
                                  //   child: CircleAvatar(
                                  //     radius: 52,
                                  //     // backgroundImage: NetworkImage(
                                  //     //     userModel!.user!.avatar,
                                  //     //   "https://www.tu-ilmenau.de/unionline/fileadmin/_processed_/0/0/csm_Person_Yury_Prof_Foto_AnLI_Footgrafie__2_.JPG_94f12fbf25.jpg",
                                  //     // ),
                                  //     backgroundImage: userModel
                                  //                 ?.user?.avatar !=
                                  //             null
                                  //         //sherini kuriw kk
                                  //         ? NetworkImage(userModel!.user!.avatar
                                  //             .toString())
                                  //         : NetworkImage(
                                  //                 'https://www.tu-ilmenau.de/unionline/fileadmin/_processed_/0/0/csm_Person_Yury_Prof_Foto_AnLI_Footgrafie__2_.JPG_94f12fbf25.jpg')
                                  //             as ImageProvider,
                                  //     onBackgroundImageError: (_, __) {
                                  //       // Handle error
                                  //     },
                                  //   ),
                                  // ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              //qara danniylarini tugirla
                              //phone null bulishi mumkin avataram
                              //boshqa daniylari bumaydi gender region holidayla
                              //nameni phonesini va rasmini uzgartirishi mumkin
                              Text(
                                userModel!.user!.email.toString(),
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                  userModel!.user!.phone != null ? "Telefon raqam: " + userModel!.user!.phone.toString() : "Telefon raqam: - ",
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Divider(
                                  color: Colors.grey[400],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: TextFormField(
                                  controller: _controller_name,
                                  maxLength: 20,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    errorText: _errorname,
                                    labelStyle: TextStyle(color: Colors.grey),
                                    hintText: userModel!.user!.name,
                                    //fullnamiga srazi name chiqsinda rasmigayam rasmi busa phonesigayam phonesi busa shulani chiqor qani keyen update qiladigan api beraman
                                    //g_m funksiyasiniyam kurib chiq model bilan qanay qilim shulaniyam hammasini xoxlasan xblayock qushib qoy blxaoklik qil xoxlasan man ketim
                                    //savola yoqmi?
                                    //gender bn tugilganni kkmasmi yoq hozircha comment qilib qoy kerka emas manimcha xay regiyoanmmi xa
                                    //xay zabanca ramsni tanlagan payt image upload busin serverga shuniyam qil add productga bor usha
                                    hintStyle: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors.blueAccent, width: 2.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Container(
                              //       width:
                              //           MediaQuery.of(context).size.width * 0.43,
                              //       child: TextFormField(
                              //         //design chotki
                              //         //backendniyam shunay urgansan
                              //         keyboardType: TextInputType.name,
                              //         decoration: InputDecoration(
                              //           labelStyle: TextStyle(color: Colors.grey),
                              //           hintText: 'Gender',
                              //           hintStyle: TextStyle(
                              //               fontSize: 14, color: Colors.grey),
                              //           contentPadding: EdgeInsets.symmetric(
                              //               vertical: 15, horizontal: 20),
                              //           border: OutlineInputBorder(
                              //             borderRadius: BorderRadius.circular(15),
                              //           ),
                              //           focusedBorder: OutlineInputBorder(
                              //             borderRadius: BorderRadius.circular(15),
                              //             borderSide: BorderSide(
                              //                 color: Colors.blueAccent,
                              //                 width: 2.0),
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //     SizedBox(
                              //       width: 10,
                              //     ),
                              //     Container(
                              //       width:
                              //           MediaQuery.of(context).size.width * 0.43,
                              //       child: Padding(
                              //         padding: const EdgeInsets.only(left: 15),
                              //         child: TextFormField(
                              //           // controller: _controller_title,
                              //           keyboardType: TextInputType.name,
                              //           decoration: InputDecoration(
                              //             // errorText: _errorMessage1,
                              //             labelStyle:
                              //                 TextStyle(color: Colors.grey),
                              //             hintText: 'Birthday',
                              //             hintStyle: TextStyle(
                              //                 fontSize: 14, color: Colors.grey),
                              //             contentPadding: EdgeInsets.symmetric(
                              //                 vertical: 15, horizontal: 20),
                              //             border: OutlineInputBorder(
                              //               borderRadius:
                              //                   BorderRadius.circular(15),
                              //             ),
                              //             focusedBorder: OutlineInputBorder(
                              //               borderRadius:
                              //                   BorderRadius.circular(15),
                              //               borderSide: BorderSide(
                              //                   color: Colors.blueAccent,
                              //                   width: 2.0),
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // SizedBox(
                              //   height: 20,
                              // ),
                              // Padding(
                              //   padding: EdgeInsets.symmetric(horizontal: 15),
                              //   child: TextFormField(
                              //     // controller: _controller_title,
                              //
                              //     keyboardType: TextInputType.name,
                              //     decoration: InputDecoration(
                              //       // errorText: _errorMessage1,
                              //       labelStyle: TextStyle(color: Colors.grey),
                              //       hintText: 'Region',
                              //       hintStyle: TextStyle(
                              //           fontSize: 14, color: Colors.grey),
                              //       contentPadding: EdgeInsets.symmetric(
                              //           vertical: 15, horizontal: 20),
                              //       border: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(15),
                              //       ),
                              //       focusedBorder: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(15),
                              //         borderSide: BorderSide(
                              //             color: Colors.blueAccent, width: 2.0),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 20,
                              // ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: TextFormField(
                                  controller: _controller_phone,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    errorText: _errornumber,
                                    //endi qara
                                    //1) 2 ta text fieledni bush emasligini tekshirasan save tugma bosilsa
                                    //2) bush bumasa va oldingidan uzgargan busa post qilasan
                                    // masalan name uzgardi serverga nameni olib post qilasan
                                    //{
                                    //     "name":"Yorqin",
                                    //     "phone":"+998998206846",
                                    //     "avatar":"wqieiugqre.png"
                                    // }
                                    //telefon uzgarsa phoneniyam qushib uzotasan jsonga uzgarmagan busa nameni uzini
                                    //shuni qilchi
                                    //tushundinmi hadavay
                                    //anabu update buganini qanay bilsam buladi eski data
                                    //name textfieledni hozirgi texttini qanay olala?
                                    //controller bn
                                    //yaxshi serverdan kegan malumot borku sanga usha bilan tekshirasanda
                                    //serverdan kegan malumot qaysi uzgaruvchiga kursatchi?
                                    //tel raqam kiritilmagan bazaga null turipti
                                    // errorText: _errorMessage1,
                                    labelStyle: TextStyle(color: Colors.grey),
                                    hintText: "Telefon raqam",

                                    hintStyle: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors.blueAccent, width: 2.0),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.19,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                      onPressed: _validateFields,
                                      child: Text(
                                        "Saqlash",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: ()async{

                                        Dialogs.materialDialog(
                                            color: Colors.white,
                                            msg: "Akkauntdan chiqishni xoxlaysizmi?",
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

                                                  bool absd = await signOutFromGoogle();
                                                  if(!absd){
                                                    Fluttertoast.showToast(
                                                        msg: "Akkauntdan chiqishda xatolik! Qayta urunib ko'ring!",
                                                        toastLength: Toast.LENGTH_SHORT,
                                                        gravity: ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor: Colors.red,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
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
                                      child: Text(
                                        "Chiqish",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // SizedBox(
                              //   height: MediaQuery.of(context).size.height * 0.03,
                              // )
                            ],
                          ),
                        ),
                      ),

        ),
      ),
    );
  }
}
