import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ameerii/Pages/loginPage.dart';
import 'package:ameerii/Routes/app_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(const Duration(milliseconds: 4000), () {});

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? counter = prefs.getString('userId');
    if (counter == null) {
      Get.toNamed('/login');
    } else {
      Get.offNamed(Routes.CARDHOME);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Implement your splash screen UI here
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/logo.png',
                height: 120,
                fit: BoxFit.fill,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
