import 'package:ad_hive/provider/auth_provider.dart';
import 'package:ad_hive/utils/admin_menu.dart';
import 'package:flutter/material.dart';
import 'package:ad_hive/utils/app_colors.dart';

import 'package:provider/provider.dart';

class AdminHome extends StatelessWidget {
  final Widget child;
  const AdminHome({super.key, required this.child});

  AdminMenu _getCurrentMenu(BuildContext context) {
    final String? routeName = ModalRoute.of(context)?.settings.name;

    return AdminMenu.values.firstWhere(
      (menu) => routeName?.startsWith(menu.path) ?? false,
      orElse: () => AdminMenu.overview,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final currentMenu = _getCurrentMenu(context);

    return Scaffold(
      drawer: isMobile ? _buildDrawer(context, currentMenu) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(context, currentMenu),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, isMobile),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AdminMenu currentMenu) {
    return Container(
      width: 200,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'AdHive',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ...AdminMenu.values.map(
            (item) => _buildSidebarItem(
              context,
              item,
              currentMenu,
              isInDrawer: false,
            ),
          ),
          _buildLogoutTile(context),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AdminMenu currentMenu) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'AdHive',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ...AdminMenu.values.map(
            (item) =>
                _buildSidebarItem(context, item, currentMenu, isInDrawer: true),
          ),
          _buildLogoutTile(context),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    AdminMenu item,
    AdminMenu currentMenu, {
    bool isInDrawer = false,
  }) {
    final isSelected = currentMenu == item;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color:
            isSelected ? AppColors.primary.withAlpha(100) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? AppColors.primary : AppColors.mediumGrey,
        ),
        title: Text(
          item.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? AppColors.primary : AppColors.softGrey,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
          ),
        ),
        onTap: () {
          if (isInDrawer) Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, item.path);
        },
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.logout, color: AppColors.redColor),
      title: Text(
        'Logout',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.redColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () async {
        final authProvider = Provider.of<UserAuthProvider>(
          context,
          listen: false,
        );
        await authProvider.logout();
        if (context.mounted)
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      height: 60,
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isMobile)
            Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
            )
          else
            Text(
              'Hello Evano',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 24),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: AppColors.mediumGrey),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/admin_img.jpeg'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
