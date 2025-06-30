import 'package:ad_hive/models/feedback_model.dart';
import 'package:ad_hive/provider/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ad_hive/provider/client_provider.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:ad_hive/widegts/task_list.dart';
import 'package:ad_hive/models/task_model.dart';

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

  void addFeedback(BuildContext context, TaskModel task) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.background,
            title: const Text("Add Feedback"),
            content: TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your feedback...',
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(context, rootNavigator: true).pop(),

                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;

                  final clientProvider = Provider.of<ClientProvider>(
                    context,
                    listen: false,
                  );
                  final client = clientProvider.getClientById(
                    task.clientId ?? '',
                  );
                  final FeedbackModel feedback = FeedbackModel(
                    clientId: task.clientId,
                    taskId: task.id,
                    feedback: text,
                    clientName: client?.name ?? "N/A",
                    date: DateTime.now(),
                  );
                  await FirebaseFirestore.instance
                      .collection('feedbacks')
                      .add(feedback.toMap());

                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: const Text("Submit"),
              ),
            ],
          ),
    );
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
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Tasks",
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
                feedBack: (task) => addFeedback(context, task),
              ),
          ],
        ),
      ),
    );
  }
}
