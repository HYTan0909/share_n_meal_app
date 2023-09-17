import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_n_meal_app/Cart.dart';
import 'package:share_n_meal_app/Menu.dart';
import 'package:intl/intl.dart';
import 'package:share_n_meal_app/meals_orders_page.dart';

import 'meal_options.dart';

class MealsCartPage extends StatefulWidget {
  const MealsCartPage({Key? key}) : super(key: key);

  @override
  State<MealsCartPage> createState() => _MealsCartPageState();
}

class _MealsCartPageState extends State<MealsCartPage> {
  //get the current user
  User? user = FirebaseAuth.instance.currentUser;

  //create a date time variable
  DateTime? orderDateTime;

  //function to create a date time picker for user to input the order date and time
  Future<void> _showDateTimePicker(BuildContext context) async {
    DateTime? selectedOrderDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selectedOrderDate != null) {
      TimeOfDay? selectedOrderTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedOrderTime != null) {
        setState(() {
          orderDateTime = DateTime(
            selectedOrderDate.year,
            selectedOrderDate.month,
            selectedOrderDate.day,
            selectedOrderTime.hour,
            selectedOrderTime.minute,
          );
        });

        //call the create order dialog function with order time here
        _createOrderDialog(context, orderDateTime!);
      }
    }
  }

  //function to show a message
  void showSnackBar(BuildContext context, content) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    String snackBarContent = content;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(snackBarContent),
        duration: Duration(seconds: 3),
      ),
    );
  }

  //function to delete user cart after placing an order
  Future<void> deleteAllCartItems(String currentUserId) async {
    try {
      //reference to cart collection
      CollectionReference cartCollection =
          FirebaseFirestore.instance.collection('cart');

      //query for documents with current user id
      QuerySnapshot querySnapshot =
          await cartCollection.where('userId', isEqualTo: currentUserId).get();

      //perform delete cart item actions
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        await cartCollection.doc(document.id).delete();
      }

      print('All items in cart deleted successfully');
    } catch (e) {
      print('Error deleting items in cart: $e');
    }
  }

  //function to check if the user cart is empty or not
  Future<bool> checkIfCartIsEmpty(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      // Check if there are no documents matching the userId
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking user cart: ${e}');
      return true; //assume that error means the cart is empty
    }
  }

  //function to delete single item in the cart
  void deleteSingleCartItem(String userId, String targetItem) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder<QuerySnapshot>(
            //connect to cart collection
            stream: FirebaseFirestore.instance
                .collection('cart')
                .where('userId', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator() //a loading indicator
                    );
              }

              //use ?. to safely access docs property
              final docs = snapshot.data?.docs;

              //handle case where no documents were retrieved
              if (docs == null || docs.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator() //a loading indicator,
                );
              }

              //call cart from cloud Firestore
              List<Cart> cartList = []; //call the List model class
              docs.forEach((doc) {
                //create a Menu object using documents stored in Firestore
                Cart cart = Cart(
                  userId: doc['userId'],
                  cartItem: doc['cartItem'],
                  cartItemPrice: doc['cartItemPrice'],
                  cartItemQuantity: doc['cartItemQuantity'],
                  cartItemImage: doc['cartItemImage'],
                );
                cartList.add(cart);
              });

              return AlertDialog(
                title: Text('Are you sure you want to delete this item? '),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            try {
                              //reference to cart collection
                              CollectionReference cartCollection =
                              FirebaseFirestore.instance.collection('cart');

                              //query for documents with current user id
                              QuerySnapshot querySnapshot = await cartCollection
                                  .where('userId', isEqualTo: userId)
                                  .where('cartItem', isEqualTo: targetItem)
                                  .get();

                              //perform delete cart item actions
                              for (QueryDocumentSnapshot document
                              in querySnapshot.docs) {
                                await cartCollection.doc(document.id).delete();
                              }

                              print('Item ${targetItem} in cart deleted successfully');
                            } catch (e) {
                              print('Error deleting items in cart: $e');
                            }
                            showSnackBar(context, 'Item deleted successfully!');
                            setState(() {

                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          )
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        });
  }

  //function to create an order confirmation dialog to the user
  void _createOrderDialog(BuildContext context, DateTime? orderDateTime) {
    String formattedOrderDateTime = '';

    if (orderDateTime != null) {
      formattedOrderDateTime =
          DateFormat('yyyy/MM/dd hh:mm a').format(orderDateTime);
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder<QuerySnapshot>(
              //connect to Firestore and access the 'cart' documents
              stream: FirebaseFirestore.instance
                  .collection('cart')
                  .where('userId', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator() //a loading indicator
                      );
                }

                //use ?. to safely access docs property
                final docs = snapshot.data?.docs;

                //handle case where no documents were retrieved
                if (docs == null || docs.isEmpty) {
                  return const Center(child: Text('No item is in the cart'));
                }

                //call cart from cloud Firestore
                List<Cart> cartList = []; //call the List model class
                docs.forEach((doc) {
                  //create a Menu object using documents stored in Firestore
                  Cart cart = Cart(
                    userId: doc['userId'],
                    cartItem: doc['cartItem'],
                    cartItemPrice: doc['cartItemPrice'],
                    cartItemQuantity: doc['cartItemQuantity'],
                    cartItemImage: doc['cartItemImage'],
                  );
                  cartList.add(cart);
                });

                int totalPrice = 0;
                int count = 0;
                String name = '';

                for (count; count < cartList.length; count++) {
                  totalPrice +=
                      int.parse(cartList[count].cartItemPrice);
                  name += cartList[count].cartItemQuantity +
                      'x ' +
                      cartList[count].cartItem +
                      '  RM' +
                      cartList[count].cartItemPrice +
                      ', ';
                }
                print(totalPrice);
                print(name);


                return AlertDialog(
                  title: Text('Order Time: ${formattedOrderDateTime}'),
                  content: Container(
                    width: double.maxFinite,
                    child: Column(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: cartList.length,
                            itemBuilder: (context, index) {
                              Cart cart = cartList[index];
                              return ListTile(
                                leading: Text('${cart.cartItemQuantity}x', style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                                title: Text(cart.cartItem, style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                                trailing: Text('Total: RM${cart.cartItemPrice}', style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                              );
                            }
                        ),
                        Spacer(),
                        Text('Total amount: RM$totalPrice', style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('Cancel'),
                    ),
                    SizedBox(
                      width: 32,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle the confirmation action here
                        //reference to order collection
                        CollectionReference ordersCollection =
                            FirebaseFirestore.instance.collection('orders');

                        //function to create an order
                        Future<void> createOrder(
                            String orderItem,
                            String orderTotal,
                            String userId,
                            String orderStatus,
                            String orderTime) async {
                          //check if user is logged in or not
                          if (user != null) {
                            try {
                              //create an order
                              await ordersCollection.add({
                                'userId': user!.uid,
                                'orderItem': orderItem,
                                'orderTotal': orderTotal,
                                'orderStatus': orderStatus,
                                'orderTime': orderTime,
                              });
                            } catch (e) {
                              print('Error creating order. $e');
                            }
                          }
                        }

                        createOrder(name, totalPrice.toString(), user!.uid,
                            'Preparing', formattedOrderDateTime);

                        showSnackBar(context, 'Order Created Successfully');

                        deleteAllCartItems(user!.uid);

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MealOptions()));
                      },
                      child: Text('Confirm Order'),
                    ),
                  ],
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Share N\' Meal App'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    'Item Cart',
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
              //connect to Firestore and access the 'cart' documents
              stream: FirebaseFirestore.instance
                  .collection('cart')
                  .where('userId', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator() //a loading indicator
                      );
                }

                //use ?. to safely access docs property
                final docs = snapshot.data?.docs;

                //handle case where no documents were retrieved
                if (docs == null || docs.isEmpty) {
                  return const Center(child: Text('No item is in the cart'));
                }

                //call cart from cloud Firestore
                List<Cart> cartList = []; //call the List model class
                docs.forEach((doc) {
                  //create a Menu object using documents stored in Firestore
                  Cart cart = Cart(
                    userId: doc['userId'],
                    cartItem: doc['cartItem'],
                    cartItemPrice: doc['cartItemPrice'],
                    cartItemQuantity: doc['cartItemQuantity'],
                    cartItemImage: doc['cartItemImage'],
                  );
                  cartList.add(cart);
                });

                return ListView.builder(
                    itemCount: cartList.length,
                    itemBuilder: (context, index) {
                      Cart cart = cartList[index];
                      return ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            //on tap action
                            deleteSingleCartItem(user!.uid, cart.cartItem);
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            child: Icon(
                              Icons.delete,
                              color: Colors
                                  .red, // You can customize the icon color
                              size: 32, // You can customize the icon size
                            ),
                          ),
                        ),
                        title: Text(cart.cartItem,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                        subtitle: Text('Quantity: ${cart.cartItemQuantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                        trailing: Text('RM ${cart.cartItemPrice}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                      );
                    });
              },
            ),
          ),
          const Spacer(),
          Column(
            children: <Widget>[
              FutureBuilder<bool>(
                future: checkIfCartIsEmpty(user!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData && !snapshot.data!) {
                    //cart is not empty
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  //on pressed action
                                  _showDateTimePicker(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    'Place Order',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    //cart is empty
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  //on pressed action
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MealOptions()));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    'Browse Menu',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
