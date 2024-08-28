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

class Billing extends StatelessWidget {
  final CartController cartController = Get.put(CartController());
  final ScrollController _scrollController = ScrollController();
  final TableController tableController = Get.put(TableController());
  TextEditingController cname = TextEditingController();
  TextEditingController cphone = TextEditingController();
  TextEditingController caddress = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments ?? {};

    final table_number = arguments['table_number'] ?? 'Default Table Number';
    final reference_id = arguments['reference_id'] ?? 'Default Reference ID';
    final Size screen = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 246, 251),
      appBar: AppBar(
        backgroundColor: CommonValue.textcolor,
        title: Text(
          'Bill Summary',
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
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 17),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.0),
                                color: Color.fromARGB(255, 224, 236, 255),
                              ),
                              child: Center(
                                  child: Text(
                                'Add Customer for further convenience',
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
                          margin: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15.0),
                          padding: EdgeInsets.symmetric(vertical: 10),
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
                              child: Obx(() => ListView.builder(
                                    controller: _scrollController,
                                    itemCount:
                                        tableController.products.value.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                          bottom: BorderSide(
                                              color: Color.fromARGB(
                                                  255, 224, 236, 255),
                                              width: 1),
                                        )),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 7.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: MediaQuery.sizeOf(context)
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
                                                        fontSize: 14.0),
                                                  ),
                                                  Text(
                                                      '${tableController.products[index]['price']}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 14.0))
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 3.0, horizontal: 9),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7.0),
                                                color: Color.fromARGB(
                                                    255, 224, 236, 255),
                                              ),
                                              child: Text(
                                                'Qty :  ${tableController.products[index]['quantity']}',
                                                style: TextStyle(
                                                    color: Colors.blue[600],
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w700,
                                                    decoration:
                                                        TextDecoration.none),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Text(
                                              ' ${tableController.products[index]['total_price']}',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 17.0),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  )),
                            ),
                          ),
                        ),
                        // Container(
                        //   margin: EdgeInsets.symmetric(
                        //       vertical: 15, horizontal: 15.0),
                        //   padding: EdgeInsets.symmetric(
                        //       vertical: 10, horizontal: 15.0),
                        //   decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(20)),
                        //   child: Row(
                        //     children: [Text('View Coupons')],
                        //   ),
                        // ),
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
                          height: MediaQuery.sizeOf(context).height * 0.25,
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
                                        'Subtotal',
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
                                color: Color.fromARGB(255, 224, 236, 255),
                              ),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Row(
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.center,
                              //       children: [
                              //         Icon(
                              //           Icons.discount_outlined,
                              //           color: Colors.black,
                              //           size: 18.0,
                              //         ),
                              //         SizedBox(
                              //           width: 4.0,
                              //         ),
                              //         Text(
                              //           'Discount',
                              //           style: TextStyle(
                              //               decoration: TextDecoration.none,
                              //               color:
                              //                   Color.fromARGB(255, 50, 50, 50),
                              //               fontSize: 17.0,
                              //               fontWeight: FontWeight.w800),
                              //         ),
                              //       ],
                              //     ),
                              //     Text(
                              //       ' ${0.00.toStringAsFixed(2)}',
                              //       style: TextStyle(
                              //           decoration: TextDecoration.none,
                              //           color: Colors.black,
                              //           fontSize: 18.0,
                              //           fontWeight: FontWeight.w800),
                              //     )
                              //   ],
                              // ),
                              // Divider(
                              //   color: Color.fromARGB(255, 224, 236, 255),
                              // ),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0.0,
            child: Material(
              elevation: 44.0, // Adjust the elevation value as needed
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 19.0, vertical: 12.0),
                width: screen.width * 0.92,
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: Color.fromARGB(255, 224, 236, 255), width: 2)),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: (() => {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  scrollable: true,
                                  title: const Text("Customer Details"),
                                  content: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Form(
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: cname,
                                            keyboardType: TextInputType.text,
                                            decoration: const InputDecoration(
                                              labelText: "Customer name",
                                              icon:
                                                  Icon(Icons.person_4_outlined),
                                            ),
                                          ),
                                          TextFormField(
                                            controller: cphone,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: "Phone",
                                              icon: Icon(Icons.phone_android),
                                            ),
                                          ),
                                          TextFormField(
                                            controller: caddress,
                                            keyboardType: TextInputType.text,
                                            decoration: const InputDecoration(
                                              labelText: "Address (Optional)",
                                              icon: Icon(
                                                  Icons.domain_add_rounded),
                                            ),
                                          ),
                                          SizedBox(height: 30),
                                          GestureDetector(
                                            onTap: () {
                                              tableController.cname.value =
                                                  cname.text;
                                              tableController.cphone.value =
                                                  cphone.text;
                                              tableController.caddress.value =
                                                  caddress.text;
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              height: 34.0,
                                              width: screen.width * 0.65,
                                              decoration: BoxDecoration(
                                                color: CommonValue.phyloText,
                                                border: Border.all(
                                                  color: CommonValue.phyloText,
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
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
                            ),
                          }),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_2_outlined,
                                color: CommonValue.phyloText,
                                size: 18.0,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Add Customer',
                                style: TextStyle(
                                  color: CommonValue.bluegrey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_up_sharp,
                                color: Colors.black,
                              ),
                            ],
                          ),
                          Text(
                            'in bill Summary',
                            style: TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w600,
                                fontSize: 15.0),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: (() => {
                            tableController.isLoading == true
                                ? null
                                : tableController.billTable(
                                    reference_id, table_number)
                          }),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => Text(
                                      ' ${tableController.totalAmount.value.toStringAsFixed(0)}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0),
                                    ),
                                  ),
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 233, 232, 232)),
                                  )
                                ],
                              ),
                            ),
                            Obx(
                              () => Text(
                                tableController.isLoading == true
                                    ? 'Loading...'
                                    : 'Create Bill',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_right_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// DSR , Transaction  , Item Sales Statement 
