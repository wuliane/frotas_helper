import 'package:flutter/material.dart';

import 'core/database/database_helper.dart';
import 'core/theme/app_theme.dart';
import 'screens/dashboard/dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseHelper.initializeDatabaseFactory();

  runApp(const FrotasHelperApp());
}

class FrotasHelperApp extends StatelessWidget {
  const FrotasHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frotas Helper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const DashboardPage(),
    );
  }
}