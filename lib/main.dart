import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_project/pages/item-list/item_list.dart';
import 'package:mobile_project/pages/landing/landing.dart';
import 'package:mobile_project/pages/login/login.dart';
import 'package:mobile_project/pages/signup/signup.dart';
import 'package:mobile_project/pages/signup/signup_display_name.dart';
import 'package:mobile_project/pages/signup/signup_profile.dart';
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
      initialRoute: '/item-list',
      // FirebaseAuth.instance.currentUser == null ? '/signup' : '/home',
      routes: pagesRoutes,
    );
  }
}

Map<String, Widget Function(BuildContext)> pagesRoutes = {
  '/landing': (context) => const LandingPage(),
  '/login': (context) => const LoginPage(),
  // sign up
  '/signup': (context) => const SignUpPage(),
  '/signup/display-name': (context) => const SetUpDisplayNamePage(),
  '/signup/profile': (context) => const SignupProfilePage(),
  // item list
  '/item-list': (context) => const ItemListPage(),
};
