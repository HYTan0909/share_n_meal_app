import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_n_meal_app/Menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_n_meal_app/canteen_menu_page.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class CanteenSingleFoodPage extends StatefulWidget {
  final Menu menu;

  const CanteenSingleFoodPage({Key? key, required this.menu}) : super(key: key);

  @override
  State<CanteenSingleFoodPage> createState() => _CanteenSingleFoodPageState();
}

class _CanteenSingleFoodPageState extends State<CanteenSingleFoodPage> {
  String selectedFoodType = 'Others'; //default selection
  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;
  String _filePath = '';
  String imageUrl = ''; //image link
  bool imageUrlIsValid = true; //initial value
  TextEditingController foodName = TextEditingController();
  TextEditingController foodDescription = TextEditingController();
  TextEditingController foodPrice = TextEditingController();
  TextEditingController foodImage = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    foodName.text = widget.menu.name;
    foodDescription.text = widget.menu.description;
    foodPrice.text = widget.menu.price;
    foodImage.text = widget.menu.imageUrl;
  }

  Future<void> openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path!;
      });
    }
  }

  Future<void> uploadImage() async {
    if (_filePath.isNotEmpty) {
      Reference storageReference =
          storage.ref().child('images/${DateTime.now()}.png');
      UploadTask uploadTask = storageReference.putFile(File(_filePath));

      TaskSnapshot taskSnapshot = await uploadTask;
      imageUrl = await taskSnapshot.ref.getDownloadURL();

      await firestore.collection('images').add({'url': imageUrl});
      setState(() {
        _filePath = ''; // Reset the file path after upload.
        foodImage.text = imageUrl;
        print(imageUrl);
      });
    }
  }

  bool checkControllerField() {
    return foodName.text.isNotEmpty &&
        foodDescription.text.isNotEmpty &&
        foodPrice.text.isNotEmpty &&
        foodImage.text.isNotEmpty;
  }

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

  void deleteItem(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm to delete this item? '),
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
                      //function to delete a food item
                      try {
                        //reference to menu collection
                        CollectionReference cartCollection =
                            FirebaseFirestore.instance.collection('menu');

                        //query for documents with current user id
                        QuerySnapshot querySnapshot = await cartCollection
                            .where('foodName', isEqualTo: widget.menu.name)
                            .get();

                        //perform delete menu item actions
                        for (QueryDocumentSnapshot document
                            in querySnapshot.docs) {
                          await cartCollection.doc(document.id).delete();
                        }

                        print('${widget.menu.name} deleted successfully');
                      } catch (e) {
                        print('Error deleting item. : $e');
                      }

                      // ignore: use_build_context_synchronously
                      showSnackBar(context, 'Food deleted successfully! ');

                      // ignore: use_build_context_synchronously
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CanteenMenuPage()));
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    )),
              ],
            ),
          ],
        );
      },
    );
  }

  void addNewItem(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm to update this item? '),
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
                      //function to delete a food item
                      if (checkControllerField()) {
                        //all fields were filled
                        //function to update single food detais
                        Future<void> addFood(
                            String foodName,
                            String foodDescription,
                            String foodPrice,
                            String foodImage,
                            String foodType) async {
                          CollectionReference menuCollection =
                              FirebaseFirestore.instance.collection('menu');

                          try {
                            //find the matching food and update the status
                            await menuCollection.doc(widget.menu.id).update({
                              'foodName': foodName,
                              'foodDescription': foodDescription,
                              'foodPrice': foodPrice,
                              'foodImage': foodImage,
                              'foodType': foodType,
                            });

                            print('Food item updated successfully.');
                          } catch (e) {
                            print('Error updating food. $e');
                          }
                        }

                        addFood(
                            foodName.text,
                            foodDescription.text,
                            foodPrice.text.toString(),
                            foodImage.text.toString(),
                            selectedFoodType.toString());
                        showSnackBar(context, 'Food updated successfully! ');

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CanteenMenuPage()));
                      } else {
                        showSnackBar(context, 'Please fill in every field ');
                      }
                    },
                    child: const Text(
                      'Update',
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

  @override
  Widget build(BuildContext context) {
    List<String> foodTypes = ['Rice', 'Noodles', 'Beverages', 'Others'];

    List<DropdownMenuItem<String>> dropdownItems =
        foodTypes.map((String foodType) {
      return DropdownMenuItem<String>(
        value: foodType,
        child: Text(foodType),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Share N\' Meal App'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Single Food Management',
                        style: TextStyle(
                          fontSize: 24.0, // Adjust the font size as needed
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: foodName,
                      decoration: const InputDecoration(
                        labelText: 'Food Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: foodDescription,
                      decoration: const InputDecoration(
                        labelText: 'Food Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: foodPrice,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Food Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 1),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  ' Select an image:  ',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: openFilePicker,
                                  child: const Icon(Icons.source),
                                ),
                              ],
                            ),
                          ),
                          _filePath == ''
                              ? const Center(child: Text(''))
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Selected file: $_filePath',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: uploadImage,
                                      child: const Text('Upload Image'),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: foodImage,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Food Image',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select a Food Type: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButton<String>(
                          hint: const Text('Select a Food Type'),
                          value: selectedFoodType,
                          items: dropdownItems,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedFoodType = newValue!;
                            });
                          },
                        ),
                        const Spacer()
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              deleteItem(widget.menu.id);
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.redAccent),
                            )),
                        ElevatedButton(
                          onPressed: () {
                            //on press action
                            addNewItem(widget.menu.id);
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
