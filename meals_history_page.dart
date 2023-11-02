import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_n_meal_app/Order.dart';
import 'package:intl/intl.dart';
import 'package:share_n_meal_app/meals_order_details.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealsHistoryPage extends StatefulWidget {
  const MealsHistoryPage({Key? key}) : super(key: key);

  @override
  State<MealsHistoryPage> createState() => _MealsHistoryPageState();
}

class _MealsHistoryPageState extends State<MealsHistoryPage> {
  //get the current user
  User? user = FirebaseAuth.instance.currentUser;

  //reference to orders collection
  CollectionReference orderCollection =
      FirebaseFirestore.instance.collection('orders');

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
                    'Order History',
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
              //connect to Firestore and access the 'orders' documents
              stream: orderCollection
                  .where('orderStatus', whereIn: ['Completed', 'Removed'])
                  .where('userId', isEqualTo: user!.uid)
                  .orderBy('orderTime', descending: true)
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
                        'No data available'),
                  ); //handle case where no documents are retrieved
                }

                //call menu from cloud Firestore
                List<Orders> ordersList = []; //call the Menu model class
                docs.forEach((doc) {
                  // Access the document ID
                  String documentId = doc.id;

                  //create a Orders object using documents stored in Firestore
                  Orders orders = Orders(
                      userId: doc['userId'],
                      id: documentId,
                      item: doc['orderItem'],
                      status: doc['orderStatus'],
                      time: doc['orderTime'],
                      total: doc['orderTotal'],
                      deleteReason: doc['deleteReason']);
                  ordersList.add(orders);
                });

                return ListView.builder(
                    itemCount: ordersList.length,
                    itemBuilder: (context, index) {
                      Orders orders = ordersList[index];

                      return ListTile(
                        //leading: Icon(Icons.history),
                        title: Text('Order ID: ${orders.id.substring(0, 10)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        subtitle: Text('${orders.time}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        trailing: Text('Status: ${orders.status}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: orders.status == 'Removed'
                                  ? Colors.redAccent
                                  : Colors.green,
                            )),
                        onTap: () {
                          //on tap action
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MealsOrderDetails(
                                        order: ordersList[index],
                                      )));
                        },
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
