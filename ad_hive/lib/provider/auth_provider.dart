import 'package:ad_hive/models/team_model.dart';
import 'package:ad_hive/models/client_model.dart';
import 'package:ad_hive/services/auth_service.dart';
import 'package:ad_hive/services/db_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAuthProvider with ChangeNotifier {
  final _authService = AuthService();
  final _dbService = DbServices();

  // Controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final contactNumberController = TextEditingController();
  final jobTitleController = TextEditingController();
  final countryController = TextEditingController();

  // State variables
  bool isLoginLoading = false;
  bool isLoading = false;
  bool isSignUpLoading = false;

  String? userRole;
  bool isInitialized = false;

  User? get currentUser => _authService.currentUser;

  // Common validation
  String? validateEmailAndPassword(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password are required.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Invalid email format.';
    }

    if (password.trim().length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  // Auth
  Future<void> checkUserRole() async {
    final user = _authService.currentUser;
    if (user != null) {
      userRole = await _dbService.getUserRole(user.uid);
    }
    isInitialized = true;
  }

  Future<String?> sendResetLink(String email) async {
    if (email.isEmpty) return 'Email is required.';

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Invalid email format.';
    }

    try {
      await _authService.sendPasswordResetEmail(email.trim());
      return null;
    } catch (e) {
      return 'Failed to send reset email: $e';
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    userRole = null;
    isInitialized = false;

    notifyListeners();
  }

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    final validationError = validateEmailAndPassword(email, password);
    if (validationError != null) return validationError;

    isLoginLoading = true;

    notifyListeners();

    try {
      await _authService.loginUser(email, password);
      await checkUserRole();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Login failed: $e';
    } finally {
      loginEmailController.clear();
      loginPasswordController.clear();
      isLoginLoading = false;
      notifyListeners();
    }
  }

  Future<String?> clientSignUpRequest() async {
    if (nameController.text.isEmpty || contactNumberController.text.isEmpty) {
      return 'Name and contact number are required.';
    }

    final validationError = validateEmailAndPassword(
      emailController.text,
      passwordController.text,
    );
    if (validationError != null) return validationError;

    isSignUpLoading = true;
    notifyListeners();
    try {
      final newUser = ClientModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        contactNumber: contactNumberController.text.trim(),
        status: "pending",
      );
      await _dbService.addClientRequest(
        newUser,
        passwordController.text.trim(),
      );
      _clearForm();
      return null;
    } catch (e) {
      return 'Error: $e';
    } finally {
      isSignUpLoading = false;
      notifyListeners();
    }
  }

  Future<String?> registerTeamMember() async {
    if (nameController.text.isEmpty ||
        jobTitleController.text.isEmpty ||
        contactNumberController.text.isEmpty ||
        countryController.text.isEmpty) {
      return 'All fields are required.';
    }

    final validationError = validateEmailAndPassword(
      emailController.text,
      passwordController.text,
    );
    if (validationError != null) return validationError;

    isSignUpLoading = true;
    notifyListeners();
    try {
      final userCredential = await _authService.registerUser(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (userCredential.user == null) {
        return 'Registration failed: No user returned from Firebase.';
      }
      final uid = userCredential.user!.uid;
      final teamMember = TeamMemberModel(
        name: nameController.text.trim(),
        jobTitle: jobTitleController.text.trim(),
        email: emailController.text.trim(),
        phone: contactNumberController.text.trim(),
        country: countryController.text.trim(),
        isActive: true,
      );

      await _dbService.addTeamMember(teamMember, uid);
      _clearForm();
      return null;
    } catch (e) {
      return 'Registration failed: $e';
    } finally {
      isSignUpLoading = false;
      notifyListeners();
    }
  }

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    contactNumberController.clear();
    jobTitleController.clear();
    countryController.clear();
  }

  void disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    contactNumberController.dispose();
    jobTitleController.dispose();
    countryController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
  }
}
