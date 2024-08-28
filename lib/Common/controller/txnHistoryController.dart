import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ameerii/Common/APIUrls.dart';
import 'dart:convert';
import '../model/txnHistoryModal.dart';

class TransactionController extends GetxController {
  var isLoading = true.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;
  var transactionList = <TxnHistoryModal>[].obs;

  @override
  void onInit() async {
    super.onInit();
  }

  void fetchCardHistory(String cardNum) async {
    try {
      log("carddd22: $cardNum");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      //Get.snackbar('Alert!', "API HIT", backgroundColor: Colors.red, colorText: Colors.white);
      var response = await http
          .get(Uri.parse('${APIUrls.card_history}$userId&cardno=$cardNum'));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var transactions = <TxnHistoryModal>[];
        for (var item in jsonData['users']) {
          transactions?.add(TxnHistoryModal.fromJson(item));
        }
        transactionList.assignAll(transactions);
        isLoading.value = false;

        log("carddd33: $cardNum");
      } else {
        throw 'Failed to load data';
        log("carddd4: $cardNum");
      }
    } catch (error) {
      log("carddd55: ${error.toString()}");
      errorMessage?.value = error.toString();
      isError.value = true;
      isLoading.value = false;
    }
  }
}
