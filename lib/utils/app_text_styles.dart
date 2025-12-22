import 'package:flutter/material.dart';
import 'app_colors2.dart';

class AppTextStyles {
  static const title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors2.darkText,
  );

  static const label = TextStyle(
    fontSize: 14,
    letterSpacing: 1.0,
    fontWeight: FontWeight.w600,
    color: AppColors2.darkText,
  );

  static const body = TextStyle(
    fontSize: 16,
    color: AppColors2.greyText,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
