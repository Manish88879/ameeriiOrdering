import 'package:flutter/material.dart';
import 'package:flutter_mosambee_aar/flutter_mosambee_aar.dart';
import 'package:flutter_mosambee_aar/models/scanner_result_data.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/cardController.dart';

class TransferCard extends StatefulWidget {
  const TransferCard({super.key});
  @override
  State<TransferCard> createState() => TransferCardState();
}

class TransferCardState extends State<TransferCard>
    with WidgetsBindingObserver {
  final TextEditingController newCardNumber = TextEditingController();
  final SwipeCardController cardController = Get.put(SwipeCardController());
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  int screennumber = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    screennumber = 2;
    cardController.screenNumber = "2";
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
    setState(() {
      _appLifecycleState = state;
    });
  }

  Future<void> _listenTransactionData() async {
    FlutterMosambeeAar.onScanResult.listen((result) {
      //Get.snackbar('Alert!', cardController.screenNumber, backgroundColor: Colors.red, colorText: Colors.white);
      if (_appLifecycleState == AppLifecycleState.resumed &&
          screennumber == 2) {
        //Logger.d(" ===========ScanResult3 Result data is ============ ${result.toMap()}");
        ScannerResultData scannerResultData = result;
        final RegExp numberRegExp = RegExp(r'^[0-9]+$');
        if (numberRegExp.hasMatch(scannerResultData.result!!)) {
          String scannedNumber = "${scannerResultData.result}";
          if (scannedNumber.length == 9) {
            if (cardController.screenNumber == "2") {
              newCardNumber.text = scannedNumber;
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
    final arguments = Get.arguments as Map<String, dynamic>;
    final cardNumber = arguments['cardNumber'];
    final Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transfer Card',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        backgroundColor: CommonValue.textcolor,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: screen.width * 0.06, vertical: screen.height * 0.15),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 17.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 10.0),
                          GestureDetector(
                            onTap: (() => {FlutterMosambeeAar.startScan(0)}),
                            child: Container(
                              width: screen.width * 0.75,
                              decoration: BoxDecoration(
                                color: CommonValue.phyloText,
                                border: Border.all(
                                  color: CommonValue
                                      .phyloText, // Change border color on hover
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              margin:
                                  EdgeInsets.only(top: screen.height * 0.01),
                              alignment: Alignment.center,
                              height: screen.height * 0.06,
                              child: const Text(
                                'Scan',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          const Text(
                            '----  OR  ----',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 10.0),
                          Container(
                            width: screen.width * 0.62,
                            height: screen.height * 0.07,
                            child: TextField(
                              maxLength: 9,
                              controller: newCardNumber,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Enter New Number',
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors
                                        .blueGrey, // Set border color here

                                    width: screen.width *
                                        0.1, // Set border width here
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30.0),
                          GestureDetector(
                            onTap: (() => {
                                  cardController.transferCard(
                                      cardNumber, newCardNumber.text)
                                }),
                            child: Container(
                              width: screen.width * 0.75,
                              decoration: BoxDecoration(
                                color: CommonValue.phyloText,
                                border: Border.all(
                                  color: CommonValue
                                      .phyloText, // Change border color on hover
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              margin:
                                  EdgeInsets.only(top: screen.height * 0.01),
                              alignment: Alignment.center,
                              height: screen.height * 0.06,
                              child: Text(
                                'Submit',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 15.0),
                        ],
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
