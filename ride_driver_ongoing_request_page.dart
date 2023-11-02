import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_n_meal_app/CarpoolModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_n_meal_app/ride_driver_carpool_details_page.dart';
import 'package:share_n_meal_app/ride_driver_main_page.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDriverOngoingRequestPage extends StatefulWidget {
  const RideDriverOngoingRequestPage({Key? key}) : super(key: key);

  @override
  State<RideDriverOngoingRequestPage> createState() =>
      _RideDriverOngoingRequestPageState();
}

class _RideDriverOngoingRequestPageState
    extends State<RideDriverOngoingRequestPage> {
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
        markerId: MarkerId('Passenger Location'),
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

  void cancelCarpoolRequest(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm cancel this request?'),
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
                      //function to cancel carpool request
                      Future<void> cancelRequest(String driverId) async {
                        try {
                          //find carpool requests of driver
                          QuerySnapshot querySnapshot =
                              await carpoolRequestCollection
                                  .where('driverId', isEqualTo: driverId)
                                  .where('status', isEqualTo: 'Accepted')
                                  .get();

                          //find the matching passengerId and update the status
                          for (QueryDocumentSnapshot doc
                              in querySnapshot.docs) {
                            await carpoolRequestCollection.doc(doc.id).update({
                              'status': 'Pending',
                              'driverId': '',
                            });
                          }
                        } catch (e) {
                          print('Error updating status for passenger. $e');
                        }
                      }

                      cancelRequest(user!.uid);
                      showSnackBar(context, 'Request cancelled successfully. ');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RideDriverMainPage(),
                          ));
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ],
          );
        });
  }

  void completeCarpoolRequest(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm complete this request?'),
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
                      Future<void> completeRequest(String driverId) async {
                        try {
                          //find carpool requests of driver
                          QuerySnapshot querySnapshot =
                              await carpoolRequestCollection
                                  .where('driverId', isEqualTo: driverId)
                                  .where('status', isEqualTo: 'Accepted')
                                  .get();

                          //find the matching passengerId and update the status
                          for (QueryDocumentSnapshot doc
                              in querySnapshot.docs) {
                            await carpoolRequestCollection.doc(doc.id).update({
                              'status': 'Completed',
                            });
                          }
                        } catch (e) {
                          print('Error updating status for passenger. $e');
                        }
                      }

                      completeRequest(user!.uid);
                      showSnackBar(context, 'Request completed successfully! ');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RideDriverMainPage(),
                          ));
                    },
                    child: const Text('Confirm'),
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
      body: FutureBuilder<QuerySnapshot>(
        future: carpoolRequestCollection
            .where('driverId', isEqualTo: user!.uid)
            .where('status', isEqualTo: 'Accepted')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No data available.'),
            );
          } else {
            QueryDocumentSnapshot doc =
                snapshot.data!.docs.first; // Access the first document

            // Display data row by row
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Text(
                            'Ongoing Carpool Request',
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
                      'Request ID: ${doc.id.substring(0, 10)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Pickup Time: ${doc['time']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Name: ${doc['passengerName']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Passenger Count: ${doc['passengerCount']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Contact: ${doc['contact']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Destination: ${doc['destination']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //on press action
                      searchPlace(doc['destination']);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RideDriverMainPage(),
                          )
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.map),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Status: ${doc['status']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          //on press action
                          cancelCarpoolRequest(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Cancel Request',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          //on press action
                          completeCarpoolRequest(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Complete Request',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
