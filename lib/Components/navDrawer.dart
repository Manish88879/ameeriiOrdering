import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/controller/authcontroller.dart';
import 'package:ameerii/Routes/app_pages.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black, // Black status bar
    ));
    return Drawer(
      backgroundColor: Color.fromARGB(173, 252, 252, 252),
      child: SafeArea(
        child: Container(
          color: Colors.white,
          child: ListView(
            children: [
              FutureBuilder<String?>(
                future: authController.getNameFromSharedPreferences(),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  String userName = 'User'; // Default user name
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    userName = 'Loading...';
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    userName = 'No name found';
                  } else {
                    userName = snapshot.data ?? 'User';
                  }
                  return UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 231, 228, 246)),
                    accountName: Text(
                      'Welcome,',
                      style: TextStyle(
                          color: Colors.blueGrey, fontWeight: FontWeight.bold),
                    ),
                    accountEmail: Text(
                      userName,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    currentAccountPicture: Image.asset('images/logo.png'),
                  );
                },
              ),
              FutureBuilder<String?>(
                future: authController.showData('card Management'),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  } else if (snapshot.hasError || snapshot.data != 'true') {
                    return SizedBox.shrink(); // Do not show the item
                  } else {
                    return buildDrawerItem(
                      text: 'Card Management',
                      icon: Icons.credit_card_outlined,
                      textIconColor: Get.currentRoute == Routes.CARDHOME
                          ? Colors.purple
                          : Colors.black,
                      tileColor: Get.currentRoute == Routes.CARDHOME
                          ? Colors.red
                          : Colors.white,
                      onTap: () => {Get.offAllNamed(Routes.CARDHOME)},
                    );
                  }
                },
              ),
              FutureBuilder<String?>(
                future: authController.showData('quick_order'),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  } else if (snapshot.hasError || snapshot.data != 'true') {
                    return SizedBox.shrink(); // Do not show the item
                  } else {
                    return buildDrawerItem(
                      text: 'Quick Order',
                      icon: Icons.credit_card_outlined,
                      textIconColor: Get.currentRoute == Routes.QUICKORDER
                          ? Colors.purple
                          : Colors.black,
                      tileColor: Get.currentRoute == Routes.QUICKORDER
                          ? Colors.red
                          : Colors.white,
                      onTap: () => {Get.offAllNamed(Routes.QUICKORDER)},
                    );
                  }
                },
              ),
              FutureBuilder<String?>(
                future: authController.showData('card table_order'),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  } else if (snapshot.hasError || snapshot.data != 'true') {
                    return SizedBox.shrink(); // Do not show the item
                  } else {
                    return buildDrawerItem(
                      text: 'Bill/Table',
                      icon: Icons.credit_card_outlined,
                      textIconColor: Get.currentRoute == Routes.TABLEHOME
                          ? Colors.purple
                          : Colors.black,
                      tileColor: Get.currentRoute == Routes.TABLEHOME
                          ? Colors.red
                          : Colors.white,
                      onTap: () => {Get.offAllNamed(Routes.TABLEHOME)},
                    );
                  }
                },
              ),
              FutureBuilder<String?>(
                future: authController.showData('reports'),
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  } else if (snapshot.hasError || snapshot.data != 'true') {
                    return SizedBox.shrink(); // Do not show the item
                  } else {
                    return buildDrawerItem(
                      text: 'Report',
                      icon: Icons.credit_card_outlined,
                      textIconColor: Get.currentRoute == Routes.REPORTHOME
                          ? Colors.purple
                          : Colors.black,
                      tileColor: Get.currentRoute == Routes.REPORTHOME
                          ? Colors.red
                          : Colors.white,
                      onTap: () => {Get.offAllNamed(Routes.REPORTHOME)},
                    );
                  }
                },
              ),
              buildDrawerItem(
                text: 'Logout',
                icon: Icons.logout_outlined,
                textIconColor: Colors.black,
                tileColor: Colors.white,
                onTap: () async {
                  await authController
                      .removeNameAndUserIdFromSharedPreferences();
                  Get.offAllNamed(Routes.LOGIN);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDrawerItem({
    required String text,
    required IconData icon,
    required Color textIconColor,
    required Color? tileColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
          leading: Icon(icon, color: textIconColor),
          title: Text(
            text,
            style: TextStyle(color: textIconColor, fontWeight: FontWeight.w500),
          ),
          tileColor: tileColor,
          onTap: onTap,
        ),
        SizedBox(
          height: 1,
        )
      ],
    );
  }
}
