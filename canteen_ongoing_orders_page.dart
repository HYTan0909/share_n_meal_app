import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_n_meal_app/Order.dart';
import 'package:share_n_meal_app/canteen_order_details_page.dart';

class CanteenOngoingOrders extends StatelessWidget {
  const CanteenOngoingOrders({Key? key}) : super(key: key);

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
                    'Ongoing Orders',
                    style: TextStyle(
                      fontSize: 36.0, // Adjust the font size as needed
                      fontWeight: FontWeight.bold,
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
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('orderStatus', isEqualTo: 'Preparing')
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
                  return const Text(
                      'No data available'); //handle case where no documents are retrieved
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
                        subtitle: Text(orders.time,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        trailing: Text('Status: ${orders.status}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            )),
                        onTap: () {
                          //on tap action
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CanteenOrderDetailsPage(
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

