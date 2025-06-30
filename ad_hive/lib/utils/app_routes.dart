import 'package:ad_hive/auth_page.dart/forget_password.dart';
import 'package:ad_hive/pages/admin/task_page.dart';
import 'package:ad_hive/pages/client/client_dashboard.dart';
import 'package:ad_hive/pages/client/client_home.dart';
import 'package:ad_hive/pages/client/client_task_page.dart';
import 'package:ad_hive/pages/team/team_home.dart';
import 'package:ad_hive/pages/team/team_dash_board.dart';
import 'package:ad_hive/provider/auth_provider.dart';
import 'package:ad_hive/pages/admin/admin_home.dart';
import 'package:ad_hive/pages/admin/package_page.dart';
import 'package:ad_hive/pages/admin/request_page.dart';
import 'package:ad_hive/pages/admin/team_page.dart';
import 'package:ad_hive/auth_page.dart/client_signup.dart';
import 'package:ad_hive/auth_page.dart/login_page.dart';
import 'package:ad_hive/pages/admin/overview.dart';
import 'package:ad_hive/pages/client/cleint_packages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(UserAuthProvider auth) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: auth.routerNotifier,
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final role = auth.userRole;
      final isInitialized = auth.isInitialized;

      final isAtLogin = state.fullPath == '/login';
      final isAtSignUp = state.fullPath == '/signup';

      if (!isInitialized) return null;

      if (!isLoggedIn) {
        if (!isAtLogin && !isAtSignUp) return '/login';
        return null;
      }
      print(role);
      if (isLoggedIn && isAtLogin) {
        switch (role) {
          case 'admin':
            return '/admin/overview';
          case 'team':
            return '/team/dashboard';
          case 'client':
            return '/client/dashboard';
        }
      }

      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, __) => const ClientSignUpPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),

      ShellRoute(
        builder: (_, __, child) => AdminHome(child: child),
        routes: [
          GoRoute(path: '/admin/overview', builder: (_, __) => OverviewPage()),
          GoRoute(
            path: '/admin/task',
            builder: (_, __) => const AdminTaskPage(),
          ),
          GoRoute(
            path: '/admin/team',
            builder: (_, __) => const TeamMembersPage(),
          ),
          GoRoute(
            path: '/admin/requests',
            builder: (_, __) => const RequestPage(),
          ),
          GoRoute(
            path: '/admin/packages',
            builder: (_, __) => const PackagePage(),
          ),
        ],
      ),
      ShellRoute(
        builder: (_, __, child) => TeamMemberHome(child: child),
        routes: [
          GoRoute(
            path: '/team/dashboard',
            builder: (_, __) => const TeamDashboard(),
          ),
          GoRoute(path: '/team/tasks', builder: (_, __) => Text('')),
        ],
      ),
      ShellRoute(
        builder: (_, __, child) => ClientHome(child: child),
        routes: [
          GoRoute(
            path: '/client/dashboard',
            builder: (_, __) => const ClientDashboard(),
          ),
          GoRoute(
            path: '/client/tasks',
            builder: (_, __) => const ClientTaskPage(),
          ),
          GoRoute(
            path: '/client/packages',
            builder: (_, __) => const CleintPackagesPage(),
          ),
        ],
      ),
    ],
  );
}
