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
import 'package:ameerii/Routes/app_pages.dart';

class YourOrders extends StatelessWidget {
  final CartController cartController = Get.put(CartController());
  final ScrollController _scrollController = ScrollController();
  final TableController tableController = Get.put(TableController());
  RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 246, 251),
      appBar: AppBar(
        backgroundColor: CommonValue.textcolor,
        title: Text(
          'Your Orders',
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
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 17),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.0),
                                color: Color.fromARGB(255, 224, 236, 255),
                              ),
                              child: Center(
                                  child: Text(
                                'Swipe end to start to delete orders',
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
                            margin: EdgeInsets.only(left: 13.0, top: 10.0),
                            child: Text(
                              'Items added',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blueGrey),
                            )),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 19.0),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          height: MediaQuery.sizeOf(context).height * 0.42,
                          child: Container(
                            child: Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                thickness: 2.0,
                                radius: Radius.circular(30),
                                child: Obx(
                                  () => ListView.builder(
                                    controller: _scrollController,
                                    itemCount:
                                        tableController.products.value.length,
                                    itemBuilder: (BuildContext context, index) {
                                      RxBool isLoad = false.obs;
                                      return Dismissible(
                                        key: Key(
                                          tableController.products.value[index]
                                              ['id'],
                                        ),
                                        onDismissed: (direction) {
                                          tableController.deleteItem(
                                              tableController.products[index]
                                                  ['id'],
                                              tableController.products[index]
                                                  ['reference_id']);
                                        },
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 7.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.red,
                                          ),
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0.0, 0.0, 10.0, 0.0),
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 30.0,
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                            bottom: BorderSide(
                                                color: Color.fromARGB(
                                                    255, 224, 236, 255),
                                                width: 1),
                                          )),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        0.45,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      tableController
                                                              .products[index]
                                                          ['product_name'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 15.0),
                                                    ),
                                                    Text(
                                                        '${tableController.products[index]['price']}',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 15.0))
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10.0,
                                              ),
                                              Obx(() => Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      tableController
                                                              .isLoading.value
                                                          ? Container(
                                                              width: 20.0,
                                                              height: 20.0,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                strokeWidth:
                                                                    2.0,
                                                                valueColor: AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    CommonValue
                                                                        .phyloText),
                                                              ),
                                                            )
                                                          : AddRemoveButton(
                                                              itemCount: int.parse(
                                                                      tableController.products[index]
                                                                          [
                                                                          'quantity'])
                                                                  .obs,
                                                              onAdd: (() => tableController.increaseQty(
                                                                  tableController
                                                                              .products[
                                                                          index]
                                                                      ['id'],
                                                                  tableController
                                                                              .products[
                                                                          index]
                                                                      ['reference_id'])),
                                                              onRemove: (() {
                                                                tableController
                                                                                .products[index]
                                                                            [
                                                                            'quantity'] ==
                                                                        '1'
                                                                    ? showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text('Confirm Deletion'),
                                                                            content:
                                                                                Text('Are you sure you want to delete this product?'),
                                                                            actions: [
                                                                              TextButton(
                                                                                child: Text('Cancel'),
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                              ),
                                                                              TextButton(
                                                                                child: Text('OK'),
                                                                                onPressed: () {
                                                                                  tableController.deleteItem(tableController.products[index]['id'], tableController.products[index]['reference_id']);
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      )
                                                                    : tableController.decreaseQty(
                                                                        tableController.products[index]
                                                                            [
                                                                            'id'],
                                                                        tableController.products[index]
                                                                            [
                                                                            'reference_id']);
                                                              })),
                                                      SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Text(
                                                        ' ${tableController.products[index]['total_price']}',
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 17.0),
                                                      ),
                                                    ],
                                                  ))
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )),
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
                              vertical: 10, horizontal: 15.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          height: MediaQuery.sizeOf(context).height * 0.20,
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
                                        'Sub Total',
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
                                        ' ${tableController.subtotal.value}',
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
                                        ' ${tableController.totalTaxes.value.toStringAsFixed(2)}',
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
                                  Text(
                                    'Grand Total',
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Colors.black,
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Obx(() => Text(
                                        ' ${tableController.totalAmount.value.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: Colors.green,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w800),
                                      ))
                                ],
                              ),

                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Expanded(
                              //       child: GestureDetector(
                              //         onTap: (() => print(
                              //             "Amount --- ${cartController.totalPrice}")),
                              //         child: Container(
                              //             height: 50.0,
                              //             decoration: BoxDecoration(
                              //                 borderRadius:
                              //                     BorderRadius.circular(5.0),
                              //                 color: Colors.orange),
                              //             child: Center(
                              //                 child: Text(
                              //               'Discount',
                              //               style: TextStyle(
                              //                   fontSize: 16,
                              //                   color: Colors.white,
                              //                   decoration: TextDecoration.none),
                              //               overflow: TextOverflow
                              //                   .ellipsis, // This ensures that the text doesn't overflow and shows an ellipsis if it's too long
                              //               maxLines: 1,
                              //             ))),
                              //       ),
                              //     ),
                              //     const SizedBox(width: 20.0),
                              //     Expanded(
                              //       child: GestureDetector(
                              //         onTap: () => Get.to(CheckoutPage()),
                              //         child: Container(
                              //             height: 50.0,
                              //             decoration: BoxDecoration(
                              //                 borderRadius:
                              //                     BorderRadius.circular(5.0),
                              //                 color: Colors.green),
                              //             child: Center(
                              //                 child: Text(
                              //               'Proceed',
                              //               style: TextStyle(
                              //                   fontSize: 16,
                              //                   color: Colors.white,
                              //                   decoration: TextDecoration.none),
                              //               overflow: TextOverflow
                              //                   .ellipsis, // This ensures that the text doesn't overflow and shows an ellipsis if it's too long
                              //               maxLines: 1,
                              //             ))),
                              //       ),
                              //     ),
                              //   ],
                              // )
                            ],
                          ),
                        ),
                        Container(
                          child: GestureDetector(
                            onTap: () {
                              Get.offAllNamed(Routes.TABLEHOME);
                              // Close the dialog
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                // width: 200.0,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15.0),
                                decoration: BoxDecoration(
                                    color: CommonValue.phyloText,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: Text(
                                  'Submit',
                                  style: TextStyle(color: Colors.white),
                                ))),
                          ),
                        ),
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
