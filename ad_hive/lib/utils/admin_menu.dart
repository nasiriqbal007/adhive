import 'package:flutter/material.dart';

enum AdminMenu {
  overview('Overview', Icons.dashboard, '/admin/overview'),
  task('Task', Icons.assignment, '/admin/task'),
  team('Your Team', Icons.group, '/admin/team'),
  requests('Requests', Icons.note_alt, '/admin/requests'),
  packages('Packages', Icons.card_giftcard, '/admin/packages');

  final String label;
  final IconData icon;
  final String path;

  const AdminMenu(this.label, this.icon, this.path);
}
