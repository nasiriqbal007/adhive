import 'package:ad_hive/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:ad_hive/models/team_model.dart';
import 'package:ad_hive/services/db_services.dart';

class TeamProvider extends ChangeNotifier {
  final DbServices _dbService = DbServices();

  List<TeamMemberModel> allMembers = [];
  TeamMemberModel? currentMember;
  List<TaskModel> myTasks = [];

  bool isLoading = false;
  String? taskError;
  String? errorMessage;

  void _setLoading(bool value) {
    if (isLoading != value) {
      isLoading = value;
      notifyListeners();
    }
  }

  Future<void> fetchTasksForTeamMember(String teamMemberId) async {
    _setLoading(true);
    taskError = null;

    try {
      myTasks = await _dbService.fetchTasksForTeamMember(teamMemberId);
    } catch (e) {
      taskError = 'Failed to fetch tasks: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAllMembers() async {
    _setLoading(true);
    errorMessage = null;

    try {
      allMembers = await _dbService.getAllMembers();
    } catch (e) {
      errorMessage = 'Failed to fetch team members: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyProfile(String uid) async {
    _setLoading(true);
    errorMessage = null;

    try {
      currentMember = await _dbService.getTeamMemberById(uid);
    } catch (e) {
      errorMessage = 'Failed to fetch profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStatus(String id, bool newStatus) async {
    try {
      await _dbService.updateTeamMemberStatus(id, newStatus);
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to update status: $e';
      notifyListeners();
    }
  }

  TeamMemberModel? getTeamMemberById(String id) {
    return allMembers.firstWhere(
      (member) => member.id == id,
      orElse: () => TeamMemberModel(name: 'Unknown'),
    );
  }
}
