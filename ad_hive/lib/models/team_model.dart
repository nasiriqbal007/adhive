import 'package:cloud_firestore/cloud_firestore.dart';

class TeamMemberModel {
  final String? id;
  final String? name;
  final String? jobTitle;
  final String? email;
  final String? phone;
  final String? country;
  bool? isActive;

  final DateTime? createdAt;

  TeamMemberModel({
    this.id,
    this.name,
    this.jobTitle,
    this.email,
    this.phone,
    this.country,
    this.isActive,
    this.createdAt,
  });

  /// From Firestore
  factory TeamMemberModel.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Document data is null for id: ${doc.id}');
    }

    return TeamMemberModel(
      id: doc.id,
      name: data['name'],
      jobTitle: data['jobTitle'],
      email: data['email'],
      phone: data['phone'],
      country: data['country'],
      isActive: data['isActive'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// To Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'jobTitle': jobTitle,
      'email': email,
      'phone': phone,
      'country': country,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
