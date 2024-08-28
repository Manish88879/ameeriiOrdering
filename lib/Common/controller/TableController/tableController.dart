import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mosambee_aar/flutter_mosambee_aar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ameerii/Common/controller/OrderController/orderController.dart';
import 'package:ameerii/Routes/app_pages.dart';

import '../../APIUrls.dart';

class TableController extends GetxController {
  final CartController cartController = Get.put(CartController());
  var tables = [].obs;
  RxBool isLoading = true.obs;
  RxBool isDisPerLoading = false.obs;
  RxBool isServiceLoading = false.obs;
  RxInt splitNumber = 1.obs;
  RxString cname = ''.obs;
  RxString cphone = ''.obs;
  RxString caddress = ''.obs;
  RxDouble tenderamount = 0.0.obs;
  RxDouble remainingAmount = 0.0.obs;
  var cashAmount = TextEditingController();

  late String? userId;

  RxBool isCouponApplied = false.obs;
  RxBool isServiceApplied = false.obs;
  RxBool isDiscoPerApplied = false.obs;

  RxDouble subtotal = 0.0.obs;
  RxDouble totalTaxes = 0.0.obs;
  RxDouble totalAmount = 0.0.obs;
  RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  RxDouble serviceCharge = 0.0.obs;
  RxDouble totalTaxesLive = 0.0.obs;
  RxDouble afterDiscountAmount = 0.0.obs;
  RxDouble discount = 0.0.obs;
  RxBool shouldcoupon = false.obs;
  RxString referenceId = ''.obs;
  var change = 0.0.obs;
  String uniqueId = "NA";
  RxString selectedCardType = 'Visa'.obs;

  @override
  void onInit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? counter = prefs.getString('userId');
    cashAmount.addListener(() {
      if (cashAmount.text.isNotEmpty) {
        try {
          change.value =
              double.parse(cashAmount.text) - remainingAmount.value > 0
                  ? double.parse(cashAmount.text) - remainingAmount.value
                  : 0;
        } catch (e) {
          change.value = 0.0; // Handle error if input is invalid
        }
      } else {
        change.value = 0.0;
      }
    });

