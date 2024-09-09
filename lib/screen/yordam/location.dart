import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  GoogleMapController? mapController;
  TextEditingController _addressController = TextEditingController();
  LatLng _currentPosition = LatLng(41.2995, 69.2401);
  Marker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition,
            zoom: 15.0,
          ),
        ),
      );
    });
  }

  Future<void> _showCurrentLocation() async {
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition,
            zoom: 15.0,
          ),
        ),
      );

      setState(() {
        _selectedMarker = Marker(
          markerId: MarkerId(_currentPosition.toString()),
          position: _currentPosition,
        );
      });
    }
  }

  Future<void> _onTap(LatLng position) async {
    //ushanga shuni yuborasan xay//davay zabanca zur faqat ozgina tezlashish kerak xay
    //muammo busa yoz cuzib yurima oldin kur yaxshilab keyene yoz xay
    String latlong =
        position.latitude.toString() + "," + position.longitude.toString();
    // print(position.latitude.toString()+","+position.longitude.toString());
    setState(() {
      _selectedMarker = Marker(
        markerId: MarkerId(position.toString()),
        position: position,
      );
    });

    List<geocoding.Placemark> placemarks =
        await geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      geocoding.Placemark place = placemarks[0];

      String address = "";

      if (place.street != null &&
          place.street!.isNotEmpty &&
          !place.street!.contains(RegExp(r'^\d'))) {
        address += "${place.street}, ";
      }
      if (place.name != null &&
          place.name!.isNotEmpty &&
          !place.name!.contains(RegExp(r'^\d'))) {
        address += "${place.name}, ";
      }
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        address += "${place.subLocality}, ";
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        address += "${place.locality}, ";
      }
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        address += "${place.administrativeArea}";
      }

      setState(() {
        _addressController.text = address.trim();
      });
    }
  }

  Future<void> _searchAndNavigate() async {
    String address = _addressController.text;
    List<geocoding.Location> locations =
        await geocoding.locationFromAddress(address);

    if (locations.isNotEmpty) {
      geocoding.Location location = locations.first;
      LatLng target = LatLng(location.latitude, location.longitude);

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: 15.0,
          ),
        ),
      );

      setState(() {
        _selectedMarker = Marker(
          markerId: MarkerId(target.toString()),
          position: target,
        );
      });
    }
  }

  void _saveCoordinates() {
    String address = _addressController.text;
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Manzil bo\'sh bo\'lishi mumkin emas'),
        ),
      );
      return;
    }

    Navigator.pop(context, address); // Ekranni yopish va manzilni qaytarish
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manzilni Tanlash"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveCoordinates,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15.0,
            ),
            markers: _selectedMarker != null ? {_selectedMarker!} : {},
            onTap: _onTap,
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: "Manzilni kiriting",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                    ),
                    onSubmitted: (value) {
                      _searchAndNavigate();
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchAndNavigate,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _showCurrentLocation,
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
