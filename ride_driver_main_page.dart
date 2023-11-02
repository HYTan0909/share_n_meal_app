import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_n_meal_app/ride_driver_carpool_request_page.dart';
import 'package:share_n_meal_app/ride_driver_maps_page.dart';
import 'package:badges/badges.dart' as badge;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'ride_driver_history_page.dart';

class RideDriverMainPage extends StatefulWidget {
  const RideDriverMainPage({Key? key}) : super(key: key);

  @override
  State<RideDriverMainPage> createState() => _RideDriverMainPageState();
}

class _RideDriverMainPageState extends State<RideDriverMainPage> {

  //current user
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference collectionReference = FirebaseFirestore.instance.collection('carpoolRequest');

  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;

    });
  }

  int calculatePendingNotificationsCount(List<QueryDocumentSnapshot> notifications) {
    int pendingNotificationsCount = 0;

    for (final notification in notifications) {
      final status = notification['status'] as String;
      if (status == 'Pending') {
        pendingNotificationsCount++;
      }
    }

    return pendingNotificationsCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Share N\' Meal App'),
        actions: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: collectionReference.where('status', isEqualTo: 'Pending').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                //calculate number of new notifications
                int newNotificationsCount = calculatePendingNotificationsCount(snapshot.data!.docs);

                //display the badge only when newNotificationsCount > 0
                if (newNotificationsCount > 0) {
                  return badge.Badge(
                      badgeContent: Text(
                        newNotificationsCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      position: badge.BadgePosition.topEnd(top: 0, end: 3),
                      child: IconButton(
                        onPressed: (){
                          //on press action
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RideDriverCarpoolRequestPage()
                              )
                          );
                        },
                        icon: Icon(Icons.people),
                      )
                  );
                }
              }

              //default badge with no count
              return badge.Badge(
                badgeContent: Text(''),
                child: IconButton(
                  onPressed: (){
                    //on press action
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RideDriverCarpoolRequestPage()
                        )
                    );
                  },
                  icon: Icon(Icons.people),
                )
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          RideDriverMapsPage(),
          RideDriverHistoryPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
