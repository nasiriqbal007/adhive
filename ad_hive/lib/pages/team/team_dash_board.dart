import 'package:ad_hive/provider/client_provider.dart';
import 'package:ad_hive/widegts/primary_btn.dart';
import 'package:ad_hive/widegts/task_list.dart';
import 'package:ad_hive/widegts/text_btn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ad_hive/provider/team_provider.dart';

import 'package:ad_hive/utils/app_colors.dart';

class TeamDashboard extends StatefulWidget {
  const TeamDashboard({super.key});

  @override
  State<TeamDashboard> createState() => _TeamDashboardState();
}

class _TeamDashboardState extends State<TeamDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);
      final clientProvider = Provider.of<ClientProvider>(
        context,
        listen: false,
      );

      await teamProvider.fetchAllMembers();

      await clientProvider.fetchApprovedClients();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await teamProvider.fetchMyProfile(uid);
        final userId = teamProvider.currentMember?.id;
        if (userId != null) {
          await teamProvider.fetchTasksForTeamMember(userId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final allTasks = teamProvider.myTasks;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        color: AppColors.whiteColor,
        child:
            teamProvider.taskError != null
                ? Center(child: Text(teamProvider.taskError!))
                : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Text(
                        "My Dashboard",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TaskListWithStats(
                      allTasks: allTasks,
                      role: 'team',
                      onExtensionRequest: (task) async {
                        DateTime? localSelectedDate;
                        bool datePickerShown = false;

                        await showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                if (!datePickerShown) {
                                  datePickerShown = true;

                                  final now = DateTime.now();
                                  final deadline = task.deadline ?? now;

                                  Future.microtask(() async {
                                    final firstDate =
                                        deadline.isAfter(now)
                                            ? deadline.add(Duration(days: 1))
                                            : now;
                                    final initialDate =
                                        firstDate.isAfter(now)
                                            ? firstDate
                                            : now;

                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: initialDate,
                                      firstDate: firstDate,
                                      lastDate: now.add(Duration(days: 90)),
                                    );

                                    if (picked != null) {
                                      setState(() {
                                        localSelectedDate = picked;
                                      });
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                  });
                                }

                                return AlertDialog(
                                  backgroundColor: AppColors.background,
                                  title: const Text(
                                    "Request Deadline Extension",
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Current deadline: ${task.deadline != null ? task.deadline!.toLocal().toString().split(' ')[0] : 'N/A'}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (localSelectedDate != null)
                                        Text(
                                          "Selected new deadline: ${localSelectedDate!.toLocal().toString().split(' ')[0]}",
                                        )
                                      else
                                        const Text("Loading date picker..."),
                                    ],
                                  ),
                                  actions: [
                                    PrimaryTextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              ).pop(),
                                      text: "Cancel",
                                    ),
                                    SizedBox(
                                      width: 120,
                                      height: 40,
                                      child: PrimaryButton(
                                        onPressed:
                                            localSelectedDate == null
                                                ? () {}
                                                : () async {
                                                  if (localSelectedDate == null)
                                                    return;

                                                  if (task.deadline != null &&
                                                      !localSelectedDate!
                                                          .isAfter(
                                                            task.deadline!,
                                                          )) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "New deadline must be after current deadline.",
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  final taskRef =
                                                      FirebaseFirestore.instance
                                                          .collection('tasks')
                                                          .doc(task.id);

                                                  await taskRef.update({
                                                    "requests": FieldValue.arrayUnion([
                                                      {
                                                        "requestedDate":
                                                            Timestamp.fromDate(
                                                              localSelectedDate!,
                                                            ),
                                                        "requestTime":
                                                            Timestamp.now(),
                                                        "status": "pending",
                                                      },
                                                    ]),
                                                  });

                                                  Navigator.of(
                                                    context,
                                                    rootNavigator: true,
                                                  ).pop();
                                                },
                                        text: "Submit",
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
      ),
    );
  }
}
