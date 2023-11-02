import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class CanteenAddNewFoodPage extends StatefulWidget {
  const CanteenAddNewFoodPage({Key? key}) : super(key: key);

  @override
  State<CanteenAddNewFoodPage> createState() => _CanteenAddNewFoodPageState();
}

class _CanteenAddNewFoodPageState extends State<CanteenAddNewFoodPage> {
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

  Future<void> openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType
          .image,
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    foodName = TextEditingController();
    foodDescription = TextEditingController();
    foodPrice = TextEditingController();
    foodImage = TextEditingController();
  }

  bool checkControllerField() {
    return foodName.text.isNotEmpty &&
        foodDescription.text.isNotEmpty &&
        foodPrice.text.isNotEmpty &&
        foodImage.text.isNotEmpty;
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
                        'Create New Food',
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
                                      onPressed: () {
                                        uploadImage();
                                      },
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
                            fontSize: 14,
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
                            //function to add new food to the menu
                            if (checkControllerField()) {
                              //all fields were filled
                              //reference to menu collection
                              CollectionReference menuCollection =
                                  FirebaseFirestore.instance.collection('menu');

                              //function to create a request
                              Future<void> createFood(
                                String foodName,
                                String foodImage,
                                String foodDescription,
                                String foodPrice,
                                String foodType,
                              ) async {
                                try {
                                  //check for duplicate item in menu
                                  final duplicateQuery = await menuCollection
                                      .where('foodName', isEqualTo: foodName)
                                      .get();

                                  if (duplicateQuery.docs.isNotEmpty) {
                                    showSnackBar(context,
                                        'Food already exist in menu. ');
                                  } else {
                                    //create new item
                                    await menuCollection.add({
                                      'foodName': foodName,
                                      'foodImage': foodImage,
                                      'foodDescription': foodDescription,
                                      'foodPrice': foodPrice,
                                      'foodType': foodType,
                                    });

                                    showSnackBar(context,
                                        'Food added to the menu successfully!');
                                  }
                                } catch (e) {
                                  print('Error adding food to menu. $e');
                                  showSnackBar(context,
                                      'An error occurred while adding the food');
                                }
                              }

                              createFood(
                                  foodName.text,
                                  foodImage.text,
                                  foodDescription.text,
                                  foodPrice.text,
                                  selectedFoodType.toString());
                            } else {
                              showSnackBar(
                                  context, 'Please fill in every field');
                            }
                          },
                          child: const Text('Add Food to Menu'),
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
