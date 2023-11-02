import 'package:flutter/material.dart';
import 'package:share_n_meal_app/Order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_n_meal_app/canteen_ongoing_orders_page.dart';
import 'package:share_n_meal_app/canteen_order_history_page.dart';
import 'package:share_n_meal_app/canteen_staff_dashboard.dart';

class CanteenOrderDetailsPage extends StatefulWidget {
  final Orders order;

  const CanteenOrderDetailsPage({Key? key, required this.order})
      : super(key: key);

  @override
  State<CanteenOrderDetailsPage> createState() =>
      _CanteenOrderDetailsPageState();
}

class _CanteenOrderDetailsPageState extends State<CanteenOrderDetailsPage> {
  TextEditingController deleteReasonController = TextEditingController();

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

  void updateOrderStatus(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm to update order status? '),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                    onPressed: () async {
                      Future<void> completeOrder(String id) async {
                        CollectionReference ordersCollection =
                            FirebaseFirestore.instance.collection('orders');

                        try {
                          //find the matching order id and update the status
                          await ordersCollection.doc(id).update({
                            'orderStatus': 'Completed',
                          });
                          print('Order status updated successfully! ');
                        } catch (e) {
                          print('Error updating order status. $e');
                        }
                      }

                      completeOrder(id);
                      showSnackBar(
                          context, 'Order status updated successfully! ');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CanteenStaffDashboard()));
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
          ],
        );
      },
    );
  }

  void deleteOrder(String id) {
    String deleteReason =
        ''; // Initialize an empty string for the delete reason

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm to delete this order? '),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please provide a reason for deletion:'),
                TextFormField(
                  controller: deleteReasonController,
                  decoration: const InputDecoration(
                    hintText: 'Reason of Delete',
                  ),
                  onChanged: (value) {
                    deleteReason =
                        value; // Update deleteReason as the user types
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Future<void> completeOrder(String id, String reason) async {
                      CollectionReference ordersCollection =
                          FirebaseFirestore.instance.collection('orders');

                      try {
                        // Find the matching order id and update the status and reason
                        await ordersCollection.doc(id).update({
                          'orderStatus': 'Removed',
                          'deleteReason': reason,
                        });
                        print('Order status and reason updated successfully! ');
                      } catch (e) {
                        print('Error updating order status and reason. $e');
                      }
                    }

                    if (deleteReasonController.text.isEmpty) {
                      showSnackBar(context,
                          'Please enter a reason for order cancellation');
                    } else {
                      completeOrder(id, deleteReason);
                      showSnackBar(context,
                          'Order status and reason updated successfully! ');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CanteenStaffDashboard(),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Share N\' Meal App'),
      ),
      body: Stack(
          children: [
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
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  )
                : const SizedBox(
                    height: 12,
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0), // Add some padding
              child: Text(
                'Total Amount: RM${widget.order.total}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(
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
                height: 500,
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
            widget.order.status == 'Completed' ||
                    widget.order.status == 'Removed'
                ? const Center(child: Text(''))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          //on press action
                          deleteOrder(widget.order.id);
                        },
                        child: const Text(
                          'Cancel Order',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          //on press action
                          updateOrderStatus(widget.order.id);
                        },
                        child: const Text('Complete Order'),
                      ),
                    ],
                  ),
            const Spacer(),
          ],
        ),
      ]),
    );
  }
}
