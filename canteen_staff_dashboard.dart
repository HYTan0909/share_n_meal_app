import 'package:flutter/material.dart';
import 'package:share_n_meal_app/canteen_menu_page.dart';
import 'package:share_n_meal_app/canteen_order_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CanteenStaffDashboard extends StatefulWidget {
  const CanteenStaffDashboard({Key? key}) : super(key: key);

  @override
  State<CanteenStaffDashboard> createState() => _CanteenStaffDashboardState();
}

class _CanteenStaffDashboardState extends State<CanteenStaffDashboard> {
  //current operating state
  bool isOperating = true;

  @override
  void initState() {
    super.initState();
    // Call the function to fetch and update 'isOperating' when the widget initializes.
    fetchCanteenState();
  }

  //function to get the operating state in Firestore
  Future<void> fetchCanteenState() async {
    try {
      final canteenStateDoc = await FirebaseFirestore.instance
          .collection('canteenState')
          .doc('GmWhGb5cSg1XOVGt4J6m')
          .get();
      if (canteenStateDoc.exists) {
        final data = canteenStateDoc.data();
        final isOperatingFromFirestore = data?['isOperating'] as bool;

        // Update the state with the value from Firestore.
        setState(() {
          isOperating = isOperatingFromFirestore;
        });
      }
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  //function to update the operating state in Firestore
  Future<void> updateOperatingState(bool newValue) async {
    try {
      await FirebaseFirestore.instance
          .collection('canteenState')
          .doc('GmWhGb5cSg1XOVGt4J6m')
          .update({
        'isOperating': newValue,
      });
    } catch (e) {
      print('Error updating data in Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Share N\' Meal App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            const Text(
              'Canteen Management',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 160,
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () {
                      //on press action
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CanteenMenuPage()));
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu,
                          size: 40,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Menu",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 160,
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () {
                      //on press action
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CanteenOrderPage()));
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pending,
                          size: 40,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Orders",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Canteen Operation State: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Switch(
                      value: isOperating,
                      onChanged: (bool newValue) {
                        setState(() {
                          isOperating = newValue;
                          updateOperatingState(newValue);
                        });
                      })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
