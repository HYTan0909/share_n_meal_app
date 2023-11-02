import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:location/location.dart' as locationPackage;
import 'package:place_picker/place_picker.dart';
import 'package:share_n_meal_app/ride_options.dart';
import 'dart:async';

class RidePassengerRequestPage extends StatefulWidget {
  const RidePassengerRequestPage({Key? key}) : super(key: key);

  @override
  State<RidePassengerRequestPage> createState() =>
      _RidePassengerRequestPageState();
}

class _RidePassengerRequestPageState extends State<RidePassengerRequestPage> {
  //current user
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference carpoolRequestCollection =
      FirebaseFirestore.instance.collection('carpoolRequest');
  //create a date time variable
  DateTime? requestDateTime;

  String selectedAddress = ''; // To store the selected address
  GoogleMapController? _mapController;
  locationPackage.LocationData? _currentLocation;
  TextEditingController addressController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController passengerCountController = TextEditingController();

  bool checkControllerField() {
    return addressController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        contactController.text.isNotEmpty &&
        passengerCountController.text.isNotEmpty;
  }

  //function to create a date time picker for user to input the request date and time
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
          requestDateTime = DateTime(
            selectedOrderDate.year,
            selectedOrderDate.month,
            selectedOrderDate.day,
            selectedOrderTime.hour,
            selectedOrderTime.minute,
          );
        });

        //call the create order dialog function with order time here
        _showInputDialog(context, requestDateTime);
      }
    }
  }

  Future<bool> hasPendingRequest(String passengerId) async {
    try {
      //find carpool requests with the given passengerId and 'Pending' status
      QuerySnapshot querySnapshot = await carpoolRequestCollection
          .where('passengerId', isEqualTo: passengerId)
          .where('status', isEqualTo: 'Pending')
          .get();

      return querySnapshot.size >
          0; //return true if have an accepted request, false otherwise
    } catch (e) {
      print('Error checking for accepted requests. $e');
      return false; // Handle the error as needed
    }
  }

  Future<void> _getAddressFromLocation(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        // Get the first placemark
        Placemark placemark = placemarks.first;

        // Build the full address using various components
        String fullAddress =
            '${placemark.name}, ${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}';

        // Update the address controller with the address
        addressController.text = fullAddress;
      }
    } catch (e) {
      print('Error getting address from location: $e');
    }
  }

  Future<void> _getUserLocation() async {
    final location = locationPackage.Location();
    try {
      final locationData = await location.getLocation();
      setState(() {
        _currentLocation = locationData;

        // Update the camera position to match the marker's position
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
          ),
        );
      });
    } catch (e) {
      print('Error getting user location: $e');
    }
    // Reverse geocode the current location to get the address
    _getAddressFromLocation(
        _currentLocation!.latitude!, _currentLocation!.longitude!);
  }

  Future<void> _showInputDialog(
      BuildContext context, DateTime? requestDateTime) async {
    String formattedRequestDateTime = '';

    if (requestDateTime != null) {
      formattedRequestDateTime =
          DateFormat('yyyy/MM/dd hh:mm a').format(requestDateTime);
    }
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text('Enter User Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  onTap: () {
                    //get the user's location and update the addressController
                    if (addressController.text.isEmpty) {
                      _getUserLocation();
                    }
                  },
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: contactController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  decoration: const InputDecoration(labelText: 'Contact'),
                ),
                TextField(
                  controller: passengerCountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  decoration:
                      const InputDecoration(labelText: 'Passenger Count'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  String name = nameController.text;
                  String contact = contactController.text;
                  String passengerCount = passengerCountController.text;
                  String destination = addressController.text;

                  if(checkControllerField()) {
                    _createCarpoolRequest(name, passengerCount, destination,
                        formattedRequestDateTime, contact);
                  }
                  else {
                    showSnackBar(context, 'Please fill in every field');
                  }
                },
                child: const Text('Create Request'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserLocation();
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

  void _createCarpoolRequest(
      String inputPassengerName,
      String inputPassengerCount,
      String inputDestination,
      String inputRequestDateTime,
      String inputContact) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Create Request?'),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Address:  $inputDestination',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Name:  $inputPassengerName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Contact:  $inputContact',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Passenger Count:  $inputPassengerCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Time:  $inputRequestDateTime',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
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
                    onPressed: () {
                      // Handle the confirmation action here
                      //reference to carpool collection
                      CollectionReference carpoolRequestCollection =
                          FirebaseFirestore.instance
                              .collection('carpoolRequest');

                      final currentTime = DateTime.now();
                      final deleteTime =
                          currentTime.add(const Duration(minutes: 10));

                      //function to create a request
                      Future<void> createRequest(
                        String driverId,
                        String passengerId,
                        String time,
                        String destination,
                        String passengerCount,
                        String passengerName,
                        String contact,
                        String status,
                        DateTime deleteTime,
                      ) async {
                        //check if user is logged in or not
                        if (user != null) {
                          try {
                            //create an order
                            await carpoolRequestCollection.add({
                              'driverId': driverId,
                              'passengerId': passengerId,
                              'time': time,
                              'destination': destination,
                              'passengerCount': passengerCount,
                              'passengerName': passengerName,
                              'contact': contact,
                              'status': status,
                              'deleteTime': deleteTime,
                            });
                          } catch (e) {
                            print('Error creating request. $e');
                          }
                        }
                      }

                      createRequest(
                          '',
                          user!.uid,
                          inputRequestDateTime,
                          inputDestination,
                          inputPassengerCount,
                          inputPassengerName,
                          inputContact,
                          'Pending',
                          deleteTime);

                      showSnackBar(context, 'Request created successfully! ');

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RideOptions(),
                          ));
                    },
                    child: const Text('Confirm Create'),
                  ),
                ],
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? const Center(child: Text('Loading'))
          : GoogleMap(
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentLocation!.latitude!,
                    _currentLocation!.longitude!), // Initial camera position
                zoom: 15.0,
              ),
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
              },
              markers: _currentLocation != null
                  ? {
                      Marker(
                          markerId: const MarkerId('CurrentLocation'),
                          position: LatLng(
                            _currentLocation!.latitude!,
                            _currentLocation!.longitude!,
                          ),
                          onTap: () async {
                            bool pendingRequest =
                                await hasPendingRequest(user!.uid);

                            if (pendingRequest) {
                              showSnackBar(context,
                                  'You already have an ongoing request');
                            } else {
                              _showDateTimePicker(context);
                            }
                          }),
                    }
                  : {},
            ),
    );
  }
}
