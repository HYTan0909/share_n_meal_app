import 'package:flutter/material.dart';
import 'package:share_n_meal_app/CarpoolModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_n_meal_app/ride_driver_main_page.dart';
import 'package:share_n_meal_app/ride_options.dart';

class RidePassengerRequestDetailsPage extends StatefulWidget {
  final CarpoolModel carpoolModel;

  const RidePassengerRequestDetailsPage({Key? key, required this.carpoolModel})
      : super(key: key);

  @override
  State<RidePassengerRequestDetailsPage> createState() =>
      _RidePassengerRequestDetailsPageState();
}

class _RidePassengerRequestDetailsPageState
    extends State<RidePassengerRequestDetailsPage> {
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

  void deleteCarpoolRequest(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm delete this request?'),
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
                      //function to delete carpool request
                      Future<void> deleteRequest(String passengerId) async {
                        try {
                          //find carpool requests of passenger
                          QuerySnapshot querySnapshot =
                              await carpoolRequestCollection
                                  .where('passengerId', isEqualTo: passengerId)
                                  .where('status', isEqualTo: 'Pending')
                                  .get();

                          //find the matching passengerId and update the status
                          for (QueryDocumentSnapshot doc
                              in querySnapshot.docs) {
                            await carpoolRequestCollection.doc(doc.id).delete();
                          }
                        } catch (e) {
                          print('Error updating status for passenger. $e');
                        }
                      }

                      deleteRequest(user!.uid);
                      showSnackBar(context, 'Request deleted successfully. ');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RideOptions(),
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
                    ? Colors.deepOrangeAccent : Colors.green,
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          if (widget.carpoolModel.status == 'Pending')
            Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              //on pressed action
                              deleteCarpoolRequest(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                'Delete Request',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    ]
      )
    )
    ;

  }
}
