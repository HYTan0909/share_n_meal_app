
//this is a CarpoolModel model class
import 'package:cloud_firestore/cloud_firestore.dart';

class CarpoolModel{
  final String driverId;
  final String passengerId;
  final String id;
  final String time;
  final String status;
  final String destination;
  final String passengerCount;
  final String passengerName;
  final String contact;


  CarpoolModel({
    required this.driverId,
    required this.passengerId,
    required this.id,
    required this.time,
    required this.status,
    required this.destination,
    required this.passengerCount,
    required this.passengerName,
    required this.contact,

  });

}