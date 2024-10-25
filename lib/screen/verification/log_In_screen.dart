import 'dart:convert';

import 'package:ehson/adjust_size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/login_api.dart';
import '../bottom_bar.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ValueNotifier userCredential = ValueNotifier('');

  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      // TODO
      print('exception->$e');
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<void> login(String name, String email, String password) async {
    try {
      String resData = await PostLogin().postLogin(name, email, password);
      if (resData != "Error") {
        final Future<SharedPreferences> _prefs =
            SharedPreferences.getInstance();
        final SharedPreferences prefs = await _prefs;
        prefs.setBool("regstatus", true);
        prefs.setString("email", email);
        prefs.setString("name", name);
        prefs.setString("password", password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomBar()),
          //bulimi polvon ha davom et xay
        );
      } else {
        print("Bera xatolik haqida xabar chiqar");
      }
    } catch (e) {
      print(e.toString());
      print("Bera xatolik haqida xabar chiqar");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(title: const Text('Google SignIn Screen')),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Sizes.heights(context) * 0.17,
              ),
              Text(
                "See waht's \nhappening in the \nworld right now.",
                style: GoogleFonts.roboto(
                  textStyle:
                      TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: Sizes.heights(context) * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () async {
                        userCredential.value = await signInWithGoogle();
                        if (userCredential.value != null) {
                          String name = userCredential.value.user!.displayName;
                          String email = userCredential.value.user!.email;
                          String password = userCredential.value.user!.uid;
                          await login(name, email, password);
                        } else {
                          print("Bera google xatolik haqida xabar chiqar");
                        }
                      },
                      child: Card(
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: Colors.black,
                            width: 0.5,
                          ),
                        ),
                        color: Colors.white,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20, // Image radius
                              backgroundImage: NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6WwgH7Nl5_AW9nDCnR2Ozb_AU3rkIbSJdAg&s'),
                            ),
                            SizedBox(
                              width: Sizes.widths(context) * 0.02,
                            ),
                            Text(
                              "Continue with google",
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: Sizes.heights(context) * 0.03,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     SizedBox(
              //       width: MediaQuery.of(context).size.width * 0.8,
              //       height: MediaQuery.of(context).size.height * 0.08,
              //       child: InkWell(
              //         onTap: () {},
              //         borderRadius: BorderRadius.circular(30),
              //         child: Card(
              //           shape: StadiumBorder(
              //             side: BorderSide(
              //               color: Colors.black,
              //               width: 0.5,
              //             ),
              //           ),
              //           color: Colors.white,
              //           child: Row(
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               CircleAvatar(
              //                 backgroundColor: Colors.white,
              //                 radius: 18, // Image radius
              //                 backgroundImage: NetworkImage(
              //                     'https://1000logos.net/wp-content/uploads/2016/10/Apple-Logo.png'),
              //               ),
              //               SizedBox(
              //                 width: 10,
              //               ),
              //               Text(
              //                 "Continue with apple",
              //                 style: GoogleFonts.roboto(
              //                   textStyle: TextStyle(
              //                       fontWeight: FontWeight.bold,
              //                       fontSize: 17),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     )
              //   ],
              // ),
              // SizedBox(
              //   height: 10,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.36,
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Or"),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.36,
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: Sizes.heights(context) * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        HapticFeedback.selectionClick();
                      },
                      child: Card(
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: Colors.white,
                            width: 0.5,
                          ),
                        ),
                        color: Colors.blue,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Create account",
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: Sizes.heights(context) * 0.02,
              ),
              Text(
                "By signing up, you agree to the Terms of Service and \nPrivacy and Policy, including Cookies Use.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
