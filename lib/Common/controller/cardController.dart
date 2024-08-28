import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mosambee_aar/flutter_mosambee_aar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ameerii/Common/APIUrls.dart';
import 'package:ameerii/Common/controller/OrderController/orderController.dart';
import 'package:ameerii/Routes/app_pages.dart';

import 'TableController/tableController.dart';

class SwipeCardController extends GetxController {
  RxString option1 = ''.obs;
  RxString option2 = ''.obs;
  RxString option3 = ''.obs;
  RxString option4 = ''.obs;
  final CartController cartController = Get.put(CartController());
  final TableController tableController = Get.put(TableController());
  var validity_options = <Map<String, String>>[].obs;
  var selected_validityOption = ''.obs;
  var payment_Options = <Map<String, String>>[].obs;
  var selected_paymentOptions = 'Cash'.obs;
  RxBool isLoading = false.obs;
  late String? userId;
  late String? balance;
  late String? name;
  RxString amount = '0'.obs;
  String screenNumber = "1";
  RxBool isPinsetup = false.obs;
  var subcardpayment_Options = <Map<String, String>>[].obs;
  var selected_subcardpaymentOptions = ''.obs;

  @override
  void onInit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? counter = prefs.getString('userId');
    userId = counter;
    super.onInit();
    //fetchValidityOptions();
    //fetchPaymentMethod();
  }

  Future<void> homepageDetail() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userid = prefs.getString('userId');
      final response =
          await http.get(Uri.parse("${APIUrls.dasboarddata}$userid"));
      final data = json.decode(response.body);
      if (data != null && data["status"]) {
        option1.value = data['card_issued'];
        option2.value = data['total_txn'];
        option3.value = data['amount_collected'];
        option4.value = data['amount_deducted'];
      } else {
        // Get.dialog(
        //   AlertDialog(
        //     title: const Text("Alertt!"),
        //     content: Text(data["message"]),
        //     actions: <Widget>[
        //       TextButton(
        //         onPressed: () {
        //           Get.back();
        //         },
        //         child: const Text("OK"),
        //       ),
        //     ],
        //   ),
        // );
      }
    } catch (error) {
      print('Error -- ${error}');
    }
  }

  void fetchValidityOptions() async {
    try {
      isLoading.value = true;
      final response =
          await http.get(Uri.parse('${APIUrls.card_validity_options}$userId'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == true) {
          validity_options.value = (data['data'] as List).map((item) {
            return {
              'name': item['name'].toString(),
              'value': item['value'].toString(),
            };
          }).toList();
        }
      } else {
        Get.snackbar('Error!', 'Validity Options issue');
      }
    } catch (e) {
      //Get.snackbar('Error', 'An error occurred');
    } finally {
      isLoading.value = false; // Set loading to false finally
    }
  }

  void fetchPaymentMethod() async {
    payment_Options.value.clear();
    payment_Options.value.addAll([
      {'name': 'Cash'},
      {'name': 'Card'},
      {'name': 'UPI'},
      {'name': 'Other'},
    ]);
    selected_paymentOptions.value = "Cash";

    subcardpayment_Options.value.clear();
    subcardpayment_Options.value.addAll([
      {'name': 'Visa'},
      {'name': 'MasterCard'},
      {'name': 'RuPay'},
      {'name': 'Maestro'},
    ]);
    selected_subcardpaymentOptions.value = "";

    // try{
    //   isLoading.value = true;
    //   final response = await http
    //       .get(Uri.parse('${APIUrls.card_payment_options}$userId'));
    //
    //   if (response.statusCode == 200) {
    //     var data = json.decode(response.body);
    //     if (data['status'] == true) {
    //       payment_Options.value = (data['data'] as List).map((item) {
    //         return {
    //           'name': item['name'].toString(),
    //         };
    //       }).toList();
    //     }
    //   } else {
    //     Get.snackbar('Error!', 'Payment method fetch issue');
    //   }
    // }catch (e) {
    //   //Get.snackbar('Error', 'An error occurred');
    // } finally {
    //   isLoading.value = false; // Set loading to false finally
    // }
  }

  Future<void> cardStatus(String cardnumber, String parent) async {
    isLoading.value = true;
    try {
      final response = await http.get(
          Uri.parse('${APIUrls.cardstatuscheck}$userId&cardno=$cardnumber'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          if (responseData['statusvalue'] == '2') {
            balance = responseData['cardbalance'];
            name = responseData['customername'];
            if (parent == '0')
              Get.toNamed(Routes.CARDDETAIL,
                  arguments: {'cardNumber': cardnumber});
          } else if (responseData['statusvalue'] == '1') {
            if (parent == '0') {
              Get.toNamed(Routes.ADDCARD,
                  arguments: {'cardNumber': cardnumber});
            }
          } else {
            Get.dialog(
              AlertDialog(
                title: const Text("Alert!"),
                content: Text(responseData["message"]),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Get.back(); // Close the dialog
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
        } else {
          // Handle error if login is not successful
          // Get.snackbar('Error', responseData['message'],
          //     backgroundColor: Colors.red, colorText: Colors.white);
          if (parent == '0')
            Get.toNamed(Routes.ADDCARD, arguments: {'cardNumber': cardnumber});
        }
      } else {
        // Handle other HTTP status codes
        Get.snackbar('Error', 'Failed to connect to the server');
      }
    } catch (e) {
      // Handle any exceptions
      Get.snackbar(
          'Error', 'Connection error. Please check your internet connection.');
    } finally {
      isLoading.value = false; // Set loading to false finally
    }
  }

  Future<void> addMoney(String cardNum, String amount, String payOption) async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(
          "${APIUrls.cardaddbalance}$userId&cardno=$cardNum&amount=$amount&otp=${""}&mode=$payOption"));
      final data = json.decode(response.body);
      if (data != null && data["status"]) {
        addmoneyPrint(cardNum!, amount, payOption);
        Get.offNamed(Routes.CARDHOME);
      } else {
        Get.dialog(
          AlertDialog(
            title: const Text("Alert!"),
            content: Text(data["message"]),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
      isLoading.value = false;
    } catch (error) {
      isLoading.value = false;
      Get.dialog(
        AlertDialog(
          title: const Text("Error!"),
          content:
              Text("Connection error. Please check your internet connection."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> createCard(String cardNum, String name, String mobile,
      String email, BuildContext context) async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(
          "${APIUrls.cardcreate}$userId&cardno=$cardNum&name=$name&mobile=$mobile&email=$email"));
      final data = json.decode(response.body);
      if (data != null && data["status"]) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Alert!"),
              content: Text(data["message"]),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.offNamed(Routes.ADDMONEY,
                        arguments: {'cardNumber': cardNum});
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Alert!"),
              content: Text(data["message"]),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // startTimer();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
      isLoading.value = false;
    } catch (error) {
      isLoading.value = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error!"),
            content: Text(
                "Connection error. Please check your internet connection."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<DateTime?> selectCustomDate(
      BuildContext context, String selectedOption) async {
    DateTime _selectedDate = DateTime.now().add(const Duration(days: 20 * 365));
    DateTime initialDate = DateTime.now();
    if (selectedOption == 'Unlimited') {
      _selectedDate = DateTime.now().add(const Duration(days: 20 * 365));
    } else {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2022),
        lastDate: DateTime(2030),
      );

      if (picked != null) {
        _selectedDate = picked;
        selectedOption = 'Custom';
      }
    }
    return _selectedDate;
  }

  Future<void> transferCard(String cardNum, String newCard) async {
    try {
      final response = await http.get(Uri.parse(
          "${APIUrls.cardtransfer}$userId&cardno=$cardNum&otp=${''}&newcardno=$newCard"));
      final data = json.decode(response.body);
      if (data != null && data["status"]) {
        transfercardPrint(cardNum!, newCard);
        Get.offNamed(Routes.CARDHOME);
      } else {
        Get.dialog(
          AlertDialog(
            title: const Text("Alert!"),
            content: Text(data["message"]),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      Get.dialog(
        AlertDialog(
          title: const Text("Error!"),
          content:
              Text("Connection error. Please check your internet connection."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  //***************** PRINT CODE ***********

  addmoneyPrint(String cardNum, String amount, String payOption) async {
    var textsizesmall = 25;
    var textsizemedium = 35;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String printedOn = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    FlutterMosambeeAar.initialise(
        APIUrls.mosambeeusername, APIUrls.mosambeepassword);
    FlutterMosambeeAar.setInternalUi(false);
    FlutterMosambeeAar.openPrinter();
    int? state = await FlutterMosambeeAar.getPrinterState();
    // if (kDebugMode) {
    //   print('state: $state');
    // }
    FlutterMosambeeAar.setPrintGray(2000);
    ByteData bytes = await rootBundle.load('images/logo.png');
    var buffer = bytes.buffer;
    var base64Image = base64.encode(Uint8List.view(buffer));

    // if (kDebugMode) {
    //   print("img_pan : $base64Image");
    // }

    FlutterMosambeeAar.printImage(
        base64Image, FlutterMosambeeAar.PRINTLINE_CENTER);
    FlutterMosambeeAar.printText3(prefs.getString('print_line1')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line2')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line3')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line4')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line5')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line6')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line7')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line8')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line9')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line10')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(
        "", FlutterMosambeeAar.PRINTLINE_LEFT, textsizemedium);
    FlutterMosambeeAar.setLineSpace(10);
    FlutterMosambeeAar.printText3("[Add Money Slip]",
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizemedium);
    FlutterMosambeeAar.setLineSpace(10);

    FlutterMosambeeAar.printList(
        "Printed On", "", printedOn, textsizesmall, false);
    FlutterMosambeeAar.printList(
        "CardNumber", "", cardNum, textsizesmall, false);
    FlutterMosambeeAar.printList(
        "Amount Added", "", amount, textsizesmall, false);
    FlutterMosambeeAar.printList(
        "Payment Mode", "", payOption, textsizesmall, false);

    FlutterMosambeeAar.printText3(
        "Thank You", FlutterMosambeeAar.PRINTLINE_CENTER, textsizemedium);
    FlutterMosambeeAar.printText3("", FlutterMosambeeAar.PRINTLINE_LEFT, 100);

    if (state != null && state == 4) {
      FlutterMosambeeAar.closePrinter();
      return;
    }
    FlutterMosambeeAar.beginPrint();
  }

  transfercardPrint(String cardNum, String newcardNum) async {
    var textsizesmall = 25;
    var textsizemedium = 35;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String printedOn = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    FlutterMosambeeAar.initialise(
        APIUrls.mosambeeusername, APIUrls.mosambeepassword);
    FlutterMosambeeAar.setInternalUi(false);
    FlutterMosambeeAar.openPrinter();
    int? state = await FlutterMosambeeAar.getPrinterState();
    // if (kDebugMode) {
    //   print('state: $state');
    // }
    FlutterMosambeeAar.setPrintGray(2000);
    ByteData bytes = await rootBundle.load('images/logo.png');
    var buffer = bytes.buffer;
    var base64Image = base64.encode(Uint8List.view(buffer));

    // if (kDebugMode) {
    //   print("img_pan : $base64Image");
    // }

    FlutterMosambeeAar.printImage(
        base64Image, FlutterMosambeeAar.PRINTLINE_CENTER);
    FlutterMosambeeAar.printText3(prefs.getString('print_line1')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line2')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line3')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line4')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line5')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line6')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line7')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line8')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line9')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(prefs.getString('print_line10')!,
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
    FlutterMosambeeAar.printText3(
        "", FlutterMosambeeAar.PRINTLINE_LEFT, textsizemedium);
    FlutterMosambeeAar.setLineSpace(10);
    FlutterMosambeeAar.printText3("[Card Transfer Slip]",
        FlutterMosambeeAar.PRINTLINE_CENTER, textsizemedium);
    FlutterMosambeeAar.setLineSpace(10);

    FlutterMosambeeAar.printList(
        "Printed On", "", printedOn, textsizesmall, false);
    FlutterMosambeeAar.printList("Old CardNumber", "", cardNum, 20, false);
    FlutterMosambeeAar.printList("New CardNumber", "", newcardNum, 20, false);

    FlutterMosambeeAar.printText3(
        "Thank You", FlutterMosambeeAar.PRINTLINE_CENTER, textsizemedium);
    FlutterMosambeeAar.printText3("", FlutterMosambeeAar.PRINTLINE_LEFT, 100);

    if (state != null && state == 4) {
      FlutterMosambeeAar.closePrinter();
      return;
    }
    FlutterMosambeeAar.beginPrint();
  }
}
