import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'firebase_options.dart';
import 'language/language_provider.dart';
import 'screens/login_screen.dart';

import 'services/local_notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotificationService.initialize(onNotificationTap: () {});

  // Initialize SQLite for Web
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const KrushiBandhu(),
    ),
  );
}

class KrushiBandhu extends StatelessWidget {
  const KrushiBandhu({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: "KrushiBandhu",
      locale: language.locale,
      home: const LoginScreen(),
    );
  }
}
