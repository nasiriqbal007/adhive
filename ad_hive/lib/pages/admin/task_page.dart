import 'package:ad_hive/widegts/task_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ad_hive/models/package_model.dart';
import 'package:ad_hive/models/task_model.dart';
import 'package:ad_hive/models/team_model.dart';
import 'package:ad_hive/models/client_model.dart';

import 'package:ad_hive/provider/client_provider.dart';
import 'package:ad_hive/provider/team_provider.dart';

import 'package:ad_hive/services/db_services.dart';
import 'package:ad_hive/utils/app_colors.dart';

import 'package:ad_hive/widegts/assign_task.dart';
import 'package:ad_hive/widegts/client_pkg_card.dart';
import 'package:ad_hive/widegts/primary_btn.dart';

class AdminTaskPage extends StatefulWidget {
  const AdminTaskPage({super.key});

  @override
  State<AdminTaskPage> createState() => _AdminTaskPageState();
}

class _AdminTaskPageState extends State<AdminTaskPage> {
  String searchQuery = '';
  List<PackageModel> allPackages = [];
  List<TaskModel> allTasks = [];
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(
        context,
        listen: false,
      ).fetchApprovedClients();
      Provider.of<TeamProvider>(context, listen: false).fetchAllMembers();
    });
    fetchPackages();
    fetchTasks();
  }

  Future<void> fetchPackages() async {
    final result = await DbServices().fetchAllPackages();
    setState(() => allPackages = result);
  }

  Future<void> fetchTasks() async {
    final result = await DbServices().fetchAllTasks();
    setState(() => allTasks = result);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final clients = Provider.of<ClientProvider>(context).approvedClients;
    final clientsWithPackages =
        clients
            .where((c) => c.packages != null && c.packages!.isNotEmpty)
            .toList();

    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : 20,
          vertical: isMobile ? 0 : 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          color: AppColors.whiteColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TabBar(
                labelColor: Colors.black,
                tabs: [Tab(text: 'Tasks'), Tab(text: 'Unassigned')],
              ),

              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    buildTaskSection(),
                    buildUnassignedClients(clientsWithPackages),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openManualExtendDialog(TaskModel task) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: task.deadline?.toLocal() ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    final clientDoc =
        await FirebaseFirestore.instance
            .collection('clients')
            .doc(task.clientId)
            .get();

    if (!clientDoc.exists) return;

    final client = ClientModel.fromJson(clientDoc);

    final updatedPackages =
        client.packages!.map((pkg) {
          if (pkg.packageId == task.packageId) {
            return ClientPackage(
              packageId: pkg.packageId,
              startDate: pkg.startDate,
              expiryDate: picked,
            );
          }
          return pkg;
        }).toList();

    await FirebaseFirestore.instance
        .collection('clients')
        .doc(clientDoc.id)
        .set({
          'packages': updatedPackages.map((e) => e.toJson()).toList(),
        }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
      'deadline': Timestamp.fromDate(picked),
    });

    await fetchTasks();
  }

  Widget buildTaskSection() {
    return ListView(
      children: [
        TaskListWithStats(
          allTasks: allTasks,
          role: 'admin',
          onChangeDeadline:
              (task, isAccepted) => handleExtensionDecision(task, isAccepted),
          onManualExtend: (task) => openManualExtendDialog(task),
        ),
      ],
    );
  }

  Future<void> handleExtensionDecision(TaskModel task, bool isAccepted) async {
    final docRef = FirebaseFirestore.instance.collection('tasks').doc(task.id);

    if (isAccepted) {
      final Timestamp? newDeadline = task.requests!.last['requestedDate'];
      await docRef.update({'deadline': newDeadline, 'requests': []});

      final clientDoc =
          await FirebaseFirestore.instance
              .collection('clients')
              .doc(task.clientId)
              .get();

      if (!clientDoc.exists) return;

      final client = ClientModel.fromJson(clientDoc);

      final updatedPackages =
          client.packages!.map((pkg) {
            if (pkg.packageId == task.packageId) {
              return ClientPackage(
                packageId: pkg.packageId,
                startDate: pkg.startDate,
                expiryDate: newDeadline!.toDate(),
              );
            }
            return pkg;
          }).toList();

      await FirebaseFirestore.instance.collection('clients').doc(client.id).set(
        {'packages': updatedPackages.map((e) => e.toJson()).toList()},
        SetOptions(merge: true),
      );
    } else {
      await docRef.update({'requests': []});
    }

    await fetchTasks();
  }

  Widget buildUnassignedClients(List<ClientModel> clients) {
    return ListView.builder(
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        final packages =
            client.packages!
                .where(
                  (pkg) => !_isTaskAlreadyAssigned(client.id!, pkg.packageId),
                )
                .toList();

        if (packages.isEmpty) return const SizedBox.shrink();

        return ExpansionTile(
          title: Text(client.name ?? "Unknown Client"),
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children:
                    packages.map((p) => buildPackageCard(p, client)).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isTaskAlreadyAssigned(String clientId, String packageId) {
    return allTasks.any(
      (task) => task.clientId == clientId && task.packageId == packageId,
    );
  }

  Widget buildPackageCard(ClientPackage p, ClientModel client) {
    final matched = allPackages.firstWhere(
      (pkg) => pkg.id == p.packageId,
      orElse: () => PackageModel(serviceName: "Unknown"),
    );

    return SizedBox(
      width: 300,
      child: Column(
        children: [
          ClientPackageCard(clientPackage: p, packageModel: matched),
          const SizedBox(height: 10),
          SizedBox(
            width: 200,
            child: PrimaryButton(
              text: "Assign Task",
              onPressed:
                  () => showAssignTaskDialog(context, (
                    TeamMemberModel member,
                  ) async {
                    final now = DateTime.now();
                    final newStart = now;
                    final newExpiry = now.add(
                      Duration(days: matched.duration! * 30),
                    );

                    final generatedChunks = List.generate(
                      matched.descriptionPoints!.length,
                      (i) => {
                        'title': matched.descriptionPoints![i],
                        'wordCount': matched.pointWordCounts![i],
                        'isDone': false,
                      },
                    );

                    final task = TaskModel(
                      title: matched.serviceName,
                      clientId: client.id,
                      teamMemberId: member.id,
                      packageId: matched.id,
                      status: 'pending',
                      deadline: newExpiry,
                      createdAt: now,
                      chunks: generatedChunks,
                    );

                    final updatedPackage = ClientPackage(
                      packageId: matched.id!,
                      startDate: newStart,
                      expiryDate: newExpiry,
                    );

                    await DbServices().assignTaskToTeamMember(
                      task: task,
                      client: client,
                      packageId: matched.id!,
                      newStartDate: newStart,
                      newExpiryDate: newExpiry,
                      updatedPackage: updatedPackage,
                    );
                    fetchTasks();
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
