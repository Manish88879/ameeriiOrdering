import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mosambee_aar/flutter_mosambee_aar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ameerii/Pages/QuickOrder/checkoutPage.dart';
import 'package:ameerii/Routes/app_pages.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../Pages/QuickOrder/discountPage.dart';
import '../../APIUrls.dart';

class CartController extends GetxController {
  RxList<Map<String, dynamic>> orderAtCart = <Map<String, dynamic>>[].obs;
  RxString SelectedCat = 'All Products'.obs;
  RxList<Map<String, dynamic>> category =
      <Map<String, dynamic>>[].obs; // Making it observable
  RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;

  RxList<Map<String, dynamic>> filteredProducts = <Map<String, dynamic>>[].obs;
  // Search query
  var searchQuery = ''.obs;

  RxString catSubcatId = '2'.obs;
  RxBool isLoading = false.obs;

// Define the reactive variables
  RxDouble subtotal = 0.0.obs;
  RxDouble totalTaxes = 0.0.obs;
  RxDouble totalAmount = 0.0.obs;
  RxString referenceId = '0'.obs;
  RxString cname = ''.obs;
  RxString cphone = ''.obs;
  RxString caddress = ''.obs;
  late String? userId;
  var totalPrice = 0.0.obs;

  RxDouble serviceCharge = 0.0.obs;
  RxDouble totalTaxesLive = 0.0.obs;
  RxDouble afterDiscountAmount = 0.0.obs;
  RxDouble discount = 0.0.obs;
  RxDouble remainingAmount = 0.0.obs;
  var cashAmount = TextEditingController();
  var change = 0.0.obs;
  String uniqueId = "NA";

  RxBool isCouponApplied = false.obs;
  RxBool isDisPerLoading = false.obs;
  RxBool isDiscoPerApplied = false.obs;
  RxString selectedCardType = 'Visa'.obs;

  @override
  void onInit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? counter = prefs.getString('userId');
    userId = counter;
    super.onInit();
    fetchCategories();
    fetchProducts('-1');

    ever(searchQuery, (query) {
      filterProducts(query);
    });

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

  void calculateSubtotalAndTotalTaxes() {
    double newSubtotal = 0.0;
    double newTotalTaxes = 0.0;

    for (var item in orderAtCart) {
      double price = double.parse(item['price']);
      int qty =
          int.parse(item['qty'].toString()); // Ensuring qty is parsed correctly

      double itemTotal = price * qty;
      newSubtotal += itemTotal;

      double itemTotalTaxes = 0.0;
      if (item['taxes'] != null && item['taxes'].isNotEmpty) {
        for (var tax in item['taxes']) {
          double taxPercentage = double.parse(tax['tax_percentage']);
          itemTotalTaxes += (itemTotal * taxPercentage) / 100;
        }
      }

      newTotalTaxes = newTotalTaxes + itemTotalTaxes;
    }

    // Update the reactive variables
    subtotal.value = newSubtotal;
    totalTaxes.value = newTotalTaxes;
    totalAmount.value = newSubtotal + newTotalTaxes;
  }

