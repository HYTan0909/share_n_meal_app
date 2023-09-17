import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:share_n_meal_app/ride_driver_maps_page.dart';

import 'ride_driver_history_page.dart';

class RideDriverMainPage extends StatefulWidget {
  const RideDriverMainPage({Key? key}) : super(key: key);

  @override
  State<RideDriverMainPage> createState() => _RideDriverMainPageState();
}

class _RideDriverMainPageState extends State<RideDriverMainPage> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;

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
