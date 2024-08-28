import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/cardController.dart';
import 'package:ameerii/Routes/app_pages.dart';

class CardDetails extends StatefulWidget {
  const CardDetails({super.key});

  @override
  State<CardDetails> createState() => CardDetailState();
}

class CardDetailState extends State<CardDetails> {
  final SwipeCardController swipeCardController =
      Get.find<SwipeCardController>();
  String cardNumber = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      cardNumber = arguments['cardNumber'];
    } else {
      Get.snackbar('Alert!', "Card number invalid",
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.back();
    }

    swipeCardController.screenNumber = "0";
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: CommonValue.textcolor,
        title: Text('Card Detail', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: screen.width * 0.1, vertical: screen.width * 0.01),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30.0),
            Container(
              height: screen.height * 0.3,
              child: Card(
                child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(13.0),
                      bottomRight: Radius.circular(15.0),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 10.0),
                          Text(
                            'Balance : ${swipeCardController.balance ?? "0"}',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 25,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'images/travelCard.png'), // Provide your image path
                                    fit: BoxFit
                                        .fill, // Adjust the fit as per your requirement
                                  ),
                                ),
                                height:
                                    MediaQuery.sizeOf(context).height * 0.18,
                                width: MediaQuery.sizeOf(context).width * 0.64,
                                child: Container(
                                  margin: EdgeInsets.only(top: 66.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Icon(
                                      //   color: Colors.white,
                                      //   Icons.format_list_numbered_sharp,
                                      // ),
                                      SizedBox(height: 3.0),
                                      Text(
                                        cardNumber ?? "0",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          letterSpacing: 9.5,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19.0,
                                          color: Colors
                                              .white, // Use your color resource
                                        ),
                                      ),
                                      SizedBox(height: 9.0),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 55, right: 30.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              swipeCardController.name ?? "0",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.0,
                                                color: Colors
                                                    .white, // Use your color resource
                                              ),
                                            ),
                                            const Text(
                                              "",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.0,
                                                color: Colors
                                                    .white, // Use your color resource
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.0),
                        ])),
              ),
            ),
            SizedBox(height: 30.0),
            Container(
              height: 300,
              child: Card(
                child: Column(
                  children: [
                    SizedBox(height: 20.0),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text(
                        //   'Card details',
                        //   style: TextStyle(color: Colors.grey, fontSize: 30),
                        // ),
                      ],
                    ),
                    const Text(
                      'Manage your options here',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: (() => {
                            Get.toNamed(Routes.ADDMONEY,
                                arguments: {'cardNumber': cardNumber})
                          }),
                      child: Container(
                        width: screen.width * 0.564,
                        decoration: BoxDecoration(
                          color: CommonValue.phyloText,
                          border: Border.all(
                            color: CommonValue
                                .phyloText, // Change border color on hover
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        margin: EdgeInsets.only(top: 16.0),
                        alignment: Alignment.center,
                        height: screen.height * 0.05,
                        child: Text(
                          'Add Money',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: (() => {Get.toNamed(Routes.USEMONEY,arguments: {'cardNumber': cardNumber})}),
                    //   child: Container(
                    //     width: screen.width * 0.564,
                    //     decoration: BoxDecoration(
                    //       color: CommonValue.phyloText,
                    //       border: Border.all(
                    //         color: CommonValue
                    //             .phyloText, // Change border color on hover
                    //         width: 2.0,
                    //       ),
                    //       borderRadius: BorderRadius.circular(5.0),
                    //     ),
                    //     margin: EdgeInsets.only(top: screen.height * 0.02),
                    //     alignment: Alignment.center,
                    //     height: screen.height * 0.05,
                    //     child: Text(
                    //       'Use Money',
                    //       style: TextStyle(color: Colors.white),
                    //     ),
                    //   ),
                    // ),

                    GestureDetector(
                      onTap: (() => {
                            Get.toNamed(Routes.TXNHISTORY,
                                arguments: {'cardNumber': cardNumber})
                          }),
                      child: Container(
                        width: screen.width * 0.564,
                        decoration: BoxDecoration(
                          color: CommonValue.phyloText,
                          border: Border.all(
                            color: CommonValue
                                .phyloText, // Change border color on hover
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        margin: EdgeInsets.only(top: 16),
                        alignment: Alignment.center,
                        height: screen.height * 0.05,
                        child: Text(
                          'Transaction History',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (() => {
                            Get.toNamed(Routes.TRANSFERCARD,
                                arguments: {'cardNumber': cardNumber})
                          }),
                      child: Container(
                        width: screen.width * 0.564,
                        decoration: BoxDecoration(
                          color: CommonValue.phyloText,
                          border: Border.all(
                            color: CommonValue
                                .phyloText, // Change border color on hover
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        margin: EdgeInsets.only(top: 16), // Tranfer Balance
                        alignment: Alignment.center,
                        height: screen.height * 0.05,
                        child: Text(
                          'Transfer Card',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right Side
          ],
        ),
      ),
    );
  }
}
