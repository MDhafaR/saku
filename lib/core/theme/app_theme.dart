import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFAFAFA); // Very Soft Off-White
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(
    0xFF111111,
  ); // Darker Black for high contrast
  static const Color lightTextSecondary = Color(0xFF6B7280); // Soft Grey
  static const Color lightBorder = Color(0xFFE5E7EB); // Subtle border
  static const Color lightShadow = Color(
    0x0A000000,
  ); // Very soft, low opacity shadow

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkShadow = Color(0x40000000);

  // Common Colors
  // Royal Blue / Dodger Blue as the single accent color
  static const Color primaryBlue = Color(0xFF2563EB);

  // Semantic Colors - Kept for functionality/feedback but should be used sparingly
  static const Color semanticGreen = Color(0xFF10B981);
  static const Color semanticRed = Color(0xFFEF4444);
  static const Color semanticOrange = Color(0xFFF59E0B);

  static double cardRadius = 24.r; // .r for radius
  static double buttonRadius = 24.r;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryBlue, // Unified accent
        surface: lightCardBackground,
        surfaceContainerLow: lightCardBackground, // For cards
        background: lightBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onBackground: lightTextPrimary,
        outline: lightBorder,
        error: semanticRed,
      ),
      cardTheme: CardThemeData(
        color: lightCardBackground,
        elevation: 0,
        shadowColor: lightShadow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        hintStyle: const TextStyle(color: lightTextSecondary),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 48.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          color: lightTextPrimary,
          fontSize: 36.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        headlineLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 32.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          color: lightTextPrimary,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        bodyLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400, // Regular/Light for body
        ),
        bodyMedium: TextStyle(
          color: lightTextPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: lightTextSecondary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: IconThemeData(color: lightTextPrimary, size: 24.sp),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryBlue,
        surface: darkCardBackground,
        surfaceContainerLow: darkCardBackground,
        background: darkBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        outline: darkBorder,
        error: semanticRed,
      ),
      cardTheme: CardThemeData(
        color: darkCardBackground,
        elevation: 0,
        shadowColor: darkShadow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF27272A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        hintStyle: const TextStyle(color: darkTextSecondary),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 48.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          color: darkTextPrimary,
          fontSize: 36.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        headlineLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 32.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          color: darkTextPrimary,
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        bodyLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: darkTextPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: darkTextSecondary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: IconThemeData(color: darkTextPrimary, size: 24.sp),
    );
  }
}
