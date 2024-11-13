import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../api/repository.dart';

class AddMavzu extends StatefulWidget {
  const AddMavzu({super.key});

  @override
  State<AddMavzu> createState() => _AddMavzuState();
}

class _AddMavzuState extends State<AddMavzu> {
  final TextEditingController _controller_title = TextEditingController();
  final TextEditingController _controller_mavzu = TextEditingController();

  String? _errortitle;
  String? _errormavzu;

  Future<void> _validateFields() async {
    setState(() {
      _errortitle =
          _controller_title.text.isEmpty ? 'Iltimos title kiriting' : null;
    });
    if (_controller_title.text.isEmpty || _controller_mavzu.text.isEmpty) {
      return;
    } else {
      String title = _controller_title.text.toString();
      String mavzu = _controller_mavzu.text.toString();
      context.loaderOverlay.show();
      String add_mavzu_response = await EhsonRepository().add_mavzu(
        title,
        mavzu,
      );
      if (add_mavzu_response.contains("Success")) {
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
          centerTitle: true,
          title: Text('Add Mavzu'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 90,
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
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: _controller_mavzu,
                  maxLength: 50,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    errorText: _errormavzu,
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
                height: 30,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "body",
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
                  maxLines: 3,
                  minLines: 2,
                  maxLength: 99,
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
              SizedBox(
                height: 250,
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
                      // onPressed: () {},
                      onPressed: _validateFields,
                      child: Text(
                        "Mavzuni joylashtirish",
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
    );
  }
}
