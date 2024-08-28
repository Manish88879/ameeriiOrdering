import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/cardController.dart';

class AddMoney extends StatefulWidget {
  const AddMoney({super.key});

  @override
  State<AddMoney> createState() => AddMoneyState();
}

class AddMoneyState extends State<AddMoney> {
  final TextEditingController amount = TextEditingController();
  final SwipeCardController cardController = Get.put(SwipeCardController());
  final selectedOption = ''.obs;
  String cardNumber = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cardController.fetchPaymentMethod();
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      cardNumber = arguments['cardNumber'];
    } else {
      Get.snackbar('Alert!', "Card number invalid",
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Money',
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 17.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Enter Details',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 30),
                              ),
                            ],
                          ),
                          const Text(
                            'Safe and Secure',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: screen.height * 0.05),
                            width: screen.width * 0.62,
                            height: screen.height * 0.07,
                            child: TextField(
                              controller: amount,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Enter Amount',
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
                          Container(
                            margin: EdgeInsets.only(top: screen.height * 0.02),
                            width: screen.width * 0.62,
                            height: screen.height * 0.072,
                            child: Obx(() {
                              return DropdownButtonFormField<String>(
                                value: cardController.selected_paymentOptions
                                        .value.isNotEmpty
                                    ? cardController
                                        .selected_paymentOptions.value
                                    : null,
                                decoration: InputDecoration(
                                  hintText: 'Select Payment Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey,
                                      width: screen.width * 0.003,
                                    ),
                                  ),
                                ),
                                items: cardController.payment_Options
                                    .map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option['name'],
                                    child: Text(option['name'] ?? ''),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  if (value != "Card") {
                                    cardController
                                        .selected_subcardpaymentOptions
                                        .value = "";
                                  }
                                  cardController.selected_paymentOptions.value =
                                      value ?? '';
                                  // Perform any additional actions here
                                },
                              );
                            }),
                          ),
                          Obx(() {
                            return cardController
                                        .selected_paymentOptions.value ==
                                    "Card"
                                ? Container(
                                    margin: EdgeInsets.only(
                                        top: screen.height * 0.02),
                                    width: screen.width * 0.62,
                                    height: screen.height * 0.072,
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        hintText: 'Select Card Type',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                            width: screen.width * 0.003,
                                          ),
                                        ),
                                      ),
                                      items: cardController
                                          .subcardpayment_Options
                                          .map((option) {
                                        return DropdownMenuItem<String>(
                                          value: option['name'],
                                          child: Text(option['name'] ?? ''),
                                        );
                                      }).toList(),
                                      onChanged: (String? value) {
                                        cardController
                                            .selected_subcardpaymentOptions
                                            .value = value ?? '';
                                      },
                                    ),
                                  )
                                : Container();
                          }),

                          // Container(
                          //   margin: EdgeInsets.only(top: screen.height * 0.02),
                          //   width: screen.width * 0.26,
                          //   height: screen.height * 0.06,
                          //   child: TextField(
                          //     keyboardType: TextInputType.number,
                          //     obscureText: true,
                          //     decoration: InputDecoration(
                          //       hintText: 'Enter OTP',
                          //       counterText: '',
                          //       border: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(5.0),
                          //         borderSide: BorderSide(
                          //           color:
                          //               Colors.blueGrey, // Set border color here

                          //           width: screen.width *
                          //               0.1, // Set border width here
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          GestureDetector(
                            onTap: (() => {
                                  cardController.isLoading == true
                                      ? null
                                      : cardController.addMoney(
                                          cardNumber,
                                          amount.text,
                                          "${cardController.selected_paymentOptions.value} ${cardController.selected_subcardpaymentOptions.value}")
                                }),
                            child: Container(
                              width: screen.width * 0.62,
                              decoration: BoxDecoration(
                                color: CommonValue.phyloText,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              margin:
                                  EdgeInsets.only(top: screen.height * 0.06),
                              alignment: Alignment.center,
                              height: screen.height * 0.06,
                              child: Obx(
                                () => Text(
                                  cardController.isLoading == true
                                      ? 'Loading...'
                                      : 'Submit',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.0,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // Right Side
              ],
            ),
          ),
        ),
      ),
    );
  }
}
