import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShowLocationScreen extends StatefulWidget {
  final String location;
  const ShowLocationScreen({super.key,required this.location});

  @override
  State<ShowLocationScreen> createState() => _ShowLocationScreenState();
}

class _ShowLocationScreenState extends State<ShowLocationScreen> {



  GoogleMapController? mapController;

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
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yordam"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: stringToLatLng(widget.location),
              zoom: 15.0,
            ),

            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            markers: {Marker(
              markerId: MarkerId(widget.location),
              position: stringToLatLng(widget.location),
            )},
          ),
        ],
      ),
    );
  }
}
