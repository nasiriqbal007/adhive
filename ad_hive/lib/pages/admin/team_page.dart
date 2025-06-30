import 'package:ad_hive/provider/team_provider.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:ad_hive/widegts/add_team.dart';
import 'package:ad_hive/widegts/primary_btn.dart';
import 'package:ad_hive/widegts/serachbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeamMembersPage extends StatefulWidget {
  const TeamMembersPage({super.key});

  @override
  State<TeamMembersPage> createState() => _TeamMembersPageState();
}

class _TeamMembersPageState extends State<TeamMembersPage> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final provider = Provider.of<TeamProvider>(context, listen: false);
        provider.fetchAllMembers();
      }
    });
  }

  void _addTeamMember() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showRegisterTeamDialog(context);
    });
  }

  void showAssignedTasksDialog(member) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("${member.name}'s Tasks"),
          content: SizedBox(
            width: 400,
            child:
                member.assignedTaskIds != null &&
                        member.assignedTaskIds!.isNotEmpty
                    ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          member.assignedTaskIds!
                              .map(
                                (taskId) => ListTile(
                                  leading: const Icon(Icons.task_alt),
                                  title: Text("Task ID: $taskId"),
                                  subtitle: const Text(
                                    "Details not loaded yet",
                                  ),
                                ),
                              )
                              .toList(),
                    )
                    : const Text("No tasks assigned."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (context, provider, _) {
        final filteredMembers =
            provider.allMembers.where((member) {
              final name = member.name?.toLowerCase() ?? '';
              final job = member.jobTitle?.toLowerCase() ?? '';
              return name.contains(searchQuery.toLowerCase()) ||
                  job.contains(searchQuery.toLowerCase());
            }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            return SingleChildScrollView(
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
                      isMobile
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Team',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 12),
                              AppSearchBar(
                                hintText: "Search Member",
                                onChanged: (v) {
                                  setState(() {
                                    searchQuery = v;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  text: "Add Member",
                                  onPressed: _addTeamMember,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Team',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(
                                width: 200,
                                child: AppSearchBar(
                                  hintText: "Search Member",
                                  onChanged: (v) {
                                    setState(() {
                                      searchQuery = v;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 200,
                                child: PrimaryButton(
                                  text: "Add Member",
                                  onPressed: _addTeamMember,
                                ),
                              ),
                            ],
                          ),
                      const SizedBox(height: 16),
                      provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: IntrinsicWidth(
                              child: DataTable(
                                headingTextStyle: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 13),
                                dataTextStyle:
                                    Theme.of(context).textTheme.titleSmall,
                                columns: const [
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Job Title')),
                                  DataColumn(label: Text('Phone')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Country')),

                                  DataColumn(label: Text('Status')),
                                ],
                                rows:
                                    filteredMembers.asMap().entries.map((
                                      entry,
                                    ) {
                                      final member = entry.value;
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(member.name ?? '')),
                                          DataCell(Text(member.jobTitle ?? '')),
                                          DataCell(Text(member.phone ?? '')),
                                          DataCell(Text(member.email ?? '')),
                                          DataCell(Text(member.country ?? '')),

                                          DataCell(
                                            Switch(
                                              value: member.isActive ?? false,
                                              activeColor: AppColors.greenColor,
                                              inactiveThumbColor:
                                                  AppColors.redColor,
                                              onChanged: (val) async {
                                                await provider.updateStatus(
                                                  member.id!,
                                                  val,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
