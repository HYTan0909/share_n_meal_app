import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_n_meal_app/home_page.dart';
import 'package:share_n_meal_app/meals_cart_page.dart';
import 'package:share_n_meal_app/meals_history_page.dart';
import 'package:share_n_meal_app/meals_orders_page.dart';
import 'package:share_n_meal_app/meals_menu_page.dart';

void main() => runApp(const MealOptions());

class MealOptions extends StatefulWidget {
  const MealOptions({Key? key}) : super(key: key);

  @override
  State<MealOptions> createState() => _MealOptionsState();
}

class _MealOptionsState extends State<MealOptions> {
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
        actions: <Widget>[
          IconButton(
              onPressed: (){
                //on press action
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MealsCartPage()
                    )
                );
              },
              icon: Icon(Icons.shopping_cart_outlined),
          )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          MealsMenuPage(),
          MealsOrdersPage(),
          MealsHistoryPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
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

