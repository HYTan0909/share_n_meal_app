import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_n_meal_app/ride_passenger_history_page.dart';
import 'package:share_n_meal_app/ride_passenger_request_page.dart';

class RidePassengerMainPage extends StatefulWidget {
  const RidePassengerMainPage({Key? key}) : super(key: key);

  @override
  State<RidePassengerMainPage> createState() => _RidePassengerMainPageState();
}

class _RidePassengerMainPageState extends State<RidePassengerMainPage> {

  //current user
  User? user = FirebaseAuth.instance.currentUser;

  int currentIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Share N\' Meal App'),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: const [
          RidePassengerRequestPage(),
          RidePassengerHistoryPage(),
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
        currentIndex: currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: onItemTapped,
      ),
    );
  }
}
