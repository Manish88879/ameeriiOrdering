import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/bottomSheet.dart';
import 'package:ameerii/Common/cardAdded.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/OrderController/orderController.dart';
import 'package:ameerii/Common/controller/TableController/tableController.dart';
import 'package:ameerii/Components/navDrawer.dart';
import 'package:ameerii/Pages/QuickOrder/checkoutPage.dart';
import 'package:ameerii/Pages/TableManagement/tableManagementModal.dart';

import '../../Routes/app_pages.dart';

class CouponPage extends StatelessWidget {
  final CartController cartController = Get.put(CartController());
  final ScrollController _scrollController = ScrollController();
  final TableController tableController = Get.put(TableController());
  RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final TextEditingController couponController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  RxDouble serviceCharge = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    final String referenceId = Get.arguments['reference_id'];
    final String tableNumber = Get.arguments['table_number'];
    tableController.getPlacedOrder(referenceId);
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
                            onTap: (() => {
                                  print(
                                      'Items --- ${tableController.products.value}')
                                }),
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
                                  Obx(() => tableController.isLoading.value
                                      ? Container(
                                          margin: EdgeInsets.only(right: 55.0),
                                          child: CircularProgressIndicator())
                                      : Container(
                                          child: Obx(() => (!tableController
                                                      .isCouponApplied.value &&
                                                  tableController
                                                          .discount.value ==
                                                      0.0)
                                              ? GestureDetector(
                                                  onTap: (() => {
                                                        tableController
                                                            .applyCoupon(
                                                                referenceId,
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
                                                        tableController
                                                            .removeCoupon(
                                                                referenceId),
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
                                  Obx(() => tableController
                                          .isDisPerLoading.value
                                      ? Container(
                                          margin: EdgeInsets.only(right: 47.0),
                                          child: CircularProgressIndicator())
                                      : Container(
                                          child: Obx(() => (!tableController
                                                      .isDiscoPerApplied
                                                      .value &&
                                                  tableController
                                                          .discount.value ==
                                                      0.0)
                                              ? GestureDetector(
                                                  onTap: (() => {
                                                        tableController
                                                            .applyDiscount(
                                                                referenceId,
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
                                                        tableController
                                                            .applyDiscount(
                                                                referenceId,
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
                              'Other Charges',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blueGrey),
                            )),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15.0),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          height: MediaQuery.sizeOf(context).height * 0.08,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'images/images.png',
                                    scale: 8,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      'Service Charge',
                                      style: TextStyle(
                                          decoration: TextDecoration.none,
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                              Obx(() => tableController.isServiceLoading.value
                                  ? Container(
                                      margin: EdgeInsets.only(right: 15.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.red,
                                      ))
                                  : Container(
                                      child: Obx(
                                      () => (!tableController
                                              .isServiceApplied.value)
                                          ? GestureDetector(
                                              onTap: (() => {
                                                    tableController
                                                        .updateServiceCharge(
                                                            referenceId, 1)
                                                  }),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  border: Border.all(
                                                    color: Colors
                                                        .red, // Change this to your desired border color
                                                    width:
                                                        1, // Adjust the border width as needed
                                                  ),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 1.0,
                                                    horizontal: 14.0),
                                                child: Text(
                                                  'APPLY',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15.0),
                                                ),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: (() => {
                                                    tableController
                                                        .updateServiceCharge(
                                                            referenceId, 0)
                                                  }),
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(right: 9.0),
                                                child: Text(
                                                  'Remove',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15.0),
                                                ),
                                              ),
                                            ),
                                    )))
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
                                        ' ${tableController.subtotal.value.toStringAsFixed(2)}',
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
                                        ' ${tableController.totalTaxesLive.value.toStringAsFixed(2)}',
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
                                        ' -  ${tableController.discount.value.toStringAsFixed(2)}',
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
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.percent_outlined,
                                        color: Colors.black,
                                        size: 18.0,
                                      ),
                                      SizedBox(
                                        width: 4.0,
                                      ),
                                      Text(
                                        'Service charges',
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: Colors.black,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                  Obx(() => Text(
                                        ' ${tableController.serviceCharge.value.toStringAsFixed(2)}',
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
                                        ' ${(tableController.remainingAmount.value).toStringAsFixed(2)}',
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
                                  tableController.printBill(
                                      referenceId, referenceId),
                                  Get.offAllNamed(Routes.TABLEHOME)
                                  //tableController.billTable(referenceId, tableNumber)
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
                                  'Print Bill',
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
