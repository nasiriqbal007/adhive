import 'package:cloud_firestore/cloud_firestore.dart';

class PackageModel {
  final String? id;

  final String? serviceName;
  final double? price;
  final String? type;
  final int? duration;
  bool? isActive;
  final List<String>? descriptionPoints;
  final List<int>? pointWordCounts;
  final DateTime? createdAt;

  PackageModel({
    this.id,
    this.serviceName,
    this.price,
    this.type,
    this.duration,
    this.isActive,
    this.descriptionPoints,
    this.pointWordCounts,
    this.createdAt,
  });

  factory PackageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PackageModel(
      id: doc.id,
      serviceName: data['serviceName'],
      price: (data['price'] as num?)?.toDouble(),
      duration: data['duration'] as int?,
      isActive: data['isActive'],
      type: data['type'] ?? '',
      descriptionPoints: List<String>.from(data['descriptionPoints'] ?? []),
      pointWordCounts: List<int>.from(data['pointWordCounts'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (serviceName != null) 'serviceName': serviceName,
      if (type != null) 'type': type,
      if (price != null) 'price': price,
      if (duration != null) 'duration': duration,
      if (isActive != null) 'isActive': isActive,
      if (descriptionPoints != null) 'descriptionPoints': descriptionPoints,
      if (pointWordCounts != null) 'pointWordCounts': pointWordCounts,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
