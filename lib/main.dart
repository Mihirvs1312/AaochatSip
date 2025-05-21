import 'package:callingproject/src/Providers/DomainProvider.dart';
import 'package:callingproject/src/Providers/LoginProvider.dart';
import 'package:callingproject/src/Providers/ThemeProvider.dart';
import 'package:callingproject/src/SplashScreen.dart';
import 'package:callingproject/src/pages/DomainScreen.dart';
import 'package:callingproject/src/utils/SharedPrefs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.init();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 750),
      minimumSize: Size(1200, 750),
      center: true,
      title: 'Teamlocus SIP',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

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
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
