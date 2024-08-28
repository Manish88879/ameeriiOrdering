import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/cardController.dart';

class AddCard extends StatefulWidget {
  const AddCard({super.key});

  @override
  State<AddCard> createState() => AddCardState();
}

class AddCardState extends State<AddCard> {
  final selectedOption = ''.obs;
  final selectedDate = DateTime.now().obs;
  final SwipeCardController cardController = Get.put(SwipeCardController());
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
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
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Card',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        backgroundColor: CommonValue.textcolor,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: screen.width * 0.06, vertical: screen.height * 0.08),
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
                            margin: EdgeInsets.only(top: screen.height * 0.04),
                            width: screen.width * 0.62,
                            height: screen.height * 0.07,
                            child: TextField(
                              controller: nameController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'Enter your name',
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
                            height: screen.height * 0.07,
                            child: TextField(
                              controller: mobileController,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              decoration: InputDecoration(
                                hintText: 'Enter mobile',
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
                            height: screen.height * 0.07,
                            child: TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Enter email',
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
                          GestureDetector(
                            onTap: (() => {
                                  if (mobileController.text.length == 10)
                                    cardController.createCard(
                                        cardNumber,
                                        nameController.text,
                                        mobileController.text,
                                        emailController.text,
                                        context)
                                  else
                                    {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Alert!"),
                                            content: const Text(
                                                'Enter Valid Mobile number'),
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
                                      )
                                    }
                                }),
                            child: Container(
                              width: screen.width * 0.62,
                              decoration: BoxDecoration(
                                color: CommonValue.phyloText,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              margin:
                                  EdgeInsets.only(top: screen.height * 0.04),
                              alignment: Alignment.center,
                              height: screen.height * 0.06,
                              child: Obx(
                                () => Text(
                                  cardController.isLoading == true
                                      ? 'Loading...'
                                      : 'Submit',
                                  style: TextStyle(color: Colors.white),
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
