import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_n_meal_app/Menu.dart';
import 'package:share_n_meal_app/canteen_add_new_food_page.dart';
import 'package:share_n_meal_app/canteen_single_food_page.dart';

class CanteenMenuPage extends StatefulWidget {
  const CanteenMenuPage({Key? key}) : super(key: key);

  @override
  State<CanteenMenuPage> createState() => _CanteenMenuPageState();
}

class _CanteenMenuPageState extends State<CanteenMenuPage> {

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
                      builder: (context) => CanteenAddNewFoodPage()
                  )
              );
            },
            icon: Icon(Icons.add),
          )
        ],
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
                    'Menu Management',
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black,
                  thickness: 2.0,
                  height: 20.0,
                ),
              ],
            ),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                //connect to Firestore and access the 'menu' documents
                stream: FirebaseFirestore.instance.collection('menu').snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData){
                    return const Center(
                        child: CircularProgressIndicator()  //a loading indicator
                    );
                  }

                  //use ?. to safely access docs property
                  final docs = snapshot.data?.docs;

                  if(docs == null || docs.isEmpty){
                    return const Text('No data available'); //handle case where no documents are retrieved
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
                              child: Image.network(menu.imageUrl)
                          ),
                          title: Text(menu.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )
                          ),
                          subtitle: Text(menu.description,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )
                          ),
                          trailing: Text('RM ${menu.price}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )
                          ),
                          onTap: (){
                            //on tap action
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CanteenSingleFoodPage(menu: menuList[index])
                                )
                            );
                          },
                        );
                      }
                  );
                },
              )
          ),
        ],
      ),
    );
  }
}
