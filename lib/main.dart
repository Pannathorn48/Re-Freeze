import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_project/pages/home/home.dart';
import 'package:mobile_project/pages/landing/landing.dart';
import 'package:mobile_project/pages/login/login.dart';
import 'package:mobile_project/signup/signup.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refreeze',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.lightBlue,
          accentColor: Colors.blueAccent,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/landing',
      // FirebaseAuth.instance.currentUser == null ? '/signup' : '/home',
      routes: pagesRoutes,
    );
  }
}

Map<String, Widget Function(BuildContext)> pagesRoutes = {
  '/landing': (context) => const LandingPage(),
  '/home': (context) => const HomePage(),
  '/login': (context) => const LoginPage(),
  '/signup': (context) => const SignUpPage(),
};
