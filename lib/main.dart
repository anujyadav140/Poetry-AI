import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/api/firebase_push.dart';
import 'package:poetry_ai/components/rate_my_app.dart';
import 'package:poetry_ai/firebase_options.dart';
import 'package:poetry_ai/pages/home_page.dart';
import 'package:poetry_ai/services/authentication/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize google ads
  MobileAds.instance.initialize();
  //initialize hive
  await Hive.initFlutter();
  //open hive box
  Animate.restartOnHotReload = true;
  await Hive.openBox('myThemeBox');
  await Hive.openBox('myIsTemplateClickedBox');
  await Hive.openBox('myPoemBox');
  await Hive.openBox('myPoemListIndexBox');
  await Hive.openBox('myCustomPoemBox');
  await Hive.openBox('myAdsCounterStore');
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();
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
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RateAppInitWidget(
        builder: (rateMyApp) => HomePage(rateMyApp: rateMyApp),
      ),
    );
  }
}
