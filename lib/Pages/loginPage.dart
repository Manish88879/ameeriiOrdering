import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/authcontroller.dart';
import 'package:ameerii/Pages/CardManagement/cardHome.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String username = '';
    String password = '';

    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: screenSize.height,
            padding: EdgeInsets.all(screenSize.width * 0.05),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'images/loginImage.png',
                  height: screenSize.height * 0.3,
                  fit: BoxFit.fill,
                ),
                SizedBox(height: screenSize.height * 0.05),
                const Text(
                  'Welcome to',
                  style: TextStyle(color: Colors.grey, fontSize: 24),
                ),
                const Text(
                  'Ameerii',
                  style: TextStyle(
                      fontFamily: 'Raleway',
                      color: CommonValue.phyloText,
                      fontSize: 30,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: screenSize.height * 0.001),
                //const Text('Safe and secure', style: TextStyle(color: Colors.grey, fontSize: 16),),
                SizedBox(height: screenSize.height * 0.04),
                SizedBox(
                  width: screenSize.width * 0.85,
                  child: TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                SizedBox(
                  width: screenSize.width * 0.85,
                  child: TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.04),
                GestureDetector(
                  onTap: authController.isLoading == true
                      ? null
                      : (() => {
                            authController.login(
                                usernameController.text, passController.text)
                          }),
                  child: Container(
                    width: screenSize.width * 0.85,
                    height: screenSize.height * 0.07,
                    decoration: BoxDecoration(
                      color: CommonValue.phyloText,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    alignment: Alignment.center,
                    child: Obx(
                      () => Text(
                        authController.isLoading == true
                            ? 'Loading...'
                            : 'Submit',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.0,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
