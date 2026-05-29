import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/user_details.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'users_details';

  // Get users details collection reference
  static CollectionReference get _collection => _firestore.collection(_collectionName);

  // Read: Realtime stream of user details for the logged-in user
  static Stream<List<UserDetails>> getUserDetailsStream(String userId) {
    return _collection.where('addedBy', isEqualTo: userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => UserDetails.fromDocument(doc)).toList(),
        );
  }

  // Create: Add new user details card
  static Future<bool> addUserDetails(UserDetails details) async {
    try {
      await _collection.add(details.toMap());
      Fluttertoast.showToast(msg: "Details added successfully!");
      return true;
    } catch (e) {
      debugPrint("Error adding details: $e");
      Fluttertoast.showToast(msg: "Failed to add details: ${e.toString()}");
      return false;
    }
  }

  // Update: Edit existing user details card
  static Future<bool> updateUserDetails(UserDetails details) async {
    try {
      await _collection.doc(details.id).update(details.toMap());
      Fluttertoast.showToast(msg: "Details updated successfully!");
      return true;
    } catch (e) {
      debugPrint("Error updating details: $e");
      Fluttertoast.showToast(msg: "Failed to update details: ${e.toString()}");
      return false;
    }
  }

  // Delete: Remove user details card
  static Future<bool> deleteUserDetails(String docId) async {
    try {
      await _collection.doc(docId).delete();
      Fluttertoast.showToast(msg: "Details deleted successfully!");
      return true;
    } catch (e) {
      debugPrint("Error deleting details: $e");
      Fluttertoast.showToast(msg: "Failed to delete details: ${e.toString()}");
      return false;
    }
  }
}
