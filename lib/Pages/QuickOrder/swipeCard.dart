import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/bottomSheet.dart';
import 'package:ameerii/Common/cardAdded.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/OrderController/orderController.dart';
import 'package:ameerii/Components/navDrawer.dart';

class CheckoutPage extends StatelessWidget {
  final CartController cartController = Get.put(CartController());

  RxInt _selectedTab = 1.obs;

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
          color: isSelected ? Colors.white : Colors.grey,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: isSelected ? CommonValue.textcolor : Colors.grey,
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
                          : Icons.paypal_sharp,
              color: isSelected ? CommonValue.phyloText : Colors.white,
            ),
            SizedBox(width: 15.0),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isSelected ? CommonValue.phyloText : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 219, 218, 218),
      appBar: AppBar(
        backgroundColor: CommonValue.textcolor,
        title: Text(
          'Checkout',
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
            height: MediaQuery.sizeOf(context).height * 0.75,
            width: MediaQuery.sizeOf(context).width * 0.8,
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Expanded(
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
                          creditCardPaymentOption(screen, 'Store Card', () {
                            _selectedTab.value = 0;
                          }, _selectedTab.value == 0),
                          creditCardPaymentOption(screen, 'Debit/Credit Card',
                              () {
                            _selectedTab.value = 1;
                          }, _selectedTab.value == 1),
                          creditCardPaymentOption(
                            screen,
                            'UPI',
                            () {
                              _selectedTab.value = 2;
                            },
                            _selectedTab.value == 2,
                          ),
                          creditCardPaymentOption(
                            screen,
                            'Cash',
                            () {
                              _selectedTab.value = 3;
                            },
                            _selectedTab.value == 3,
                          ),
                          Container(
                            height: screen.height * 0.06,
                            margin: EdgeInsets.only(
                              top: MediaQuery.sizeOf(context).height * 0.06,
                            ),
                            child: GestureDetector(
                              onTap: (() => {print('Manish Kumar')}),
                              child: Container(
                                width: screen.width * 0.65,
                                decoration: BoxDecoration(
                                  color: CommonValue.phyloText,
                                  border: Border.all(
                                    color: CommonValue.phyloText,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Proceed',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
