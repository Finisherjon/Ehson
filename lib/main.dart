import 'package:ehson/bloc/add_product/add_product_bloc.dart';
import 'package:ehson/bloc/homebloc/home_bloc.dart';
import 'package:ehson/screen/add_product/screen/add_product_screen.dart';
import 'package:ehson/screen/bottom_bar.dart';
import 'package:ehson/screen/home/home_screen.dart';
import 'package:ehson/screen/verification/log_In_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


bool isreg = false;
final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly'
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await _prefs;

  isreg = prefs.getBool("regstatus") ?? false;
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyAVqdkABR2L5mzLt6oXMb1xfiTjHNzFxMw',
        appId: "1:892715575526:android:ae077b4239610b59d53327",
        messagingSenderId: "892715575526",
        projectId: "ehson-6d76d"),
  );
  runApp(const MyApp());
}

//hozircha + comment qilib qoy
//manashu floating action buttondan qusahdi

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  //gogole signni qiludikmi? ha
  //sign uini tugirlab qoy keyen
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AddProductBloc(),
        ),
        BlocProvider(
          create: (context) => HomeBloc(),
        ),
      ],
      // create: (context) => AddProductBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        //taxladinmi?
        // hoz bitta qarangqani
        //home screen qaysi bulopti?
        home: isreg ? BottomBar() : LoginScreen(),
        // home: LoginScreen(),
        // home: BottomBar(),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MapScreen(),
//     );
//   }
// }
//
// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? mapController;
//   final TextEditingController _addressController = TextEditingController();
//
//   final LatLng _initialPosition = const LatLng(41.2995, 69.2401); // San-Fransisko koordinatalari
//   Marker? _selectedMarker;
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
//
//   Future<void> _onTap(LatLng position) async {
//     setState(() {
//       _selectedMarker = Marker(
//         markerId: MarkerId(position.toString()),
//         position: position,
//       );
//     });
//
//     // Koordinatalarni manzilga o'zgartirish (Reverse Geocoding)
//     List<Placemark> placemarks = await placemarkFromCoordinates(
//       position.latitude,
//       position.longitude,
//     );
//
//     if (placemarks.isNotEmpty) {
//       Placemark place = placemarks[0];
//
//       // Faqat shahar, viloyat va mamlakatni tanlab olish
//       String address = "${place.locality}, ${place.administrativeArea}, ${place.country}";
//
//       setState(() {
//         _addressController.text = address;
//       });
//     }
//   }
//
//   Future<void> _searchAndNavigate() async {
//     String address = _addressController.text;
//
//     try {
//       // Manzilni koordinatalarga o'zgartirish (Forward Geocoding)
//       List<Location> locations = await locationFromAddress(address);
//
//       if (locations.isNotEmpty) {
//         Location location = locations[0];
//         LatLng target = LatLng(location.latitude, location.longitude);
//
//         mapController?.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(
//               target: target,
//               zoom: 12.0,
//             ),
//           ),
//         );
//
//         setState(() {
//           _selectedMarker = Marker(
//             markerId: MarkerId(target.toString()),
//             position: target,
//           );
//         });
//       }
//     } catch (e) {
//       // Agar manzil topilmasa, xato xabarini ko'rsatish
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Manzil topilmadi')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Xarita'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _addressController,
//               decoration: InputDecoration(
//                 labelText: 'Manzilni kiriting',
//                 border: OutlineInputBorder(),
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: _searchAndNavigate,
//                 ),
//               ),
//               onSubmitted: (value) => _searchAndNavigate(),
//             ),
//           ),
//           Expanded(
//             child: GoogleMap(
//               onMapCreated: _onMapCreated,
//               onTap: _onTap,
//               markers: _selectedMarker != null ? {_selectedMarker!} : {},
//               initialCameraPosition: CameraPosition(
//                 target: _initialPosition,
//                 zoom: 17.0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }