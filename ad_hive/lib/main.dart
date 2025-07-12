import 'package:ad_hive/auth_page.dart/client_signup.dart';
import 'package:ad_hive/auth_page.dart/forget_password.dart';
import 'package:ad_hive/auth_page.dart/guest_page.dart';
import 'package:ad_hive/auth_page.dart/login_page.dart';
import 'package:ad_hive/pages/admin/admin_home.dart';
import 'package:ad_hive/pages/admin/overview.dart';
import 'package:ad_hive/pages/admin/package_page.dart';
import 'package:ad_hive/pages/admin/request_page.dart';
import 'package:ad_hive/pages/admin/task_page.dart';
import 'package:ad_hive/pages/admin/team_page.dart';
import 'package:ad_hive/pages/client/cleint_packages.dart';
import 'package:ad_hive/pages/client/client_dashboard.dart';
import 'package:ad_hive/pages/client/client_home.dart';
import 'package:ad_hive/pages/team/team_dash_board.dart';
import 'package:ad_hive/pages/team/team_home.dart';
import 'package:ad_hive/provider/auth_provider.dart';
import 'package:ad_hive/provider/client_provider.dart';
import 'package:ad_hive/provider/team_provider.dart';
import 'package:ad_hive/firebase_options.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
      ],
      child: Consumer<UserAuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            theme: AppTheme.getAppTheme(),
            initialRoute: '/guest-dashboard',
            routes: {
              '/login': (_) => const LoginPage(),
              '/signup': (_) => const ClientSignUpPage(),
              '/forgot-password': (_) => const ForgotPasswordPage(),
              '/guest-dashboard': (_) => const GuestDashBoardPage(),

              // Admin
              '/admin/overview': (_) => AdminHome(child: OverviewPage()),
              '/admin/task': (_) => AdminHome(child: AdminTaskPage()),
              '/admin/team': (_) => AdminHome(child: TeamMembersPage()),
              '/admin/requests': (_) => AdminHome(child: RequestPage()),
              '/admin/packages': (_) => AdminHome(child: PackagePage()),

              // Client
              '/client/dashboard': (_) => ClientHome(child: ClientDashboard()),
              '/client/packages':
                  (_) => ClientHome(child: CleintPackagesPage()),

              // Team
              '/team/dashboard': (_) => TeamMemberHome(child: TeamDashboard()),
            },
          );
        },
      ),
    );
  }
}
