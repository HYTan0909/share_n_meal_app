import 'package:flutter/material.dart';
import 'package:share_n_meal_app/canteen_menu_page.dart';
import 'package:share_n_meal_app/canteen_ongoing_orders_page.dart';
import 'package:share_n_meal_app/canteen_order_history_page.dart';

class CanteenOrderPage extends StatefulWidget {
  const CanteenOrderPage({Key? key}) : super(key: key);

  @override
  State<CanteenOrderPage> createState() => _CanteenOrderPageState();
}

class _CanteenOrderPageState extends State<CanteenOrderPage> {

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
          CanteenOngoingOrders(),
          CanteenOrderHistoryPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(Icons.dinner_dining),
            label: 'Orders',
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
