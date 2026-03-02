import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument(String uid, String email) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  CollectionReference<Map<String, dynamic>> getUserExpensesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('expenses');
  }

  Future<void> deleteUserDocument(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}