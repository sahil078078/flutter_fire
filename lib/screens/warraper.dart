import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fire/screens/auth_screen.dart';
import 'package:flutter_fire/screens/home_screen.dart';

import '../services/auth_service.dart';

class Warraper extends StatelessWidget {
  const Warraper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authState,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen();
        } else {
          return AuthScreen();
        }
      },
    );
  }
}
