import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/color.dart';

import '../../Common/controller/OrderController/orderController.dart';
import 'checkoutPage.dart';
import 'package:get/get.dart';

class DiscountPage extends StatelessWidget {
  final CartController cartController = Get.put(CartController());
  RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final TextEditingController couponController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  RxDouble serviceCharge = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    cartController.getPlacedOrder(cartController.referenceId.value);
    final Size screen = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 246, 251),
      appBar: AppBar(
        backgroundColor: CommonValue.textcolor,
        title: Text(
          'Discount',
          style: TextStyle(
              fontFamily: 'Raleway',
              color: Colors.white,
              fontWeight: FontWeight.w400),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: EdgeInsets.only(top: 10.0),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 245, 246, 251),
                    borderRadius: BorderRadius.circular(6)),
                width: MediaQuery.of(context).size.width *
                    0.3, // Adjust width as needed
                height: MediaQuery.of(context)
                    .size
                    .height, // 100% of the screen height

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: (() => {}),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10.0),
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.0),
                                color: Color.fromARGB(255, 224, 236, 255),
                              ),
                              child: Center(
                                  child: Text(
                                'Discount by coupon or enter discount percentage',
                                style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 33, 93, 243),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.none),
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(
                                left: 17.0, top: 1.0, bottom: 2.0),
                            child: Text(
                              'Create Discount',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blueGrey),
                            )),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          margin: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10.0),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 1.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.6,
                                    height: 45.0,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 15.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: CommonValue
                                            .phyloText, // Specify the color of the border
                                        width:
                                            1.0, // Specify the width of the border
                                      ),
                                    ),
                                    child: Container(
                                      height: 0.0,
                                      width: 100.0,
                                      child: TextField(
                                        controller: couponController,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          hintStyle: TextStyle(fontSize: 14.0),
                                          hintText: 'Enter Coupon code ',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: CommonValue
                                                  .phyloText, // Active border color
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Obx(() => cartController.isLoading.value
                                      ? Container(
                                          margin: EdgeInsets.only(right: 55.0),
                                          child: CircularProgressIndicator())
                                      : Container(
                                          child: Obx(() => (!cartController
                                                      .isCouponApplied.value &&
                                                  cartController
                                                          .discount.value ==
                                                      0.0)
                                              ? GestureDetector(
                                                  onTap: (() => {
                                                        cartController
                                                            .applyCoupon(
                                                                cartController
                                                                    .referenceId
                                                                    .value,
                                                                couponController
                                                                    .text),
                                                      }),
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        right: 11.0),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              38, 76, 175, 79),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      border: Border.all(
                                                        color: Colors
                                                            .green, // Change this to your desired border color
                                                        width:
                                                            1, // Adjust the border width as needed
                                                      ),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5.0,
                                                            horizontal: 10.0),
                                                    child: Text(
                                                      'APPLY',
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 18.0),
                                                    ),
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: (() => {
                                                        cartController
                                                            .removeCoupon(
                                                                cartController
                                                                    .referenceId
                                                                    .value),
                                                        couponController.text =
                                                            '',
                                                        discountController
                                                            .text = ''
                                                      }),
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        right: 31.0),
                                                    child: Text(
                                                      'Remove',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 17.0),
                                                    ),
                                                  ),
                                                )),
                                        ))
                                ],
                              ),
                              Text('Or'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.6,
                                    height: 45.0,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 15.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: CommonValue
                                            .phyloText, // Specify the color of the border
                                        width:
                                            1.0, // Specify the width of the border
                                      ),
                                    ),
                                    child: Container(
                                      height: 0.0,
                                      width: 100.0,
                                      child: TextField(
                                        controller: discountController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintStyle: TextStyle(fontSize: 14.0),
                                          hintText: 'Enter Discount %',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: CommonValue
                                                  .phyloText, // Active border color
                                              width: 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Obx(() => cartController.isDisPerLoading.value
                                      ? Container(
                                          margin: EdgeInsets.only(right: 47.0),
                                          child: CircularProgressIndicator())
                                      : Container(
                                          child: Obx(() => (!cartController
                                                      .isDiscoPerApplied
                                                      .value &&
                                                  cartController
                                                          .discount.value ==
                                                      0.0)
                                              ? GestureDetector(
                                                  onTap: (() => {
                                                        cartController
                                                            .applyDiscount(
                                                                cartController
                                                                    .referenceId
                                                                    .value,
                                                                discountController
                                                                    .text),
                                                      }),
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        right: 12.0),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              38, 76, 175, 79),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      border: Border.all(
                                                        color: Colors
                                                            .green, // Change this to your desired border color
                                                        width:
                                                            1, // Adjust the border width as needed
                                                      ),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5.0,
                                                            horizontal: 10.0),
                                                    child: Text(
                                                      'APPLY',
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 18.0),
                                                    ),
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onTap: (() => {
                                                        discountController
                                                            .text = '',
                                                        cartController
                                                            .applyDiscount(
                                                                cartController
                                                                    .referenceId
                                                                    .value,
                                                                '0'),
                                                        couponController.text =
                                                            '',
                                                        discountController
                                                            .text = ''
                                                      }),
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        right: 20.0),
                                                    child: Text(
                                                      'Remove',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 17.0),
                                                    ),
                                                  ),
                                                )),
                                        ))
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 17.0, top: 1.0),
                            child: Text(
                              'Bill Details',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blueGrey),
                            )),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15.0),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        color: Colors.black,
                                        size: 18.0,
                                      ),
                                      SizedBox(
                                        width: 4.0,
                                      ),
                                      Text(
                                        'Item total',
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color:
                                                Color.fromARGB(255, 50, 50, 50),
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                  Obx(() => Text(
                                        ' ${cartController.subtotal.value.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: Colors.black,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w800),
                                      ))
                                ],
                              ),
                              Divider(
                                height: 25.0,
                                color: Color.fromARGB(255, 224, 236, 255),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.black,
                                        size: 18.0,
                                      ),
                                      SizedBox(
                                        width: 4.0,
                                      ),
                                      Text(
                                        'Total Tax',
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color:
                                                Color.fromARGB(255, 50, 50, 50),
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                  Obx(() => Text(
                                        ' ${cartController.totalTaxesLive.value.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: Colors.black,
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w800),
                                      ))
                                ],
                              ),
                              Divider(
                                height: 25.0,
                                color: Color.fromARGB(255, 224, 236, 255),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.money_rounded,
                                        color: Colors.black,
                                        size: 18.0,
                                      ),
                                      SizedBox(
                                        width: 4.0,
                                      ),
                                      Text(
                                        'Discount',
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: Colors.black,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                  Obx(() => Text(
                                        ' -  ${cartController.discount.value.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: Color.fromARGB(
                                                255, 193, 193, 25),
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w800),
                                      ))
                                ],
                              ),
                              Divider(
                                height: 25.0,
                                color: Color.fromARGB(255, 224, 236, 255),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Amount',
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Colors.black,
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Obx(() => Text(
                                        ' ${(cartController.remainingAmount.value).toStringAsFixed(2)}',
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: Colors.green,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w800),
                                      ))
                                ],
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: (() => {
                                  cartController.getPlacedOrder(
                                      cartController.referenceId.value),
                                  Get.to(CheckoutPage())
                                }),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10)),
                              margin: EdgeInsets.only(top: 5.0),
                              height: 40.0,
                              width: MediaQuery.sizeOf(context).width * 0.9,
                              child: Center(
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
