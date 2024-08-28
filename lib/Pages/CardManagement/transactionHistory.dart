import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:ameerii/Common/color.dart';
import '../../Common/controller/txnHistoryController.dart';

class TxnHistory extends StatefulWidget {
  const TxnHistory({super.key});

  @override
  State<TxnHistory> createState() => TxnHistoryState();
}

class TxnHistoryState extends State<TxnHistory> with WidgetsBindingObserver {
  TransactionController txncontroller = Get.put(TransactionController());
  String cardNumber = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      cardNumber = arguments['cardNumber'];
    } else {
      Get.snackbar('Alert!', "Card number invalid",
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.back();
    }
    log("carddd: $cardNumber");
    txncontroller.fetchCardHistory(cardNumber);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    txncontroller.fetchCardHistory(cardNumber);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Transaction History',
            style: TextStyle(color: Colors.white),
          ),
          foregroundColor: Colors.white,
          backgroundColor: CommonValue.textcolor,
        ),
        body: Obx(() => (txncontroller.isLoading.value)
            ? Center(child: CircularProgressIndicator())
            : ListView.separated(
                itemCount: txncontroller.transactionList.length,
                itemBuilder: (context, index) {
                  var transaction = txncontroller.transactionList[index];
                  return ListTile(
                    title: Text(
                      'Transaction ID: ${transaction.txnID}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date : ${transaction.created}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (transaction.type == '1' || transaction.type == '3')
                              ? Icons.add
                              : Icons.remove,
                          color: (transaction.type == '1' ||
                                  transaction.type == '3')
                              ? Colors.green
                              : Colors.red,
                        ),
                        SizedBox(width: 4), // Add some spacing
                        Text(
                          '₹${transaction.amount}',
                          style: TextStyle(
                              color: (transaction.type == '1' ||
                                      transaction.type == '3')
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
              )));
  }
}
