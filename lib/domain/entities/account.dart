import 'package:flutter/material.dart';

class Account {
  final String id;
  final String name;
  final String type;
  final double balance;
  final String iconPath;
  final Color iconColor;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.iconPath,
    required this.iconColor,
  });
}

class SettingsItem {
  final String id;
  final String title;
  final String subtitle;
  final String iconPath;
  final Color iconColor;
  final String? status;
  final bool isToggle;
  final bool toggleValue;

  SettingsItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.iconColor,
    this.status,
    this.isToggle = false,
    this.toggleValue = false,
  });
}
