import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ehson/api/models/category_model.dart';
import 'package:ehson/bloc/add_product/add_product_bloc.dart';
import 'package:ehson/screen/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;

import '../../../constants/constants.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _controller_title = TextEditingController();
  final TextEditingController _controller_body = TextEditingController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  String? _errorMessage1;
  String? _errorMessage2;
  String? _errorMessage3;

  @override
  void dispose() {
    _controller_title.dispose();
    _controller_body.dispose();
    super.dispose();
  }

  Future<void> _validateFields() async {
    setState(() {
      _errorMessage1 =
          _controller_title.text.isEmpty ? 'Iltimos sarlavhani kiriting' : null;
      _errorMessage2 =
          _controller_body.text.isEmpty ? 'Iltimos ruknnni kiriting' : null;
    });
    if (_controller_title.text.isEmpty || _controller_body.text.isEmpty) {
      return;
    } else {
      String title = _controller_title.text.toString();
      String info = _controller_body.text.toString();
      //qani nima bumayopti??
      //bulli nma bulli
      //hot restart qisan pasga print qiganman tokenni ushani qoyasan postmanga keyen ishlaydi bu token har 1 soatga yangi bulad
      //
      //loading dialog chiqarish kerak
      context.loaderOverlay.show();

      String addProduct = await add_product(title, info, category_id,city_id, rasm1);
      if (addProduct.contains("Success")) {
        context.loaderOverlay.hide();
        Fluttertoast.showToast(
            msg: "E'lon qo'shildi!",
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

  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  String? rasm1;
  String? rasm2;
  String? rasm3;

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
        final respStr = await response.stream.bytesToString();
        final decodedJson = jsonDecode(respStr);
        print('Image upload failed.'+decodedJson.toString());
        return "Error";
      }
    }
    catch(e){
      print(e.toString());
      return "Error";
    }

  }

  //qanay qilib faqat bitta rasm tanlaykon qisa bo'ladi?
  Future<void> _pickImagesFromGallery() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only select up to 3 images.')),
      );
      return;
    }

    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null) {
      for (var image in pickedImages) {
        if (rasm1 == null) {
          String rasm1_upload = await _uploadImage(image);
          if (rasm1_upload != "Error") {
            setState(() {
              _images.add(image);
              rasm1 = rasm1_upload;
            });
          }
        } else if (rasm2 == null) {
          String rasm1_upload = await _uploadImage(image);
          if (rasm1_upload != "Error") {
            setState(() {
              _images.add(image);
              rasm2 = rasm1_upload;
            });
          }
        } else {
          String rasm1_upload = await _uploadImage(image);
          if (rasm1_upload != "Error") {
            setState(() {
              _images.add(image);
              rasm3 = rasm1_upload;
            });
          }
        }
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only select up to 3 images.')),
      );
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
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
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Kameradan olish'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  //

  void _showImageOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: Text(
                'Olib tashlash',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.of(context).pop();
                setState(() {
                  if (index == 0) {
                    rasm1 = null;
                  } else if (index == 1) {
                    rasm2 = null;
                  } else {
                    rasm3 = null;
                  }
                  _images.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  final List<String> items = [];
  final List<String> cities = [];
  String? selectedValue;
  String? selectedValue_city;
  int category_id = 0;
  int city_id = 0;

  Future<String> add_product(
      String title, String info, int category_id, int city_id,String? img1) async {
    var uri = Uri.parse(AppConstans.BASE_URL + '/addproduct');
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    Map data = {
      "title": title,
      "info": info,
      "category_id": category_id,
      "city_id": city_id,
      "img1": img1,
    };
    var body = json.encode(data);

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json","Authorization": 'Bearer $token',},
        body: body,
      );

      if (response.statusCode == 200) {
        final resdata = json.decode(utf8.decode(response.bodyBytes));
        print(resdata);
        if (resdata["status"] == true) {
          return "Success";
        } else {
          return "Error: ${response.statusCode}";
        }
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      print("Error: $e");
      return "Exception: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("E'lon berish"),
      ),
      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: () {
            BlocProvider.of<AddProductBloc>(context)
                .add(AddProductLoadingData());
            _refreshController.refreshCompleted();
          },
          child: BlocBuilder<AddProductBloc, AddProductState>(
            builder: (context, state) {
              if (state is AddProductSuccess) {
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
                return LoaderOverlay(
                  useDefaultLoading: false,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --> intro kattaroq text
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 10),
                            child: Text(
                              "Rasmlar",
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          // --> rasm quwiw
                          //birdaniga 3 ta knopka chiqib hammasini bitta bitta bosib tanlaydigan qilib bilasanmi?
                          //4 ta tanlasam qaysi birini olopti 1-sini
                          Container(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Container(
                                  height: 150,
                                  child: GridView.builder(
                                    padding: EdgeInsets.all(8.0),
                                    scrollDirection: Axis.vertical,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount: 3,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () => _images
                                                .asMap()
                                                .containsKey(index)
                                            ? _showImageOptions(context, index)
                                            : _showImageSourceActionSheet(
                                                context),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            width: 100,
                                            height: 100,
                                            child: !_images
                                                    .asMap()
                                                    .containsKey(index)
                                                ? Icon(Icons.camera_alt,
                                                    size: 50,
                                                    color: Colors.grey)
                                                : Image.file(
                                                    File(_images[index].path),
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Expanded(
                                //   child: Align(
                                //     alignment: Alignment.bottomCenter,
                                //     child: Text(
                                //       'Birinchi surat e’loningiz asosiy rasmi bo’ladi.\nSuratlar tartibini ularning ustiga bosib va olib o’tish bilan o’zgartirishingiz mumkin.',
                                //       style: TextStyle(
                                //           fontSize: 14, color: Colors.grey),
                                //       textAlign: TextAlign.center,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),

                          // --> title

                          SizedBox(
                            
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              "Title",
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(fontSize: 20)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: _controller_title,
                              maxLength: 20,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                errorText: _errorMessage1,
                                labelStyle: TextStyle(color: Colors.grey),
                                hintText: 'Masalan: 40-razmerli tufli',
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
                                        color: Colors.blueAccent, width: 2.0)),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              "Category",
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(fontSize: 20)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField2<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              value: items.first,
                              hint: const Text(
                                'Select Category',
                                style: TextStyle(fontSize: 14),
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
                                Categories cat = state.categoryModel.categories!
                                    .firstWhere((category) =>
                                        category.name == selectedValue);
                                category_id = cat.id!;
                              },
                              buttonStyleData: const ButtonStyleData(
                                padding: EdgeInsets.only(right: 8),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black45,
                                ),
                                iconSize: 24,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 10,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              "Shaharlar",
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(fontSize: 20)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField2<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              value: cities.first,
                              hint: const Text(
                                'Shaharni tanlang',
                                style: TextStyle(fontSize: 14),
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

                                  Cities citis = state
                                      .categoryModel.cities!
                                      .firstWhere((city) =>
                                      city.name == selectedValue_city);

                                  city_id = citis.id!;
                                  print(city_id);
                                });
                              },
                              onSaved: (value) {
                                selectedValue_city = value.toString();
                                Cities citis = state
                                    .categoryModel.cities!
                                    .firstWhere((city) =>
                                city.name == selectedValue_city);

                                city_id = citis.id!;
                              },
                              buttonStyleData: const ButtonStyleData(
                                padding: EdgeInsets.only(right: 8),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black45,
                                ),
                                iconSize: 24,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 10,
                          ),
                          // --> info
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              "Info",
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(fontSize: 20)),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: _controller_body,
                              maxLines: 4,
                              minLines: 3,
                              maxLength: 300,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                errorText: _errorMessage3,
                                labelStyle: TextStyle(color: Colors.grey),
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
                                        color: Colors.blueAccent, width: 2.0)),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),

                          //--> Tasdiqlash Button

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.85,
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
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

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (state is AddProductError) {
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
