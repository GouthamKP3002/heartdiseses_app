import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    User? user = _authService.currentUser;

    if (user == null) {
      // User not logged in
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // User logged in, check profile completion
      String? role = await _authService.getUserRole(user.uid);
      bool profileCompleted = await _authService.isProfileCompleted(user.uid);

      if (!mounted) return;

      if (role == null) {
        // Error getting role
        await _authService.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      } else if (!profileCompleted) {
        // Profile not completed
        Navigator.pushReplacementNamed(
          context,
          '/profile-setup',
          arguments: {'role': role},
        );
      } else {
        // Profile completed, go to dashboard
        if (role == 'doctor') {
          Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/patient-dashboard');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                'Heart Disease App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}