  String generateReference() {
    // Get the current time in milliseconds since epoch
    int datetimeInMillis = DateTime.now().millisecondsSinceEpoch;

    referenceId.value = '$userId$datetimeInMillis';
    String rId = '$userId$datetimeInMillis';

    // print("Generated Reference ID: $referenceId");

    return rId;
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      filteredProducts.assignAll(products);
    } else {
      filteredProducts.assignAll(products.where((product) {
        return product['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList());
    }
  }

  static CartController get to => Get.find();
  RxInt getOrderItemCount(Map<String, dynamic> product) {
    RxInt count = 0.obs;
    for (var item in orderAtCart) {
      if (item['id'] == product['id']) {
        count = (item['qty'] ?? 0.obs);
      }
    }
    return count;
  }

  void addToCart(Map<String, dynamic> product) {
    String productId = product['id'];
    bool productExists = false;

    for (int i = 0; i < orderAtCart.value.length; i++) {
      if (orderAtCart.value[i]['id'] == productId) {
        if (!(orderAtCart.value[i]['qty'] is RxInt)) {
          orderAtCart.value[i]['qty'] = (orderAtCart.value[i]['qty'] ?? 0).obs;
        }

        orderAtCart.value[i]['qty'].value++;
        productExists = true;
        break;
      }
    }

    if (!productExists) {
      // Create RxInt for qty and initialize it to 1
      product['qty'] = 1.obs;
      orderAtCart.add(product);
    }
    // print('Product added to cart: ${product}');
    updateTotalPrice();
    calculateSubtotalAndTotalTaxes();
  }

  void removeItemFromCart(Map<String, dynamic> product) {
    // print('Removed Clicked ');
    String productId = product['id'];

    // Iterate through the cart items
    for (int i = 0; i < orderAtCart.value.length; i++) {
      // Check if the current item matches the product ID
      if (orderAtCart.value[i]['id'] == productId) {
        // Decrement the quantity using RxInt's value property
        orderAtCart.value[i]['qty'].value--;

        // If the quantity becomes zero, remove the item from the cart
        if (orderAtCart.value[i]['qty'].value == 0) {
          orderAtCart.remove(product);
        }
        calculateSubtotalAndTotalTaxes();
        break; // Exit the loop after processing the item
      }
    }
    updateTotalPrice();
    // print('Product removed from cart: $product');
  }

  void deleteItemFromCart(Map<String, dynamic> product) {
    // print('Delete Clicked');
    String productId = product['id'];

    // Remove all items matching the product ID
    // for (int i = 0; i < orderAtCart.value.length; i++) {
    //   if (orderAtCart.value[i]['qty'].value == 0) ;
    // }
    orderAtCart.remove(product);
    calculateSubtotalAndTotalTaxes();
    // print('Product deleted from cart: $product');
  }

  Future<void> fetchCategories() async {
    final response =
        await http.get(Uri.parse('${APIUrls.category_list}$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        category.value = List<Map<String, dynamic>>.from(data['category']);
        // print('Categories fetched and updated: $category');
      } else {
        print('Failed to fetch categories: ${data['message']}');
      }
    } else {
      print('Failed to fetch categories: ${response.statusCode}');
    }
  }

  Future<void> fetchProducts(String catId) async {
    // print('Fetch Products called -------------- ');
    filteredProducts.value = [];

    String url = '';
    if (catId == '-1') {
      orderAtCart.value = [];
      products.value = [];
      url = '${APIUrls.allproduct_list}$userId';
    } else {
      url = '${APIUrls.product_list}$userId&subcatid=$catId';
    }
    final response = await http.get(Uri.parse(url));
    // print('Response Add Order Api ${response.request}');
    // print('Response --  Product list Api ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        List<Map<String, dynamic>> productList =
            List<Map<String, dynamic>>.from(data['products']);
        products.assignAll(productList);
        filteredProducts
            .assignAll(productList); // Ensure filteredProducts is updated
      } else {
        Get.snackbar('Error', data['message'],
            backgroundColor: Colors.red, colorText: Colors.white);
        products.value = [];
        filteredProducts.value = []; // Ensure filteredProducts is also cleared
        print('Failed to fetch products: ${data['message']}');
      }
    } else {
      print('Failed to fetch products: ${response.statusCode}');
    }
  }

  Future<void> fetchAllProducts(BuildContext context) async {
    try {
      SelectedCat.value = 'All Products';
      // print('Fetch Products called -------------- ');
      filteredProducts.value = [];

      String url = '';

      url = '${APIUrls.allproduct_list}$userId';

      final response = await http.get(Uri.parse(url));
      // print('Response Add Order Api ${response.request}');
      // print('Response --  Product list Api ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          List<Map<String, dynamic>> productList =
              List<Map<String, dynamic>>.from(data['products']);
          products.assignAll(productList);
          filteredProducts
              .assignAll(productList); // Ensure filteredProducts is updated
        } else {
          Get.snackbar('Error', data['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
          products.value = [];
          filteredProducts.value =
              []; // Ensure filteredProducts is also cleared
          print('Failed to fetch products: ${data['message']}');
        }
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error!"),
            content: Text(error.toString()),
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
      // Return an empty list if there's an error
    }
  }

  void updateTotalPrice() {
    double sum = 0.0;
    for (var product in orderAtCart) {
      sum += double.tryParse(product['price'].toString()) ??
          0.0; // Parse price to double
    }
    totalPrice.value = sum;
  }

  Future<void> sendOrderHistory() async {
    isLoading.value = true;
    // print('Reference ID: ${referenceId.value}');
    // if (referenceId.value == '0') {
    await generateReference();
    // }

    try {
      List<Map<String, dynamic>> orderHistoryData = orderAtCart.map((order) {
        double totalTax = 0.0;
        double totalTaxPercentage = 0.0;
        List<Map<String, dynamic>> orderTaxList = [];

        for (var tax in order['taxes']) {
          if (tax['tax_id'] != null &&
              tax['tax_name'] != null &&
              tax['tax_percentage'] != null) {
            double taxValue = (double.parse(order['price'].toString()) *
                    double.parse(order['qty'].toString()) *
                    double.parse(tax['tax_percentage'].toString())) /
                100;
            totalTax += taxValue;
            totalTaxPercentage +=
                double.parse(tax['tax_percentage'].toString());

            orderTaxList.add({
              'id': tax['tax_id'].toString(),
              'tax_name': tax['tax_name'],
              'tax_percentage': tax['tax_percentage'].toString(),
              'tax_value': taxValue.toStringAsFixed(2),
            });
          }
        }

        return {
          'cat_id': order['cat_id'].toString(),
          'cat_name': order['cat_name'],
          'product_id': order['id'].toString(),
          'product_name': order['name'],
          'kds': order['kds'],
          'quantity': int.parse(order['qty'].toString()),
          'price': double.parse(order['price'].toString()),
          'total_tax': totalTax,
          'total_tax_percentage': totalTaxPercentage.toStringAsFixed(2),
          'total_price': double.parse(order['price'].toString()) *
              int.parse(order['qty'].toString()),
          'discount': '0', // Assuming a default value or calculate accordingly
          'remarks': '', // Assuming a default value or input
          'order_tax': orderTaxList,
        };
      }).toList();

      // Create the data to be sent in the request body
      Map<String, dynamic> bodyData = {
        'reference_id': referenceId.value,
        'device_id': uniqueId,
        'name': cname.value,
        'phone': cphone.value,
        'address': caddress.value,
        'orderhistory': orderHistoryData
      };
      // Ensure this matches your endpoint URL
      var request = http.MultipartRequest(
          'POST', Uri.parse("${APIUrls.orderhistorysave}$userId"));
      request.fields.addAll({'data': jsonEncode(bodyData).toString()});

      // print('JSON --- ${jsonEncode(bodyData)}');

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = jsonDecode(responseBody);
        if (data['status'] == true) {
          // print('Response --- $responseBody');
          getPlacedOrder(referenceId.value);
          Get.to(DiscountPage());
        } else {
          Get.snackbar('Error', data['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        // print('Response --- $responseBody');
      } else {
        // print("status Code ${response.statusCode}");
        Get.snackbar('Error', response.statusCode.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', '$e',
          backgroundColor: Colors.red, colorText: Colors.white);
      print('Error ---- $e');
    } finally {
      isLoading.value = false;
    }
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
            printBill(reference_id);
            orderAtCart.value = [];
            referenceId.value = '0';
            //Get.offAllNamed(Routes.QUICKORDER);
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

  Future<void> orderpaymentsave(String type, String typeValue,
      String reference_id, String remarks) async {
    isLoading.value = true;
    try {
      final String url = '${APIUrls.orderpaymentsave}$userId';

      final Map<String, dynamic> data = {
        "reference_id": referenceId.value,
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
            printBill(reference_id);
            orderAtCart.value = [];
            referenceId.value = '0';
            Get.offAllNamed(Routes.QUICKORDER);
          }
          getPlacedOrder(reference_id);
          Get.snackbar('Message', 'Purchase Done!',
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar('C Error', responseData['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        // print('Response data: ${response.body}');
        isLoading.value = false;
      } else {
        print('Request failed with status: ${response.statusCode}');
        isLoading.value = false;
      }
    } catch (e) {
      Get.snackbar('C Error', '$e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> orderHistory_table(
      String tableNumber, String table_reference_number) async {
    isLoading.value = true;
    //print('Reference ID: ${referenceId.value}');
    await generateReference();
    try {
      List<Map<String, dynamic>> orderHistoryData = orderAtCart.map((order) {
        double totalTax = 0.0;
        double totalTaxPercentage = 0.0;
        List<Map<String, dynamic>> orderTaxList = [];

        //print('order    ------------- ${order}');

        for (var tax in order['taxes']) {
          if (tax['tax_id'] != null &&
              tax['tax_name'] != null &&
              tax['tax_percentage'] != null) {
            double taxValue = (double.parse(order['price'].toString()) *
                    double.parse(order['qty'].toString()) *
                    double.parse(tax['tax_percentage'])) /
                100;
            totalTax += taxValue;
            totalTaxPercentage +=
                double.parse(tax['tax_percentage'].toString());

            orderTaxList.add({
              'id': tax['tax_id'].toString(),
              'tax_name': tax['tax_name'],
              'tax_percentage': tax['tax_percentage'].toString(),
              'tax_value': taxValue.toStringAsFixed(2),
            });
          }
        }
        //print('Total Tax ----   ${totalTax}');

        return {
          'cat_id': order['cat_id'].toString(),
          'cat_name': order['cat_name'],
          'product_id': order['id'].toString(),
          'kds': order['kds'].toString(),
          'product_name': order['name'],
          'quantity': int.parse(order['qty'].toString()),
          'price': double.parse(order['price'].toString()),
          'total_tax': totalTax,
          'total_tax_percentage': totalTaxPercentage.toStringAsFixed(2),
          'total_price': double.parse(order['price'].toString()) *
              int.parse(order['qty'].toString()),
          'discount': '0',
          'remarks': '',
          'order_tax': orderTaxList,
        };
      }).toList();

      Map<String, dynamic> bodyData = {
        'table_number': tableNumber,
        'tablereference_id': table_reference_number,
        'device_id': uniqueId,
        'orderhistory': orderHistoryData
      };
      var request = http.MultipartRequest(
          'POST', Uri.parse("${APIUrls.orderhistorysave_table}$userId"));
      request.fields.addAll({'data': jsonEncode(bodyData).toString()});
      //print('JSON --- ${jsonEncode(bodyData)}');
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = jsonDecode(responseBody);
        if (data['status'] == true) {
          orderAtCart.value = [];
          printKOT_table(data['reference_id'], data['group_id']);
          getPlacedOrder(table_reference_number);
          Get.offAllNamed(Routes.TABLEHOME);
        } else {
          Get.snackbar('Error', data['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        //print('Response --- $responseBody');
      } else {
        //print("status Code ${response.statusCode}");
        Get.snackbar('Error', response.statusCode.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', '$e',
          backgroundColor: Colors.red, colorText: Colors.white);
      //print('Error ---- $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> getPlacedOrder(String reference_id) async {
    String url = '${APIUrls.reprint_data}$userId&reference_id=$reference_id';
    Uri uri = Uri.parse(url);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
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

  Future<void> useStoreCard(
      String reference_id, String cardNum, String amount, String pin) async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(
          "${APIUrls.payment_storecard}$userId&cardno=$cardNum&amount=$amount&otp=$pin&mode=withdraw&reference_id=$reference_id&device_id=$uniqueId"));
      final responseData = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData['status']) {
          if (responseData['full_payment']) {
            printBill(reference_id);
            orderAtCart.value = [];
            referenceId.value = '0';
            Get.offAllNamed(Routes.QUICKORDER);
          }
          getPlacedOrder(reference_id);
          Get.snackbar('Message', 'Purchase Done!',
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar('C Error', responseData['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
        // print('Response data: ${response.body}');
        isLoading.value = false;
      } else {
        print('Request failed with status: ${response.statusCode}');
        isLoading.value = false;
      }
    } catch (e) {
      Get.snackbar('C Error', '$e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> printKOT_table(String txnid, String group_id) async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(
          '${APIUrls.reprint_kot_group}$userId&reference_id=$txnid&group_id=$group_id'));
      final responseData = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData['status']) {
          var textsizesmall = 25;
          var textsizemedium = 35;
          var userName = responseData['cashier_name'];
          var tableNumber = "";

          for (var transaction in responseData['transactions']) {
            tableNumber = transaction["table_number"];
          }

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          DateTime now = DateTime.now();
          String printedOn = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

          for (var printer in responseData['printers']) {
            bool isPrint = false;
            String selectedPrinterName = printer['name'];
            String selectedPrinterKDS = printer['kds'];
            String selectedPrinterIP = printer['ip'];

            for (var order in responseData['orders']) {
              tableNumber = order["table_number"];
              if (order['kds'] == selectedPrinterKDS) {
                isPrint = true;
              }
            }

            if (isPrint) {
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
              // FlutterMosambeeAar.printText3(prefs.getString('print_line1')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line2')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line3')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line4')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line5')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line6')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line7')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line8')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line9')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line10')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              FlutterMosambeeAar.printText3(
                  "", FlutterMosambeeAar.PRINTLINE_LEFT, textsizemedium);
              FlutterMosambeeAar.setLineSpace(10);
              String str2 = "[ $selectedPrinterName Slip ]";
              FlutterMosambeeAar.setLineSpace(10);
              FlutterMosambeeAar.printText3(
                  str2, FlutterMosambeeAar.PRINTLINE_CENTER, textsizemedium);
              FlutterMosambeeAar.setLineSpace(5);
              FlutterMosambeeAar.printList(
                  "Printed On", "", printedOn, textsizesmall, false);
              FlutterMosambeeAar.printList(
                  "User", "", userName, textsizesmall, false);
              FlutterMosambeeAar.printList(
                  "Table Number", "", tableNumber, textsizesmall, false);
              FlutterMosambeeAar.printText1(
                  "------------------------------------------------------");
              FlutterMosambeeAar.printList(
                  "Product", "", "Qty.", textsizesmall, false);
              FlutterMosambeeAar.printText1(
                  "------------------------------------------------------");
              for (var order in responseData['orders']) {
                if (selectedPrinterKDS == order['kds']) {
                  String productname = order["product_name"];
                  String printProductname = "";

                  if (productname.length < 30) {
                    String itemname = productname.padRight(30);
                    printProductname = itemname.substring(0, 30);
                  } else {
                    printProductname = productname;
                  }

                  List<String> parts = getParts(printProductname, 30);
                  for (int j = 0; j < parts.length; j++) {
                    if (j == 0) {
                      FlutterMosambeeAar.printList(" ${parts[j]}", "",
                          "${order["quantity"]}", textsizesmall, false);
                    } else {
                      FlutterMosambeeAar.printList(
                          "  ${parts[j]}", "", "", textsizesmall, false);
                    }
                  }
                }
              }
              FlutterMosambeeAar.printText1(
                  "------------------------------------------------------");
              FlutterMosambeeAar.printText3(
                  "", FlutterMosambeeAar.PRINTLINE_LEFT, 100);

              if (state != null && state == 4) {
                FlutterMosambeeAar.closePrinter();
                return;
              }
              FlutterMosambeeAar.beginPrint();
            }
          }
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

  Future<void> printBill(String txnid) async {
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
          //FlutterMosambeeAar.printList("Table Number", "", tableNumber, textsizesmall, false);
          FlutterMosambeeAar.printList(
              "Pay Mode", "", paymode, textsizesmall, false);
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

      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm'),
            content: const Text('Do you want to print KOT?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  printKOT_QuickOrder(txnid);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      Get.offAllNamed(Routes.QUICKORDER);
      Get.snackbar('Error', '$e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> printKOT_QuickOrder(String txnid) async {
    isLoading.value = true;
    try {
      final response = await http
          .get(Uri.parse('${APIUrls.reprint_data}$userId&reference_id=$txnid'));
      final responseData = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseData['status']) {
          var textsizesmall = 25;
          var textsizemedium = 35;
          var userName = responseData['cashier_name'];
          // var tableNumber = "";
          //
          // for (var transaction in responseData['transactions']) {
          //   tableNumber = transaction["table_number"];
          // }

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          DateTime now = DateTime.now();
          String printedOn = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

          for (var printer in responseData['printers']) {
            bool isPrint = false;
            String selectedPrinterName = printer['name'];
            String selectedPrinterKDS = printer['kds'];
            String selectedPrinterIP = printer['ip'];

            for (var order in responseData['orders']) {
              if (order['kds'] == selectedPrinterKDS) {
                isPrint = true;
              }
            }

            if (isPrint) {
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
              // FlutterMosambeeAar.printText3(prefs.getString('print_line1')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line2')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line3')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line4')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line5')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line6')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line7')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line8')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line9')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              // FlutterMosambeeAar.printText3(prefs.getString('print_line10')!, FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
              FlutterMosambeeAar.printText3(
                  "", FlutterMosambeeAar.PRINTLINE_LEFT, textsizemedium);
              FlutterMosambeeAar.setLineSpace(10);
              String str2 = "[ $selectedPrinterName Slip ]";
              FlutterMosambeeAar.setLineSpace(10);
              FlutterMosambeeAar.printText3(
                  str2, FlutterMosambeeAar.PRINTLINE_CENTER, textsizemedium);
              FlutterMosambeeAar.setLineSpace(5);
              FlutterMosambeeAar.printList(
                  "Printed On", "", printedOn, textsizesmall, false);
              FlutterMosambeeAar.printList(
                  "User", "", userName, textsizesmall, false);
              //FlutterMosambeeAar.printList("Table Number", "", tableNumber, textsizesmall, false);
              FlutterMosambeeAar.printText1(
                  "------------------------------------------------------");
              FlutterMosambeeAar.printList(
                  "Product", "", "Qty.", textsizesmall, false);
              FlutterMosambeeAar.printText1(
                  "------------------------------------------------------");
              for (var order in responseData['orders']) {
                if (selectedPrinterKDS == order['kds']) {
                  String productname = order["product_name"];
                  String printProductname = "";

                  if (productname.length < 30) {
                    String itemname = productname.padRight(30);
                    printProductname = itemname.substring(0, 30);
                  } else {
                    printProductname = productname;
                  }

                  List<String> parts = getParts(printProductname, 30);
                  for (int j = 0; j < parts.length; j++) {
                    if (j == 0) {
                      FlutterMosambeeAar.printList(" ${parts[j]}", "",
                          "${order["quantity"]}", textsizesmall, false);
                    } else {
                      FlutterMosambeeAar.printList(
                          "  ${parts[j]}", "", "", textsizesmall, false);
                    }
                  }
                }
              }
              FlutterMosambeeAar.printText1(
                  "------------------------------------------------------");
              FlutterMosambeeAar.printText3(
                  "", FlutterMosambeeAar.PRINTLINE_LEFT, 100);

              if (state != null && state == 4) {
                FlutterMosambeeAar.closePrinter();
                return;
              }
              FlutterMosambeeAar.beginPrint();
            }
          }
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

  //*************** DISCOUNT **************

  void applyDiscount(String reference_id, String discount) async {
    if (isCouponApplied.value) removeCoupon(reference_id);
    try {
      isDisPerLoading.value = true;
      String url =
          '${APIUrls.quick_billupdate_discount}$userId&reference_id=$reference_id&discount=$discount';
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
          '${APIUrls.quick_billupdate_coupon}$userId&reference_id=$reference_id&coupon=$couponCode';
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
        '${APIUrls.quick_bill_coupon_removed}$userId&reference_id=$reference_id';
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
}
