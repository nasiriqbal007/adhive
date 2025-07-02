import 'package:flutter/material.dart';

enum TeamMenu {
  dashboard('Dashboard', Icons.dashboard, '/team/dashboard');

  final String label;
  final IconData icon;
  final String path;

  const TeamMenu(this.label, this.icon, this.path);
}
