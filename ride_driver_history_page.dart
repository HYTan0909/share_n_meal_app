import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_n_meal_app/CarpoolModel.dart';
import 'package:share_n_meal_app/ride_driver_carpool_details_page.dart';

class RideDriverHistoryPage extends StatefulWidget {
  const RideDriverHistoryPage({Key? key}) : super(key: key);

  @override
  State<RideDriverHistoryPage> createState() => _RideDriverHistoryPageState();
}

class _RideDriverHistoryPageState extends State<RideDriverHistoryPage> {
  //get the current user
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      'Carpool History',
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
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              //connect to Firestore and access the 'carpoolRequest' documents
              stream: FirebaseFirestore.instance
                  .collection('carpoolRequest')
                  .where('driverId', isEqualTo: user!.uid)
                  .where('status', isEqualTo: 'Completed')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator() //a loading indicator
                      );
                }

                //use ?. to safely access docs property
                final docs = snapshot.data?.docs;

                if (docs == null || docs.isEmpty) {
                  return const Center(
                      child: Text(
                          'No data available')
                  ); //handle case where no documents are retrieved
                }

                //call carpool model from cloud Firestore
                List<CarpoolModel> carpoolModelList = [];
                docs.forEach((doc) {
                  // Access the document ID
                  String documentId = doc.id;

                  //create a carpool model object using documents stored in Firestore
                  CarpoolModel carpoolModel = CarpoolModel(
                    driverId: doc['driverId'],
                    passengerId: doc['passengerId'],
                    id: documentId,
                    time: doc['time'],
                    status: doc['status'],
                    destination: doc['destination'],
                    passengerCount: doc['passengerCount'],
                    passengerName: doc['passengerName'],
                    contact: doc['contact'],
                  );
                  carpoolModelList.add(carpoolModel);
                });

                return ListView.builder(
                    itemCount: carpoolModelList.length,
                    itemBuilder: (context, index) {
                      CarpoolModel carpoolModel = carpoolModelList[index];

                      return ListTile(
                        //leading: Icon(Icons.history),
                        title: Text(
                            'Carpool ID: ${carpoolModel.id.substring(0, 8)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        subtitle: Text(
                            'Passenger Name: ${carpoolModel.passengerName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        trailing: Text('${carpoolModel.time}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                        onTap: () {
                          //on tap action
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RideDriverCarpoolDetailsPage(
                                          carpoolModel:
                                              carpoolModelList[index])));
                        },
                      );
                    });
              },
            )),
          ]),
    );
  }
}
