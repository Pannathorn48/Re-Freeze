import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_project/pages/item-list/item_list_page.dart';
import 'package:mobile_project/pages/landing/landing_page.dart';
import 'package:mobile_project/pages/login/login_page.dart';
import 'package:mobile_project/pages/refrigerators/refrigerators_page.dart';
import 'package:mobile_project/pages/signup/signup_page.dart';
import 'package:mobile_project/pages/signup/signup_display_name_page.dart';
import 'package:mobile_project/pages/signup/signup_profile_page.dart';
import 'package:mobile_project/services/custom_navbar.dart';
import 'package:mobile_project/services/providers.dart';
import 'package:mobile_project/supabase_key.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseKey.url,
    anonKey: SupabaseKey.anonKey,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => LoadingProvider())
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

const themeColor = Colors.lightBlue;

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refreeze',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: themeColor,
          accentColor: Colors.blueAccent,
        ).copyWith(
          secondary: themeColor[800],
          outline: themeColor,
          primaryContainer: themeColor[100],
        ),
        useMaterial3: true,
      ),
      // initialRoute: '/item-list',
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/landing' : '/home',
      routes: pagesRoutes,
    );
  }
}

Map<String, Widget Function(BuildContext)> pagesRoutes = {
  '/home': (context) => const BottomNavBar(),
  '/landing': (context) => const LandingPage(),
  '/login': (context) => const LoginPage(),
  // sign up
  '/signup': (context) => const SignUpPage(),
  '/signup/display-name': (context) => const SetUpDisplayNamePage(),
  '/signup/profile': (context) => const SignupProfilePage(),
  // item list
  '/item-list': (context) => const ItemListPage(),
  //refrigerators
  '/refrigerators': (context) => const RefrigeratorsPage()
};
