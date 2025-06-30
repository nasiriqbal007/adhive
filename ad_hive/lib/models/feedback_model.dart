import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String? id;
  final String? taskId;
  final String? clientId;
  final String? feedback;
  final String? clientName;
  final DateTime? date;

  FeedbackModel({
    this.id,
    this.taskId,
    this.clientId,
    this.feedback,
    this.clientName,
    this.date,
  });

  factory FeedbackModel.fromMap(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return FeedbackModel(
      id: doc.id,
      taskId: map['taskId'],
      clientId: map['clientId'],
      feedback: map['feedback'],
      clientName: map['clientName'],
      date: (map['date'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'clientId': clientId,
      'feedback': feedback,
      'clientName': clientName,
      'date': date,
    };
  }
}
