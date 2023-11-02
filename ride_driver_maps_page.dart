import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:badges/badges.dart' as badge;
import 'package:share_n_meal_app/ride_driver_carpool_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_n_meal_app/ride_driver_ongoing_request_page.dart';

class RideDriverMapsPage extends StatefulWidget {

  const RideDriverMapsPage({Key? key}) : super(key: key);

  @override
  State<RideDriverMapsPage> createState() => _RideDriverMapsPageState();
}

class _RideDriverMapsPageState extends State<RideDriverMapsPage> {

  //current user
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference collectionReference = FirebaseFirestore.instance.collection('carpoolRequest');
  GoogleMapController? mapController;
  LocationData? currentLocation;

  int calculateAcceptedRequestCount(List<QueryDocumentSnapshot> notifications, String userId) {
    int acceptedRequestCount = 0;

    for (final notification in notifications) {
      final status = notification['status'] as String;
      final notificationUserID  = notification['driverId'] as String;
      if (status == 'Accepted' && notificationUserID  == userId) {
        acceptedRequestCount++;
      }
    }

    return acceptedRequestCount;
  }

  void getCurrentLocation() {
    Location location = Location();

    location.getLocation().then(
            (location) {
          currentLocation = location;
          setState(() {});
        }
    );
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    markers.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialTarget;
    if (markers!.isNotEmpty) {
      initialTarget = LatLng(markers!.first.position.latitude, markers!.first.position.longitude);
    } else if (currentLocation != null) {
      initialTarget = LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
    } else {
      initialTarget = const LatLng(0, 0); // Default target
    }

    return Scaffold(
      body: currentLocation == null
          ? const Center(child: Text('Loading'))
          : Stack(
        children: [
          GoogleMap(
            markers: markers,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 15.0,
            ),
            //onTap: onMapTapped,
          ),
          Positioned(
            bottom: 64.0,
            left: 16.0,
            child: StreamBuilder<QuerySnapshot>(
              stream: collectionReference.snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  int newNotificationsCount = calculateAcceptedRequestCount(snapshot.data!.docs, user!.uid);

                  return Stack(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          // Your press action for the floating action button
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RideDriverOngoingRequestPage()
                              )
                          );
                        },
                        child: const Icon(Icons.directions_car), // Replace with your desired icon
                      ),
                      if (newNotificationsCount > 0)
                        Positioned(
                          top: 0, // Adjust the top value to move the badge upwards
                          right: 0, // Adjust the right value to move the badge to the right
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              newNotificationsCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  );
                }
                return FloatingActionButton(
                  onPressed: () {
                    //on press action
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RideDriverOngoingRequestPage()
                        )
                    );
                  },
                  child: const Icon(Icons.directions_car),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

