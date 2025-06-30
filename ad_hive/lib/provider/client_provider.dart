import 'package:ad_hive/models/client_model.dart';
import 'package:ad_hive/models/package_model.dart';
import 'package:ad_hive/models/task_model.dart';
import 'package:ad_hive/services/db_services.dart';
import 'package:flutter/material.dart';

class ClientProvider with ChangeNotifier {
  final DbServices _dbServices = DbServices();
  ClientModel? currentClient;
  List<ClientModel> _pendingClients = [];
  List<ClientModel> _approvedClients = [];
  List<PackageModel> _clientPackages = [];
  List<TaskModel> myTasks = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<ClientModel> get pendingClients => _pendingClients;
  List<ClientModel> get approvedClients => _approvedClients;
  List<PackageModel> get clientPackages => _clientPackages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(Object e) {
    _error = e.toString();
    notifyListeners();
  }

  List<String> _getPackageIdsFromClient(ClientModel client) {
    return client.packages?.map((p) => p.packageId).toList() ?? [];
  }

  ClientModel? getClientById(String id) {
    return _approvedClients.firstWhere(
      (client) => client.id == id,
      orElse: () => ClientModel(name: 'Unknown'),
    );
  }

  Future<void> fetchPendingClients() async {
    _setLoading(true);
    try {
      _pendingClients = await _dbServices.fetchPendingClients();
      _error = null;
    } catch (e) {
      _setError(e);
    }
    _setLoading(false);
  }

  Future<void> fetchApprovedClients() async {
    _setLoading(true);
    try {
      _approvedClients = await _dbServices.fetchAllClients();
      _error = null;
    } catch (e) {
      _setError(e);
    }
    _setLoading(false);
  }

  Future<void> approveClient({
    required String requestId,
    required ClientModel client,
  }) async {
    _setLoading(true);
    try {
      await _dbServices.approveClientRequest(
        requestId: requestId,
        clientModel: client,
      );
      _pendingClients.removeWhere((c) => c.id == requestId);
      await fetchApprovedClients();
      _error = null;
    } catch (e) {
      _setError(e);
    }
    _setLoading(false);
  }

  Future<void> fetchCurrentClient(String uid) async {
    _setLoading(true);
    try {
      currentClient = await _dbServices.getClientById(uid);
      _error = null;
    } catch (e) {
      _setError(e);
      currentClient = null;
    }
    _setLoading(false);
  }

  Future<void> fetchTasksForCurrentUser(String clientId) async {
    _setLoading(true);
    try {
      myTasks = await _dbServices.fetchTasksForClient(clientId);
      _error = null;
    } catch (e) {
      _setError('Failed to fetch tasks: $e');
    }
    _setLoading(false);
  }

  Future<void> fetchPackagesForClient(List<String>? packageIds) async {
    if (packageIds == null || packageIds.isEmpty) {
      _clientPackages = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      _clientPackages = await _dbServices.fetchPackagesByIds(packageIds);
      _error = null;
    } catch (e) {
      _setError(e);
    }
    _setLoading(false);
  }

  Future<ClientModel?> fetchClientPackagesByUserId(String clientId) async {
    _setLoading(true);
    try {
      final client = await _dbServices.getClientById(clientId);

      if (client != null &&
          client.packages != null &&
          client.packages!.isNotEmpty) {
        final packageIds = _getPackageIdsFromClient(client);
        _clientPackages = await _dbServices.fetchPackagesByIds(packageIds);
      } else {
        _clientPackages = [];
      }

      _error = null;
      return client;
    } catch (e) {
      _setError(e);
      _clientPackages = [];
      return null;
    } finally {
      _setLoading(false);
    }
  }
}
