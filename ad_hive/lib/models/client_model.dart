import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  final String? id;
  final String? name;
  final String? email;
  final String? contactNumber;
  final List<ClientPackage>? packages;

  final Timestamp? createdAt;
  final Timestamp? approvedAt;
  final String? status;

  ClientModel({
    this.id,
    this.name,
    this.email,
    this.contactNumber,
    this.packages,
    this.createdAt,
    this.approvedAt,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (contactNumber != null) 'contactNumber': contactNumber,
      if (packages != null)
        'packages': packages!.map((pkg) => pkg.toJson()).toList(),
      if (status != null) 'status': status,

      // ✅ Only set on first save (client registration)
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory ClientModel.fromJson(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ClientModel(
      id: snapshot.id,
      name: data['name'],
      email: data['email'],
      contactNumber: data['contactNumber'],
      packages:
          data['packages'] != null
              ? (data['packages'] as List)
                  .map((pkg) => ClientPackage.fromMap(pkg))
                  .toList()
              : null,
      createdAt:
          data['createdAt'] != null ? data['createdAt'] as Timestamp : null,
      approvedAt: data['approvedAt'],
      status: data['status'],
    );
  }
}

class ClientPackage {
  final String packageId; // 🔥 Just store ID now
  final DateTime startDate;
  final DateTime expiryDate;

  ClientPackage({
    required this.packageId,
    required this.startDate,
    required this.expiryDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'startDate': Timestamp.fromDate(startDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
    };
  }

  factory ClientPackage.fromMap(Map<String, dynamic> map) {
    return ClientPackage(
      packageId: map['packageId'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
    );
  }
}
