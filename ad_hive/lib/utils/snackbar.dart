import 'package:flutter/material.dart';
import 'package:ad_hive/utils/app_colors.dart';

void showAppSnackbar({
  required BuildContext context,
  required String message,
  String title = '',
  bool isError = false,
}) {
  if (message.trim().isEmpty) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isError ? AppColors.redColor : AppColors.greenColor,
      content: Text(
        title.isEmpty ? message : '$title\n$message',
        style: const TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: isError ? 5 : 3),
    ),
  );
}
