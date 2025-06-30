import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF5577FF);
  static const Color bgColor = Color(0xFFFFFAFA);
  static const Color borderLightGrey = Color(0xFFD0D5DD);
  static const Color neutralGrey = Color(0xFFABABAB);

  static const Color background = Color(0xFFFBFBFB);

  // Text Colors
  static const Color mainBlack = Color(0xFF000000);
  static const Color softGrey = Color(0xFFB5B7C0);
  static const Color secondaryBlack = Color(0xFF292D32);
  static const Color mediumGrey = Color(0xFF727272);

  static const Color whiteColor = Color(0xFFFFFFFF);

  // Others
  static const Color redColor = Colors.red;
  static const Color greenColor = Colors.green;
}

// ✅ Add this theme getter here:
class AppTheme {
  static ThemeData getAppTheme() {
    return ThemeData(
      cardColor: AppColors.whiteColor,
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackgroundColor: AppColors.bgColor,
      primaryColor: AppColors.primary,
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.mainBlack,
        ),

        titleMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryBlack,
        ),
        titleSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.secondaryBlack,
        ),
        bodySmall: TextStyle(
          fontSize: 16,
          color: AppColors.softGrey,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
