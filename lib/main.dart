import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/components/form.dart';
import 'package:poetry_ai/firebase_options.dart';
import 'package:poetry_ai/pages/give_title.dart';
import 'package:poetry_ai/pages/home_page.dart';
import 'package:poetry_ai/pages/quick_editor.dart';
import 'package:poetry_ai/services/authentication/auth_gate.dart';
import 'package:poetry_ai/services/authentication/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  //initialize hive
  await Hive.initFlutter();
  //open hive box
  Animate.restartOnHotReload = true;
  var themeBox = await Hive.openBox('myThemeBox');
  var templateBoolBox = await Hive.openBox('myIsTemplateClickedBox');
  var poemListBox = await Hive.openBox('myPoemBox');
  var poemListIndexBox = await Hive.openBox('myPoemListIndexBox');
  var customPoemListBox = await Hive.openBox('myCustomPoemBox');
  var adsCounterStore = await Hive.openBox('myAdsCounterStore');
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
        // primarySwatch: const MaterialColor(
        //   0xFFBB99FA,
        //   <int, Color>{
        //     50: Color(0xFFEDE7FD),
        //     100: Color(0xFFDDD1FA),
        //     200: Color(0xFFD1B9F6),
        //     300: Color(0xFFC4A1F2),
        //     400: Color(0xFFB68AF0),
        //     500: Color(0xFFA873ED),
        //     600: Color(0xFF9B5CEA),
        //     700: Color(0xFF8D44E6),
        //     800: Color(0xFF803CE3),
        //     900: Color(0xFF6F2EDF),
        //   },
        // ),
        // primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: const AuthGate(),
      home: const HomePage(),
      // home: const QuickMode(),
      // home: const GiveTitle(),
    );
  }
}
