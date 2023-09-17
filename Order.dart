
//this is a Orders model class
import 'package:cloud_firestore/cloud_firestore.dart';

class Orders{
  final String userId;
  final String id;
  final String item;
  final String status;
  final String time;
  final String total;

  Orders({
    required this.userId,
    required this.id,
    required this.item,
    required this.status,
    required this.time,
    required this.total,
  });

}