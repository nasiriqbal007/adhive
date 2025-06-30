import 'package:ad_hive/utils/app_colors.dart';
import 'package:flutter/material.dart';

class PrimaryTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? size;
  final FontWeight? fontWeight;

  const PrimaryTextButton({
    super.key,
    required this.text,
    this.size,
    this.fontWeight,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: size ?? 14,
          fontWeight: fontWeight ?? FontWeight.w300,
        ),
      ),
    );
  }
}
