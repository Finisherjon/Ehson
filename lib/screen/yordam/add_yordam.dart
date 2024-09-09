import 'dart:convert';
import 'dart:io';

import 'package:ehson/screen/yordam/location.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/repository.dart';
import '../../constants/constants.dart';
import 'package:http/http.dart' as http;
class AddYordam extends StatefulWidget {
  const AddYordam({super.key});

  @override
  State<AddYordam> createState() => _AddYordamState();
}

class _AddYordamState extends State<AddYordam> {
  final TextEditingController _savedAddressController = TextEditingController();
  final TextEditingController _controller_title = TextEditingController();
  final TextEditingController _controller_info = TextEditingController();
  final TextEditingController _controller_number = TextEditingController();


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
//prosta ui ku holi hechi yoqku ?
  //zur gap yoq faqat anlagan joyini lat longini serverga yuborishin kerak

  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String server_image_upload_name = await _uploadImage(pickedFile);
      if(server_image_upload_name != "Error"){
        setState(() {
          _image = File(pickedFile.path);
          profilePicture = server_image_upload_name;
        });
      }
      else{
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

  String? profilePicture;
  String? _errortitle;
  String? _errorinfo;
  String? _errornumber;
  String? _errorlocation;

  Future<void> _validateFields() async {
    setState(() {
      _errortitle =
          _controller_title.text.isEmpty ? 'Iltimos title kiriting' : null;
      _errorinfo =
          _controller_info.text.isEmpty ? 'Iltimos info kiriting' : null;
      _errorlocation = _savedAddressController.text.isEmpty
          ? 'Iltimos location kiriting'
          : null;
      _errornumber = _controller_number.text.isEmpty
          ? 'Iltimos phone number kiriting'
          : null;
    });
    if (_controller_title.text.isEmpty ||
        _controller_info.text.isEmpty ||
        _controller_number.text.isEmpty ||
        _savedAddressController.text.isEmpty) {
      return;
    } else {
      String title = _controller_title.text.toString();
      String info = _controller_info.text.toString();
      String number = _controller_number.text.toString();
      String location = _savedAddressController.text.toString();
      context.loaderOverlay.show();
      String add_yordam_response = await EhsonRepository()
          .add_yordam(title, info, number,profilePicture == null ? "" : profilePicture!,location );
      if (add_yordam_response.contains("Success")) {
        context.loaderOverlay.hide();
        Fluttertoast.showToast(
            msg: "Ma'lumotlar yangilandi!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Yordam"),
          centerTitle: true,
        ),
        body: LoaderOverlay(
          useDefaultLoading: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // SizedBox(
                  //   height: 10,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        // onTap: _showImageSourceActionSheet,
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          width: 250,
                          height: 150,
                          child: _image == null
                              ? Icon(
                                  Icons.wallpaper,
                                  size: 40,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          // Icon(
                          //   Icons.wallpaper,
                          //   size: 40,
                          // ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "Title",
                          style: GoogleFonts.roboto(
                              textStyle: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: _controller_title,
                      maxLength: 20,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        errorText: _errortitle,
                        labelStyle: TextStyle(color: Colors.grey),
                        // hintText: userModel!.user!.name,
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.blueAccent, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "Info",
                          style: GoogleFonts.roboto(
                              textStyle: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: _controller_info,
                      maxLines: 2,
                      minLines: 1,
                      maxLength: 50,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        errorText: _errorinfo,
                        labelStyle: TextStyle(color: Colors.grey),
                        // hintText: userModel!.user!.name,
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.blueAccent, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "Phone number",
                          style: GoogleFonts.roboto(
                              textStyle: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: _controller_number,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        errorText: _errornumber,
                        labelStyle: TextStyle(color: Colors.grey),
                        // hintText: userModel!.user!.name,
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: Colors.blueAccent, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "Location",
                          style: GoogleFonts.roboto(
                              textStyle: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 11, right: 10),
                          child: TextFormField(
                            controller: _savedAddressController,
                            readOnly: true,
                            maxLines: 2,
                            minLines: 1,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              // errorText: _errorname,
                              labelStyle: TextStyle(color: Colors.grey),
                              // hintText: userModel!.user!.name,
                              hintStyle:
                                  TextStyle(fontSize: 14, color: Colors.grey),
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
                      ),
                      Container(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Location(),
                              ),
                            );
                            if (result != null) {
                              _savedAddressController.text = result;
                            }
                          },
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 25,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: MediaQuery.of(context).size.height * 0.06,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                          ),
                          onPressed: _validateFields,
                          child: Text(
                            "E'lonni joylashtirish",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
