import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'journal_list.dart';
import 'brand_config.dart';
import 'auth page/login.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Check for an existing session
  final authService = AuthService();
  final savedUsername = await authService.getSavedSession();

  runApp(MyApp(isLoggedIn: savedUsername != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: BrandConfig.themeData,
      home: isLoggedIn ? const JournalListsPage() : const LoginPage(),
    );
  }
}
