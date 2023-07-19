import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/firebase_options.dart';
import 'package:poetry_ai/home_page.dart';
import 'package:poetry_ai/services/authentication/auth_gate.dart';
import 'package:poetry_ai/services/authentication/auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  //initialize hive
  await Hive.initFlutter();
  //open hive box
  var box = await Hive.openBox('myBox');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => AuthService(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthGate(),
    );
  }
}

