import 'package:flutter/material.dart';

enum ClientMenu {
  dashboard('Dashboard', Icons.dashboard, '/client/dashboard'),

  packages('My Packages', Icons.card_giftcard, '/client/packages');

  final String label;
  final IconData icon;
  final String path;

  const ClientMenu(this.label, this.icon, this.path);
}
