import 'package:flutter/material.dart';
import 'package:share_n_meal_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_n_meal_app/Order.dart';

import 'meals_order_details.dart';

class MealsOrdersPage extends StatefulWidget {
  const MealsOrdersPage({Key? key}) : super(key: key);

  @override
  State<MealsOrdersPage> createState() => _MealsOrdersPageState();
}

class _MealsOrdersPageState extends State<MealsOrdersPage> {

  //get the current user
  User? user = FirebaseAuth.instance.currentUser;

  //reference to orders collection
  CollectionReference orderCollection = FirebaseFirestore.instance.collection('orders');

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
              stream: FirebaseFirestore.instance.collection('orders').where('orderStatus', isEqualTo: 'Preparing').where('userId', isEqualTo: user!.uid).snapshots(),
              builder: (context, snapshot) {
                if(!snapshot.hasData){
                  return const Center(
                      child: CircularProgressIndicator()  //a loading indicator
                  );
                }

                //use ?. to safely access docs property
                final docs = snapshot.data?.docs;

                if(docs == null || docs.isEmpty){
                  return const Text('No Orders available'); //handle case where no documents are retrieved
                }

                //call menu from cloud Firestore
                List<Orders> ordersList = []; //call the Menu model class
                docs.forEach((doc) {

                  // Access the document ID
                  String documentId = doc.id;

                  //create a Orders object using documents stored in Firestore
                  Orders orders = Orders(
                    userId: user! .uid,
                    id: documentId,
                    item: doc['orderItem'],
                    status: doc['orderStatus'],
                    time: doc['orderTime'],
                    total: doc['orderTotal'],
                  );
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
                            )
                        ),
                        subtitle: Text('Order Time: ${orders.time}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )
                        ),
                        trailing: Text('${orders.status}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent,
                          )
                      ),
                        onTap: (){
                          //on tap action
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MealsOrderDetails(order: ordersList[index],)
                              )
                          );
                        },
                      );
                    }
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
