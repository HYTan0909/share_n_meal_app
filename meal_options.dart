import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badge;
import 'package:share_n_meal_app/meals_cart_page.dart';
import 'package:share_n_meal_app/meals_history_page.dart';
import 'package:share_n_meal_app/meals_orders_page.dart';
import 'package:share_n_meal_app/meals_menu_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(const MealOptions());

class MealOptions extends StatefulWidget {
  const MealOptions({Key? key}) : super(key: key);

  @override
  State<MealOptions> createState() => _MealOptionsState();
}

class _MealOptionsState extends State<MealOptions> {

  //current user
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference collectionReference = FirebaseFirestore.instance.collection('cart');
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;

    });
  }

  int calculateCartItemCount(List<QueryDocumentSnapshot> notifications, String userID) {
    int cartItemCount = 0;

    for (final notification in notifications) {
      final notificationUserID = notification['userId'] as String;

      if (notificationUserID == userID) {
        cartItemCount++;
      }
    }

    return cartItemCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Share N\' Meal App'),
        actions: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: collectionReference.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                //calculate number of new notifications
                int newNotificationsCount = calculateCartItemCount(snapshot.data!.docs, user!.uid);

                //display the badge only when newNotificationsCount > 0
                if (newNotificationsCount > 0) {
                  return badge.Badge(
                      badgeContent: Text(
                        newNotificationsCount.toString(),
                        style: const TextStyle(
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
                                  builder: (context) => MealsCartPage()
                              )
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
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
                              builder: (context) => MealsCartPage()
                          )
                      );
                    },
                    icon: Icon(Icons.shopping_cart_outlined),
                  )
              );
            },
          ),
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

