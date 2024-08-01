import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchExpenses() async {
    QuerySnapshot snapshot = await _firestore.collection('expenses').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> fetchBudget() async {
    DocumentSnapshot snapshot = await _firestore.collection('budget').doc('current').get();
    return snapshot.data() as Map<String, dynamic>;
  }
}
