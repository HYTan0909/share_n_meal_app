import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_n_meal_app/Menu.dart';

import 'meals_cart_page.dart';

class MealsSingleFoodPage extends StatefulWidget {

  final Menu menu;

  const MealsSingleFoodPage({Key? key, required this.menu}) : super(key: key);

  @override
  State<MealsSingleFoodPage> createState() => _MealsSingleFoodPageState();
}

class _MealsSingleFoodPageState extends State<MealsSingleFoodPage> {

  //get the current user
  User? user = FirebaseAuth.instance.currentUser;

  //reference to cart collection
  CollectionReference cartCollection = FirebaseFirestore.instance.collection('cart');

  //function to add an item to cart
  Future<void> addToCart(String cartItem, String cartItemQuantity, String cartItemPrice, String cartItemImage) async{
    //check if user is logged in or not
    if(user != null){

      //check if the item already exists or not
      final existingItem = await cartCollection
          .where('userId', isEqualTo: user!.uid)
          .where('cartItem', isEqualTo: cartItem)
          .get();

      //update the item if already exis
      if (existingItem.docs.isNotEmpty) {
        final existingItemId = existingItem.docs.first.id;
        await cartCollection.doc(existingItemId).update({
          'cartItemQuantity': cartItemQuantity,
          'cartItemPrice': cartItemPrice,
          'cartItemImage': cartItemImage,
        });
      }
      else {
        // Create a new item
        try {
          await cartCollection.add({
            'userId': user!.uid,
            'cartItem': cartItem,
            'cartItemQuantity': cartItemQuantity,
            'cartItemPrice': cartItemPrice,
            'cartItemImage': cartItemImage,
          });
        } catch (e) {
          print('Error creating or updating cart item: $e');
        }
      }
    }
  }

  //set initial quantity
  int quantity = 1;

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  //function to show a message
  void showSnackBar(BuildContext context, content) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    String snackBarContent = content;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(snackBarContent),
        duration: const Duration(seconds: 3),
      ),
    );
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
                      builder: (context) => const MealsCartPage()
                  )
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.network(
              widget.menu.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.menu.name, style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24
                  )
                ),
                Text('RM ${double.parse(widget.menu.price).toStringAsFixed(2)}', style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                )
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.menu.description,
            style: const TextStyle(
              fontSize: 16,
            ),
            ),
          ),
          const Divider(
            color: Colors.black, // Set the color of the divider
            thickness: 1.0, // Set the thickness of the divider
            height: 20.0,
            indent: 16.0,
            endIndent: 16.0,// Set the height of the divider
          ),
          const SizedBox(
            height: 20,
          ),
          // Quantity Selector Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Quantity:',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: decrementQuantity,
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: incrementQuantity,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (){
                        //on pressed action
                        double? totalPrice = 0;

                        totalPrice = quantity * double.parse(widget.menu.price);
                        addToCart(widget.menu.name, quantity.toString(), totalPrice.toString(), widget.menu.imageUrl);
                        showSnackBar(context, 'Item added to cart!');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Add to cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
