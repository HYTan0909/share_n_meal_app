import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_n_meal_app/Order.dart';

class MealsOrderDetails extends StatefulWidget {
  final Orders order;

  const MealsOrderDetails({Key? key, required this.order}) : super(key: key);

  @override
  State<MealsOrderDetails> createState() => _MealsOrderDetailsState();
}

class _MealsOrderDetailsState extends State<MealsOrderDetails> {
  //get the current user
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Share N\' Meal App'),
      ),
      body: Stack(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      'Order Details',
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
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Order ID: ${widget.order.id.substring(0, 10)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Order Pickup Time: ${widget.order.time}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Order Status: ${widget.order.status}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: widget.order.status == 'Preparing'
                      ? Colors.deepOrangeAccent
                      : widget.order.status == 'Removed'
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            widget.order.status == 'Removed'
            ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Order removed reason: ${widget.order.deleteReason}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
            )
            : const SizedBox(
              height: 12,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Order Items: ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Expanded(
              child: Container(
                height: 1000,
                child: ListView.builder(
                    itemCount: widget.order.item.split(', ').length,
                    itemBuilder: (context, index) {
                      List<String> orderItem = widget.order.item.split(', ');
                      String item = orderItem[index];
                      return ListTile(
                        title: Text(
                          item,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      );
                    }),
              ),
            ),
            const Spacer(),
          ],
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Add some padding
            child: Text(
              'Total Amount: RM${double.parse(widget.order.total).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
