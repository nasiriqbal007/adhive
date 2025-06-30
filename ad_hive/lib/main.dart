import 'package:ad_hive/provider/auth_provider.dart';
import 'package:ad_hive/provider/client_provider.dart';
import 'package:ad_hive/provider/team_provider.dart';
import 'package:ad_hive/firebase_options.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:ad_hive/utils/app_routes.dart';
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
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getAppTheme(),
            routerConfig: createRouter(authProvider),
          );
        },
      ),
    );
  }
}
