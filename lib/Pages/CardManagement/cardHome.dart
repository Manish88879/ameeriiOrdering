import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mosambee_aar/flutter_mosambee_aar.dart';
import 'package:flutter_mosambee_aar/models/scanner_result_data.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/cardController.dart';
import 'package:ameerii/Components/navDrawer.dart';
import '../../Common/controller/logger.dart';
import '../../Routes/app_pages.dart';

class CardHome extends StatefulWidget {
  const CardHome({super.key});

  @override
  State<CardHome> createState() => CardHomeState();
}

class CardHomeState extends State<CardHome> with WidgetsBindingObserver {
  final TextEditingController cardNumber = TextEditingController();
  final SwipeCardController cardController = Get.put(SwipeCardController());
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  late Timer _timer;
  int screennumber = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //FlutterMosambeeAar.startScan(0);
    screennumber = 1;
    cardController.screenNumber = "1";
    cardController.homepageDetail();
    _listenTransactionData();
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cardController.screenNumber = "0";
    super.dispose();
  }

  void _startTimer() {
    const Duration period = Duration(seconds: 10);
    _timer = Timer.periodic(period, (timer) {
      cardController.homepageDetail();
    });
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
    cardController.screenNumber = "1";
    FlutterMosambeeAar.startScan(0);
  }

  Future<void> _listenTransactionData() async {
    FlutterMosambeeAar.onScanResult.listen((result) {
      //Get.snackbar('Alert!', cardController.screenNumber, backgroundColor: Colors.red, colorText: Colors.white);
      if (_appLifecycleState == AppLifecycleState.resumed) {
        //Logger.d(" ===========ScanResult3 Result data is ============ ${result.toMap()}");
        ScannerResultData scannerResultData = result;
        final RegExp numberRegExp = RegExp(r'^[0-9]+$');
        if (numberRegExp.hasMatch(scannerResultData.result!!)) {
          String scannedNumber = "${scannerResultData.result}";
          if (scannedNumber.length == 9) {
            //Get.toNamed(Routes.ADDCARD,arguments: {'cardNumber': scannedNumber});
            if (cardController.screenNumber == "1") {
              cardController.cardStatus(scannedNumber, '0');
            }
          } else {
            Get.snackbar(
                'Alert!', "Invalid Card Number. Please contact to support.",
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        } else {
          Logger.d("Result is not a valid number");
        }
      }
    });
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  Icons
                      .align_horizontal_left_outlined, // You can replace this with your custom icon
                  color: Colors.white,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          backgroundColor: CommonValue.textcolor,
          title: const Text(
            'Card Management',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontFamily: 'Raleway'),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: NavDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.all(10.0),
                  height: 330,
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyCustomContainer(
                                title: 'Card Issued',
                                content: cardController.option1),
                            MyCustomContainer(
                                title: 'Transactions',
                                content: cardController.option2),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyCustomContainer(
                                title: 'Amount Collected',
                                content: cardController.option3),
                            MyCustomContainer(
                                title: 'Amount Spent',
                                content: cardController.option4),
                          ],
                        ),
                      ],
                    ),
                  )),
              // TextField
              Container(
                padding: EdgeInsets.all(20),
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: (() => {_startScan()}),
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
                          margin: EdgeInsets.only(top: screen.height * 0.01),
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
                        height: 52.0,
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: cardNumber,
                          onChanged: (value) {
                            if (value.length == 9) {
                              cardController.cardStatus(cardNumber.text, '0');
                              cardNumber.text = '';
                            }
                          },
                          keyboardType: TextInputType.number,
                          enabled: true,
                          decoration: InputDecoration(
                            hintText: 'Enter card number',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: CommonValue
                                    .phyloText, // Inactive border color
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: CommonValue
                                    .phyloText, // Active border color
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0),
                      GestureDetector(
                        onTap: (() => {
                              //FlutterMosambeeAar.startScan(0)
                              if (cardNumber.text == '')
                                {
                                  Get.snackbar(
                                      'Message', 'Card Number is Empty',
                                      colorText: Colors.white)
                                }
                              else if (cardNumber.text.length < 9)
                                {
                                  Get.snackbar(
                                      'Message', 'Enter Valid Card number',
                                      colorText: Colors.white)
                                }
                              else
                                {
                                  cardController.cardStatus(
                                          cardNumber.text, '0'):
                                      cardNumber.text = ''
                                }
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
                          margin: EdgeInsets.only(top: screen.height * 0.01),
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
            ],
          ),
        ),
      ),
    );
  }
}

class MyCustomContainer extends StatelessWidget {
  final String title;
  final RxString content;

  const MyCustomContainer({
    required this.title,
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.17,
      width: MediaQuery.of(context).size.width * 0.42,
      child: Card(
        color: CommonValue.bluegrey,
        child: InkWell(
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 5.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 5.0),
              Obx(
                () => Text(
                  content.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
