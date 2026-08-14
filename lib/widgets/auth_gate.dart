import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../pages/login_page.dart';
import '../screens/dashboard_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _loggedInFuture;

  @override
  void initState() {
    super.initState();
    _loggedInFuture = AuthService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final loggedIn = snapshot.data ?? false;
        return loggedIn ? const DashboardScreen() : const LoginPage();
      },
    );
  }
}