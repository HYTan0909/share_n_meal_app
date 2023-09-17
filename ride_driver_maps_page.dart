import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class RideDriverMapsPage extends StatefulWidget {
  const RideDriverMapsPage({Key? key}) : super(key: key);

  @override
  State<RideDriverMapsPage> createState() => _RideDriverMapsPageState();
}

class _RideDriverMapsPageState extends State<RideDriverMapsPage> {
  GoogleMapController? _controller;
  LatLng _currentLatLng = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Future<void> _getCurrentLocation() async {
  //   final position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  //
  //   setState(() {
  //     _currentLatLng = LatLng(position.latitude, position.longitude);
  //   });
  //
  //   // Move the camera to the user's location
  //   if (_controller != null) {
  //     _controller!.animateCamera(CameraUpdate.newLatLng(_currentLatLng));
  //   }
  // }

  Future<void> _getCurrentLocation() async {
    final location = Location();
    final LocationData position = await location.getLocation();

    setState(() {
      _currentLatLng = LatLng(position.latitude!, position.longitude!);
    });

    // Move the camera to the user's location
    if (_controller != null) {
      _controller!.animateCamera(CameraUpdate.newLatLng(_currentLatLng));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLatLng,
          zoom: 15.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          setState(() {
            _controller = controller;
          });
        },
        markers: Set<Marker>.from([
          Marker(
            markerId: MarkerId('marker 1'),
            position: _currentLatLng,
            infoWindow: InfoWindow(
              title: 'Your location',
              snippet: 'You are here',
            ),
          ),
        ]),
      ),
    );
  }
}
