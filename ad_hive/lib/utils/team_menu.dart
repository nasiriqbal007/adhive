import 'package:flutter/material.dart';

enum TeamMenu {
  dashboard('Dashboard', Icons.dashboard, '/team/dashboard'),
  tasks('Task', Icons.task, '/team/tasks');

  final String label;
  final IconData icon;
  final String path;

  const TeamMenu(this.label, this.icon, this.path);
}
