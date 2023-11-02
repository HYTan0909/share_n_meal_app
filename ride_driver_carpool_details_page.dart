import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_n_meal_app/CarpoolModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:share_n_meal_app/ride_driver_main_page.dart';
import 'package:share_n_meal_app/ride_driver_maps_page.dart';

Set<Marker> markers = {};

class RideDriverCarpoolDetailsPage extends StatefulWidget {
  final CarpoolModel carpoolModel;

  const RideDriverCarpoolDetailsPage({Key? key, required this.carpoolModel})
      : super(key: key);

  @override
  State<RideDriverCarpoolDetailsPage> createState() =>
      _RideDriverCarpoolDetailsPageState();
}

class _RideDriverCarpoolDetailsPageState
    extends State<RideDriverCarpoolDetailsPage> {
  //current user
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference carpoolRequestCollection =
      FirebaseFirestore.instance.collection('carpoolRequest');

  void showSnackBar(BuildContext context, content) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    String snackBarContent = content;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(snackBarContent),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> searchPlace(String query) async {
    List<Location> locations = await locationFromAddress(query);

    if (locations.isNotEmpty) {
      final location = locations.first;
      final newMarker = Marker(
        markerId: const MarkerId('Passenger Location'),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(
          title: query,
        ),
      );

      setState(() {
        markers.add(newMarker);
      });
    }
  }

  //function to check if driver has an accepted request or not
  Future<bool> hasAcceptedRequest(String driverId) async {
    try {
      //find carpool requests with the given driverId and 'Accepted' status
      QuerySnapshot querySnapshot = await carpoolRequestCollection
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'Accepted')
          .get();

      return querySnapshot.size >
          0; //return true if have accepted request, false otherwise
    } catch (e) {
      print('Error checking for accepted requests. $e');
      return false;
    }
  }

  void _acceptCarpoolRequest(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Accept this Request?'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //function to accept carpool request
                      Future<void> acceptRequest(
                          String passengerId, String driverId) async {
                        CollectionReference carpoolRequestCollection =
                            FirebaseFirestore.instance
                                .collection('carpoolRequest');

                        try {
                          //find carpool requests with the given passengerId
                          QuerySnapshot querySnapshot =
                              await carpoolRequestCollection
                                  .where('passengerId', isEqualTo: passengerId)
                                  .get();

                          //find the matching passengerId and update the status
                          for (QueryDocumentSnapshot doc
                              in querySnapshot.docs) {
                            await carpoolRequestCollection.doc(doc.id).update(
                                {'status': 'Accepted', 'driverId': driverId});
                          }
                        } catch (e) {
                          print('Error updating status for passenger. $e');
                        }
                      }

                      acceptRequest(widget.carpoolModel.passengerId, user!.uid);

                      searchPlace(widget.carpoolModel.destination);

                      print(markers.toString());

                      showSnackBar(context, 'Request accepted successfully! ');

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RideDriverMainPage(),
                          ));
                    },
                    child: const Text('Confirm Accept'),
                  ),
                ],
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Share N\' Meal App'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    'Carpool Details',
                    style: TextStyle(
                      fontSize: 36.0, // Adjust the font size as needed
                      fontWeight: FontWeight.bold,
                      fontFamily: 'DancingScript',
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black, // Set the color of the divider
                  thickness: 2.0, // Set the thickness of the divider
                  height: 20.0, // Set the height of the divider
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Request ID: ${widget.carpoolModel.id.substring(0, 8)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Pickup Time: ${widget.carpoolModel.time}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Name: ${widget.carpoolModel.passengerName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Passenger Count: ${widget.carpoolModel.passengerCount}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Contact : ${widget.carpoolModel.contact}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Destination: ${widget.carpoolModel.destination}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Status: ${widget.carpoolModel.status}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: widget.carpoolModel.status == 'Pending'
                    ? Colors.deepOrangeAccent
                    : Colors.green,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          if (widget.carpoolModel.status == 'Completed')
            const Center(child: Text(''))
          else
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          //on pressed action
                          searchPlace(widget.carpoolModel.destination);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RideDriverMainPage(),
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'View on Map',
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          //on pressed action
                          bool acceptedRequest =
                              await hasAcceptedRequest(user!.uid);
                          if (acceptedRequest) {
                            showSnackBar(
                                context, 'You already have an ongoing request');
                          } else {
                            _acceptCarpoolRequest(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Accept Request',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}
