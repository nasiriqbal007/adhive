import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(dynamic dateInput) {
  if (dateInput == null) return '';
  DateTime date;
  if (dateInput is Timestamp) {
    date = dateInput.toDate();
  } else if (dateInput is DateTime) {
    date = dateInput;
  } else {
    return '';
  }
  return "${date.day}-${date.month}-${date.year}";
}
