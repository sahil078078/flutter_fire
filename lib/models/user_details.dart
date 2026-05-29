import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  final String id;
  final String name;
  final String number;
  final String email;
  final String address;
  final String addedBy;
  final DateTime? createdAt;

  UserDetails({
    required this.id,
    required this.name,
    required this.number,
    required this.email,
    required this.address,
    required this.addedBy,
    this.createdAt,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'number': number,
      'email': email,
      'address': address,
      'addedBy': addedBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore Document Snapshot
  factory UserDetails.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    // Safely parse timestamp
    DateTime? parsedDate;
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        parsedDate = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        parsedDate = DateTime.tryParse(data['createdAt']);
      }
    }

    return UserDetails(
      id: doc.id,
      name: data['name'] ?? '',
      number: data['number'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      addedBy: data['addedBy'] ?? '',
      createdAt: parsedDate,
    );
  }
}
