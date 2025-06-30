import 'package:ad_hive/provider/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ad_hive/provider/client_provider.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:ad_hive/widegts/task_list.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final clientProvider = Provider.of<ClientProvider>(
        context,
        listen: false,
      );
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await clientProvider.fetchApprovedClients();
        await clientProvider.fetchTasksForCurrentUser(currentUser.uid);
        await teamProvider.fetchAllMembers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        color: AppColors.whiteColor,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to Your Dashboard",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Here’s an overview of your current tasks and progress.",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Package Alerts",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withAlpha(30)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Your package will expire in 3 days. Please renew to avoid interruption.",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Your Assigned Tasks",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),

            if (clientProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              TaskListWithStats(
                allTasks: clientProvider.myTasks,
                role: 'client',
              ),
          ],
        ),
      ),
    );
  }
}
