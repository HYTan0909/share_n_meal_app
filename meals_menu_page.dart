import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_n_meal_app/Menu.dart';
import 'package:share_n_meal_app/meals_cart_page.dart';
import 'package:share_n_meal_app/meals_order_details.dart';
import 'package:share_n_meal_app/meals_single_food_page.dart';
import 'package:share_n_meal_app/src/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealsMenuPage extends StatefulWidget {
  const MealsMenuPage({Key? key}) : super(key: key);

  @override
  State<MealsMenuPage> createState() => _MealsMenuPageState();
}

class _MealsMenuPageState extends State<MealsMenuPage> {
  //current operating state
  bool isOperating = false;

  @override
  void initState() {
    super.initState();
    //call the function to fetch the operation state of canteen
    fetchCanteenState();
  }

  //function to update the operating state in Firestore
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isOperating == false)
              Column(
                children: [
                  const SizedBox(
                    height: 24,
                  ),
                  Image.network(
                      'https://cdn3.iconfinder.com/data/icons/shopping-icons-14/128/18_Closed_Sign-512.png'),
                  const Center(
                      child: Text(
                    'Out of canteen operation time \n Please come again tomorrow! ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontStyle: FontStyle.italic),
                  )),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Text(
                            'Canteen Menu',
                            style: TextStyle(
                              fontSize: 36.0, // Adjust the font size as needed
                              fontWeight: FontWeight.bold,
                              fontFamily: 'DancingScript',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Rice',
                          style: TextStyle(
                            fontSize: 24.0, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Divider(
                          color: Colors.black, // Set the color of the divider
                          thickness: 2.0, // Set the thickness of the divider
                          height: 20.0, // Set the height of the divider
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    child: StreamBuilder<QuerySnapshot>(
                      //connect to Firestore and access the 'menu' documents
                      stream: FirebaseFirestore.instance
                          .collection('menu')
                          .where('foodType', isEqualTo: 'Rice')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child:
                                  CircularProgressIndicator() //a loading indicator
                              );
                        }

                        //use ?. to safely access docs property
                        final docs = snapshot.data?.docs;

                        if (docs == null || docs.isEmpty) {
                          return const Center(
                              child: Text(
                                  'No data available')); //handle case where no documents are retrieved
                        }

                        //call menu from cloud Firestore
                        List<Menu> menuList = []; //call the Menu model class
                        docs.forEach((doc) {
                          //create a Menu object using documents stored in Firestore
                          Menu menu = Menu(
                            id: doc.id,
                            name: doc['foodName'],
                            description: doc['foodDescription'],
                            imageUrl: doc['foodImage'],
                            price: doc['foodPrice'].toString(),
                            type: doc['foodType'].toString(),
                          );
                          menuList.add(menu);
                        });

                        return ListView.builder(
                            itemCount: menuList.length,
                            itemBuilder: (context, index) {
                              Menu menu = menuList[index];
                              return ListTile(
                                leading: Container(
                                    height: 60,
                                    width: 60,
                                    child: Image.network(menu.imageUrl)),
                                title: Text(menu.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                                trailing: Text('RM ${double.parse(menu.price).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )),
                                onTap: () {
                                  //on tap action
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MealsSingleFoodPage(
                                                  menu: menuList[index])));
                                },
                              );
                            });
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Noodles',
                          style: TextStyle(
                            fontSize: 24.0, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Divider(
                          color: Colors.black, // Set the color of the divider
                          thickness: 2.0, // Set the thickness of the divider
                          height: 20.0, // Set the height of the divider
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    child: StreamBuilder<QuerySnapshot>(
                      //connect to Firestore and access the 'menu' documents
                      stream: FirebaseFirestore.instance
                          .collection('menu')
                          .where('foodType', isEqualTo: 'Noodles')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child:
                                  CircularProgressIndicator() //a loading indicator
                              );
                        }

                        //use ?. to safely access docs property
                        final docs = snapshot.data?.docs;

                        if (docs == null || docs.isEmpty) {
                          return const Center(
                              child: Text(
                                  'No data available')); //handle case where no documents are retrieved
                        }

                        //call menu from cloud Firestore
                        List<Menu> menuList = []; //call the Menu model class
                        docs.forEach((doc) {
                          //create a Menu object using documents stored in Firestore
                          Menu menu = Menu(
                            id: doc.id,
                            name: doc['foodName'],
                            description: doc['foodDescription'],
                            imageUrl: doc['foodImage'],
                            price: doc['foodPrice'].toString(),
                            type: doc['foodType'].toString(),
                          );
                          menuList.add(menu);
                        });

                        return ListView.builder(
                            itemCount: menuList.length,
                            itemBuilder: (context, index) {
                              Menu menu = menuList[index];
                              return ListTile(
                                leading: Container(
                                    height: 60,
                                    width: 60,
                                    child: Image.network(menu.imageUrl)),
                                title: Text(menu.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                                trailing: Text('RM ${double.parse(menu.price).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )),
                                onTap: () {
                                  //on tap action
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MealsSingleFoodPage(
                                                  menu: menuList[index])));
                                },
                              );
                            });
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Beverages',
                          style: TextStyle(
                            fontSize: 24.0, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Divider(
                          color: Colors.black, // Set the color of the divider
                          thickness: 2.0, // Set the thickness of the divider
                          height: 20.0, // Set the height of the divider
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    child: StreamBuilder<QuerySnapshot>(
                      //connect to Firestore and access the 'menu' documents
                      stream: FirebaseFirestore.instance
                          .collection('menu')
                          .where('foodType', isEqualTo: 'Beverages')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child:
                                  CircularProgressIndicator() //a loading indicator
                              );
                        }

                        //use ?. to safely access docs property
                        final docs = snapshot.data?.docs;

                        if (docs == null || docs.isEmpty) {
                          return const Center(
                              child: Text(
                                  'No data available')); //handle case where no documents are retrieved
                        }

                        //call menu from cloud Firestore
                        List<Menu> menuList = []; //call the Menu model class
                        docs.forEach((doc) {
                          //create a Menu object using documents stored in Firestore
                          Menu menu = Menu(
                            id: doc.id,
                            name: doc['foodName'],
                            description: doc['foodDescription'],
                            imageUrl: doc['foodImage'],
                            price: doc['foodPrice'].toString(),
                            type: doc['foodType'].toString(),
                          );
                          menuList.add(menu);
                        });

                        return ListView.builder(
                            itemCount: menuList.length,
                            itemBuilder: (context, index) {
                              Menu menu = menuList[index];
                              return ListTile(
                                leading: Container(
                                    height: 60,
                                    width: 60,
                                    child: Image.network(menu.imageUrl)),
                                title: Text(menu.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                                trailing: Text('RM ${double.parse(menu.price).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )),
                                onTap: () {
                                  //on tap action
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MealsSingleFoodPage(
                                                  menu: menuList[index])));
                                },
                              );
                            });
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Others',
                          style: TextStyle(
                            fontSize: 24.0, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Divider(
                          color: Colors.black, // Set the color of the divider
                          thickness: 2.0, // Set the thickness of the divider
                          height: 20.0, // Set the height of the divider
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    child: StreamBuilder<QuerySnapshot>(
                      //connect to Firestore and access the 'menu' documents
                      stream: FirebaseFirestore.instance
                          .collection('menu')
                          .where('foodType', isEqualTo: 'Others')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child:
                                  CircularProgressIndicator() //a loading indicator
                              );
                        }

                        //use ?. to safely access docs property
                        final docs = snapshot.data?.docs;

                        if (docs == null || docs.isEmpty) {
                          return const Center(
                              child: Text(
                                  'No data available')); //handle case where no documents are retrieved
                        }

                        //call menu from cloud Firestore
                        List<Menu> menuList = []; //call the Menu model class
                        docs.forEach((doc) {
                          //create a Menu object using documents stored in Firestore
                          Menu menu = Menu(
                            id: doc.id,
                            name: doc['foodName'],
                            description: doc['foodDescription'],
                            imageUrl: doc['foodImage'],
                            price: doc['foodPrice'].toString(),
                            type: doc['foodType'].toString(),
                          );
                          menuList.add(menu);
                        });

                        return ListView.builder(
                            itemCount: menuList.length,
                            itemBuilder: (context, index) {
                              Menu menu = menuList[index];
                              return ListTile(
                                leading: Container(
                                    height: 60,
                                    width: 60,
                                    child: Image.network(menu.imageUrl)),
                                title: Text(menu.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                                trailing: Text('RM ${double.parse(menu.price).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )),
                                onTap: () {
                                  //on tap action
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MealsSingleFoodPage(
                                                  menu: menuList[index])));
                                },
                              );
                            });
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
