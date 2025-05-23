import 'dart:io';

import 'package:callingproject/src/Providers/domain_provider.dart';
import 'package:callingproject/src/Providers/login_provider.dart';
import 'package:callingproject/src/Providers/theme_provider.dart';
import 'package:callingproject/src/models/appacount_model.dart';
import 'package:callingproject/src/models/call_model.dart';
import 'package:callingproject/src/pages/call_screen.dart';
import 'package:callingproject/src/providers/call_logs_provider.dart';
import 'package:callingproject/src/splash_screen.dart';
import 'package:callingproject/src/pages/domain_screen.dart';
import 'package:callingproject/src/utils/shared_prefs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/cdrs_model.dart';
import 'package:siprix_voip_sdk/devices_model.dart';
import 'package:siprix_voip_sdk/logs_model.dart';
import 'package:siprix_voip_sdk/messages_model.dart';
import 'package:siprix_voip_sdk/network_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';
import 'package:siprix_voip_sdk/subscriptions_model.dart';
import 'package:window_manager/window_manager.dart';

main() async {
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

  LogsModel logsModel = LogsModel(true);
  CdrsModel cdrsModel = CdrsModel();
  AppAccountsModel accountsModel = AppAccountsModel(logsModel);
  MessagesModel messagesModel = MessagesModel(accountsModel, logsModel);
  AppCallsModel callsModel = AppCallsModel(accountsModel, logsModel, cdrsModel);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => DomainProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
        ChangeNotifierProvider(create: (context) => AppAccountsModel(logsModel),),
        ChangeNotifierProvider(create: (context) => NetworkModel(logsModel)),
        ChangeNotifierProvider(create: (context) => DevicesModel(logsModel)),
        ChangeNotifierProvider(create: (context) => messagesModel),
        ChangeNotifierProvider(create: (context) => callsModel),
        ChangeNotifierProvider(create: (context) => cdrsModel),
        ChangeNotifierProvider(create: (context) => logsModel),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static String _ringtonePath = "";

  @override
  State<MyApp> createState() => _MyAppState();

  /// Returns ringtone's path saved on device
  static String getRingtonePath() => _ringtonePath;

  void writeRingtoneAsset() async {
    _ringtonePath = await writeAssetAndGetFilePath("ringtone.mp3");
  }

  static Future<String> writeAssetAndGetFilePath(String assetsFileName) async {
    var homeFolder = await SiprixVoipSdk().homeFolder();
    var filePath = '$homeFolder$assetsFileName';

    var file = File(filePath);
    var exists = file.existsSync();
    debugPrint("writeAsset: '$filePath' exists:$exists");
    if (exists) return filePath;

    final byteData = await rootBundle.load('assets/$assetsFileName');
    await file.create(recursive: true);
    file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return filePath;
  }

  static Future<String> getRecFilePathName(int callId) async {
    String dateTime = DateFormat('yyyyMMdd_HHmmss_').format(DateTime.now());
    var homeFolder = await SiprixVoipSdk().homeFolder();
    var filePath = '$homeFolder$dateTime$callId.mp3';
    return filePath;
  }
}

class _MyAppState extends State<MyApp> {
  void initState() {
    super.initState();
    _initializeSiprix(context.read<LogsModel>());
    widget.writeRingtoneAsset();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teamlocus SIP',
      home: const Splashscreen(),
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      debugShowCheckedModeBanner: false,
    );
  }

  static void _initializeSiprix([LogsModel? logsModel]) async {
    debugPrint('_initializeSiprix');
    InitData iniData = InitData();
    iniData.license = "...license-credentials...";
    iniData.logLevelFile = LogLevel.debug;
    iniData.logLevelIde = LogLevel.info;
    await SiprixVoipSdk().initialize(iniData, logsModel);
  }
}
