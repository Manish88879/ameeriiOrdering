import 'package:flutter/material.dart';
import 'package:flutter_mosambee_aar/flutter_mosambee_aar.dart';
import 'package:flutter_mosambee_aar/models/scanner_result_data.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/TableController/tableController.dart';

import '../../Common/controller/OrderController/orderController.dart';
import '../../Common/controller/cardController.dart';

class TableCheckout extends StatefulWidget {
  const TableCheckout({super.key});

  @override
  State<TableCheckout> createState() => TableCheckoutState();
}

class TableCheckoutState extends State<TableCheckout>
    with WidgetsBindingObserver {
  final TableController tableController = Get.put(TableController());

  final CartController cartController = Get.put(CartController());
  final SwipeCardController cardController = Get.put(SwipeCardController());
  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController PinNumber = TextEditingController();
  final TextEditingController cardNumberScan = TextEditingController();
  final TextEditingController cashAmount = TextEditingController();
  final TextEditingController nameOnCard = TextEditingController();
  final TextEditingController last4Digits = TextEditingController();
  final TextEditingController remarks = TextEditingController();
  final TextEditingController tenderAmount = TextEditingController();
  final RxInt _selectedTab = 0.obs;
  int screennumber = 0;
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  Widget creditCardPaymentOption(
    Size screen,
    String text,
    VoidCallback onTapCallback,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: onTapCallback,
      child: Container(
        decoration: BoxDecoration(
          color: !isSelected ? Colors.white : Colors.grey,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: !isSelected ? CommonValue.textcolor : Colors.grey,
            width: 2,
          ),
        ),
        margin: EdgeInsets.only(top: screen.height * 0.02),
        width: screen.width * 0.66,
        height: screen.height * 0.06,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              text == 'Store Card'
                  ? Icons.credit_card
                  : text == 'Debit/Credit Card'
                      ? Icons.card_membership
                      : text == 'Cash'
                          ? Icons.money
                          : text == 'Cash Partial Pay'
                              ? Icons.money
                              : Icons.paypal_sharp,
              color: !isSelected ? CommonValue.phyloText : Colors.white,
            ),
            SizedBox(width: 15.0),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: !isSelected ? CommonValue.phyloText : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    screennumber = 4;
    cardController.screenNumber = "4";
    _listenTransactionData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cardController.screenNumber = "0";
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    // if(state==AppLifecycleState.resumed)
    //     {
    //       cardController.screenNumber="1";
    //     }

    setState(() {
      _appLifecycleState = state;
      cardController.homepageDetail();
    });
  }

  void _startScan() {
    cardController.screenNumber = "4";
    FlutterMosambeeAar.startScan(0);
  }

  Future<void> _listenTransactionData() async {
    FlutterMosambeeAar.onScanResult.listen((result) {
      //Get.snackbar('Alert!', cardController.screenNumber, backgroundColor: Colors.red, colorText: Colors.white);
      if (_appLifecycleState == AppLifecycleState.resumed &&
          screennumber == 4) {
        //Logger.d(" ===========ScanResult3 Result data is ============ ${result.toMap()}");
        ScannerResultData scannerResultData = result;
        final RegExp numberRegExp = RegExp(r'^[0-9]+$');
        if (numberRegExp.hasMatch(scannerResultData.result!!)) {
          String scannedNumber = "${scannerResultData.result}";
          if (scannedNumber.length == 9) {
            if (cardController.screenNumber == "4") {
              cardNumberScan.text = scannedNumber;
            }
          } else {
            Get.snackbar(
                'Alert!', "Invalid Card Number. Please contact to support.",
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        } else {
          //Logger.d("Result is not a valid number");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    tableController.getPlacedOrder(cartController.referenceId.value);
    final Size screen = MediaQuery.of(context).size;
    // final arguments = Get.arguments;
    // final referenceId =
    //     arguments['reference_id']; // Get the reference_id argument

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 219, 218, 218),
      appBar: AppBar(
        backgroundColor: CommonValue.textcolor,
        title: Text(
          'Table Checkout',
          style: TextStyle(
              fontFamily: 'Raleway',
              color: Colors.white,
              fontWeight: FontWeight.w400),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Card(
          elevation: 15.0,
          child: Container(
            height: screen.height * 0.75,
            width: screen.width * 0.8,
            padding: EdgeInsets.symmetric(vertical: 30),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Payment options',
                            style: TextStyle(
                              color: CommonValue.phyloText,
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Safe and secure',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        // color: Colors.white,

                        padding: EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 5.0),
                        margin:
                            EdgeInsets.only(left: 10.0, top: 10.0, right: 20.0),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Grand Total',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${tableController.afterDiscountAmount.value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        // color: Colors.green,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 5.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'To Pay ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${tableController.remainingAmount.value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      tableController.isLoading.value
                          ? const Text("Loading")
                          : creditCardPaymentOption(screen, 'Store Card', () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    scrollable: true,
                                    title: const Text("Scan or enter card "),
                                    content: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Form(
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: (() => {_startScan()}),
                                              child: Container(
                                                height: 34.0,
                                                width: screen.width * 0.65,
                                                decoration: BoxDecoration(
                                                  color: CommonValue.phyloText,
                                                  border: Border.all(
                                                    color:
                                                        CommonValue.phyloText,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Scan',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6.0),
                                            const Text(
                                              '----  OR  ----',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                            ),
                                            const SizedBox(height: 10.0),
                                            TextFormField(
                                              maxLength: 9,
                                              controller: cardNumberScan,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: "Enter Card Number",
                                                icon: Icon(Icons.credit_card),
                                              ),
                                            ),
                                            TextFormField(
                                              controller: PinNumber,
                                              keyboardType: TextInputType.text,
                                              decoration: const InputDecoration(
                                                labelText: "Enter Customer Pin",
                                                icon: Icon(Icons.credit_card),
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                tableController
                                                    .useStoreCardtable(
                                                        cartController
                                                            .referenceId.value,
                                                        cardNumberScan.text,
                                                        tableController
                                                            .remainingAmount
                                                            .value
                                                            .toString(),
                                                        PinNumber.text);
                                              },
                                              child: Container(
                                                height: 34.0,
                                                width: screen.width * 0.65,
                                                decoration: BoxDecoration(
                                                  color: CommonValue.phyloText,
                                                  border: Border.all(
                                                    color:
                                                        CommonValue.phyloText,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Submit',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }, _selectedTab.value != 0),
                      tableController.isLoading.value
                          ? const Text("Loading")
                          : creditCardPaymentOption(screen, 'Cash', () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    scrollable: true,
                                    title: const Text("Cash"),
                                    content: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Form(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                              controller:
                                                  tableController.cashAmount,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: "Enter amount",
                                                icon: Icon(Icons.credit_card),
                                              ),
                                            ),
                                            SizedBox(height: 20.0),
                                            Obx(() => Text(
                                                  "Change:  ${tableController.change.value.toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0,
                                                      color: CommonValue
                                                          .textcolor),
                                                )),
                                            const SizedBox(height: 30),
                                            GestureDetector(
                                              onTap: () {
                                                if (tableController
                                                        .cashAmount.text ==
                                                    '') {
                                                  tableController
                                                          .cashAmount.text =
                                                      "${tableController.remainingAmount.value}";
                                                }
                                                if (double.parse(tableController
                                                        .cashAmount.text) <
                                                    tableController
                                                        .remainingAmount
                                                        .value) {
                                                  Get.snackbar('Message',
                                                      'Minimum ${tableController.remainingAmount.value} Cash needed',
                                                      colorText: Colors.white);
                                                } else {
                                                  tableController.totalAmount
                                                      .value = tableController
                                                          .totalAmount.value -
                                                      double.parse(
                                                          tableController
                                                              .cashAmount.text);
                                                  Navigator.of(context).pop();
                                                  tableController
                                                      .orderpaymentsave(
                                                          '1',
                                                          'Cash',
                                                          cartController
                                                              .referenceId
                                                              .value,
                                                          tableController
                                                              .cashAmount.text);
                                                }
                                              },
                                              child: Container(
                                                height: 34.0,
                                                width: screen.width * 0.65,
                                                decoration: BoxDecoration(
                                                  color: CommonValue.phyloText,
                                                  border: Border.all(
                                                    color:
                                                        CommonValue.phyloText,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Submit',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }, _selectedTab.value == 3),
                      tableController.isLoading.value
                          ? const Text("Loading")
                          : creditCardPaymentOption(screen, 'Cash Partial Pay',
                              () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    scrollable: true,
                                    title: const Text("Cash Partial Payment"),
                                    content: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Form(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Amount :  ${tableController.remainingAmount}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.0,
                                                  color: CommonValue.textcolor),
                                            ),
                                            SizedBox(height: 10.0),
                                            TextFormField(
                                              controller: tenderAmount,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: "Enter amount",
                                                icon: Icon(Icons.credit_card),
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                            GestureDetector(
                                              onTap: () {
                                                if (int.parse(
                                                        tenderAmount.text) >
                                                    tableController
                                                        .remainingAmount
                                                        .value) {
                                                  Get.snackbar('Message',
                                                      'Tender amount cannot be greater than ${tableController.remainingAmount.value}',
                                                      backgroundColor:
                                                          Colors.red,
                                                      colorText: Colors.white);
                                                } else {
                                                  tableController.totalAmount
                                                      .value = tableController
                                                          .totalAmount.value -
                                                      double.parse(
                                                          tenderAmount.text);
                                                  Navigator.of(context).pop();
                                                  tableController
                                                      .PartialPaymentSave(
                                                          '1',
                                                          'Cash',
                                                          cartController
                                                              .referenceId
                                                              .value,
                                                          "Partial Pay",
                                                          tenderAmount.text);
                                                  tenderAmount.text = '';
                                                }
                                              },
                                              child: Container(
                                                height: 34.0,
                                                width: screen.width * 0.65,
                                                decoration: BoxDecoration(
                                                  color: CommonValue.phyloText,
                                                  border: Border.all(
                                                    color:
                                                        CommonValue.phyloText,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Submit',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }, _selectedTab.value == 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
