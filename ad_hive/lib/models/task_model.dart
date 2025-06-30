import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String? id;

  final String? title;
  final String? clientId;
  final String? teamMemberId;
  final String? packageId;

  final String? status;
  final DateTime? deadline;
  final DateTime? createdAt;

  final List<Map<String, dynamic>>? chunks;
  final List<Map<String, dynamic>>? requests;

  TaskModel({
    this.id,
    this.title,

    this.clientId,
    this.teamMemberId,
    this.packageId,
    this.status,
    this.deadline,
    this.createdAt,
    this.chunks,
    this.requests,
  });

  factory TaskModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'],
      clientId: data['clientId'],
      teamMemberId: data['teamMemberId'],
      packageId: data['packageId'],
      status: data['status'],
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      chunks: List<Map<String, dynamic>>.from(data['chunks'] ?? []),
      requests: List<Map<String, dynamic>>.from(data['requests'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (title != null) 'title': title,
      if (clientId != null) 'clientId': clientId,
      if (teamMemberId != null) 'teamMemberId': teamMemberId,
      if (packageId != null) 'packageId': packageId,
      if (status != null) 'status': status,
      if (deadline != null) 'deadline': deadline,
      if (createdAt != null) 'createdAt': createdAt,

      if (chunks != null) 'chunks': chunks,
      if (requests != null) 'requests': requests,
    };
  }
}
