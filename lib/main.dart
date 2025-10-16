import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/profile_setup_screen.dart';
import 'screens/doctor/doctor_dashboard.dart';
import 'screens/patient/patient_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart Disease App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/signup': (context) => const SignupScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/doctor-dashboard': (context) => const DoctorDashboard(),
        '/patient-dashboard': (context) => const PatientDashboard(),
      },
    );
  }
}