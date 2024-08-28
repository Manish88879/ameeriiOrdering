import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:ameerii/Pages/splashScreen.dart';

import 'Common/controller/logger.dart';
import 'Routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  Logger.enableDebugLogging(true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ameerii',
      theme: ThemeData.light(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
