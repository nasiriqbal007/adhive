import 'package:ad_hive/models/feedback_model.dart';
import 'package:ad_hive/models/package_model.dart';
import 'package:ad_hive/models/task_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ad_hive/models/client_model.dart';
import 'package:ad_hive/models/team_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DbServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _auth = FirebaseAuth.instance;

  Future<void> approveClientRequest({
    required String requestId,
    required ClientModel clientModel,
  }) async {
    final requestDocRef = _firestore.collection('requests').doc(requestId);
    final requestSnapshot = await requestDocRef.get();

    if (!requestSnapshot.exists) throw 'Request not found';

    final requestData = requestSnapshot.data()!;
    final email = requestData['email'];
    final password = requestData['password'];

    // 1. Create FirebaseAuth user
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user?.uid;
    if (uid == null) throw 'User creation failed';

    final batch = _firestore.batch();

    final clientDoc = _firestore.collection('clients').doc(uid);

    batch.set(clientDoc, {
      ...clientModel.toJson(),

      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });

    batch.delete(requestDocRef);
    await batch.commit();
  }

  // Add client signup request (pending)
  Future<void> addClientRequest(
    ClientModel clientModel,
    String password,
  ) async {
    await _firestore.collection('requests').add({
      ...clientModel.toJson(),
      'password': password,

      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  //reject client
  Future<void> rejectClientRequest(String requestId) async {
    final requestDocRef = _firestore.collection('requests').doc(requestId);
    final requestSnapshot = await requestDocRef.get();

    if (!requestSnapshot.exists) throw 'Request not found';

    await requestDocRef.delete();
  }

  // Fetch all pending client
  Future<List<ClientModel>> fetchPendingClients() async {
    final snapshot =
        await _firestore
            .collection('requests')
            .orderBy('requestedAt', descending: true)
            .get();
    if (snapshot.docs.isEmpty) return [];

    return snapshot.docs.map((doc) => ClientModel.fromJson(doc)).toList();
  }

  Future<void> buyPackageForClient({
    required String? clientId,
    required ClientPackage clientPackage,
  }) async {
    final clientRef = _firestore.collection('clients').doc(clientId);

    await clientRef.update({
      'packages': FieldValue.arrayUnion([clientPackage.toJson()]),
    });
  }

  Future<List<FeedbackModel>> fetchAllFeedbacks() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('feedbacks')
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs.map((doc) => FeedbackModel.fromMap(doc)).toList();
    } catch (e) {
      print('Error fetching feedbacks: $e');
      return [];
    }
  }

  Future<void> assignTaskToTeamMember({
    required TaskModel task,
    required ClientModel client,
    required String packageId,
    required DateTime newStartDate,
    required DateTime newExpiryDate,
    required ClientPackage updatedPackage,
  }) async {
    final taskRef = _firestore.collection('tasks').doc();

    final clientRef = _firestore.collection('clients').doc(client.id);

    // 🔁 Update only the matching package
    final updatedPackages =
        client.packages!.map((pkg) {
          if (pkg.packageId == packageId) {
            return ClientPackage(
              packageId: pkg.packageId,
              startDate: newStartDate,
              expiryDate: newExpiryDate,
            );
          }
          return pkg;
        }).toList();

    final batch = _firestore.batch();

    // ✅ 1. Create the task
    batch.set(taskRef, {
      ...task.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // ✅ 3. Update client's package list
    batch.update(clientRef, {
      'packages': updatedPackages.map((pkg) => pkg.toJson()).toList(),
    });

    await batch.commit();
  }

  Future<List<TaskModel>> fetchTasksForTeamMember(String teamMemberId) async {
    final snapshot =
        await _firestore
            .collection('tasks')
            .where('teamMemberId', isEqualTo: teamMemberId)
            .get();

    return snapshot.docs.map((doc) => TaskModel.fromDoc(doc)).toList();
  }

  Future<List<TaskModel>> fetchTasksForClient(String clientId) async {
    final snapshot =
        await _firestore
            .collection('tasks')
            .where('clientId', isEqualTo: clientId)
            .get();

    return snapshot.docs.map((doc) => TaskModel.fromDoc(doc)).toList();
  }

  Future<List<TaskModel>> fetchAllTasks() async {
    final snapshot =
        await _firestore
            .collection('tasks')
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => TaskModel.fromDoc(doc)).toList();
  }

  // Fetch all approved clients
  Future<List<ClientModel>> fetchAllClients() async {
    final snapshot =
        await _firestore
            .collection('clients')
            .orderBy('approvedAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => ClientModel.fromJson(doc)).toList();
  }

  // Fetch single client by ID
  Future<ClientModel?> getClientById(String clientId) async {
    final doc = await _firestore.collection('clients').doc(clientId).get();
    if (!doc.exists) return null;
    return ClientModel.fromJson(doc);
  }

  Future<List<TeamMemberModel>> getAllMembers() async {
    final querySnapshot = await _firestore.collection('team_members').get();
    return querySnapshot.docs
        .map((doc) => TeamMemberModel.fromMap(doc))
        .toList();
  }

  Future<void> updateTeamMemberStatus(String id, bool isActive) async {
    await _firestore.collection('team_members').doc(id).update({
      'isActive': isActive,
    });
  }

  Future<void> addPackage(PackageModel package) async {
    await _firestore.collection('packages').add(package.toMap());
  }

  Future<List<PackageModel>> fetchAllPackages() async {
    final snapshot =
        await _firestore
            .collection('packages')
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => PackageModel.fromDoc(doc)).toList();
  }

  Future<List<PackageModel>> fetchPackagesByIds(List<String> packageIds) async {
    if (packageIds.isEmpty) return [];
    final snapshot =
        await _firestore
            .collection('packages')
            .where(FieldPath.documentId, whereIn: packageIds)
            .get();

    return snapshot.docs.map((doc) => PackageModel.fromDoc(doc)).toList();
  }

  Future<TeamMemberModel?> getTeamMemberById(String id) async {
    final doc = await _firestore.collection('team_members').doc(id).get();
    if (!doc.exists) return null;
    return TeamMemberModel.fromMap(doc);
  }

  Future<void> addTeamMember(TeamMemberModel model, String id) async {
    await _firestore.collection('team_members').doc(id).set(model.toMap());
  }

  Future<String?> getUserRole(String uid) async {
    if ((await _firestore.collection('admin').doc(uid).get()).exists)
      return 'admin';
    if ((await _firestore.collection('team_members').doc(uid).get()).exists)
      return 'team';
    if ((await _firestore.collection('clients').doc(uid).get()).exists)
      return 'client';
    return null;
  }
}
