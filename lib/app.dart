import 'package:flutter/material.dart';
import 'package:student_dashboard/pages/login_page.dart';

import 'screens/dashboard_screen.dart';

class StudentDashboardApp extends StatelessWidget {
  const StudentDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ສະຖິຕິນັກຮຽນ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2A78D6),
        scaffoldBackgroundColor: const Color(0xFFF5F4F0),
        fontFamily: 'NotoSansLao',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF2A78D6),
        scaffoldBackgroundColor: const Color(0xFF161615),
        fontFamily: 'NotoSansLao',
      ),
      themeMode: ThemeMode.system,
      home: const LoginPage(),
    );
  }
}
