import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ameerii/Common/APIUrls.dart';
import 'package:ameerii/Routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  RxString userId = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isCard_management = false.obs;
  RxBool quick_order = false.obs;
  RxBool table_order = false.obs;
  RxBool reports = false.obs;

  Future<void> login(String username, String password) async {
    isLoading.value = true; // Set loading to true when function called
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      //print('${APIUrls.login}$username&password=$password');
      final response = await http
          .get(Uri.parse('${APIUrls.login}$username&password=$password'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          userId.value = responseData['id'];
          prefs.setString('name', responseData['name'].toString());
          prefs.setString(
              'card Management', responseData['card_management'].toString());
          prefs.setString(
              'quick_order', responseData['quick_order'].toString());
          prefs.setString(
              'card table_order', responseData['table_order'].toString());
          prefs.setString('reports', responseData['reports'].toString());
          prefs.setString('userId', responseData['id'].toString());
          prefs.setString(
              'print_line1', responseData['print_line1'].toString());
          prefs.setString(
              'print_line2', responseData['print_line2'].toString());
          prefs.setString(
              'print_line3', responseData['print_line3'].toString());
          prefs.setString(
              'print_line4', responseData['print_line4'].toString());
          prefs.setString(
              'print_line5', responseData['print_line5'].toString());
          prefs.setString(
              'print_line6', responseData['print_line6'].toString());
          prefs.setString(
              'print_line7', responseData['print_line7'].toString());
          prefs.setString(
              'print_line8', responseData['print_line8'].toString());
          prefs.setString(
              'print_line9', responseData['print_line9'].toString());
          prefs.setString(
              'print_line10', responseData['print_line10'].toString());
          prefs.setString('footer_msg', responseData['footer_msg'].toString());
          prefs.setString(
              'currency_symbol', responseData['currency_symbol'].toString());
          // Navigate to the dashboard
          if (responseData['card_management']) {
            Get.offAllNamed(Routes.CARDHOME);
          } else if (responseData['quick_order']) {
            Get.offAllNamed(Routes.QUICKORDER);
          } else if (responseData['table_order']) {
            Get.offAllNamed(Routes.TABLEHOME);
          } else {
            Get.offAllNamed(Routes.REPORTHOME);
          }
        } else {
          Get.snackbar('Error', responseData['message']);
        }
      } else {
        Get.snackbar('Error', 'Failed to connect to the server');
      }
    } catch (e) {
      // Handle any exceptions
      Get.snackbar('Error', '$e');
    } finally {
      isLoading.value = false; // Set loading to false finally
    }
  }

  Future<void> removeNameAndUserIdFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
    await prefs.remove('userId');
  }

  String getUserId() {
    return userId.value;
  }

  Future<String?> getNameFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  Future<String?> showData(String data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(data);
  }
}
