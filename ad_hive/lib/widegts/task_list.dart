import 'package:ad_hive/models/client_model.dart';
import 'package:ad_hive/models/team_model.dart';
import 'package:ad_hive/provider/client_provider.dart';
import 'package:ad_hive/provider/team_provider.dart';
import 'package:ad_hive/utils/date_format.dart';
import 'package:ad_hive/widegts/custom_drop_down.dart';
import 'package:ad_hive/widegts/text_btn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ad_hive/models/task_model.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:ad_hive/widegts/primary_btn.dart';
import 'package:ad_hive/widegts/serachbar.dart';
import 'package:provider/provider.dart';

class TaskListWithStats extends StatefulWidget {
  final List<TaskModel> allTasks;
  final String role; // 'admin', 'team', 'client'
  final void Function(TaskModel task)? onExtensionRequest;
  final void Function(TaskModel task, bool)? onChangeDeadline;

  const TaskListWithStats({
    super.key,
    required this.allTasks,
    required this.role,
    this.onExtensionRequest,
    this.onChangeDeadline,
  });

  @override
  State<TaskListWithStats> createState() => _TaskListWithStatsState();
}

class _TaskListWithStatsState extends State<TaskListWithStats> {
  String searchQuery = '';
  String selectedFilter = 'All';

  List<TaskModel> _filterTasks() {
    return widget.allTasks.where((task) {
      final title = task.title?.toLowerCase() ?? '';
      return title.contains(searchQuery.toLowerCase());
    }).toList();
  }

  List<TaskModel> _filterByStatus(List<TaskModel> tasks, String status) {
    return tasks
        .where(
          (task) => (task.status ?? '').toLowerCase() == status.toLowerCase(),
        )
        .toList();
  }

