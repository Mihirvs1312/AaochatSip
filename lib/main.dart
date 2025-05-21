import 'package:callingproject/src/Providers/DomainProvider.dart';
import 'package:callingproject/src/Providers/LoginProvider.dart';
import 'package:callingproject/src/Providers/ThemeProvider.dart';
import 'package:callingproject/src/SplashScreen.dart';
import 'package:callingproject/src/pages/DomainScreen.dart';
import 'package:callingproject/src/utils/SharedPrefs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => DomainProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teamlocus SIP',
      home: const Splashscreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
