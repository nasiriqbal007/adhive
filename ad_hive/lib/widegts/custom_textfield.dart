import 'package:ad_hive/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final int? maxLines;

  const CustomTextField({
    super.key,
    this.maxLines,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderLightGrey),
            ),
            child: TextField(
              maxLines: maxLines ?? 1,

              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: Theme.of(context).textTheme.titleSmall,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.neutralGrey,
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: InputBorder.none,
                suffixIcon:
                    suffixIcon != null
                        ? IconButton(
                          icon: suffixIcon!,
                          onPressed: onSuffixIconTap,
                          splashRadius: 20,
                        )
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
