import 'package:ad_hive/models/team_model.dart';
import 'package:ad_hive/provider/team_provider.dart';
import 'package:ad_hive/widegts/serachbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showAssignTaskDialog(
  BuildContext context,
  void Function(TeamMemberModel) onAssign,
) async {
  final teamProvider = Provider.of<TeamProvider>(context, listen: false);
  List<TeamMemberModel> allMembers = teamProvider.allMembers;

  String selectedJob = 'All';
  String searchQuery = '';

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final filteredMembers =
              allMembers.where((member) {
                final matchesJob =
                    selectedJob == 'All' || member.jobTitle == selectedJob;
                final matchesSearch =
                    member.name?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ??
                    false;
                return matchesJob && matchesSearch;
              }).toList();

          final uniqueJobs = {
            'All',
            ...allMembers.map((m) => m.jobTitle ?? '').toSet(),
          };

          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: selectedJob,
                      isExpanded: true,
                      items:
                          uniqueJobs.map((job) {
                            return DropdownMenuItem<String>(
                              value: job,
                              child: Text(job),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedJob = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Search bar
                    AppSearchBar(
                      hintText: "Search",
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // List of filtered members
                    SizedBox(
                      height: 200,
                      child:
                          filteredMembers.isEmpty
                              ? const Center(
                                child: Text('No team members found.'),
                              )
                              : ListView.builder(
                                itemCount: filteredMembers.length,
                                itemBuilder: (context, index) {
                                  final member = filteredMembers[index];
                                  return ListTile(
                                    title: Text(member.name ?? 'No Name'),
                                    subtitle: Text(
                                      member.jobTitle ?? 'No Role',
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        onAssign(member);
                                      },
                                      child: const Text('Assign'),
                                    ),
                                  );
                                },
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
