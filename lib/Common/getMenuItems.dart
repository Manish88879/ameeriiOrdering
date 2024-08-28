// menu_items.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/OrderController/orderController.dart';
import 'package:ameerii/Common/controller/TableController/tableController.dart';
import 'package:ameerii/Pages/QuickOrder/checkoutPage.dart';
import 'package:ameerii/Pages/TableManagement/tableManagementModal.dart';
import 'package:ameerii/Pages/TableManagement/tablecheckout.dart';
import 'package:ameerii/Routes/app_pages.dart';

List<Widget> getMenuItems(var table, BuildContext context) {
  final TableController tableController = Get.put(TableController());
  final CartController cartController = Get.put(CartController());

  RxInt numSplit = 1.obs;
  print(table);
  if (table["status"] == '2') {
    // Options when status is 'Booked'
    return [
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
          cartController.fetchProducts('-1');
          Get.toNamed(Routes.ADDORDER, arguments: {
            'table_number': table["id"],
            'reference_id': table['reference_id']
          }); // Close the dialog
        },
        child: Container(
            width: 200.0,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
            decoration: BoxDecoration(
                color: CommonValue.phyloText,
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(
              'Quick Order',
              style: TextStyle(color: Colors.white),
            ))),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
          tableController.getPlacedOrder(table['reference_id']);
          Get.toNamed(Routes.BILLING, arguments: {
            'table_number': table["id"],
            'reference_id': table['reference_id']
          }); // Close the dialog
        },
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            width: 200.0,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
            decoration: BoxDecoration(
                color: CommonValue.phyloText,
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(
              'Generate Bill',
              style: TextStyle(color: Colors.white),
            ))),
      ),

      GestureDetector(
        onTap: () {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return TableManagementModal(
                fromReference_number: table['reference_id'],
              );
            },
          );
          // Close the dialog
        },
        child: Container(
            width: 200.0,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
            decoration: BoxDecoration(
                color: CommonValue.phyloText,
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(
              'Change Table',
              style: TextStyle(color: Colors.white),
            ))),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
          tableController.getPlacedOrder(table['reference_id']);
          Get.toNamed(Routes.YOURORDERS);
          // Close the dialog
        },
        child: Container(
            margin: EdgeInsets.only(top: 10.0),
            width: 200.0,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
            decoration: BoxDecoration(
                color: CommonValue.phyloText,
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(
              'Edit Order',
              style: TextStyle(color: Colors.white),
            ))),
      ),
      // GestureDetector(
      //   onTap: () {
      //     Navigator.pop(context); // Close the previous dialog
      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return AlertDialog(
      //           title: Text(
      //             'Are you sure?',
      //             style: TextStyle(
      //                 color: Colors.blueGrey, fontWeight: FontWeight.w800),
      //           ),
      //           actions: [
      //             TextButton(
      //               child: Text('Cancel'),
      //               onPressed: () {
      //                 Navigator.of(context)
      //                     .pop(); // Close the confirmation dialog
      //               },
      //             ),
      //             TextButton(
      //               child: Text('Yes'),
      //               onPressed: () {
      //                 Navigator.of(context)
      //                     .pop(); // Close the confirmation dialog
      //                 tableController.clearTable(table['reference_id']);
      //               },
      //             ),
      //           ],
      //         );
      //       },
      //     );
      //   },
      //   child: Container(
      //       margin: EdgeInsets.symmetric(vertical: 10.0),
      //       width: 200.0,
      //       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
      //       decoration: BoxDecoration(
      //           color: CommonValue.phyloText,
      //           borderRadius: BorderRadius.circular(8)),
      //       child: Center(
      //           child: Text(
      //         'Clear Table',
      //         style: TextStyle(color: Colors.white),
      //       ))),
      // ),
    ];
  } else if (table['status'] == '1') {
    // Options when status is 'Vacant'
    return [
      GestureDetector(
        onTap: () {
          Navigator.pop(context); // Close the dialog
          // Add your action here
        },
        child: Text('Reserve'),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pop(context); // Close the dialog
          // Add your action here
        },
        child: Text('Details'),
      ),
    ];
  } else {
    // Options when status is 'Billed' or any other status
    return [
      GestureDetector(
        onTap: () {
          tableController
              .getPlacedOrder(table['reference_id'])
              .then((int result) {
            if (result == 1) {
              print('Result -----------1');
              cartController.referenceId.value = table['reference_id'];
              cartController.totalAmount.value =
                  tableController.totalAmount.value;
              // tableControlller.referenceId.value = table['reference_id'];
              Get.to(TableCheckout(),
                  arguments: {'reference_id': table['reference_id']});

              // Open CheckoutPage
            }
          }).catchError((error) {});
          Navigator.pop(context);
          // Add your action here
        },
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            width: 200.0,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
            decoration: BoxDecoration(
                color: CommonValue.phyloText,
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(
              'Settle Bill',
              style: TextStyle(color: Colors.white),
            ))),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pop(context); // Close the dialog
          // Add your action here
          tableController.isCouponApplied.value = false;
          tableController.getPlacedOrder(table['reference_id']);
          Get.toNamed(Routes.COUPONPAGE, arguments: {
            'table_number': table["id"],
            'reference_id': table['reference_id']
          });
        },
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            width: 200.0,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
            decoration: BoxDecoration(
                color: CommonValue.phyloText,
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(
              'Apply Discount',
              style: TextStyle(color: Colors.white),
            ))),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pop(context); // Close the previous dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Are you sure?',
                  style: TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.w800),
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Close the confirmation dialog
                    },
                  ),
                  TextButton(
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Close the confirmation dialog
                      tableController.unbill(table['reference_id']);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          width: 200.0,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
          decoration: BoxDecoration(
            color: CommonValue.phyloText,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Unbill',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      // GestureDetector(
      //   onTap: () {
      //     tableController.getPlacedOrder(table['reference_id']).then((value) =>
      //         {
      //           if (value == 1)
      //             {
      //               Navigator.pop(context), // Close the dialog
      //               // Add your action here
      //               showDialog(
      //                 context: context,
      //                 builder: (BuildContext context) {
      //                   return AlertDialog(
      //                     title: Text(
      //                       'Set number of Splits',
      //                       style: TextStyle(
      //                           color: Colors.blueGrey,
      //                           fontWeight: FontWeight.w800),
      //                     ),
      //                     content: SingleChildScrollView(
      //                       child: Column(
      //                         mainAxisSize: MainAxisSize.min,
      //                         children: [
      //                           Container(
      //                             margin: EdgeInsets.only(left: 4.0),
      //                             child: Row(
      //                               mainAxisAlignment: MainAxisAlignment.center,
      //                               children: [
      //                                 GestureDetector(
      //                                   onTap: (() => {
      //                                         tableController
      //                                                     .splitNumber.value !=
      //                                                 1
      //                                             ? tableController
      //                                                 .splitNumber.value--
      //                                             : null
      //                                       }),
      //                                   child: Container(
      //                                       decoration: const BoxDecoration(
      //                                         color: Color.fromARGB(
      //                                             255, 236, 234, 234),
      //                                         borderRadius: BorderRadius.only(
      //                                           topLeft: Radius.circular(5.0),
      //                                           bottomLeft:
      //                                               Radius.circular(5.0),
      //                                         ),
      //                                       ),
      //                                       padding: const EdgeInsets.symmetric(
      //                                           horizontal: 15.0,
      //                                           vertical: 12.0),
      //                                       child: Obx(
      //                                         () => Icon(
      //                                           Icons.remove,
      //                                           color: tableController
      //                                                       .splitNumber
      //                                                       .value ==
      //                                                   1
      //                                               ? Colors.grey
      //                                               : Colors.black,
      //                                         ),
      //                                       )),
      //                                 ),
      //                                 Container(
      //                                   padding: const EdgeInsets.symmetric(
      //                                       horizontal: 15.0, vertical: 5.0),
      //                                   decoration: BoxDecoration(),
      //                                   child: Center(
      //                                       child: Obx(
      //                                     () => Text(
      //                                       tableController.splitNumber.value
      //                                           .toString(),
      //                                       style: const TextStyle(
      //                                         color: Colors.black,
      //                                         fontSize: 30.0,
      //                                         fontWeight: FontWeight.w700,
      //                                       ),
      //                                     ),
      //                                   )),
      //                                 ),
      //                                 GestureDetector(
      //                                   onTap: (() => {
      //                                         tableController
      //                                             .splitNumber.value++
      //                                       }),
      //                                   child: Container(
      //                                     decoration: const BoxDecoration(
      //                                       color: Color.fromARGB(
      //                                           255, 236, 234, 234),
      //                                       borderRadius: BorderRadius.only(
      //                                         topRight: Radius.circular(5.0),
      //                                         bottomRight: Radius.circular(5.0),
      //                                       ),
      //                                     ),
      //                                     padding: const EdgeInsets.symmetric(
      //                                         horizontal: 15.0, vertical: 14.0),
      //                                     child: const Icon(
      //                                       Icons.add,
      //                                       size: 20,
      //                                       color: Colors.black,
      //                                     ),
      //                                   ),
      //                                 ),
      //                               ],
      //                             ),
      //                           ),
      //                           SizedBox(height: 13.0),
      //                           Obx(
      //                             () => Text(
      //                               '${tableController.splitNumber.value} payment${tableController.splitNumber.value > 1 ? 's' : ''} of ',
      //                               style: TextStyle(
      //                                   fontSize: 18.0,
      //                                   fontWeight: FontWeight.w400),
      //                             ),
      //                           ),
      //                           SizedBox(height: 10.0),
      //                           Obx(() => Text(
      //                               '₹ ${(tableController.totalAmount.value / tableController.splitNumber.value).toStringAsFixed(2)}',
      //                               style: TextStyle(
      //                                   fontSize: 25.0,
      //                                   fontWeight: FontWeight.w900))),
      //                           Container(
      //                             decoration: BoxDecoration(
      //                               color: CommonValue.textcolor,
      //                               borderRadius: BorderRadius.circular(5.0),
      //                             ),
      //                             width: MediaQuery.sizeOf(context).width,
      //                             margin: EdgeInsets.only(top: 22.0),
      //                             padding: EdgeInsets.symmetric(
      //                                 vertical: 10.0, horizontal: 20.0),
      //                             child: Center(
      //                               child: Text(
      //                                 'Print Bill',
      //                                 style: TextStyle(color: Colors.white),
      //                               ),
      //                             ),
      //                           )
      //                         ],
      //                       ),
      //                     ),
      //                   );
      //                 },
      //               )
      //             }
      //         });
      //   },
      //   child: Container(
      //       margin: EdgeInsets.symmetric(vertical: 10.0),
      //       width: 200.0,
      //       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
      //       decoration: BoxDecoration(
      //           color: CommonValue.phyloText,
      //           borderRadius: BorderRadius.circular(8)),
      //       child: Center(
      //           child: Text(
      //         'Equal Split',
      //         style: TextStyle(color: Colors.white),
      //       ))),
      // ),
    ];
  }
}