    userId = counter;
    super.onInit();
    fetchTables();
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
    if (Platform.isAndroid) {
      var deviceInfo = DeviceInfoPlugin();
      var androidInfo = await deviceInfo.androidInfo;
      uniqueId = androidInfo.id!;
    } else if (Platform.isIOS) {
      var deviceInfo = DeviceInfoPlugin();
      var iosInfo = await deviceInfo.iosInfo;
      uniqueId = iosInfo.identifierForVendor!!;
    } else {
      uniqueId = "NA";
    }
  }

  Future<void> fetchTables() async {
    final response = await http.get(Uri.parse('${APIUrls.table_list}$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        // print('Table Data ---- $data');
        tables.value = data['tables'];
      } else {
        print('Failed to fetch tables: ${data['message']}');
      }
    } else {
      print('Failed to fetch tables: ${response.statusCode}');
    }
    isLoading.value = false;
  }

  Future<int> getPlacedOrder(String reference_id) async {
    String url = '${APIUrls.reprint_data}$userId&reference_id=$reference_id';
    Uri uri = Uri.parse(url);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        // print('Orders -- ${data}');
        // print('Discount Aount --- ${data['transactions']}');
        products.value = List<Map<String, dynamic>>.from(data['orders']);
        remainingAmount.value = double.parse(data['remaining_amount']);

        if (data['transactions'] != null && data['transactions'].isNotEmpty) {
          afterDiscountAmount.value =
              double.parse(data['transactions'][0]['amount']);
          discount.value = double.parse(data['transactions'][0]['discount']);

          serviceCharge.value =
              double.parse(data['transactions'][0]['servicecharge']);
          totalTaxes.value = double.parse(data['transactions'][0]['total_tax']);
          totalTaxesLive.value =
              double.parse(data['transactions'][0]['total_tax']);
        } else {
          afterDiscountAmount.value = 0.0;
          print('No transactiom Data '); // Or any default value
        }
        // afterDiscountAmount.value = data['transactions']['amount'];
        calculateSubtotalAndTotalTaxes();
        return 1;
      } else {
        products.value = [];
        print('Failed to fetch products: ${data['message']}');
        return 0;
      }
    } else {
      print('Failed to fetch products: ${response.statusCode}');
      return 0;
    }
  }

  void calculateSubtotalAndTotalTaxes() {
    double newSubtotal = 0.0;
    double newTotalTaxes = 0.0;

    for (var item in products) {
      double price = double.parse(item['price']);
      int qty = int.parse(
          item['quantity'].toString()); // Ensuring qty is parsed correctly
      double taxPercentage = 0.0;

      double itemTotalTaxes = 0.0;
      newTotalTaxes = newTotalTaxes + double.parse(item['total_tax']);

      double itemTotal = price * qty;
      newSubtotal = newSubtotal + itemTotal;

      newTotalTaxes = newTotalTaxes + itemTotalTaxes;
    }

    // Update the reactive variables
    subtotal.value = newSubtotal;
    totalTaxes.value = newTotalTaxes;
    totalAmount.value = newSubtotal + newTotalTaxes;
  }

  Future<void> PartialPaymentSave(String type, String typeValue,
      String reference_id, String remarks, String partialamount) async {
    isLoading.value = true;
    try {
      final String url = '${APIUrls.orderpaymentsave_table}$userId';

      final Map<String, dynamic> data = {
        "reference_id": reference_id,
        "device_id": uniqueId,
        "remarks": remarks,
        "payment": [
          {
            "type": type,
            "type_value": typeValue,
            "amount": double.parse(partialamount)
          }
        ]
      };

      final String dataString = json.encode(data);
      final response = await http.get(Uri.parse('$url&data=$dataString'));

      final responseData = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData['status']) {
          if (responseData['full_payment']) {
            printPayment(reference_id);
            Get.offAllNamed(Routes.TABLEHOME);
          }
          Get.snackbar('Message', 'Purchase Done!',
              backgroundColor: Colors.green, colorText: Colors.white);
          getPlacedOrder(reference_id);
        } else {
          Get.snackbar('Table Error', responseData['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        // print('Response data: ${response.body}');
        isLoading.value = false;
      } else {
        print('Request failed with status: ${response.statusCode}');
        isLoading.value = false;
      }
    } catch (e) {
      Get.snackbar('Table Error', '$e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> orderpaymentsave(String type, String typeValue,
      String reference_id, String remarks) async {
    isLoading.value = true;
    try {
      final String url = '${APIUrls.orderpaymentsave_table}$userId';

      final Map<String, dynamic> data = {
        "reference_id": cartController.referenceId.value,
        "device_id": uniqueId,
        "remarks": remarks,
        "payment": [
          {
            "type": type,
            "type_value": typeValue,
            "amount": remainingAmount.value,
            "remarks": remarks
          }
        ]
      };

      final String dataString = json.encode(data);
      final response = await http.get(Uri.parse('$url&data=$dataString'));

      final responseData = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData['status']) {
          if (responseData['full_payment']) {
            printPayment(reference_id);
            Get.offAllNamed(Routes.TABLEHOME);
          }
          getPlacedOrder(reference_id);
          Get.snackbar('Message', 'Purchase Done!',
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar('Table Error', responseData['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        // print('Response data: ${response.body}');
        isLoading.value = false;
      } else {
        print('Request failed with status: ${response.statusCode}');
        isLoading.value = false;
      }
    } catch (e) {
      Get.snackbar('Table Error', '$e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void increaseQty(String order_id, String reference_id) async {
    isLoading.value = true;
    try {
      String url = '${APIUrls.quantity_increase}$userId&order_id=$order_id';
      Uri uri = Uri.parse(url);
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          getPlacedOrder(reference_id);
          calculateSubtotalAndTotalTaxes();
        } else {
          products.value = [];
          print('Failed to fetch products: ${data['message']}');
        }
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Message', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void decreaseQty(String order_id, String reference_id) async {
    isLoading.value = true;
    try {
      String url = '${APIUrls.quantity_decrease}$userId&order_id=$order_id';
      Uri uri = Uri.parse(url);
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          getPlacedOrder(reference_id);
        } else {
          products.value = [];
          print('Failed to fetch products: ${data['message']}');
        }
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Message', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void deleteItem(String order_id, String reference_id) async {
    isLoading.value = true;
    try {
      String url = '${APIUrls.remove_item}$userId&order_id=$order_id';

      Uri uri = Uri.parse(url);
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          getPlacedOrder(reference_id);
        } else {
          products.value = [];
          print('Failed to fetch products: ${data['message']}');
        }
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Message', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void swap_table(String from_reference_id, to_reference_id) async {
    isLoading.value = true;
    try {
      String url =
          '${APIUrls.swap_table}$userId&from_reference_id=$from_reference_id&to_reference_id=$to_reference_id';

      Uri uri = Uri.parse(url);
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        fetchTables();
        Get.offAllNamed(Routes.TABLEHOME);
      } else {
        print('not 200 ');
      }
      isLoading.value = false;
    } catch (ee) {
      isLoading.value = false;
    }
  }

  void billTable(String reference_id, table_number) async {
    isLoading.value = true;
    try {
      String url =
          '${APIUrls.bill_table}$userId&reference_id=$reference_id&table_number=$table_number&device_id=$uniqueId&name=${cname.value}&phone=${cphone.value}&address=${caddress.value}';
      Uri uri = Uri.parse(url);
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          isCouponApplied.value = false;
          getPlacedOrder(reference_id);
          Get.toNamed(Routes.COUPONPAGE, arguments: {
            'table_number': table_number,
            'reference_id': reference_id
          });
          // printBill(reference_id, table_number);
          // Get.offAllNamed(Routes.TABLEHOME);
          fetchTables();
        } else {
          //print('not 200 ');
        }
      }
      isLoading.value = false;
    } catch (ee) {
      isLoading.value = false;
    }
  }

  void unbill(String reference_id) async {
    String url = '${APIUrls.table_unbill}$userId&reference_id=$reference_id';
    Uri uri = Uri.parse(url);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      fetchTables();
      Get.offAllNamed(Routes.TABLEHOME);
    } else {
      print('not 200 ');
    }
  }

  void clearTable(String reference_id) async {
    String url = '${APIUrls.table_clear}$userId&reference_id=$reference_id';

    Uri uri = Uri.parse(url);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      fetchTables();
      Get.offAllNamed(Routes.TABLEHOME);
      // print('Swap Response body --- ${response.body}');
    } else {
      print('not 200 ');
    }
  }

  void updateServiceCharge(String reference_id, int isServiceCharge) async {
    String url =
        '${APIUrls.table_billupdate_servicecharge}$userId&reference_id=$reference_id&service_charge=$isServiceCharge';
    try {
      isServiceLoading.value = true;
      Uri uri = Uri.parse(url);
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          getPlacedOrder(reference_id);
          if (isServiceCharge == 0) {
            isServiceApplied.value = false;
          } else {
            isServiceApplied.value = true;
            Get.snackbar(
              'Messsage',
              'Service Charge applied!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: Duration(milliseconds: 1000),
            );
          }
        } else {
          Get.snackbar('Message', data['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        print('not 200 ');
      }
    } catch (e) {
      Get.snackbar('Message', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isServiceLoading.value = false;
    }
  }

  void applyDiscount(String reference_id, String discount) async {
    if (isCouponApplied.value) removeCoupon(reference_id);
    try {
      isDisPerLoading.value = true;
      String url =
          '${APIUrls.table_billupdate_discount}$userId&reference_id=$reference_id&discount=$discount';
      Uri uri = Uri.parse(url);
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          getPlacedOrder(reference_id);

          if (discount == '0') {
            isDiscoPerApplied.value = false;
          } else {
            isDiscoPerApplied.value = true;
            Get.snackbar(
              'Messsage',
              'Congratulations!🎉 . Discount Applied',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: Duration(milliseconds: 900),
            );
          }
        } else {
          Get.snackbar('Message', data['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        print('not 200 ');
      }
    } catch (e) {
      Get.snackbar('Message', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isDisPerLoading.value = false;
    }
  }

  void applyCoupon(String reference_id, String couponCode) async {
    if (isDiscoPerApplied.value) applyDiscount(reference_id, '0');
    try {
      isLoading.value = true;
      String url =
          '${APIUrls.table_billupdate_coupon}$userId&reference_id=$reference_id&coupon=$couponCode';
      Uri uri = Uri.parse(url);
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          getPlacedOrder(reference_id);
          isCouponApplied.value = true;
          Get.snackbar(
            'Messsage',
            'Congratulations!🎉 . Discount Applied',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(milliseconds: 900),
          );
        } else {
          Get.snackbar(
            'Message',
            data['message'],
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(milliseconds: 900),
          );
        }
      } else {
        print('not 200 ');
      }
    } catch (e) {
      Get.snackbar('Message', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void removeCoupon(String reference_id) async {
    String url =
        '${APIUrls.table_bill_coupon_removed}$userId&reference_id=$reference_id';
    Uri uri = Uri.parse(url);
    http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        getPlacedOrder(reference_id);
        isCouponApplied.value = false;
      } else {
        Get.snackbar('Message', data['message'],
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      print('not 200 ');
    }
  }

  Future<void> useStoreCardtable(
      String reference_id, String cardNum, String amount, String pin) async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(
          "${APIUrls.payment_storecard_table}$userId&cardno=$cardNum&amount=$amount&otp=$pin&mode=withdraw&reference_id=$reference_id&device_id=$uniqueId"));
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData['status']) {
          if (responseData['full_payment']) {
            printPayment(reference_id);
            Get.offAllNamed(Routes.TABLEHOME);
          }
          getPlacedOrder(reference_id);
          Get.snackbar('Message', 'Purchase Done!',
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar('Table Error', responseData['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        // print('Response data: ${response.body}');
        isLoading.value = false;
      } else {
        print('Request failed with status: ${response.statusCode}');
        isLoading.value = false;
      }
    } catch (error) {
      isLoading.value = false;
      Get.snackbar('Table Error', '$error',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> printBill(String txnid, String table_number) async {
    isLoading.value = true;
    try {
      final response = await http
          .get(Uri.parse('${APIUrls.reprint_data}$userId&reference_id=$txnid'));
      final responseData = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData['status']) {
          var textsizesmall = 25;
          var textsizemedium = 35;
          var tableNumber = "";
          var billno = "";
          var billdate = "";
          var userName = responseData['cashier_name'];
          var paymode = "";
          var tokennumber = "";
          var subtotal = "";
          var totaltax = "";
          var grossamount = "";
          var discount = "";
          var discountpercentage = "";
          var servicecharge = "";
          var delivery_charge = "";
          var packing_charge = "";

          for (var transaction in responseData['transactions']) {
            tableNumber = transaction["table_number"];
            billno = transaction["orderno"];
            billdate = transaction["created"];
            tokennumber = transaction["tokenno"];
            subtotal = transaction["price"];
            totaltax = transaction["total_tax"];
            grossamount = transaction["amount"];
            discount = transaction["discount"];
            servicecharge = transaction["servicecharge"];
            delivery_charge = transaction["delivery_charge"];
            packing_charge = transaction["packing_charge"];
            discountpercentage = transaction["discount_percentage"];
          }

          for (var payment in responseData['payments']) {
            paymode =
                "${payment["type_value"]}(${payment["amount"]}), $paymode";
          }

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
          String str2 = "[ Tax Invoice ]";
          FlutterMosambeeAar.setLineSpace(10);
          FlutterMosambeeAar.printText3(
              str2, FlutterMosambeeAar.PRINTLINE_CENTER, textsizemedium);
          FlutterMosambeeAar.setLineSpace(5);
          FlutterMosambeeAar.printList(
              "Printed On", "", printedOn, textsizesmall, false);
          FlutterMosambeeAar.printList(
              "Bill No.", "", billno, textsizesmall, false);
          FlutterMosambeeAar.printList(
              "Bill Date", "", billdate, textsizesmall, false);
          FlutterMosambeeAar.printList(
              "User", "", userName, textsizesmall, false);
          FlutterMosambeeAar.printList(
              "Table Number", "", tableNumber, textsizesmall, false);
          //FlutterMosambeeAar.printList("Pay Mode", "", paymode, textsizesmall, false);
          FlutterMosambeeAar.printText1(
              "------------------------------------------------------");
          FlutterMosambeeAar.printList(
              "", "Order# $tokennumber", "", textsizesmall, true);
          FlutterMosambeeAar.printText1(
              "------------------------------------------------------");
          FlutterMosambeeAar.printList(
              "Qty. Product", "", "Amount", textsizesmall, false);
          FlutterMosambeeAar.printText1(
              "------------------------------------------------------");
          for (var order in responseData['orders']) {
            String productname = order["product_name"];
            String printProductname = "";

            if (productname.length < 20) {
              String itemname = productname.padRight(20);
              printProductname = itemname.substring(0, 20);
            } else {
              printProductname = productname;
            }

            //log("  //  "+printProductname);
            List<String> parts = getParts(printProductname, 20);
            for (int j = 0; j < parts.length; j++) {
              if (j == 0) {
                FlutterMosambeeAar.printList(
                    " ${order["quantity"]} ${parts[j]}",
                    "",
                    "${prefs.getString('currency_symbol')!}${order["total_price"]}",
                    textsizesmall,
                    false);
              } else {
                FlutterMosambeeAar.printList(
                    "     ${parts[j]}", "", "", textsizesmall, false);
              }
            }
          }
          FlutterMosambeeAar.printText1(
              "------------------------------------------------------");
          FlutterMosambeeAar.printList(
              "Subtotal",
              "",
              "${prefs.getString('currency_symbol')!}$subtotal    ",
              textsizesmall,
              false);
          if (double.parse(discount) > 0) {
            FlutterMosambeeAar.printList(
                "Discount($discountpercentage %)",
                "",
                "${prefs.getString('currency_symbol')!}$discount    ",
                textsizesmall,
                false);
          }
          if (double.parse(servicecharge) > 0) {
            FlutterMosambeeAar.printList(
                "Service Charge",
                "",
                "${prefs.getString('currency_symbol')!}$servicecharge    ",
                textsizesmall,
                false);
          }
          if (double.parse(delivery_charge) > 0) {
            FlutterMosambeeAar.printList(
                "Delivery Charge",
                "",
                "${prefs.getString('currency_symbol')!}$delivery_charge    ",
                textsizesmall,
                false);
          }
          if (double.parse(packing_charge) > 0) {
            FlutterMosambeeAar.printList(
                "Packaging Charge",
                "",
                "${prefs.getString('currency_symbol')!}$packing_charge    ",
                textsizesmall,
                false);
          }

          for (var taxes in responseData['taxes']) {
            FlutterMosambeeAar.printList(
                "${taxes["tax_name"]}(${taxes["tax_percentage"]}%)",
                "",
                "${prefs.getString('currency_symbol')!}${taxes["tax_value"]}    ",
                textsizesmall,
                false);
          }

          FlutterMosambeeAar.printList(
              "Gross Amount",
              "",
              "${prefs.getString('currency_symbol')!}$grossamount    ",
              textsizesmall,
              true);
          FlutterMosambeeAar.printText1(
              "------------------------------------------------------");
          FlutterMosambeeAar.printList(
              "", prefs.getString('footer_msg')!, "", textsizesmall, true);
          FlutterMosambeeAar.printText1(
              "------------------------------------------------------");
          FlutterMosambeeAar.printText3(
              "", FlutterMosambeeAar.PRINTLINE_LEFT, 100);

          if (state != null && state == 4) {
            FlutterMosambeeAar.closePrinter();
            return;
          }
          FlutterMosambeeAar.beginPrint();
        } else {
          Get.snackbar('Print Error', responseData['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        isLoading.value = false;
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', '$e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> printPayment(String txnid) async {
    isLoading.value = true;
    try {
      final response = await http
          .get(Uri.parse('${APIUrls.reprint_data}$userId&reference_id=$txnid'));
      final responseData = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData['status']) {
          var textsizesmall = 25;
          var textsizemedium = 35;
          var tableNumber = "";
          var billno = "";
          var billdate = "";
          var userName = responseData['cashier_name'];
          var paymode = "";
          var tokennumber = "";
          var subtotal = "";
          var totaltax = "";
          var grossamount = "";
          var discount = "";
          var servicecharge = "";
          var delivery_charge = "";
          var packing_charge = "";

          for (var transaction in responseData['transactions']) {
            tableNumber = transaction["table_number"];
            billno = transaction["orderno"];
            billdate = transaction["created"];
            tokennumber = transaction["tokenno"];
            subtotal = transaction["price"];
            totaltax = transaction["total_tax"];
            grossamount = transaction["amount"];
            discount = transaction["discount"];
            servicecharge = transaction["servicecharge"];
            delivery_charge = transaction["delivery_charge"];
            packing_charge = transaction["packing_charge"];
          }

          for (var payment in responseData['payments']) {
            paymode = "${payment["type_value"]}(${payment["amount"]}),$paymode";
          }

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
          // FlutterMosambeeAar.printText3(prefs.getString('print_line3')!,
          //     FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
          // FlutterMosambeeAar.printText3(prefs.getString('print_line4')!,
          //     FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
          // FlutterMosambeeAar.printText3(prefs.getString('print_line5')!,
          //     FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
          // FlutterMosambeeAar.printText3(prefs.getString('print_line6')!,
          //     FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
          // FlutterMosambeeAar.printText3(prefs.getString('print_line7')!,
          //     FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
          // FlutterMosambeeAar.printText3(prefs.getString('print_line8')!,
          //     FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
          // FlutterMosambeeAar.printText3(prefs.getString('print_line9')!,
          //     FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
          // FlutterMosambeeAar.printText3(prefs.getString('print_line10')!,
          //     FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
          FlutterMosambeeAar.printText3(
              "", FlutterMosambeeAar.PRINTLINE_LEFT, textsizemedium);
          FlutterMosambeeAar.setLineSpace(10);
          String str2 = "[ Payment Slip ]";
          FlutterMosambeeAar.setLineSpace(10);
          FlutterMosambeeAar.printText3(
              str2, FlutterMosambeeAar.PRINTLINE_CENTER, textsizemedium);
          FlutterMosambeeAar.setLineSpace(5);
          FlutterMosambeeAar.printList(
              "Printed On", "", printedOn, textsizesmall, false);
          FlutterMosambeeAar.printList(
              "Bill No.", "", billno, textsizesmall, false);
          FlutterMosambeeAar.printList(
              "Bill Date", "", billdate, textsizesmall, false);
          FlutterMosambeeAar.printList(
              "User", "", userName, textsizesmall, false);
          FlutterMosambeeAar.printList(
              "Table Number", "", tableNumber, textsizesmall, false);
          //FlutterMosambeeAar.printList("Pay Mode", "", paymode, textsizesmall, false);
          FlutterMosambeeAar.printText1(
              "------------------------------------------------------");
          FlutterMosambeeAar.printList("", paymode, "", textsizesmall, true);
          FlutterMosambeeAar.printText1(
              "------------------------------------------------------");
          FlutterMosambeeAar.printText3(
              "", FlutterMosambeeAar.PRINTLINE_LEFT, 100);

          if (state != null && state == 4) {
            FlutterMosambeeAar.closePrinter();
            return;
          }
          FlutterMosambeeAar.beginPrint();
        } else {
          Get.snackbar('Print Error', responseData['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        isLoading.value = false;
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', '$e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  //**************** SPLIT STRING TO PARTS ************

  List<String> getParts(String stringValue, int partitionSize) {
    List<String> parts = [];
    int len = stringValue.length;
    int i = 0;

    while (i < len) {
      if (i + partitionSize > len) {
        stringValue = stringValue.padRight(len + (i + partitionSize - len));
      }
      parts.add(stringValue.substring(i, i + partitionSize));
      i += partitionSize;
    }

    return parts;
  }
}
