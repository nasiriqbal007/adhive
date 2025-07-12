import 'package:ad_hive/provider/auth_provider.dart';
import 'package:ad_hive/provider/team_provider.dart';
import 'package:ad_hive/utils/team_menu.dart';
import 'package:flutter/material.dart';
import 'package:ad_hive/utils/app_colors.dart';

import 'package:provider/provider.dart';

class TeamMemberHome extends StatefulWidget {
  final Widget child;
  const TeamMemberHome({super.key, required this.child});

  @override
  State<TeamMemberHome> createState() => _TeamMemberHomeState();
}

class _TeamMemberHomeState extends State<TeamMemberHome> {
  TeamMenu _getCurrentMenu(BuildContext context) {
    final String? routeName = ModalRoute.of(context)?.settings.name;
    return TeamMenu.values.firstWhere(
      (menu) => routeName?.startsWith(menu.path) ?? false,
      orElse: () => TeamMenu.dashboard,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUser =
          Provider.of<UserAuthProvider>(context, listen: false).currentUser;
      final uid = currentUser?.uid;
      if (uid != null) {
        await Provider.of<TeamProvider>(
          context,
          listen: false,
        ).fetchMyProfile(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final currentMenu = _getCurrentMenu(context);
    final teamProvider = Provider.of<TeamProvider>(context);
    final memberName = teamProvider.currentMember?.name ?? 'Team Member';
    return Scaffold(
      drawer: isMobile ? _buildDrawer(context, currentMenu) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(context, currentMenu),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, isMobile, memberName),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, TeamMenu currentMenu) {
    return Container(
      width: 200,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Team Panel',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ...TeamMenu.values.map(
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

  Widget _buildDrawer(BuildContext context, TeamMenu currentMenu) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Team Panel',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ...TeamMenu.values.map(
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
    TeamMenu item,
    TeamMenu currentMenu, {
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
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      },
    );
  }

  Widget _buildTopBar(BuildContext context, bool isMobile, String memberName) {
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
              'Welcome $memberName!',
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
              CircleAvatar(
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
