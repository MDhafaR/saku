import 'package:flutter/material.dart';

class Account {
  final String id;
  final String name;
  final String type;
  final double balance;
  final String iconPath;
  final Color iconColor;
  final bool isHidden;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.iconPath,
    required this.iconColor,
    this.isHidden = false,
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

  SettingsItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? iconPath,
    Color? iconColor,
    String? status,
    bool clearStatus = false,
    bool? isToggle,
    bool? toggleValue,
  }) {
    return SettingsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconPath: iconPath ?? this.iconPath,
      iconColor: iconColor ?? this.iconColor,
      status: clearStatus ? null : (status ?? this.status),
      isToggle: isToggle ?? this.isToggle,
      toggleValue: toggleValue ?? this.toggleValue,
    );
  }
}