  Map<String, int> _calculateProgress(TaskModel task) {
    int total = 0, written = 0;
    if (task.chunks != null) {
      for (var chunk in task.chunks!) {
        final wordCount = (chunk['wordCount'] as num?)?.toInt() ?? 0;
        final writtenWords = (chunk['writtenWords'] as num?)?.toInt() ?? 0;
        total += wordCount;
        written += writtenWords;
      }
    }
    return {'total': total, 'written': written};
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filterTasks();

    final completed = _filterByStatus(filteredTasks, 'completed');
    final inProgress = _filterByStatus(filteredTasks, 'in progress');
    final pending = _filterByStatus(filteredTasks, 'pending');

    List<TaskModel> visible;
    if (selectedFilter == 'Completed') {
      visible = completed;
    } else if (selectedFilter == 'In Progress') {
      visible = inProgress;
    } else if (selectedFilter == 'Pending') {
      visible = pending;
    } else {
      visible = filteredTasks;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppSearchBar(
            hintText: 'Search Task',
            onChanged: (val) => setState(() => searchQuery = val),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 20,
            runSpacing: 16,
            children: [
              _buildStatBox("All", "${filteredTasks.length}", Colors.blueGrey),
              const SizedBox(width: 8),
              _buildStatBox(
                "Completed",
                "${completed.length}",
                AppColors.greenColor,
              ),
              const SizedBox(width: 8),
              _buildStatBox(
                "In Progress",
                "${inProgress.length}",
                Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildStatBox("Pending", "${pending.length}", Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("No tasks found."),
          )
        else
          ...visible.map(_buildTaskCard),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    final isSelected = selectedFilter == label;

    return SizedBox(
      width: 200,
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = label),
        child: Container(
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(40) : color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : color.withAlpha(100),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label, style: TextStyle(color: color.withAlpha(120))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final progressData = _calculateProgress(task);
    final total = progressData['total']!;
    final written = progressData['written']!;
    final progress = total == 0 ? 0.0 : written / total;
    final TeamMemberModel? teamModel = Provider.of<TeamProvider>(
      context,
      listen: false,
    ).getTeamMemberById(task.teamMemberId ?? '');
    final memberName = teamModel?.name ?? 'N/A';
    final ClientModel? clientModel = Provider.of<ClientProvider>(
      context,
      listen: false,
    ).getClientById(task.clientId ?? '');
    final String clientName = clientModel?.name ?? 'Unknown';
    final deadline = task.deadline?.toLocal();
    final now = DateTime.now();
    final daysLeft =
        (deadline != null && deadline.isAfter(now))
            ? (deadline.difference(now).inHours / 24).ceil()
            : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.borderLightGrey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title ?? '',
              style: Theme.of(context).textTheme.titleSmall,
            ),

            const SizedBox(height: 6),
            if (widget.role == 'client')
              Text(
                "Team Member: $memberName ",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            if (widget.role == 'team')
              Text(
                "Client: $clientName ",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            if (widget.role == 'admin')
              Row(
                children: [
                  Text(
                    "Client: $clientName ",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Team Member: $memberName ",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            const SizedBox(height: 6),

            Text("Deadline: ${formatDate(task.deadline)}"),
            if (daysLeft != null && daysLeft <= 2 && task.status != 'completed')
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Deadline approaching in $daysLeft day(s)',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.softGrey,
              color: AppColors.primary,
              minHeight: 6,
            ),
            const SizedBox(height: 4),
            Text(
              "$written/$total",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              runAlignment: WrapAlignment.spaceBetween,
              children: [
                if (widget.role == 'team')
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    runAlignment: WrapAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 200,
                        child: PrimaryButton(
                          text: "Request Extension",
                          onPressed:
                              () => widget.onExtensionRequest?.call(task),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: PrimaryButton(
                          text: "Add Words",
                          onPressed: () => _openAddWordsDialog(task),
                        ),
                      ),
                    ],
                  ),
                if (widget.role == 'admin' &&
                    task.requests != null &&
                    task.requests!.isNotEmpty &&
                    task.requests!.last['status'] == 'pending') ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Extension Requested: ${formatDate(task.requests!.last['requestedDate'])}",
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            PrimaryTextButton(
                              text: "Accept",
                              onPressed:
                                  () =>
                                      widget.onChangeDeadline?.call(task, true),
                            ),
                            const SizedBox(width: 12),
                            PrimaryTextButton(
                              text: "Reject",
                              onPressed:
                                  () => widget.onChangeDeadline?.call(
                                    task,
                                    false,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openAddWordsDialog(TaskModel task) async {
    final controller = TextEditingController();
    final chunks = task.chunks ?? [];

    int selectedChunkIndex = chunks.indexWhere(
      (chunk) => chunk['isDone'] != true,
    );
    if (selectedChunkIndex == -1) return;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: const Text("Add Work"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomDropdownField<int>(
                    label: 'Select Chunk',
                    value: selectedChunkIndex,
                    items:
                        chunks
                            .asMap()
                            .entries
                            .where((entry) => entry.value['isDone'] != true)
                            .map((entry) => entry.key)
                            .toList(),
                    itemLabelBuilder:
                        (index) => chunks[index]['title'] ?? 'Untitled',
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedChunkIndex = val);
                      }
                    },
                  ),

                  const SizedBox(height: 10),
                  if ((chunks[selectedChunkIndex]['content'] ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty)
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Previous Work:\n",
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(color: AppColors.primary),
                            ),
                            TextSpan(
                              text: chunks[selectedChunkIndex]['content'] ?? '',
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w300,
                                color: AppColors.greenColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Write your today work...',
                    ),
                  ),
                ],
              ),

              actions: [
                PrimaryTextButton(
                  text: 'Cancel',
                  onPressed:
                      () => Navigator.of(context, rootNavigator: true).pop(),
                ),
                SizedBox(
                  width: 120,
                  height: 40,
                  child: PrimaryButton(
                    text: "Submit",
                    onPressed: () async {
                      final inputText = controller.text.trim();
                      final inputWords =
                          inputText.isEmpty
                              ? 0
                              : inputText.split(RegExp(r'\s+')).length;

                      final updatedChunks = List<Map<String, dynamic>>.from(
                        chunks,
                      );
                      final chunk = updatedChunks[selectedChunkIndex];

                      final required = (chunk['wordCount'] ?? 0) as int;
                      final written = (chunk['writtenWords'] ?? 0) as int;
                      final newWritten = written + inputWords;

                      // Append content
                      final existingContent =
                          (chunk['content'] ?? '').toString().trim();
                      final newContent =
                          existingContent.isEmpty
                              ? inputText
                              : '$existingContent\n$inputText';

                      updatedChunks[selectedChunkIndex]['writtenWords'] =
                          newWritten;
                      updatedChunks[selectedChunkIndex]['content'] = newContent;

                      if (newWritten >= required) {
                        updatedChunks[selectedChunkIndex]['isDone'] = true;
                      }

                      final updatedStatus =
                          (task.status == 'pending')
                              ? 'in progress'
                              : task.status;

                      await FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(task.id)
                          .update({
                            'chunks': updatedChunks,
                            'status': updatedStatus,
                          });

                      setState(() {});
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
