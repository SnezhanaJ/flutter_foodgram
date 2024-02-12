
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodgram/firebase_options.dart';
import 'package:foodgram/pages/login_page.dart';
import 'package:foodgram/splash_screen.dart';
import 'package:foodgram/widgets/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return const Navigations_Screen();
            }
          }
          // means connection to future hasnt been made yet
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return const SplashScreen(
            child: LoginPage(),
          );
        },
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
    );
  }
}